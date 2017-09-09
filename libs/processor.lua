--
-- User: jiang
-- Date: 2017/8/28
-- Time: 13:07
--

local response = require "libs.helpers.response";
local config_type = require "libs.config.type";
local action = require "libs.config.action";

local _M = { _VERSION = '0.01' };
local mt = { __index = _M };

-- init processor
function _M:new(storage)
    return setmetatable({ storage = storage }, mt);
end

-- block list manager
function _M:manger()
    ngx.req.read_body();
    local get_args = ngx.req.get_uri_args();
    if (not get_args['type']) or (not config_type[get_args['type']]) or (not get_args['action']) or (not action[get_args['action']]) then
        return response.error('Invalid request.');
    end
    local get_type = get_args['type'];
    local get_action = get_args['action'];
    local processor = self:get_proccessor(get_type);
    -- @todo try to call function by string
    if get_action == 'add' then
        return processor:add();
    elseif get_action == 'remove' then
        return processor:remove();
    elseif get_action == 'flush' then
        return processor:flush();
    elseif get_action == 'update' then
        return processor:update();
    elseif get_action == 'list' then
        return processor:list();
    end
    return response.error('Invalid request.');
end

-- block handler
function _M:block()
    local processor;
    for type, _ in pairs(config_type) do
        processor = self:get_proccessor(type);
        processor:block();
    end
end

-- init proccessor
function _M:get_proccessor(type)
    local processor = require("libs.processors.processor_" .. type);
    return processor:new(self.storage);
end

return _M;