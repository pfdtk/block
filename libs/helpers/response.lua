--
-- User: jiang
-- Date: 2017/8/28
-- Time: 13:51
--

local cjson = require "cjson"

local _M = { _VERSION = '0.01' };

function _M.success(message, data)
    ngx.header.content_type = "application/json; charset=utf-8";
    ngx.say(cjson.encode({ status = true, message = message, data = data }));
    return ngx.exit(ngx.HTTP_OK);
end

function _M.error(message)
    ngx.header.content_type = "application/json; charset=utf-8";
    ngx.say(cjson.encode({ status = false, message = message }));
    return ngx.exit(ngx.HTTP_OK);
end

return _M;