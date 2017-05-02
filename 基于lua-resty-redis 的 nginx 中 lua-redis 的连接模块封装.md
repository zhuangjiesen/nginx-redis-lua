# 基于lua-resty-redis 的 nginx 中 lua-redis 的连接模块封装

### 入门：
https://github.com/zhuangjiesen/nginx-redis-lua




##### lua-resty-redis 模块 [lua-resty-redis](https://github.com/openresty/lua-resty-redis#status)
 
 

### 背景：
#### 看了文档发现模块调用 redis 时，每个连接都需要去调用连接和授权验证，操作完还需要 close 或者 放回连接池 ，就想起封装成新模块
```

  # you do not need the following line if you are using
    # the OpenResty bundle:
    lua_package_path "/path/to/lua-resty-redis/lib/?.lua;;";

    server {
        location /test {
            content_by_lua_block {
                local redis = require "resty.redis"
                local red = redis:new()

                red:set_timeout(1000) -- 1 sec

                -- or connect to a unix domain socket file listened
                -- by a redis server:
                --     local ok, err = red:connect("unix:/path/to/redis.sock")

                local ok, err = red:connect("127.0.0.1", 6379)
                if not ok then
                    ngx.say("failed to connect: ", err)
                    return
                end

                ok, err = red:set("dog", "an animal")
                if not ok then
                    ngx.say("failed to set dog: ", err)
                    return
                end

                ngx.say("set result: ", ok)

                local res, err = red:get("dog")
                if not res then
                    ngx.say("failed to get dog: ", err)
                    return
                end

                if res == ngx.null then
                    ngx.say("dog not found.")
                    return
                end

                ngx.say("dog: ", res)

                red:init_pipeline()
                red:set("cat", "Marry")
                red:set("horse", "Bob")
                red:get("cat")
                red:get("horse")
                local results, err = red:commit_pipeline()
                if not results then
                    ngx.say("failed to commit the pipelined requests: ", err)
                    return
                end

                for i, res in ipairs(results) do
                    if type(res) == "table" then
                        if res[1] == false then
                            ngx.say("failed to run command ", i, ": ", res[2])
                        else
                            -- process the table value
                        end
                    else
                        -- process the scalar value
                    end
                end

                -- put it into the connection pool of size 100,
                -- with 10 seconds max idle time
                local ok, err = red:set_keepalive(10000, 100)
                if not ok then
                    ngx.say("failed to set keepalive: ", err)
                    return
                end

                -- or just close the connection right away:
                -- local ok, err = red:close()
                -- if not ok then
                --     ngx.say("failed to close: ", err)
                --     return
                -- end
            }
        }
    }
```


#### lua-resty-redis 封装模块app_redis_client.lua
代码如下：

```

-- redis lua 模块封装
local redis_client = {};


-- ip 地址
local  url = "127.0.0.1";
-- 端口号
local  port = 6379;

-- 密码
local  psw = "redis";

-- 连接池参数
local pool_max_idle_time = 10000 --毫秒  
local pool_size = 100 --连接池大小   

--[[

--]]

-- 回调函数执行 ，封装获取连接 与 放回连接池操作
function  redis_client.get_red(callback)

  -- body
    local redis = require "resty.redis"
    local red = redis:new()
    red:set_timeout(1000) -- 1 sec
    local  success = true;

-- or connect to a unix domain socket file listened
-- by a redis server:
--     local ok, err = red:connect("unix:/path/to/redis.sock")

    local ok, err = red:connect( url , port );
    if not ok then
        success = false;
    end

    local res, err = red:auth( psw );
    if not res then
        success = false;
    end

    -- 回调函数
    if callback then 
        callback(success , red);
    else 

        return false;
    end


    --释放连接(连接池实现)  
    local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)  
    if not ok then  
        return false;   
    end  
    
    return true;
end

-- 创建客户端
function  redis_client.create_new()
    -- body
    local redis = require "resty.redis"
    local red = redis:new()
    red:set_timeout(1000) -- 1 sec


-- or connect to a unix domain socket file listened
-- by a redis server:
--     local ok, err = red:connect("unix:/path/to/redis.sock")

    local ok, err = red:connect("127.0.0.1", 6379 )
    if not ok then
        return false;
    end

    local res, err = red:auth("redis")
    if not res then
        return false;
    end

    return red;
end



return redis_client;

```


#### 代码调用模块：hello.lua

```


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



```


#### nginx 的 nginx.conf 中配置代码：

```


worker_processes  1;

error_log  /home/nginx-1.4.2/logs/error.log;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;


	# lua 模块路径 ，类似java 中的导入包
	lua_package_path "/home/lua-resty-redis/lib/?.lua;/mnt/hgfs/vm_shared_files/lua_develop/lua_files/?.lua;";

#lua 代码缓存，平时开发可以设置成 off 用于调试
	lua_code_cache on; 

	lua_shared_dict shared_data 512m;  
	init_by_lua '
		
	';
	
    sendfile        on;

    keepalive_timeout  65;


    server {
        listen       80;
        server_name  localhost;


		
		location = /hello.do {
      		default_type 'text/plain';
      		# hello.lua 代码 
		 	content_by_lua_file <lua代码的本机路径>/hello.lua;
       
		}
		
		
		# lua 连接
		location = /test-redis {
				default_type 'text/html';
               content_by_lua '
               
                local redis = require "resty.redis"
                local red = redis:new()

                red:set_timeout(1000) -- 1 sec

                -- or connect to a unix domain socket file listened
                -- by a redis server:
                --     local ok, err = red:connect("unix:/path/to/redis.sock")

                local ok, err = red:connect("127.0.0.1", 6379 )
                if not ok then
                    ngx.say("failed to connect: ", err)
                    return
                end
                
                local res, err = red:auth("redis")
    			if not res then
        			ngx.say("failed to authenticate: ", err)
        			return
    			end
                
                ok, err = red:set("dog", "an animal")
                if not ok then
                    ngx.say("failed to set dog: ", err)
                    return
                end

                ngx.say("set result: ", ok)

                local res, err = red:get("dog")
                if not res then
                    ngx.say("failed to get dog: ", err)
                    return
                end
                
                if res == ngx.null then
                    ngx.say("dog not found.")
                    return
                end

 
                local mcat = red:get("cat")
                local mhorse = red:get("horse")
                ngx.say("<br>")                
                ngx.say("<br> red dog: ", red:get("dog"))
                ngx.say("<br> cat: ", mcat)
                ngx.say("<br> horse: ", mhorse)

                ngx.say("<br>---------------")                


                ngx.say("dog: ", res)

                red:init_pipeline()
                red:set("cat", "Marry")
                red:set("horse", "Bob")
                
                
                local mcat = red:get("cat")
                local mhorse = red:get("horse")
                ngx.say("<br>")                
                ngx.say("<br> red dog: ", red:get("dog"))
                ngx.say("<br> cat: ", mcat)
                ngx.say("<br> horse: ", mhorse)

                local results, err = red:commit_pipeline()
                
                
                
               		local str = 333
                   ngx.say("Hello World " ,str)
               ngx.log(ngx.ERR, "err err err")
               ';
        }

        location / {

    			set $a $1;   
    			set $b $host; 
    			
    			set $jason 'zhuangjiesen';
        		# nginx 变量 与 lua 变量的通信(共享)
				# 在 lua 中 用 ngx.var 获取变量
				# local var = ngx.var;
				# local jason = var.jason;

        		set $myuri $uri;
        
        		default_type 'text/html'; 
        		# nginx 中的 if 判断
        		if ( $uri != 'hello' ){
         			
               		content_by_lua_file /mnt/hgfs/vm_shared_files/lua_develop/lua_files/$uri.lua;
       
        		}
        		
        		if ( $uri = '/hello.html' ){
        				access_by_lua '
        						
        					local uri_args = ngx.req.get_uri_args();
        					local name = uri_args["name"];
        					if name == "zhuangjiesen" then
        					
        						return ngx.exit(403);
        					else 
        						local shared_data = ngx.shared.shared_data  
  
								local globalStr = shared_data:get("globalStr")  
								local red = shared_data:get("red")  

								red:set("thums", "i kdsajhkjdash")
								
        						ngx.say(" name is not ... zhuangjiesen <br/> globalStr ： " ,globalStr  );

        					end
        					
           					ngx.say(" name : " , name);

        					ngx.say("hello,xxxxxxx lua")
        				
        				';

        				root   /home/nginx-1.4.2/html;
        			}
        			
        		 
        	}


        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/local/nginx/html;
        }

    }



}


```


#### 启动nginx
##### 测试 http://127.0.0.1/hello.do lua-redis自定义封装模块结果

