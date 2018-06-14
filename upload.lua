local upload = require "resty.upload"
local cjson = require "cjson"

local chunk_size = 4096
local home = "/tmp/upload"

local form, err = upload:new(chunk_size)
if not form then
    ngx.log(ngx.ERR, "failed to new upload: ", err)
    ngx.exit(500)
end

form:set_timeout(1000) -- 1 sec

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
local file

while true do
    local typ, res, err = form:read()
    if not typ then
        ngx.say("failed to read: ", err)
        return
    end        
    if typ == "header" then
        if res[1] == "Content-Disposition" then
            filename = getfilename(res[2])
            if filename == "" then
                ngx.say("filename not found")
            end
            
            local path = home .. "/" .. filename
            file = io.open(path, "w+")
            if not file then
                ngx.say("open " .. path .. " failed")
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