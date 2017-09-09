--
-- User: jiang
-- Date: 2017/8/30
-- Time: 17:28
--


local _M = { _VERSION = '0.01' };

-- return current url
function _M.get_request_url()
    local scheme = ngx.var.scheme or '';
    local host = ngx.var.host or '';
    local port = ngx.var.server_port;
    local uri = ngx.var.uri or '';
    local is_args = ngx.var.is_args or '';
    local args = ngx.var.args or '';
    local port_str = '';
    if uri == '/' then
        uri = '';
    end
    if port ~= 80 then
        port_str = ':' .. port;
    end
    return scheme .. '://' .. host .. port_str .. uri .. is_args .. args;
end

return _M;