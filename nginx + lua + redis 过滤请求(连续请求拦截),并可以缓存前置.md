# nginx + lua + redis 过滤请求(连续请求拦截),并可以缓存前置

### 准备
##### 拦截次数 access_times = 5
##### 访问间隔 access_pirod = 1 秒，连续访问超过 5 次 ，拦截请求


##### noAccess.html 拦截页面


##### uri : /getCacheData.do 获取缓存的测试请求


#### Lua 代码 ： access_control.lua 
```
-- nginx 变量
local ngx_var = ngx.var;
--请求
local uri = ngx_var.uri;
-- 服务端ip
local host = ngx_var.host;
-- 客户端ip 
local remote_addr = ngx_var.remote_addr;

-- 限制ip 访问次数 超过5次跳转到 noAccess.html 页面
local access_times = 5;
-- 访问间隔
local access_pirod = 1;


if uri == '/noAccess.html' then

else

	local  redis_module = require "app_redis_client";
	redis_module.get_red(
		-- 回调函数 将获取连接池连接，放回连接池操作封装起来
		function (success , red) 

			local nginx_key = "nginx_redis_access_ip:" .. remote_addr;


			-- ip 递增
			local ok, err = red:incr(nginx_key);

			if ok then
			  	ok, err = red:expire(nginx_key , access_pirod);
  
			end
			local times, err = red:get( nginx_key );
			-- ip 登陆次数
			if times  then
				times = times + 0;
				if (times < access_times) then

					--   不作处理 或者 返回缓存数据
					if uri == '/getCacheData.do' then
						ngx.say("<h1> 从redis获取缓存数据 </h1>", "<br/>");
						ngx.say("<h3> key : lua_redis_cache_data  </h3>", "<br/>");

						-- 查询缓存
						local value , err = red:get("lua_redis_cache_data" );


						-- redis 的 get 方法返回值 null 的判断
						-- 判空
						-- value 类型 userdata 
						if value and (value ~= ngx.null) then 

							-- 查询到缓存可以直接返回
							ngx.say("<h3> 查到缓存  value : ", value);
							ngx.say(" </h3>");

							ngx.exit(200);
						else
							-- 查不到缓存可以，直接继续落入后台 服务器 
							ngx.say("<h3> 查不到缓存...走后台查询 </h3>", "<br/>");
							ngx.exit(200);

						end
						
					end


				else

					-- 超过访问次数限制
					return ngx.redirect("/noAccess.html", 302)  
				end
			   
			end

		

		end

	);
 
end



```


####  nginx 配置文件 nginx.conf
代码如下：


```

worker_processes  1;

error_log  /home/nginx-1.4.2/logs/error.log;

events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

	# lua 库 多个用分号 ; 隔开
    lua_package_path "/home/lua-resty-redis/lib/?.lua;/mnt/hgfs/vm_shared_files/lua_develop/lua_files/?.lua;";

	lua_code_cache on; 

	# lua 共享内存
	lua_shared_dict shared_data 512m; 
	# 初始化 
	init_by_lua '
		
	';
	
    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;


    server {
        listen       80;
        server_name  localhost;

        location / {

			default_type 'text/html'; 
			charset utf-8;  
			
			access_by_lua_file /mnt/hgfs/vm_shared_files/lua_develop/lua_files/access_control.lua;

			# access_by_lua_file 过滤并没有进行处理 即 没有调用ngx.exit(); 
			# 会继续执行跳转 
			# 这里也可以改成反向代理 proxy-pass 
			root   /home/nginx-1.4.2/html;
			index index.html;

        }

        
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/local/nginx/html;
        }

    }
    
}





```


