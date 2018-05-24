
local lfs=require("lfs")
local wjson=require("wetgenes.json")

local findfiles;findfiles=function(dir,filter,ret)
	ret=ret or {}
	
	local subdirs={}
	if lfs.attributes(dir) then -- only if dir exists
		for fname in lfs.dir(dir) do
			local a=lfs.attributes(dir.."/"..fname)
			if a.mode=="file" then
				if string.find(fname,filter) then
					ret[#ret+1]=dir.."/"..fname
				end
			end
			if a.mode=="directory" then
				if fname:sub(1,1)~="." then
					subdirs[#subdirs+1]=fname
				end
			end
		end
	end
	
-- recurse
	for i,v in ipairs(subdirs) do
		findfiles(dir.."/"..v,filter,ret)
	end

	return ret
end


for _,filename in ipairs( findfiles("./plated/source/blog","^%^%.html") ) do

	local fp=assert(io.open(filename,"r"))
	local str=fp:read("*all")
	fp:close()
	
	print(filename)
	
	local attachments={}
	for ogg in str:gmatch("\"([^\"]*%.ogg)\"") do
		if not ogg:find("/embed/") then
			print("",ogg)
			
			attachments[#attachments+1]={
				url=ogg,mime_type="audio/ogg",
			}
		end
	end
	
	str=str:gsub("^(#%^_blog_post_json%s*{)",function(s)
		return s.."\nfeed:{\nattachments:"..wjson.encode(attachments).."\n},\n"
	end)

	if false then
		print(str)
	else
		local fp=assert(io.open(filename,"w"))
		fp:write(str)
		fp:close()
	end
end
