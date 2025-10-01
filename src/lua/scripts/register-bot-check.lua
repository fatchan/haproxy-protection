package.path = package.path .. "./?.lua;/etc/haproxy/scripts/?.lua;/etc/haproxy/libs/?.lua"

local bot_check = require("bot-check")
local utils = require("utils")
local server_port_split_pattern = "([^:]+):(%d+)"
local backends_map = Map.new('/etc/haproxy/map/backends.map', Map._str)
local haproxy_cn = os.getenv("HAPROXY_CONTINENT") or "XX" -- should never be XX but avoid typing issue
local json = require("json")

function Get_server_info(txn, return_ip)
	local key = txn.sf:hdr("Host")
	local target_backend_cn = haproxy_cn
	local value = backends_map:lookup(key or "")

	if value ~= nil then
		local filtered_backends = {}
		local all_backends = {}
		-- decode value as JSON array of objects {h, cn, xp} (h=server name)
		local decoded = json.decode(value) --pcall?
		if type(decoded) ~= "table" then
			print(string.format("invalid backends.map JSON for key=%s value=%s", tostring(key), tostring(value)))
			return ""
		end

		for _, obj in ipairs(decoded) do
			if type(obj) == "table" and obj.h then
				local cport = tonumber(txn.sf:hdr("txn-cport")) or 0
				local backend_server_name = obj.h
				local xp_val = obj.xp
				local should_use_check = obj.c

				-- server always considered up if check not enabled
				local server_up = true
				if should_use_check then
					server_up = txn.f:srv_is_up('servers/' .. backend_server_name)
				end

				-- if client requested non-default port and this backend disables extra ports, skip adding it when return_ip mode
				local valid_server = (not (return_ip and cport ~= 80 and cport ~= 443 and xp_val == false))

				if valid_server and server_up then
					table.insert(all_backends, backend_server_name)
					if tostring(obj.cn or "") == target_backend_cn then
						table.insert(filtered_backends, backend_server_name)
					end
				end
				-- else xp disabled for extra ports; do not include this backend for IP-returning on extra port
			else
				print(string.format("invalid backend object in backends.map for key=%s value=%s", tostring(key), tostring(value)))
				return ""
			end
		end

		-- Randomly select from filtered backends if available
		local selected_backend
		if #filtered_backends > 0 then
			selected_backend = filtered_backends[math.random(#filtered_backends)]
		elseif #all_backends > 0 then
			-- If no filtered backends, randomly select from all backends
			selected_backend = all_backends[math.random(#all_backends)]
		end

		if selected_backend then
			if return_ip then
				-- todo: more ifs here?
				local s_ip, _ = core.proxies["servers"]["servers"][selected_backend]:get_addr():match(server_port_split_pattern)
				-- print(s_ip)
				return s_ip
			else
				-- print(selected_backend)
				return selected_backend
			end
		end
	end
	return 0 -- for -m bool for xp, see https://docs.haproxy.org/3.2/configuration.html#7.1.1 0 = false, anythign else = true
end

function Get_server_ip(txn)
	return Get_server_info(txn, true)
end

function Get_server_names(txn)
	return Get_server_info(txn, false)
end

core.register_fetches("get_server_names", Get_server_names)
core.register_fetches("get_server_ip", Get_server_ip)
core.register_service("bot-check", "http", bot_check.view)
core.register_action("captcha-check", { 'http-req', }, bot_check.check_captcha_status)
core.register_action("pow-check", { 'http-req', }, bot_check.check_pow_status)
core.register_action("decide-checks-necessary", { 'http-req', }, bot_check.decide_checks_necessary)
core.register_action("kill-tor-circuit", { 'http-req', }, bot_check.kill_tor_circuit)
core.register_action("set-lang-json", { 'http-req', }, bot_check.set_lang_json)
core.register_action("set-ip-var", { 'http-req', }, bot_check.set_ip_var, 3)
