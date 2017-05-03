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
