--
-- User: jiang
-- Date: 2017/8/30
-- Time: 11:44
--

local str = require "resty.string";
local resty_md5 = require "resty.md5";
local md5 = resty_md5:new();
local url_items = {};

url_items.need_args = { data = 1, mode = 2 };
url_items.storage_key = 'waf:url:';
url_items.mode = { regular = 1, eq = 2 };
if ngx.var.request_id ~= nil then
    url_items.id = ngx.var.request_id;
else
    local _str = ngx.var.uri .. ngx.var.request_body .. math.random(1, 999999999);
    md5:update(_str);
    local digest = md5:final();
    url_items.id = str.to_hex(digest);
end

return url_items;