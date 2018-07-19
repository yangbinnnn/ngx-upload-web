# ngx-upload-web

openresty 简单上传服务

# openresty(nginx) 配置
`/path/to/public/` 目录代指openresty(或nginx) 的公共静态文件目录, 如果使用nginx 需要安装[lua-nginx-module](https://github.com/openresty/lua-nginx-module)

- nginx.conf
```
server {
    listen       80;
    location / {
        autoindex on;
        alias /path/to/public/;
    }

    location ~ ^/_upload {
        client_max_body_size 4000m;
        content_by_lua_file /path/to/upload.lua;
    }
}
```
- upload.lua 配置数据保存目录
```
local home = "/path/to/public"
```

- upload.html 上传页面需要放到`/path/to/public` 目录, `dirs` 配置上传的子目录，需要提前创建
```
data: {
    dirs: [
        '/',
        '/tmp'
    ],
    ......
},
```

# 预览
![upload](./upload.png)