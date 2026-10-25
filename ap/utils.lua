local utils = {}

-- (Mostly a stripped down version of bbp's loader)
function utils.getModsPath(id)
	if not id then return false end

	local modsPath = "Mods"
	local success = love.filesystem.getInfo(modsPath, 'directory')

	if not success then return false end

	for _, modDir in ipairs(love.filesystem.getDirectoryItems(modsPath)) do
		if not love.filesystem.getInfo(modsPath .. "/" .. modDir .. "/mod.json", 'file') then
			goto continue
		end

		local mod = {
			path = modsPath .. "/" .. modDir,
			id = modDir
		}

		if not love.filesystem.getInfo(mod.path, 'directory') then
			goto continue
		end

		local modData = dpf.loadJson(mod.path .. "/mod.json")
		mod.id = modData.id or mod.id

		if mod.id == id then
			log("Found mod \"" .. id .. "\" at \"" .. mod.path .. "\"", 'AP-Block')
			return love.filesystem.getSaveDirectory() .. "/Mods/" .. mod.id
		end

		::continue::
	end
	return false
end

function utils.addPathDll(path, ext)
	if not ext then
		ext = { "dll" }
	end

	log("Adding dlls from \"" .. path .. "\"" , 'AP-Block')
	love.filesystem.setCRequirePath(path..'??')
	for i,v in ipairs(ext) do
		package.cpath = string.format("%s;%s/?.%s", package.cpath, path, v)
	end
end

function utils.tableHas(table, value)
	if not table or not value then
		return false
	end

	local result = false
	for _, v in ipairs(table) do
		if v == value then
			result = true
			break
		end
	end
	return result
end

return utils
