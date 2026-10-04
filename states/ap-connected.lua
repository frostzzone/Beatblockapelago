local st = Gamestate:new(MyCustomState)

local config = {
    
}

-- Sorry it felt weird without them but they're stupid
function st:backroundInit()
	shuv.usePalette = false
	self.bg.skipRender = true
	self.bgCanv = love.graphics.newCanvas(project.res.x, project.res.y)
	self.bgCanv:renderTo(function()
		love.graphics.clear(1, 1, 1, 1)
		self.bg:draw()
	end)
end

-- [[ State functions ]]

function st:GetPossibleMissing()
	-- Get possible locations from missing locations
	self.possible_missing_locations = {}
	for k, v in pairs(ap.client.missing_locations) do
		local itemName = ap.data.id_to_location[tostring(v)]

		print(itemName)

		-- Catch ${fish}
		if itemName:match("Catch") then
			if not ap.data.allowFishing then
				break
			end
			-- table.insert(self.possible_missing_locations, itemName)
		
		-- ${level} Get ${rank} Rank
		elseif itemName:match("Get") then
			local levelName = itemName:match("(.+) Get (.+) Rank")
			-- print(levelName)

			-- erachimaera is a special case
			if levelName == "Era Chimaera" then
				levelName = "Era Chimæra"
			end

			local level = nil
			for k, v in pairs(ap.data.playable) do
				if v.name == levelName then
					level = v
					break
				end
			end

			if level then
				-- Check if atom is unlocked
				local APID = ap.data.atom_keys[level.atom]
				for x,y in ipairs(ap.data.received) do
					if y == APID then
						table.insert(self.possible_missing_locations, itemName)
						break
					end
				end
			end
		end
	end

	-- Check if goal can be achieved
	local goallevel = ap.data.goal_level
	local goal = "GOAL: " .. goallevel .. " Get " .. ap.data.goal_rank .. " Rank"

	if goallevel == "Era Chimaera" then
		goallevel = "Era Chimæra"
	end
	
	if not ap.data.has_goal then
		for k, v in pairs(ap.data.playable) do
			if v.name == goallevel then
				local APID = ap.data.atom_keys[v.atom]
				for x,y in ipairs(ap.data.received) do
					if y == APID then
						table.insert(self.possible_missing_locations, goal)
						break
					end
				end
				break
			end
		end
	else
		table.insert(self.possible_missing_locations, "You Beat the Archapelago!")
	end
end

st:setInit(function(self)
	st:GetPossibleMissing(self)

	ap.gui.pushStyle()

	love.mouse.setVisible(true)
	love.keyboard.setTextInput(true)

	-- Options list
	self.optionsList = em.init("OptionsList")
	local optionsHeight = 20

	-- self.optionsList:addOption("Play", function()
	-- 	ap.send("test")
	-- end, optionsHeight*0)

	-- self.optionsList:addOption("Console", function()
	-- 	self:switchState("ap-console")
	-- end, optionsHeight*4)

	self.optionsList:addOption("Leave AP", function()
		ap.leave()
		self:switchState("AP")
	end, optionsHeight*5)

	self.optionsList:addOption("Back", function()
		self.optionsList:callReturn()
	end, 140)

	self.optionsList:setSelection(1)

	-- it breaks if its not wrapped in a function
	self.optionsList.returnLoc["main"] = function()
		self:switchState("Menu")
	end

	self.optionsList.x = project.res.cx
	self.optionsList.y = 200

	-- IDk
	self.selectedLevel = nil
	self.selected = {
		level = nil,
		variant = nil,
	}

	-- Background
	self:backroundInit()
end)

function st:switchState(state)
	love.mouse.setVisible(false)
	love.keyboard.setTextInput(false)

	ap.gui.popStyle()

	-- Send background data to next menu
	cs = bs.load(state)
	self.menuMusicManager:clearOnBeatHooks()
	self.menuMusicManager:forceUnmute()
	cs.menuMusicManager = self.menuMusicManager
	cs.bg = self.bg
	cs.bg.skipRender = false
	shuv.usePalette = true
	cs:init()
	table.insert(entities, cs.bg)
end

st:setUpdate(function(self, dt)
	if maininput:pressed("back") or mouse.altpress == -1 then
        -- TODO: Add a Are you sure you want to leave? prompt
		self.optionsList:callReturn()
	end

    self.optionsList:update()

	-- Background
	if self.bg then
		self.bg:update(dt)
	end
end)

st:setBgDraw(function(self)
	love.graphics.setFont(fonts.digitalDisco)

	color()
	love.graphics.rectangle("fill", 0, 0, project.res.x, project.res.y)

	self.bgCanv:renderTo(function()
		love.graphics.clear(1, 1, 1, 1)
		self.bg:draw()
	end)

	shuv.drawWithPalette(function()
		love.graphics.draw(self.bgCanv)
	end, {
		[0] = { r = 255, g = 255, b = 255 },
		[1] = { r = 0, g = 0, b = 0 },
		[2] = { r = 205, g = 205, b = 205 },
		[3] = { r = 255, g = 52, b = 50 },
		[4] = { r = 224, g = 227, b = 0 },
		[5] = { r = 44, g = 255, b = 57 },
		[6] = { r = 0, g = 222, b = 229 },
		[7] = { r = 63, g = 38, b = 255 },
	})
end)

st:setFgDraw(function(self)
	love.graphics.setFont(fonts.digitalDisco)
	color("black")

	-- local watermarkText = "Im stupid"
	-- love.graphics.print(watermarkText, project.res.cx * 2 - fonts.digitalDisco:getWidth(watermarkText) - 10, 6)

	local windowWidth = imgui.canvasScale and (project.res.x * imgui.canvasScale) or love.graphics.getWidth()
	local windowHeight = imgui.canvasScale and (project.res.y * imgui.canvasScale) or love.graphics.getHeight()

	local padding = 60

	local actualWidth = windowWidth - padding * 4
	local actualHeight = windowHeight - padding * 4

	helpers.SetNextWindowPos(padding * 2, padding)
	helpers.SetNextWindowSize(actualWidth, actualHeight)

	imgui.Begin("Ap Menu", true, 295)

	imgui.SetWindowFontScale(2)

	-- imgui.SetCursorPosX(400)
	-- imgui.Text("Ap Menu")
	-- imgui.Separator()

	imgui.Columns(2, "main", true)
	imgui.SetColumnWidth(imgui.GetColumnIndex(), actualWidth/2)

	-- start received list
	imgui.BeginChild_Str("received_list", imgui.ImVec2_Float(550 / 600 * actualWidth, actualHeight-20), 0)

	imgui.Text("Received")
	imgui.Separator()

	if ap.data.received then
		for k, v in pairs(ap.data.received) do
			local itemName = ap.data.items[tostring(v)]
			imgui.Text(itemName)
		end
	end

	imgui.EndChild()

	imgui.NextColumn()
	imgui.SetColumnWidth(imgui.GetColumnIndex(), actualWidth / 2)

	-- start missing list
	imgui.BeginChild_Str("missing_list", imgui.ImVec2_Float(550 / 600 * actualWidth, actualHeight-20), 0)

	imgui.Text("Missing")
	imgui.Separator()

	if self.possible_missing_locations then
		for k, v in pairs(self.possible_missing_locations) do imgui.Text(v) end
	end

	imgui.EndChild()

	imgui.End()

    -- draw options
	self.optionsList:draw()
end)

return st
