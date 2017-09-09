--
-- User: jiang
-- Date: 2017/8/28
-- Time: 13:07
--

local cjson = require "cjson"
local table = table;

local _M = { _VERSION = '0.01' };
local mt = { __index = _M };

function _M:new()
    return setmetatable({}, mt);
end

function _M:get(key)
    local result;
    local access_dict = ngx.shared.hjj_access;
    local data = access_dict:get(key);
    if data then
        result = cjson.decode(data);
    end
    return result;
end

function _M:add(key, value)
    local _insert = {};
    local _get = self:get(key);
    if _get then
        _insert = _get
    end
    table.insert(_insert, value)
    local access_dict = ngx.shared.hjj_access;
    return access_dict:set(key, cjson.encode(_insert));
end

function _M:list(key)
    cjson.encode_empty_table_as_object(false);
    return self:get(key);
end

function _M:remove(key)
    local access_dict = ngx.shared.hjj_access;
    return access_dict:delete(key);
end

function _M:update(key, value)
    local access_dict = ngx.shared.hjj_access;
    return access_dict:set(key, cjson.encode(value));
end

function _M:flush()
    local access_dict = ngx.shared.hjj_access;
    return access_dict:flush_all();
end

return _M;