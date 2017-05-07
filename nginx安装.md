# nginx 安装


#### 下载最新nginx 包


```

wget -c http://nginx.org/download/nginx-1.11.2.tar.gz
tar -xzvf nginx-1.11.2.tar.gz
cd nginx-1.11.2/
./configure xxxxxx(你要的模块)
make
make install


```


```
这条语句需要同一行执行，不能有换行符,配置各种Nginx模块，比如tcp 负载均衡，lua 模块 ，ssl 模块 等


./configure 
--add-module=../ngx_devel_kit-0.2.18/ 
--add-module=../lua-nginx-module-0.9.3/ 
--with-http_ssl_module --with-openssl=../openssl-1.1.0e 
--with-http_v2_module 
--with-http_stub_status_module 
--with-http_realip_module --with-stream 
--with-stream_ssl_module 

```


