# upload

openresty 简单上传服务

# openresty 配置

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
