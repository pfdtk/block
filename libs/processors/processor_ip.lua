--
-- User: jiang
-- Date: 2017/8/28
-- Time: 13:07
--

local response = require "libs.helpers.response";
local type_ip = require "libs.types.ip";
local log = require "libs.helpers.log";

local _M = { _VERSION = '0.01' };
local mt = { __index = _M };

-- init
function _M:new(storage)
    return setmetatable({ storage = storage }, mt);
end

-- block handler
function _M:block()
    local client_ip = "" .. ngx.var.remote_addr;
    local storage = self:get_storage();
    local block_ips = storage:get(type_ip.storage_key);
    if not block_ips or type(block_ips) ~= 'table' then
        return true;
    end
    for _, block_ip in pairs(block_ips) do
        -- @todo check ip format
        if type(block_ip) == 'string' and block_ip == client_ip then
            log.push(ngx.ALERT, 'IP mode block:' .. block_ip);
            return ngx.exit(ngx.HTTP_FORBIDDEN);
        end
    end
end

-- add block rule
function _M:add()
    local post_args = ngx.req.get_post_args();
    local storage = self:get_storage();
    -- @todo check ip format
    local block_ip = self:resolve_args_ip(post_args);
    local res = storage:add(type_ip.storage_key, block_ip);
    if not res then
        return response.error('add fails.');
    end
    return response.success('add success.');
end

-- remove block rule
function _M:remove()
    local storage = self:get_storage();
    local post_args = ngx.req.get_post_args();
    local remove_ip = self:resolve_args_ip(post_args);
    local block_ips = storage:get(type_ip.storage_key);
    if type(block_ips) ~= 'table' then
        return response.error('Not found:' .. remove_ip);
    end
    local found = false;
    for index, ip in pairs(block_ips) do
        if remove_ip == ip then
            table.remove(block_ips, index);
            found = true;
            break;
        end
    end
    if not found then
        return response.error('Not found:' .. remove_ip);
    end
    storage:update(type_ip.storage_key, block_ips);
    return response.success('remove:' .. remove_ip);
end

-- flush block rule
function _M:flush()
    local storage = self:get_storage();
    storage:remove(type_ip.storage_key);
    return response.success('flush all.');
end

-- flush block rule
function _M.update()
    return response.error('Not support.');
end

-- list data
function _M:list()
    local storage = self:get_storage();
    local result = {};
    local list = storage:list(type_ip.storage_key);
    if list then result = list end
    return response.success('success', result);
end

-- ensure args
function _M:resolve_args_ip(args)
    local result;
    for key, _ in pairs(type_ip.need_args) do
        if not args[key] then
            return response.error(key .. " required.");
        end
        result = args[key];
        break;
    end
    return result;
end

-- get storage
function _M:get_storage()
    local storage = require("libs.storages." .. self.storage);
    return storage.new();
end

return _M;