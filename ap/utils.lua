local utils = {}

-- [[ EDITED DPF ]]
dpf = {}

local mod_id = "unset"

love.filesystem.createDirectory("savedata/Mods/")
love.filesystem.createDirectory("savedata/Mods/" .. mod_id .. "/")

function dpf.setModId(modid)
	mod_id = modid
	love.filesystem.createDirectory("savedata/Mods/" .. mod_id .. "/")
end

function dpf.exists(f)
	return love.filesystem.getInfo(f) ~= nil
end

function dpf.checkForBlank(s)
	if s == nil or s == "" or s == "null" then
		error("Tried to write a blank file!!!! this should never happen!!!!!!!!!")
	end
	return s
end

function dpf.loadJson(inputed_f, w)
	local f = "savedata/Mods/" .. mod_id .. "/" .. inputed_f
	log("loading " .. f, "ap_dpf")
	local cf = love.filesystem.read(f)
	if cf == nil then
		if not w then
			error("Could not load file " .. f)
		end
		love.filesystem.createDirectory(helpers.rliid(f))
		--log("trying to write a file cause it didnt exist", 'dpf')
		cf = json.encode(w)

		--log(love.filesystem.write(f,dpf.checkForBlank(cf)), 'dpf')
	end
	return json.decode(cf)
end

function dpf.loadText(inputed_f, w)
	local f = "savedata/Mods/" .. mod_id .. "/" .. inputed_f
	log("loading " .. f, "ap_dpf")
	local cf = love.filesystem.read(f)
	if cf == nil then
		if not w then
			error("Could not load file " .. f)
		end
		love.filesystem.createDirectory(helpers.rliid(f))
		--log("trying to write a file cause it didnt exist", 'dpf')
		cf = w

		--log(love.filesystem.write(f,dpf.checkForBlank(cf)), 'dpf')
	end
	return cf
end

function dpf.saveJson(inputed_f, w, tablesort)
	local f = "savedata/Mods/" .. mod_id .. "/" .. inputed_f
	local newdir = helpers.rliid(f)
	if newdir ~= "" then
		love.filesystem.createDirectory(helpers.rliid(f))
	end
	local success1, msg = love.filesystem.write(f .. ".tmp", dpf.checkForBlank(json.encode(w, tablesort)))
	if success1 then
		local success2, msg = love.filesystem.write(f, dpf.checkForBlank(json.encode(w, tablesort)))
		if success2 then
			log("Saved: " .. f, "ap_dpf")
			-- wow! incredible success!
			love.filesystem.remove(f .. ".tmp")
		else
			error(
				"Saving to "
					.. f
					.. " failed!\n"
					.. "A temp file was able to be made at "
					.. f
					.. ".tmp.\n"
					.. "A common cause for this is a full drive. Make sure you have enough free space!\n"
					.. "Message: "
					.. tostring(msg)
			)
		end
	else
		error(
			"Saving to "
				.. f
				.. " failed!\n"
				.. "The data in the file was not updated.\n"
				.. "A common cause for this is a full drive. Make sure you have enough free space!\n"
				.. "Message: "
				.. tostring(msg)
		)
	end
end

function dpf.saveText(inputed_f, w, tablesort)
	local f = "savedata/Mods/" .. mod_id .. "/" .. inputed_f
	local newdir = helpers.rliid(f)
	if newdir ~= "" then
		love.filesystem.createDirectory(helpers.rliid(f))
	end
	local success1, msg = love.filesystem.write(f .. ".tmp", dpf.checkForBlank(w))
	if success1 then
		local success2, msg = love.filesystem.write(f, dpf.checkForBlank(w))
		if success2 then
			-- wow! incredible success!
			love.filesystem.remove(f .. ".tmp")
		else
			error(
				"Saving to "
					.. f
					.. " failed!\n"
					.. "A temp file was able to be made at "
					.. f
					.. ".tmp.\n"
					.. "A common cause for this is a full drive. Make sure you have enough free space!\n"
					.. "Message: "
					.. tostring(msg)
			)
		end
	else
		error(
			"Saving to "
				.. f
				.. " failed!\n"
				.. "The data in the file was not updated.\n"
				.. "A common cause for this is a full drive. Make sure you have enough free space!\n"
				.. "Message: "
				.. tostring(msg)
		)
	end
end

--[[
function dpf.patchLoveFilesystem()
	--returns true if a file is in savedata, not source code. If the file exists in neither, returns true. If the file exists in both, returns false.
	function love.filesystem.inSaveData(filename)
		local realdir = love.filesystem.getRealDirectory(filename)
		return realdir == nil or realdir == love.filesystem.getSaveDirectory()
	end
	
	--set whether or not saving in source code should be forced
	function love.filesystem.forceSaveInSource(doForce)
		love.filesystem.saveInSource = doForce
	end
	
	if not love.filesystem.isFused() then
		log('RUNNING UNFUSED. PATCHING FILESYSTEM!!!','warning')
		local oldWrite = love.filesystem.write
		local oldCreateDirectory = love.filesystem.createDirectory
		
		function love.filesystem.write(name, data, size)
			local isTmpFile = string.sub(name,-4) == ".tmp" -- tmp files should never exist, so we need to check where the main file is first
			local saveInSource = love.filesystem.saveInSource or (not love.filesystem.inSaveData(isTmpFile and string.sub(name,1,-5) or name))
			saveInSource = saveInSource and (not love.filesystem.isFused()) --if fused, force to no
			if saveInSource then
				if helpers.rliid(name) ~= '' then
					love.filesystem.createDirectory(helpers.rliid(name), true)
				end
				local file, err = io.open(love.filesystem.getSource() ..'/'..name,'w')
				if file ~= nil and err == nil then
					file:write(dpf.checkForBlank(data))
					file:close()
					return true, nil
				end
				return false, err
			else
				return oldWrite(name, dpf.checkForBlank(data), size)
			end
		end
		
		function love.filesystem.createDirectory(name, force)
			if love.filesystem.getInfo(name, 'directory') then
				return false
			end
			if force or (love.filesystem.saveInSource and (not love.filesystem.isFused())) then
				local handle = io.popen('mkdir "' .. love.filesystem.getSource() ..'/'.. name ..'"')
				handle:close()
			else
				return oldCreateDirectory(name)
			end
		end
	else
		log('NOT patching filesystem!!!')
	end
	

end
--]]

utils.dpf = dpf

return utils
