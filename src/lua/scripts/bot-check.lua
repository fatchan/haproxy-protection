_M = {}

-- Testing only
-- require("socket")
-- require("print_r")

-- main libs
local url = require("url")
local utils = require("utils")
local cookie = require("cookie")
local json = require("json")
local randbytes = require("randbytes")
local templates = require("templates")

-- load locales
local locales_path = "/etc/haproxy/locales/"
local locales_table = {}
local locales_strings = {}
for file_name in io.popen('ls "' .. locales_path .. '"*.json'):lines() do
	local file_name_with_path = utils.split(file_name, "/")
	local file_name_without_ext = utils.split(file_name_with_path[#file_name_with_path], ".")[1]
	local file = io.open(file_name, "r")
	local json_contents = file:read("*all")
	local json_object = json.decode(json_contents)
	file:close()
	locales_table[file_name_without_ext] = json_object
	locales_strings[file_name_without_ext] = json.encode(json_object)
end

-- POW
local sha = require("sha")
local argon2 = require("argon2")
local argon_time = tonumber(os.getenv("ARGON_TIME") or 1)
local argon_kb = tonumber(os.getenv("ARGON_KB") or 6000)
argon2.parallelism(1)
argon2.hash_len(32)
argon2.variant(argon2.variants.argon2_id)
argon2.t_cost(argon_time)
argon2.m_cost(argon_kb)

-- captcha variables
local captcha_secret = os.getenv("HCAPTCHA_SECRET") or os.getenv("RECAPTCHA_SECRET")
local captcha_cookie_secret = os.getenv("CAPTCHA_COOKIE_SECRET")
local pow_cookie_secret = os.getenv("POW_COOKIE_SECRET")
local hmac_cookie_secret = os.getenv("HMAC_COOKIE_SECRET")
local ray_id = os.getenv("RAY_ID")

-- load captcha map and set hcaptcha/recaptch based off env vars
local captcha_provider_domain = ""
local captcha_siteverify_path = ""
if os.getenv("HCAPTCHA_SITEKEY") then
	captcha_provider_domain = "hcaptcha.com"
	captcha_siteverify_path = "/siteverify"
else
	captcha_provider_domain = "www.google.com"
	captcha_siteverify_path = "/recaptcha/api/siteverify"
end

-- kill a tor circuit
function _M.kill_tor_circuit(txn)
	local ip = txn.sf:src()
	if ip:sub(1, 19) ~= "fc00:dead:beef:4dad" then
		return -- not a tor circuit id/ip. we shouldn't get here, but just in case.
	end
	-- split the IP, take the last 2 sections
	local split_ip = utils.split(ip, ":")
	local aa_bb = split_ip[5] or "0000"
	local cc_dd = split_ip[6] or "0000"
	aa_bb = string.rep("0", 4 - #aa_bb) .. aa_bb
	cc_dd = string.rep("0", 4 - #cc_dd) .. cc_dd
	-- convert the last 2 sections to a number from hex, which makes the circuit ID
	local circuit_identifier = tonumber(aa_bb .. cc_dd, 16)
	print('Closing Tor circuit ID: ' .. circuit_identifier .. ', "IP": ' .. ip)
	utils.send_tor_control_port(circuit_identifier)
end

-- read first language from accept-language in applet (note: does not consider q values)
local default_lang = "en-US"
local function get_first_language(context, is_applet)
	local accept_language = utils.get_header_from_context(context, "accept-language", is_applet)
	if #accept_language > 0 and #accept_language < 100 then -- length limit preventing abuse
		for lang in accept_language:gmatch("[^,%s]+") do
			if not lang:find(";") then
				return lang
			end
		end
	end
end

-- ddos and sus maps
local bfp_map = Map.new("/etc/haproxy/map/bfp.map", Map._str);
local vpn_map = Map.new("/etc/haproxy/map/vpn.map", Map._str);
local dc_map = Map.new("/etc/haproxy/map/dc.map", Map._str);
local ddos_map = Map.new("/etc/haproxy/map/ddos.map", Map._str);
local ddos_config_map = Map.new("/etc/haproxy/map/ddos_config.map", Map._str)
local ddos_default_config = {
	["pt"] = os.getenv("POW_TYPE") or "argon2",
	["pd"] = tonumber(os.getenv("POW_DIFFICULTY") or 18),
	["cip"] = (os.getenv("CHALLENGE_INCLUDES_IP") ~= nil and true or false),
	["cex"] = tonumber(os.getenv("CHALLENGE_EXPIRY")),
}
local function get_ddos_config(context, is_applet)
	local host = utils.get_header_from_context(context, "host", is_applet)
	local ddos_config = ddos_config_map:lookup(host)
	if ddos_config ~= nil then
		ddos_config = json.decode(ddos_config)
	else
		ddos_config = ddos_default_config
	end
	return ddos_config
end

local ProtectionMode = {
    NONE = 0,
    POW_SUS_ONLY = 1,
    CAPTCHA_SUS_ONLY = 2,
    POW_ALL = 3,
    POW_ALL_CAPTCHA_SUS_ONLY = 4,
    CAPTCHA_ALL = 5
}

local function check_sus(fp, ip, asn, country_code)
    local is_bfp = bfp_map:lookup(fp) ~= nil
    local is_vpn = vpn_map:lookup(asn) ~= nil
    local is_dc = dc_map:lookup(asn) ~= nil
    local is_t1 = country_code == "T1"
    return is_bfp, is_vpn, is_dc, is_t1
end

local function is_request_sus(level, fp, ip, asn, country_code)
    local req_sus = false
    local sus_level = 0
    local is_bfp, is_vpn, is_dc, is_t1 = check_sus(fp, ip, asn, country_code)
	-- todo bitfield
    if level == 1 and is_t1 then
        req_sus = true
        sus_level = 1
    elseif level == 2 and (is_t1 or is_bfp) then
        req_sus = true
        sus_level = 2
    elseif level == 3 and (is_t1 or is_vpn or is_bfp) then
        req_sus = true
        sus_level = 3
    elseif level == 4 and (is_t1 or is_vpn or is_bfp or is_dc) then
        req_sus = true
        sus_level = 4
    end
    return req_sus, sus_level
end

local function determine_validation_settings(ddos_map_json, fp, ip, asn, country_code)
	local mode = ddos_map_json.m
	local validate_pow = false
	local validate_captcha = false
	local req_sus, sus_level = is_request_sus(ddos_map_json.l, fp, ip, asn, country_code)

	if mode == ProtectionMode.NONE then
		return false, false, req_sus, sus_level
	end

	if mode == ProtectionMode.POW_SUS_ONLY and req_sus then
		validate_pow = true
	elseif mode == ProtectionMode.CAPTCHA_SUS_ONLY and req_sus then
		validate_pow = true
		validate_captcha = true
	elseif mode == ProtectionMode.POW_ALL then
		validate_pow = true
	elseif mode == ProtectionMode.POW_ALL_CAPTCHA_SUS_ONLY and req_sus then
		validate_pow = true
		validate_captcha = req_sus
	elseif mode == ProtectionMode.CAPTCHA_ALL then
		validate_captcha = true
		validate_pow = true
	end

	return validate_pow, validate_captcha, req_sus, sus_level
end

local function secondsToDate(seconds)
	local formattedDate = os.date("!%a, %d-%b-%y %H:%M:%S GMT", seconds)
	return formattedDate
end

function _M.decide_checks_necessary(txn)
	local host = txn.sf:hdr("Host")
	local path = txn.sf:path()
	local ddos_map_lookup = ddos_map:lookup(host .. path) or ddos_map:lookup(host)
	if ddos_map_lookup ~= nil then
		local ddos_map_json = json.decode(ddos_map_lookup)
		local ip = txn.sf:src()
		local fp = txn:get_var("txn.fp_custom") or ""
		local asn = txn:get_var("req.asn") or ""
		local country_code = txn.sf:hdr("X-Country-Code") or ""
		local validate_pow, validate_captcha, _, sus_level = determine_validation_settings(ddos_map_json, fp, ip, asn, country_code)
		txn:set_var("txn.validate_pow", validate_pow)
		txn:set_var("txn.validate_captcha", validate_captcha)
		if sus_level then
			txn.http:req_set_header("X-Sus-Level", sus_level)
		end
	end
end

local css_map = Map.new("/etc/haproxy/map/css.map", Map._str);
function _M.view(applet)
	-- host header
	local host = applet.headers['host'][0]

	-- set the ll and ls language var based off header or default to en-US
	local lang = get_first_language(applet, true)
	local ll = locales_table[lang]
	if ll == nil then
		ll = locales_table[default_lang]
		lang = default_lang
	end
	local ls = locales_strings[lang]

	-- get any custom css
	local css_val = css_map:lookup(host) or ""

	-- set response body and declare status code
	local response_body = ""
	local response_status_code

	-- get the config from ddos_config.map
	local ddos_config = get_ddos_config(applet, true)

	-- if request is GET, serve the challenge page
	if applet.method == "GET" then
		-- get the user_key#challenge#sig
		local user_key = sha.bin_to_hex(randbytes(16))
		local challenge_hash, expiry = utils.generate_challenge(applet, pow_cookie_secret, user_key, ddos_config, true)
		local signature = sha.hmac(sha.sha3_256, hmac_cookie_secret, user_key .. challenge_hash .. expiry)
		local combined_challenge = user_key .. "#" .. challenge_hash .. "#" .. expiry .. "#" .. signature

		-- define body sections
		local captcha_body = ""
		local pow_body = ""
		local noscript_extra_body = ""

		-- check if captcha is enabled, path+domain priority, then just domain, and 0 otherwise
		local captcha_enabled = false
		local path = url.getpath(applet.qs); --because on /.basedflare/bot-check?/whatever, .qs (query string) holds the old path
		local ddos_map_lookup = ddos_map:lookup(host .. path) or ddos_map:lookup(host)
		if ddos_map_lookup ~= nil then
			local ddos_map_json = json.decode(ddos_map_lookup)
			local ip = applet.sf:src()		
			local fp = applet:get_var("txn.fp_custom") or ""
			local asn = applet:get_var("req.asn") or ""
			local country_code = applet:get_var("req.xcc") or ""
			local _, validate_captcha, _ = determine_validation_settings(ddos_map_json, fp, ip, asn, country_code)
			captcha_enabled = validate_captcha
		end

		-- return simple json if they send accept: application/json header
		local accept_header = applet.headers['accept']
		if accept_header ~= nil and accept_header[0] == 'application/json' then
			local local_pow_combined = string.format('%s#%d#%s#%s', ddos_config["pt"], math.ceil(ddos_config["pd"] / 8),
				argon_time, argon_kb)
			response_body = "{\"ch\":\"" ..
				combined_challenge ..
				"\",\"ca\":" .. (captcha_enabled and "true" or "false") .. ",\"pow\":\"" .. local_pow_combined .. "\"}"
			applet:set_status(403)
			applet:add_header("content-type", "application/json; charset=utf-8")
			applet:add_header("content-length", string.len(response_body))
			applet:start_response()
			applet:send(response_body)
			return
		end

		-- pow at least is always enabled when reaching bot-check page
		if captcha_enabled then
			captcha_body = string.format(
				templates.captcha_section,
				ll["Please solve the captcha to continue."]
			)
		else
			pow_body = string.format(
				templates.pow_section,
				ll["This process is automatic, please wait a moment..."]
			)
			if ddos_config["js"] ~= false then
				local noscript_extra
				local noscript_prompt
				if ddos_config["pt"] == "argon2" then
					noscript_extra = templates.noscript_extra_argon2
					noscript_prompt = ll
						["Run this in a linux terminal (requires <code>argon2</code> package installed):"]
				else
					noscript_extra = templates.noscript_extra_sha256
					noscript_prompt = ll["Run this in a linux terminal (requires <code>perl</code>):"]
				end
				noscript_extra_body = string.format(
					noscript_extra,
					ll["No JavaScript?"],
					noscript_prompt,
					user_key,
					challenge_hash,
					expiry,
					signature,
					math.ceil(ddos_config["pd"] / 8),
					argon_time,
					argon_kb,
					ll["Paste the script output into the box and submit:"]
				)
			end
		end

		-- local extra_challenge = [[
		-- 	<script src="/.basedflare/js/bc.js"></script>
		-- 	<script src="/.basedflare/js/bm.min.js"></script>
		-- ]]
		local extra_challenge = ""

		-- sub in the body sections
		response_body = string.format(
			templates.body,
			lang,
			ls,
			ll["Hold on..."],
			css_val,
			extra_challenge,
			combined_challenge,
			ddos_config["pd"],
			argon_time,
			argon_kb,
			ddos_config["pt"],
			string.format(ll["Verifying your connection to %s"], host),
			pow_body,
			captcha_body,
			ll["JavaScript is required on this page."],
			noscript_extra_body,
			ray_id,
			ll["Performance & security by BasedFlare"]
		)
		response_status_code = 403

		-- if request is POST, check the answer to the pow/cookie
	elseif applet.method == "POST" then
		-- if they fail, set a var for use in ACLs later
		local valid_submission = false
		local number_expiry = nil

		-- parsed POST body
		local parsed_body = url.parseQuery(applet.receive(applet))

		-- whether to set cookies sent as secure or not
		local secure_cookie_flag = " Secure=true;"
		if applet.sf:ssl_fc() == "0" then
			secure_cookie_flag = ""
		end

		-- handle setting the POW cookie
		local user_pow_response = parsed_body["pow_response"]
		local matched_expiry = 0 -- ensure captcha cookie expiry matches POW cookie
		if user_pow_response then
			-- split the response up (makes the nojs submission easier because it can be a single field)
			local split_response = utils.split(user_pow_response, "#")

			if #split_response == 5 then
				local given_user_key = split_response[1]
				local given_challenge_hash = split_response[2]
				local given_expiry = split_response[3]
				local given_signature = split_response[4]
				local given_answer = split_response[5]

				-- expiry check
				number_expiry = tonumber(given_expiry, 10)
				if number_expiry ~= nil and number_expiry > core.now()['sec'] then
					-- regenerate the challenge and compare it
					local generated_challenge_hash = utils.generate_challenge(applet, pow_cookie_secret, given_user_key,
						ddos_config, true)

					if given_challenge_hash == generated_challenge_hash then
						-- regenerate the signature and compare it
						local generated_signature = sha.hmac(sha.sha3_256, hmac_cookie_secret,
							given_user_key .. given_challenge_hash .. given_expiry)

						if given_signature == generated_signature then
							-- do the work with their given answer
							local hex_hash_output = ""
							if ddos_config["pt"] == "argon2" then
								local encoded_argon_hash = argon2.hash_encoded(given_challenge_hash .. given_answer,
									given_user_key)
								local trimmed_argon_hash = utils.split(encoded_argon_hash, '$')[6]:sub(0, 43) -- https://github.com/thibaultcha/lua-argon2/issues/37
								hex_hash_output = sha.bin_to_hex(sha.base64_to_bin(trimmed_argon_hash));
							else
								hex_hash_output = sha.sha256(given_user_key .. given_challenge_hash .. given_answer)
							end

							if utils.checkdiff(hex_hash_output, ddos_config["pd"]) then
								-- the answer was good, give them a cookie
								local signature = sha.hmac(sha.sha3_256, hmac_cookie_secret,
									given_user_key .. given_challenge_hash .. given_expiry .. given_answer)
								local combined_cookie = given_user_key ..
									"#" ..
									given_challenge_hash ..
									"#" .. given_expiry .. "#" .. given_answer .. "#" .. signature
								local expiry_date_p = secondsToDate(number_expiry)
								applet:add_header(
									"set-cookie",
									string.format(
									--"_basedflare_pow=%s; Expires=%s; Path=/; Domain=.%s; SameSite=None; HttpOnly;%s",
										"_basedflare_pow=%s; Expires=%s; Path=/; Domain=%s; SameSite=None; %s",
										combined_cookie,
										expiry_date_p,
										applet.headers['host'][0],
										secure_cookie_flag
									)
								)
								valid_submission = true
								matched_expiry = number_expiry
							end
						end
					end
				end
			end
		end

		-- handle setting the captcha cookie
		local user_captcha_response = parsed_body["h-captcha-response"] or parsed_body["g-recaptcha-response"]

		if valid_submission and user_captcha_response then -- only check captcha if POW is already correct
			-- format the url for verifying the captcha response
			local captcha_url = string.format(
				"https://%s%s",
				captcha_provider_domain,
				captcha_siteverify_path
			)

			-- construct the captcha body to send to the captcha url
			local captcha_body = url.buildQuery({
				secret = captcha_secret,
				response = user_captcha_response
			})

			-- instantiate an http client and make the request
			local httpclient = core.httpclient()
			local res = httpclient:post {
				url = captcha_url,
				body = captcha_body,
				headers = {
					["host"] = { captcha_provider_domain },
					["content-type"] = { "application/x-www-form-urlencoded" },
					["user-agent"] = { "haproxy-protection (haproxy-protection/0.1; +https://gitgud.io/fatchan/haproxy-protection)" }
				}
			}

			-- try parsing the response as json
			local status, api_response = pcall(json.decode, res.body)
			if not status then
				api_response = {}
			end

			-- the response was good i.e the captcha provider says they passed, give them a cookie
			if api_response.success == true then
				local user_key = sha.bin_to_hex(randbytes(16))
				local user_hash = utils.generate_challenge(applet, captcha_cookie_secret, user_key, ddos_config, true)
				local signature = sha.hmac(sha.sha3_256, hmac_cookie_secret, user_key .. user_hash .. matched_expiry)
				local combined_cookie = user_key .. "#" .. user_hash .. "#" .. matched_expiry .. "#" .. signature
				local expiry_date_c = secondsToDate(number_expiry)
				applet:add_header(
					"set-cookie",
					string.format(
						"_basedflare_captcha=%s; Expires=%s; Path=/; Domain=%s; SameSite=None; HttpOnly;%s",
						combined_cookie,
						expiry_date_c,
						applet.headers['host'][0],
						secure_cookie_flag
					)
				)
				valid_submission = valid_submission and true
			end
		end

		if not valid_submission then
			_M.kill_tor_circuit(applet)
		end

		-- redirect them to their desired page in applet.qs (query string)
		-- if they didn't get the appropriate cookies they will be sent back to the challenge page
		response_status_code = 302
		applet:add_header("location", applet.qs)

		-- else if its another http method, just 403 them
	else
		response_status_code = 403
	end

	-- finish sending the response
	applet:set_status(response_status_code)
	applet:add_header("content-type", "text/html; charset=utf-8")
	applet:add_header("content-length", string.len(response_body))
	applet:start_response()
	applet:send(response_body)
end

-- set a variable if ip or subnet in blocked/whitelist map and list of usernames matches the one for the current domain
local blockedip_map = Map.new("/etc/haproxy/map/blockedip.map", Map._ip);
local blockedasn_map = Map.new("/etc/haproxy/map/blockedasn.map", Map._str);
local blockedcc_map = Map.new("/etc/haproxy/map/blockedcc.map", Map._str);
local blockedcn_map = Map.new("/etc/haproxy/map/blockedcn.map", Map._str);
local whitelist_map = Map.new("/etc/haproxy/map/whitelist.map", Map._ip);
local accounts_map = Map.new("/etc/haproxy/map/domtoacc.map", Map._str);
local maps_tbl = {
	["blockedip"] = blockedip_map,
	["blockedasn"] = blockedasn_map,
	["blockedcc"] = blockedcc_map,
	["blockedcn"] = blockedcn_map,
	["whitelist"] = whitelist_map,
}
local lookupvar_tbl = {
	["ip"] = function(_txn)
		return _txn.sf:src()
	end,
	["asn"] = function(_txn)
		return _txn:get_var("req.asn")
	end,
	["cc"] = function(_txn)
		return _txn:get_var("req.xcc")
	end,
	["cn"] = function(_txn)
		return _txn:get_var("txn.xcn")
	end,
}

-- set lang json in var for use with json_query sf for using translations in template files without a lua view
function _M.set_lang_json(txn)
	local lang = get_first_language(txn, false)
	local ls = locales_strings[lang]
	if ls == nil then
		ls = locales_strings[default_lang]
	end
	txn:set_var("txn.lang_json", ls)
end

function _M.set_ip_var(txn, map_name, set_variable, lookup_var)
	-- get the host header and user ip
	local host = txn.sf:hdr("Host")
	-- choose lookup key
	local lookup_key = lookupvar_tbl[lookup_var](txn)
	-- if none return
	if lookup_key == nil or host == nil then
		return
	end
	-- get the name of current domain user, and the list
	-- of names that have blocked this ip (in case multiple)
	local names_list = maps_tbl[map_name]:lookup(lookup_key)
	local current_name = accounts_map:lookup(string.lower(host))
	if names_list == nil or current_name == nil then
		return
	end
	-- loop through them and set the blocked var if found
	local split_names = utils.split(names_list, ":")
	for _, name in ipairs(split_names) do
		if name == current_name or (map_name == "whitelist" and name == "admin") then
			txn:set_var(set_variable, true)
			return
		end
	end
end

-- check if captcha cookie is valid, separate secret from POW
function _M.check_captcha_status(txn)
	local parsed_request_cookies = cookie.get_cookie_table(txn.sf:hdr("Cookie"))
	local received_captcha_cookie = parsed_request_cookies["_basedflare_captcha"] or ""

	-- split the cookie up
	local split_cookie = utils.split(received_captcha_cookie, "#")
	if #split_cookie ~= 4 then
		return
	end
	local given_user_key = split_cookie[1]
	local given_user_hash = split_cookie[2]
	local given_expiry = split_cookie[3]
	local given_signature = split_cookie[4]

	-- expiry check
	local number_expiry = tonumber(given_expiry, 10)
	if number_expiry == nil or number_expiry <= core.now()['sec'] then
		return
	end
	-- regenerate the user hash and compare it
	local ddos_config = get_ddos_config(txn, false)
	local generated_user_hash = utils.generate_challenge(txn, captcha_cookie_secret, given_user_key, ddos_config, false)
	if generated_user_hash ~= given_user_hash then
		return
	end
	-- regenerate the signature and compare it
	local generated_signature = sha.hmac(sha.sha3_256, hmac_cookie_secret,
		given_user_key .. given_user_hash .. given_expiry)
	if given_signature == generated_signature then
		return txn:set_var("txn.captcha_passed", true)
	end

end

-- check if pow cookie is valid
function _M.check_pow_status(txn)
	local parsed_request_cookies = cookie.get_cookie_table(txn.sf:hdr("Cookie"))
	local received_pow_cookie = parsed_request_cookies["_basedflare_pow"] or ""

	-- split the cookie up
	local split_cookie = utils.split(received_pow_cookie, "#")
	if #split_cookie ~= 5 then
		return
	end
	local given_user_key = split_cookie[1]
	local given_challenge_hash = split_cookie[2]
	local given_expiry = split_cookie[3]
	local given_answer = split_cookie[4]
	local given_signature = split_cookie[5]

	-- expiry check
	local number_expiry = tonumber(given_expiry, 10)
	if number_expiry == nil or number_expiry <= core.now()['sec'] then
		return
	end
	-- regenerate the challenge and compare it
	local ddos_config = get_ddos_config(txn, false)
	local generated_challenge_hash = utils.generate_challenge(txn, pow_cookie_secret, given_user_key, ddos_config, false)
	if given_challenge_hash ~= generated_challenge_hash then
		return
	end
	-- regenerate the signature and compare it
	local generated_signature = sha.hmac(sha.sha3_256, hmac_cookie_secret,
		given_user_key .. given_challenge_hash .. given_expiry .. given_answer)
	if given_signature == generated_signature then
		return txn:set_var("txn.pow_passed", true)
	end

end

return _M
