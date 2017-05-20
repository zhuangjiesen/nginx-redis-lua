# nginx 的 Lua  模块安装

### 开涛的博客上 nginx版本 1.4.2 版本太老
### 这个 nginx 版本 1.11.2
### LuaJIT

```

是一个利用JIT编译技术把Lua脚本直接编译成机器码由CPU运行

版本：2.0 与 2.1

当前稳定版本为 2.0。
2.1为版本与ngx_lua将有较大性能提升，主要是CloudFlare公司对luajit的捐赠。

FFI库，是LuaJIT中最重要的一个扩展库。
1. 它允许从纯Lua代码调用外部C函数，使用C数据结构;
2. 就不用再像Lua标准math库一样，编写Lua扩展库;
3. 把开发者从开发Lua扩展C库（语言/功能绑定库）的繁重工作中释放出来;

```

#### 下载编译
```

wget -c http://luajit.org/download/LuaJIT-2.0.2.tar.gz
tar xzvf LuaJIT-2.0.2.tar.gz
cd LuaJIT-2.0.2
make install PREFIX=/usr/local/luajit
echo "/usr/local/luajit/lib" > /etc/ld.so.conf.d/usr_local_luajit_lib.conf
ldconfig
#注意环境变量!
export LUAJIT_LIB=/usr/local/luajit/lib
export LUAJIT_INC=/usr/local/luajit/include/luajit-2.0

```

### NDK与Lua_module
之前用Nginx1.4版本，版本太老

[官网，可以查最新版](https://github.com/openresty/lua-nginx-module)

[](https://github.com/openresty/lua-nginx-module#data-sharing-within-an-nginx-worker)

```

wget -c https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz
wget -c https://github.com/chaoslawful/lua-nginx-module/archive/v0.10.8.tar.gz
tar xzvf v0.3.0.tar.gz
tar xzvf v0.10.8.tar.gz

```

#### 编译安装Nginx
nginx 1.11.2 版本

```

wget -c http://nginx.org/download/nginx-1.11.2.tar.gz
tar -xzvf nginx-1.11.2.tar.gz
cd nginx-1.11.2/
./configure --add-module=/home/nginx/ngx_devel_kit-0.3.0/ --add-module=/home/nginx/lua-nginx-module-0.10.8/ 

make
make install

```

#### 编译完带有 lua 模块的 nginx 
目录：
##### /home/nginx-1.11.2/objs 


### 检验

```

自己编译官方的 nginx 源码包，只需事前指定 LUAJIT_INC 和 LUAJIT_LIB 这两个环境变量。

验证你的 LuaJIT 是否生效，可以通过下面这个接口： 

location = /lua-version { 
	content_by_lua ' 
        	if jit then 
                	ngx.say(jit.version) 
            	else 
                	ngx.say(_VERSION) 
        	end 
        '; 
} 



如果使用的是标准 Lua，访问 /lua-version 应当返回响应体 Lua 5.1
如果是 LuaJIT 则应当返回类似 LuaJIT 2.0.2 这样的输出。 
不要使用标准lua，应当使用luajit, 后者的效率比前者高多了。

也可以直接用 ldd 命令验证是否链了 libluajit-5.1 这样的 .so 文件，例如： 
[root@limq5 sbin]# ldd  nginx | grep lua
	libluajit-5.1.so.2 => /usr/local/luajit/lib/libluajit-5.1.so.2 (0x00007f48e408b000)
[root@limq5 sbin]#

```

测试 lua 安装成功


