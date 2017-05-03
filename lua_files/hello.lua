
--[[
加载自定义 lua 模块
--]]
local  redis_module = require "app_redis_client";
redis_module.get_red(
	-- 回调函数 将获取连接池连接，放回连接池操作封装起来
	function (success , red) 


		local ok, err = red:set("hello_callback", "new redis")
		if not ok then
		    ngx.say("failed to set dog: ", err)
		    return
		end

		local new_redis = red:get("hello_callback");
		ngx.say("hello_callback : ", new_redis)

	end

);



ngx.say("<h1>hello i am hello.do </h1>" , "<br/>")  
