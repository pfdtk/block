--
-- User: jiang
-- Date: 2017/8/30
-- Time: 17:28
--


local _M = { _VERSION = '0.01' };

function _M.push(level, message)
    local get_args = ngx.req.get_uri_args();
    if get_args['__show_log'] and get_args['__show_log'] == '3b53d26b0bf39dd119a66cef26e940a9' then
        ngx.log(level, message);
    end
end

return _M;