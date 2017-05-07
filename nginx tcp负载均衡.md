# nginx tcp负载均衡
#### 用途：可以做rpc服务集群的负载均衡器，比如thrfit服务

#### nginx从1.9.0后引入模块ngx_stream_core_module，模块是没有编译的，需要用到编译需添加--with-stream配置参数，stream负载均衡官方配置样例



### nginx 配置文件

代码如下:

```



worker_processes  1;

#error_log  /home/nginx-1.11.2/logs/error.log;


events {
    worker_connections  1024;
}


#tcp 负载均衡
stream{
	upstream thrift{
		server 172.16.236.1:22222 weight=1;
	}
        
    # 监听 33333 代理到 thrift 服务上
	server{
		listen 33333;
		proxy_pass thrift;
	}

}

http {
    include       mime.types;
    default_type  application/octet-stream;

	
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
			
		 
			root   /home/nginx-1.11.2/html;
			index index.html;
	

        }

        
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/local/nginx/html;
        }

    }



}


```


