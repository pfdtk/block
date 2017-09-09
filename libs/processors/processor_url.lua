--
-- User: jiang
-- Date: 2017/8/30
-- Time: 13:07
--

local response = require "libs.helpers.response";
local type_url = require "libs.types.url";
local util_url = require "libs.helpers.url";
local log = require "libs.helpers.log";

local _M = { _VERSION = '0.01' };
local mt = { __index = _M };

-- init
function _M:new(storage)
    return setmetatable({ storage = storage }, mt);
end

-- block handler
function _M:block()
    self:check_mode_eq();
    self:check_mode_regular();
end

-- check url mode regular
function _M:check_mode_regular()
    local url = util_url.get_request_url();
    local storage = self:get_storage();
    local block_urls = storage:get(type_url.storage_key);
    if not block_urls or type(block_urls) ~= 'table' then
        return true;
    end
    for _, block_url in pairs(block_urls) do
        if type(block_url) ~= 'table' then
            return true;
        end
        if block_url.mode ~= nil and block_url.data ~= nil and block_url.mode == 'regular' then
            local m, _ = ngx.re.match(url, block_url.data, 'isjo')
            if m then
                log.push(ngx.ALERT, 'REGULAR mode block:' .. block_url.data);
                return ngx.exit(ngx.HTTP_FORBIDDEN);
            end
        end
    end
end

-- check url by mode eq
function _M:check_mode_eq()
    local url = util_url.get_request_url();
    local storage = self:get_storage();
    local block_urls = storage:get(type_url.storage_key);
    if not block_urls or type(block_urls) ~= 'table' then
        return true;
    end
    for _, block_url in pairs(block_urls) do
        if type(block_url) ~= 'table' then
            return true;
        end
        if block_url.mode ~= nil and block_url.data ~= nil and block_url.mode == 'eq' then
            if url == block_url.data then
                log.push(ngx.ALERT, 'EQ mode block:' .. block_url.data);
                return ngx.exit(ngx.HTTP_FORBIDDEN);
            end
        end
    end
    return true;
end

-- add block rule
function _M:add()
    local post_args = ngx.req.get_post_args();
    local storage = self:get_storage();
    local url_items = self:resolve_args(post_args);
    url_items.id = type_url.id;
    self:check_mode(url_items.mode);
    local res = storage:add(type_url.storage_key, url_items);
    if not res then
        return response.error('add fails.');
    end
    return response.success('add success.');
end

-- remove block rule
function _M:remove()
    local storage = self:get_storage();
    local post_args = ngx.req.get_post_args();
    if not post_args.id then
        return response.error('Id required.');
    end
    local block_urls = storage:get(type_url.storage_key);
    if type(block_urls) ~= 'table' then
        return response.error('Not found:' .. post_args.id);
    end
    local found = false;
    for index, url in pairs(block_urls) do
        if post_args.id == url.id then
            table.remove(block_urls, index);
            found = true;
            break;
        end
    end
    if not found then
        return response.error('Not found:' .. post_args.id);
    end
    storage:update(type_url.storage_key, block_urls);
    return response.success('remove:' .. post_args.id);
end

-- flush block rule
function _M:flush()
    local storage = self:get_storage();
    storage:remove(type_url.storage_key);
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
    local list = storage:list(type_url.storage_key);
    if list then result = list end
    return response.success('success', result);
end

-- check mode
function _M:check_mode(_mode)
    local block_modes = type_url.mode;
    if not block_modes[_mode] then
        return response.error('Invalid mode.');
    end
end

-- ensure args
function _M:resolve_args(args)
    local result = {};
    for key, _ in pairs(type_url.need_args) do
        if not args[key] then
            return response.error(key .. " required.");
        end
        result[key] = args[key];
    end
    return result;
end

-- get storage
function _M:get_storage()
    local storage = require("libs.storages." .. self.storage);
    return storage.new();
end

return _M;