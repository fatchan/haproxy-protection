package.path = package.path .. "./?.lua;/etc/haproxy/scripts/?.lua;/etc/haproxy/libs/?.lua"

local bot_check = require("bot-check")
local utils = require("utils")
local server_cn_split_regex = "([^;]+)|(%u%u)$"
local backends_map = Map.new('/etc/haproxy/map/backends.map', Map._str)

function get_server_names(txn)
    local key = txn.sf:hdr("Host")
    local user_cn = txn:get_var("txn.xcn") or "XX"
    print(user_cn)
    local value = backends_map:lookup(key or "")
    if value ~= nil then
        local filtered_backends = {}
        local all_backends = {}
        local vals = utils.split(value, ",")
        -- Single pass to filter and collect backends
        for _, backend in ipairs(vals) do
            local backend_server_name, server_cn = backend:match(server_cn_split_regex)
            if backend_server_name then
                table.insert(all_backends, backend_server_name)
                if server_cn == user_cn or server_cn == "XX" then
                    table.insert(filtered_backends, backend_server_name)
                end
            end
        end
        -- Randomly select from filtered backends if available
        if #filtered_backends > 0 then
            local s = filtered_backends[math.random(#filtered_backends)]
            print(s)
            return s
        elseif #all_backends > 0 then
            -- If no filtered backends, randomly select from all backends
            local s = all_backends[math.random(#all_backends)]
            print(s)
            return s
        end
    end
    return ""
end

core.register_fetches("get_server_names", get_server_names)
core.register_service("bot-check", "http", bot_check.view)
core.register_action("captcha-check", { 'http-req', }, bot_check.check_captcha_status)
core.register_action("pow-check", { 'http-req', }, bot_check.check_pow_status)
core.register_action("decide-checks-necessary", { 'http-req', }, bot_check.decide_checks_necessary)
core.register_action("kill-tor-circuit", { 'http-req', }, bot_check.kill_tor_circuit)
core.register_action("set-lang-json", { 'http-req', }, bot_check.set_lang_json)
core.register_action("set-ip-var", { 'http-req', }, bot_check.set_ip_var, 3)
