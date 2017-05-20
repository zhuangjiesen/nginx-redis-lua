# nginx docker 镜像


#### 为了方便 nginx 配置模块与安装
### nginx 版本：

#### 带有 lua 模块(已经安装好)的  nginx.1.11.2
#### 与 nginx.1.12.0

[docker镜像地址_百度云](https://pan.baidu.com/s/1eRPqfcu)

##### 如果不行可以加我qq 234778286


##### 镜像下载完是 tar文件

[docker基本操作](https://github.com/zhuangjiesen/reading-learning-coding/blob/master/docker/docker%20操作.md)

##### docker  导出 images 命令: 



```
先查看 images 运行状态:
docker ps 
导出:
docker export <imageid> > <image_file>

例子:
docker export 5c106ce7677a > nginx_docker.tar

```
##### docker  导入 images.tar 命令: 

```
导入:
docker import <image_file> <REPOSITORY_Name>:<TAG>

例子:
docker import nginx_docker.tar  centos_docker_nginx_1:centos_docker_nginx_1_tag

```

##### docker 运行容器

```
启动：
docker run -it --volumes-from dataVol new_repository:newTAG /bin/bash
例子：
docker run -it --volumes-from dataVol -p 8080:8080 centos_docker_nginx:centos_docker_nginx_tag /bin/bash
```
命令中的 dataVol 是共享数据卷，用来与宿主机共享文件的一个docker容器，可以使 docker容器可以与宿主机进行文件传输
具体可以搜：**docker 与宿主共享文件夹**

    
-p 8080:8080 宿主机的8080端口映射 docker容器的8080 端口


##### 进入容器后

```
docker nginx目录：
/home/nginx/nginx-1.11.2

软件目录都在：
/home/nginx

```

