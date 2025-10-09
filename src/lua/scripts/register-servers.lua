package.path = package.path .. "./?.lua;/etc/haproxy/scripts/?.lua;/etc/haproxy/libs/?.lua"

local json = require("json")
local pow_difficulty = tonumber(os.getenv("POW_DIFFICULTY") or 18)
local backends_map = Map.new('/etc/haproxy/map/backends.map', Map._str)
local utils = require("utils")
local map_space_split_rexex = "([^%s]+)%s+([^%s]+)"
local check_options = " check observe layer4 inter 120s"

-- setup initial server backends based on hosts.map (JSON values required)
local function setup_servers()
	if pow_difficulty < 8 then
		error("POW_DIFFICULTY must be > 8. Around 16-32 is better")
	end
	local backend_name = os.getenv("BACKEND_NAME")
	local server_prefix = os.getenv("SERVER_PREFIX")
	if backend_name == nil or server_prefix == nil then
		return;
	end
	local handle = io.open("/etc/haproxy/map/hosts.map", "r")
	local line = handle:read("*line")
	local verify_backend_ssl = os.getenv("VERIFY_BACKEND_SSL")
	local verify_none = os.getenv("VERIFY_BACKEND_SSL_VERIFYNONE")
	local counter = 1
	-- NOTE: using tcp socket to interact with runtime API because lua can't add servers
	local tcp = core.tcp();
	tcp:settimeout(10);
	tcp:connect("127.0.0.1", 2000);
	tcp:send("prompt i;\n")

	while line do
		local domain, backend_data = line:match(map_space_split_rexex)
		-- backend JSON like {"h":"host:port","cn":"CN","xp":true/false,"c":true/false}
		local backend_host, continent_code, check_string

		-- parse JSON value (direct json.decode as requested)
		local obj = json.decode(backend_data) --pcall?
		if type(obj) == "table" then
			backend_host = tostring(obj.h)
			continent_code = tostring(obj.cn or "")
			check_string = obj.c and check_options or ""

			local websrv = "websrv" .. counter
			local server_name = "servers/" .. websrv
			local new_server_entry = { h = websrv, cn = continent_code or "", xp = obj.xp, c = obj.c }
			local existing_map_value = backends_map:lookup(domain)
			local entries = {}
			if existing_map_value ~= nil then
				local decoded = json.decode(existing_map_value) -- assume valid JSON array?
				if type(decoded) == "table" then
					for _, v in ipairs(decoded) do table.insert(entries, v) end
				end
			end
			table.insert(entries, new_server_entry) -- append new entry
			local new_map_value = json.encode(entries)
			print("setting hosts.map " .. domain .. " " .. new_map_value)
			core.set_map("/etc/haproxy/map/backends.map", domain, new_map_value)


			--NOTE: if you have a proper CA setup,
			if verify_backend_ssl ~= nil then
				if verify_none ~= nil then -- for development use only
					tcp:send(string.format(
						"add server %s %s ssl verify none ca-file ca-certificates.crt sni req.hdr(Host)%s;",
						server_name, backend_host, check_string))
				else
					tcp:send(string.format(
						"add server %s %s ssl verify required ca-file ca-certificates.crt sni req.hdr(Host)%s;",
						server_name, backend_host, check_string))
				end
			else
				tcp:send(string.format("add server %s %s%s;", server_name, backend_host, check_string))
			end
			tcp:send(string.format("enable server %s;", server_name))
			tcp:send(string.format("enable health %s;\n", server_name)) -- NOTE: newline to send commands
		end

		line = handle:read("*line")
		counter = counter + 1
	end
	handle:close()
	tcp:close()
end

core.register_task(setup_servers)
