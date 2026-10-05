local apclientpp = require("lua-apclientpp")

local ap = {}

ap.gui = require("ap.gui")
ap.utils = require("ap.utils")

ap.client = nil
ap.connected = false

-- Because im lazy
local got_all_levels = false
ap.levels = {}

function ap.toast(title, msg)
	local m = msg

	if type(msg) == "table" then
		m = ""
		for _, v in ipairs(msg) do
			m = m .. v .. "\n"
		end
	end

	-- print("AP TOAST: " .. title .. " | " .. m)

	UnlockManager.queueToast({
		title = title,
		description = m,
	})
end

-- Notes:
--   10 is filler
--   11 is fishing rod
function ap.addItem(id)
	local itemName = ap.data.items[tostring(id)]

	-- The stupid edge cases
	if itemName == "Era Chimaera" then
		itemName = "Era Chimæra"
	elseif itemName == "publico cautivo" then
		itemName = "público cautivo"
	elseif itemName == "C-me B-me" then
		itemName = "C-ミ B-ミ"
	end

	-- print("Received: " .. itemName)
	if id == 10 then
		return
	end

	if id == 11 then
		ap.data.allowFishing = true
		return
	end

	table.insert(ap.data.received,id)
	--ap.data.received:insert(id or "Fuck")

	if id >= 1000 then
		
	else
		-- if ap.levels[itemName] then
		-- 	print("Adding level to playable: " .. itemName)
		-- else
		-- 	print("Adding unknown: ".. itemName)
		-- end

		table.insert(ap.data.playable, ap.levels[itemName])
	end
end

-- Need this to convert ap IDs to level names to level paths
function ap.get_all_levels_OLD()
	if not got_all_levels then
		print("Getting all levels")
		-- love.filesystem.getDirectoryItems('levels/')
		ap.level = love.filesystem.getDirectoryItems("levels/Finished levels/")

		for k, v in pairs(ap.level) do
			-- Get metadata
			local metadata = dpf.loadJson("levels/Finished levels/" .. tostring(v) .. "/manifest.json")
			local songName = metadata.metadata.songName

			-- The stupid æ
			if songName == "Era Chimæra" then
				songName = "Era Chimaera"
			end

			print("Path: " .. "levels/Finished levels/" .. tostring(v) .. " | " .. songName)
			ap.levels[songName] = {
				name = songName,
				id = v,
				path = "levels/Finished levels/" .. tostring(v),
				variants = metadata.variants,
			}
		end

		-- TODO: Unhardcode this... im too lazy
		ap.levels["gone fishin'"] = {
			name = "gone fishin'",
			path = "levels/Other/fishing",
			variants = {
				charter = 'Samario as "SIZE 2 FISHERMAN"',
				difficulty = 9,
				display = "loc@difficultyTangent",
				hidden = false,
				levelFile = "level-Tangent.json",
				name = "Tangent",
				slot = 0,
			},
		}

		-- ap.utils.dpf.saveJson("ap_levels.json", ap.levels, function(a, b)
		-- 	return a < b
		-- end)

		got_all_levels = true
	else
		print("Already got all levels")
	end
end

function set_level_data(atomID, levelPath)
	local path = levelPath .. '/'
	local levelMetadata = LevelManager:loadMetadata(path)
	local songName = levelMetadata.metadata.songName

	-- print("AtomID: " .. atomID .. " | Path: " .. path .. " | Level: " .. songName)

	ap.levels[songName] = {
		atom = atomID,
		name = songName,
		id = levelPath,
		path = "levels/" .. levelPath,
		variants = levelMetadata.variants,
	}
end

function get_atom_data(atomData)
	local atomID = (atomData.icon or "Base"):gsub('images/',"")

	if atomData.nucleus then
		set_level_data(atomID, "levels/" .. atomData.nucleus.level)
	end
	if atomData.rings then
		for i, ring in ipairs(atomData.rings) do
			for j, level in ipairs(ring.objects) do
				if level.type == "Level" then
					set_level_data(atomID, "levels/" .. level.level)
				end
			end
		end
	end
end

-- Levels from AtomMap.json
function ap.get_all_levels()
	if not got_all_levels_atom then
		print("Getting all levels")
		local atomMap = dpf.loadJson("levels/AtomMap.json")
		atomMap = atomMap.root

		-- root AKA Intro atom
		get_atom_data(atomMap.nucleus)

		for i, ring in ipairs(atomMap.rings) do
			for j, atom in ipairs(ring.objects) do
				get_atom_data(atom)
			end
		end
		
	else
		print("Already got all levels")
	end
end

--[[
    Notes:
        Official levels:
            Level: levels/Finished levels/selfportrait/
            Grade: 93.79
            misses: 51
            Barelies: 38

        Custom levels:
            Level: Custom Levels/darksheep/
            Grade: 98.08
            misses: 64
            Barelies: 62

        Workshop levels:
            Level: Workshop/3741465074/
            Grade: 87.04
            misses: 135
            Barelies: 84
]]

-- Send
function ap.send(item)
	if ap.client == nil then
		print("AP client is not connected")
		return
	end

	local id = ap.data.locations[item]

	if id == nil then
		print("Item not found: " .. item)
		return
	end

	if not ap.client.checked_locations[id] == nil then
		print("Already checked: " .. item)
		return
	end

	print("Sending check for: " .. item)
	ap.client:LocationChecks({ id })
end

function ap.join(host, slot, password)
	connect(host, slot, password)
end

function ap.leave()
	if ap.client == nil then
		return
	end
	-- ap.client:Disconnect()
	print("Force Disconnecting")
	ap.client = nil
	ap.data = {}
	ap.connected = false
	collectgarbage("collect")
end

function ap.IsDeathlinkOn()
	if ap.data.slot_data and ap.data.slot_data.death_link then
		return true
	end
	return false
end

-- send out deathlink
function ap.sendDeathLink(cause, source)
	if ap.client == nil then
		print("AP client is not connected")
		return
	end
	if not ap.IsDeathlinkOn() then
		print("Deathlink is not on")
		return
	end

	print("sendDeathLink started")
	cause = cause or "Beatblock"
	source = source or ap.data.slot or "BeatblockPlayer"
	local time = ap.client:get_server_time()
	print("AP:sendDeathLink " .. tostring(time) .. " " .. cause .. " " .. source)
	local res = ap.client:Bounce({
		time = time,
		cause = cause,
		source = source,
	}, {}, {}, { "DeathLink" })
end

-- TODO: Finish check results
-- Check results
function ap.checkResults(level_path, results)
	if ap.client == nil then
		print("Hit fallback ap results return :C")
		return
	end

	local level_name = results.level.metadata.songName

	if level_name == "Era Chimæra" then
		level_name = "Era Chimaera"
	end

	print("Checking results")

	-- print(ap.data.slot_data.ranksanity)

	print("Goal: " .. ap.data.goal_level .. " | Goal Rank: " .. ap.data.goal_rank)
	print("Level: " .. level_name .. " | Level Rank: " .. results.lGrade)

	goal_rank = ap.data.slot_data.goal_rank	
	if goal_rank == "p" then goal_rank = "perfect" end

	target_rank = ap.data.slot_data.target_rank
	if target_rank == "p" then target_rank = "perfect" end

	-- Victory location check
	if level_name == ap.data.goal_level then
		print("Victory location check :3")
		local t = GameManager:gradeCalcEvil(goal_rank)

		if results.pctGrade <= t then
			print("Goal not a " .. ap.data.slot_data.goal_rank .. " rank")
			return
		end

		print("WIN YIPPE")
		ap.toast("Victory!", "You beat the archapelago!")
		
		ap.client:StatusUpdate(ap.client.ClientStatus.GOAL)
		ap.client:Set("goal", true, true, {{"replace", true}})
	end

	if not ap.data.slot_data.ranksanity then
		local t = GameManager:gradeCalcEvil(target_rank)

		print("Only checking for " .. t .. " or better !")
		if results.pctGrade <= t then
			print("Not a " .. ap.data.slot_data.target_rank .. " rank")
			return
		end

		ap.send(level_name .. " Get " .. ap.data.slot_data.target_rank .. " Rank")

		-- local locationId = ap.data.locations[level_name .. " Get " .. results.lGrade .. " Rank"]

		-- -- Get ap location of the level
		-- ap.client:LocationChecks({ locationId })

		return
	else
		-- like eventually add rank sanity

		-- Stupid result fix
		local elgrade = results.lGrade
		if elgrade == "perfect" then elgrade = "p" end
		if elgrade == "almost" then elgrade = "s plus" end
		
		ap.send(level_name .. " Get " .. elgrade .. " Rank")
	end
	-- level_path: levels/Finished levels/destroydestroy/ | level_name: Destroy, Destroy (ft. eili) | Grade: b | + or -: plus
	-- level_path: Workshop/3748025162/ | level_name: boss battle against that random npc | Grade: a | + or -: plus

	-- print(
	-- 	"level_path: "
	-- 		.. level_path
	-- 		.. " | level_name: "
	-- 		.. level_name
	-- 		.. " | Grade: "
	-- 		.. results.lGrade
	-- 		.. " | + or -: "
	-- 		.. results.lGradePM
	-- )
end

function ap.checkFish(fish) 
	if ap.client == nil then
		print("Hit fallback fish check return :C")
		return
	end

	ap.send("Catch " .. fish)
	
end

-- AP client
-- global to this mod
local game_name = "Beatblockapelago"
local items_handling = 7 -- full remote
local client_version = { 0, 5, 1 } -- optional, defaults to lib version
local message_format = apclientpp.RenderFormat.TEXT

---@type APClient
ap.client = nil

ap.data = {}

function connect(server, slot, password)
	function on_socket_connected()
		ap.connected = true
		print("Socket connected")
	end

	local connection_attempts = 0
	function on_socket_error(msg)
		print("Socket error: " .. msg)
		connection_attempts = connection_attempts + 1
		if connection_attempts >= 3 then
			print("Max attempts reached, disconnecting")
			ap.client = nil
			ap.data = {}
			ap.connected = false
			collectgarbage("collect")
		end
	end

	function on_socket_disconnected()
		print("Socket disconnected")
		ap.client = nil
		ap.data = {}
		ap.connected = false
		collectgarbage("collect")
	end

	function on_room_info()
		print("Room info")
		ap.client:ConnectSlot(slot, password, items_handling, { "Lua-ap.clientClientPP" }, client_version)
	end

	function on_slot_connected(slot_data)
		print("Slot connected")

		--print("slot_data: " .. bbp.utils.printTable(slot_data))
		ap.data.allowFishing = false
		ap.data.playable = {} -- List of level items that can be played

		-- Add tutorial to playable
		table.insert(ap.data.playable, ap.levels["Tutorial"])

		ap.data.received = {} -- List of ALL recieved items

		ap.data.has_goal = false

		ap.data.slot = slot
		ap.data.slot_data = slot_data

		ap.data.goal_level = slot_data.goal_level
		ap.data.goal_rank = slot_data.goal_rank or "b minus"

		ap.data.locations = json.decode(slot_data.locations)
		ap.data.items = json.decode(slot_data.items)

		ap.data.team = ap.client:get_team_number()
		ap.data.player_id = ap.client:get_player_number()

		ap.data.atom_keys = json.decode(slot_data.atom_keys) or {}

		local tags = { "Lua-APClientPP" }
		print("Deathlink: " .. tostring(ap.IsDeathlinkOn()))
		if ap.IsDeathlinkOn() then
			tags[#tags + 1] = "DeathLink"
		end

		ap.data.id_to_location = {}
		for k, v in pairs(ap.data.locations) do
			ap.data.id_to_location[tostring(v)] = k
		end

		-- print("Target rank: " .. tostring(ap.data.slot_data.target_rank))
		-- print("Ranksanity: " .. tostring(ap.data.slot_data.ranksanity))
		-- print("Fishsanity: " .. tostring(ap.data.slot_data.fishsanity))
		if ap.data.slot_data.fishsanity then
			print("Fishsanity: " .. tostring(ap.data.slot_data.fishsanity))
		end

		-- print("locations: " .. type(ap.data.locations))
		-- bbp.utils.printTable(ap.data.locations, "locations", 1)
		-- print("items: " .. type(ap.data.items))

		print("Goal: " .. ap.data.goal_level .. " (".. ap.data.goal_rank .. ")")

		ap.client:ConnectUpdate(nil, tags)

		-- assert(not pcall(function() ap.client:get_item_name(64055) end)) -- not valid anymore, need 2nd arg
		-- assert(ap.client:get_item_name(64055, nil) == ap.client:get_item_name(64055, ap.client:get_game()))
		-- assert(not pcall(function() ap.client:get_location_name(64000) end)) -- not valid anymore, need 2nd arg
		-- assert(ap.client:get_location_name(64000, nil) == ap.client:get_location_name(64000, ap.client:get_game()))

		ap.client:Get({"goal"}, nil)

		-- print("Slot connected")
		-- print(slot_data)
		-- print("missing locations: " .. table.concat(ap.client.missing_locations, ", "))
		-- print("checked locations: " .. table.concat(ap.client.checked_locations, ", "))
		-- ap.client:Say("Hello World!")
		-- ap.client:Bounce({name="test"}, {game_name})
		-- local extra = {nonce = 123}  -- optional extra data will be in the server reply
		-- ap.client:Get({"counter"}, extra)
		-- ap.client:Set("counter", 0, true, {{"add", 1}}, extra)
		-- ap.client:Set("empty_array", nil, true, {{"replace", apclientpp.EMPTY_ARRAY}})
		-- ap.client:ConnectUpdate(nil, {"Lua-ap.clientClientPP"})
		-- ap.client:LocationChecks({64000, 64001, 64002})
		-- print("Players:")
		-- local players = ap.client:get_players()
		-- for _, player in ipairs(players) do
		--     print("  " .. tostring(player.slot) .. ": " .. player.name ..
		--           " playing " .. ap.client:get_player_game(player.slot))
		-- end
	end

	function on_slot_refused(reasons)
		print("Slot refused: " .. table.concat(reasons, ", "))
		ap.client = nil
		collectgarbage("collect")
	end

	function on_items_received(items)
		print("Items received:")
		-- { item, location }
		local item_list = {}
		for _, item in ipairs(items) do
			-- bbp.utils.printTable(item, "item", 1)

			ap.addItem(item.item)
			table.insert(item_list, ap.data.items[tostring(item.item)])
			-- print(item.item .. " | Name: " .. ap.data.items[tostring(item.item)])
		end
		ap.toast("Items Received", item_list)
	end

	function on_location_info(items)
		print("Locations scouted:")
		for _, item in ipairs(items) do
			print(item.item)
		end
	end

	function on_location_checked(locations)
		print("Locations checked:" .. table.concat(locations, ", "))
		-- print("Checked locations: " .. table.concat(ap.client.checked_locations, ", "))
	end

	function on_data_package_changed(data_package)
		print("Data package changed:")
		print(data_package)
	end

	function on_print(msg)
		print("Print: " .. msg)
	end

	function on_print_json(msg, extra)
		print(ap.client:render_json(msg, message_format))
		for key, value in pairs(extra) do
			-- print("  " .. key .. ": " .. tostring(value))
		end
	end

	function on_bounced(bounce)
		print("Bounced:")
		print(bounce)
		print("Bounced: " .. tostring(bounce.cause) .. " from " .. tostring(bounce.source))
	end

	function on_retrieved(map, keys, extra)
		print("Retrieved:")
		-- since lua tables won't contain nil values, we can use keys array
		for _, key in ipairs(keys) do
			if key == "goal" then
				if tostring(map[key]) == "true" then
					ap.data.has_goal = true
				else
					if not tostring(map[key]) == "false" then
						ap.client:Set("goal", false, true, {{"replace", false}})
					end
					ap.data.has_goal = false
				end
			end
			print("  " .. key .. ": " .. tostring(map[key]))
		end
		-- extra will include extra fields from Get
		print("Extra:")
		for key, value in pairs(extra) do
			print("  " .. key .. ": " .. tostring(value))
		end
		-- both keys and extra are optional
	end

	function on_set_reply(message)
		print("Set Reply:")
		for key, value in pairs(message) do
			print("  " .. key .. ": " .. tostring(value))
			if key == "value" and type(value) == "table" then
				for subkey, subvalue in pairs(value) do
					print("    " .. subkey .. ": " .. tostring(subvalue))
				end
			end
		end
	end

	local uuid = ""
	ap.client = apclientpp(uuid, game_name, server)

	ap.client:set_socket_connected_handler(on_socket_connected)
	ap.client:set_socket_error_handler(on_socket_error)
	ap.client:set_socket_disconnected_handler(on_socket_disconnected)
	ap.client:set_room_info_handler(on_room_info)
	ap.client:set_slot_connected_handler(on_slot_connected)
	ap.client:set_slot_refused_handler(on_slot_refused)
	ap.client:set_items_received_handler(on_items_received)
	ap.client:set_location_info_handler(on_location_info)
	ap.client:set_location_checked_handler(on_location_checked)
	ap.client:set_data_package_changed_handler(on_data_package_changed)
	ap.client:set_print_handler(on_print)
	ap.client:set_print_json_handler(on_print_json)
	ap.client:set_bounced_handler(on_bounced)
	ap.client:set_retrieved_handler(on_retrieved)
	ap.client:set_set_reply_handler(on_set_reply)
end

--]]
return ap
