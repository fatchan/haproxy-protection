package.path = package.path .. "./?.lua;/etc/haproxy/scripts/?.lua;/etc/haproxy/libs/?.lua"

local pow_difficulty = tonumber(os.getenv("POW_DIFFICULTY") or 18)
local backends_map = Map.new('/etc/haproxy/map/backends.map', Map._str)
local utils = require("utils")
local server_cn_split_regex = "([^;]+)|(%u%u)$"
local map_space_split_rexex = "([^%s]+)%s+([^%s]+)"

-- setup initial server backends based on hosts.map
function setup_servers()
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
		local backend_host, continent_code = backend_data:match(server_cn_split_regex)
		local new_map_value = server_prefix .. counter .. '|' .. continent_code
		local existing_map_value = backends_map:lookup(domain)
		if existing_map_value ~= nil then
			local current_backends = utils.split(existing_map_value, ",")
			if not utils.contains(current_backends, new_map_value) then
				new_map_value = new_map_value .. "," .. existing_map_value
			end
		end
		print("setting hosts.map " .. domain .. " " .. new_map_value)
		core.set_map("/etc/haproxy/map/backends.map", domain, new_map_value)
		local server_name = "servers/websrv" .. counter

		--NOTE: if you have a proper CA setup,
		if verify_backend_ssl ~= nil then
			if verify_none ~= nil then -- for development use only
				tcp:send(string.format(
					"add server %s %s ssl verify none ca-file ca-certificates.crt sni req.hdr(Host);",
					server_name, backend_host))
			else
				tcp:send(string.format(
					"add server %s %s ssl verify required ca-file ca-certificates.crt sni req.hdr(Host);",
					server_name, backend_host))
			end
		else
			tcp:send(string.format("add server %s %s;", server_name, backend_host))
		end
		tcp:send(string.format("enable server %s;", server_name))
		tcp:send(string.format("enable health %s;\n", server_name)) -- NOTE: newline to send commands

		line = handle:read("*line")
		counter = counter + 1
	end
	handle:close()
	tcp:close()
end

core.register_task(setup_servers)
