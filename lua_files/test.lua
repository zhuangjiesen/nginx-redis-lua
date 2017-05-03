local var = ngx.var;

local jason = var.jason;

local myuri = var.myuri;
ngx.say("app uri : ", myuri , "<br/>")  


ngx.say("jason", jason , "<br/>")  

 v = ngx.req.http_version();

 m = ngx.req.get_method();


local uri_args = ngx.req.get_uri_args()  
for k, v in pairs(uri_args) do  
    if type(v) == "table" then  
        ngx.say(k, " : ", table.concat(v, ", "), "<br/>")  
    else  
        ngx.say(k, ": ", v, "<br/>")  
    end  
end  
ngx.say("uri args end", "<br/>")  

ngx.say(' VESION : ' .. v);
ngx.say(' method : ' .. m);


ngx.say("======================================", "<br/>")  

local  m1 = require "module_test";

ngx.say("get name : ", m1.get_name() , "<br/>")  


