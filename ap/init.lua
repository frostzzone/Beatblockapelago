local apclientpp = require("lua-apclientpp")

local ap = {}

ap.gui = require("ap.gui")
ap.utils = require("ap.utils")

ap.client = nil

local got_all_levels = false
ap.levels = {}

-- Because im lazy and levels cant be preloaded
--[[
function ap.get_all_levels()
	if not got_all_levels then
		print("Getting all levels")
		-- love.filesystem.getDirectoryItems('levels/')
		ap.level = love.filesystem.getDirectoryItems("levels/Finished levels/")

        -- levels/Other/fishing/
        ap.levels["gone fishin'"] = 1
		for k, v in pairs(ap.level) do
			-- Get metadata
			local metadata = dpf.loadJson("levels/Finished levels/" .. tostring(v) .. "/manifest.json")
			print("Path: " .. "levels/Finished levels/" .. tostring(v) .. " | " .. metadata.metadata.songName)
			ap.levels[metadata.metadata.songName] = k+1
		end

		ap.utils.dpf.saveJson("ap_levels.json", ap.levels, function(a, b)
			return a < b
		end)

		got_all_levels = true
	else
		print("Already got all levels")
	end
end
]]

-- Dev stuff

local dev = {}

function dev.send(msg)
	print("sending: " .. msg)
end

function dev.receive(msg)
	print("received: " .. msg)
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
function ap.send(msg)
	dev.send(msg)
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
        source = source
    }, {}, {}, {"DeathLink"})
end

-- level to id
-- IDK

-- AP client
-- global to this mod
local game_name = "Beatblockapelago"
local items_handling = 7  -- full remote
local client_version = {0, 5, 1}  -- optional, defaults to lib version
local message_format = apclientpp.RenderFormat.TEXT

---@type APClient
ap.client = nil

ap.data = {}

function connect(server, slot, password)
    function on_socket_connected()
        print("Socket connected")
    end

    function on_socket_error(msg)
        print("Socket error: " .. msg)
    end

    function on_socket_disconnected()
        print("Socket disconnected")
        ap.client = nil
        collectgarbage("collect")
    end

    function on_room_info()
        print("Room info")
        ap.client:ConnectSlot(slot, password, items_handling, {"Lua-ap.clientClientPP"}, client_version)
    end

    function on_slot_connected(slot_data)
        print("Slot connected")

        --print("slot_data: " .. bbp.utils.printTable(slot_data))
        ap.data.slot = slot
        ap.data.slot_data = slot_data
        ap.data.team = ap.client:get_team_number()
        ap.data.player_id = ap.client:get_player_number()

        local tags = {"Lua-APClientPP"}
        print("Deathlink: " .. tostring(ap.IsDeathlinkOn()))
        if (ap.IsDeathlinkOn()) then
            tags[#tags + 1] = "DeathLink"
        end

        ap.client:ConnectUpdate(nil, tags)

        -- assert(not pcall(function() ap.client:get_item_name(64055) end)) -- not valid anymore, need 2nd arg
        -- assert(ap.client:get_item_name(64055, nil) == ap.client:get_item_name(64055, ap.client:get_game()))
        -- assert(not pcall(function() ap.client:get_location_name(64000) end)) -- not valid anymore, need 2nd arg
        -- assert(ap.client:get_location_name(64000, nil) == ap.client:get_location_name(64000, ap.client:get_game()))

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
        for _, item in ipairs(items) do
            print(item.item)
        end
    end

    function on_location_info(items)
        print("Locations scouted:")
        for _, item in ipairs(items) do
            print(item.item)
        end
    end

    function on_location_checked(locations)
        print("Locations checked:" .. table.concat(locations, ", "))
        print("Checked locations: " .. table.concat(ap.client.checked_locations, ", "))
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
    ap.client = apclientpp(uuid, game_name, server);

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
