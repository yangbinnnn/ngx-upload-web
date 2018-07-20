-- yangbin
-- 2018年06月14日

local upload = require "resty.upload"
local cjson = require "cjson"


local chunk_size = 4096
local home = "/path/to/public"


local form, err = upload:new(chunk_size)
if not form then
    ngx.log(ngx.ERR, "failed to new upload: ", err)
    ngx.exit(500)
end

form:set_timeout(1000) -- 1 sec

local function getsubdir(uri)
    return uri:gsub("^/_upload", "")
end

local function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

local function strip(s)
	char = "%s"
	return string.match(s, "^" .. char .. "*(.-)" .. char .. "*$") or s
end

local function startswith(line, s)
    return line:find("^" .. s) ~= nil
end

local function getfilename(line)
    items = split(line, ";")
    for i, item in ipairs(items) do
        item = strip(item)
        if startswith(item, "filename") then
            name = split(item, "=")
            return name[2]:sub(2, -2)
        end
    end
    return ""
end

local filename = ""
local subdir = getsubdir(ngx.var.uri)
local file

while true do
    local typ, res, err = form:read()
    if not typ then
        ngx.say("failed to read: ", err)
        ngx.exit(500)
    end        
    if typ == "header" then
        if res[1] == "Content-Disposition" then
            filename = getfilename(res[2])
            if filename == "" then
                ngx.say("filename not found")
                ngx.exit(400)
            end
            
            local path = home .. subdir .. "/" .. filename
            file = assert(io.open(path, "w+"))
            if not file then
                ngx.say("open " .. path .. " failed")
                ngx.exit(500)
            end
        end
    elseif typ == "body" then
        if file then
            file:write(res)
        end
    elseif typ == "part_end" then
        if file then
            file:close()
            file = nil
        end
    elseif typ == "eof" then
        break
    end
end

ngx.header.content_type = "text/html"
ngx.say("<p>upload success</p>")
