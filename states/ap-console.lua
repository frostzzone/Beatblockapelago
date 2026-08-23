local st = Gamestate:new(MyCustomState)

-- TODO: Make this

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

st:setInit(function(self) -- initialization function, called when the state is loaded
	ap.gui.pushStyle()

	love.mouse.setVisible(true)
	love.keyboard.setTextInput(true)

	-- Options list
	self.optionsList = em.init("OptionsList")
	local optionsHeight = 20

	self.optionsList:addOption("Play", function()
		ap.send("test")
	end, optionsHeight*0)

	self.optionsList:addOption("Console", function()
		self.switchState("ap-console")
	end, optionsHeight*4)

	self.optionsList:addOption("back", function()
		self.optionsList:callReturn()
	end, 140)

	self.optionsList:setSelection(1)

	-- it breaks if its not wrapped in a function
	self.optionsList.returnLoc["main"] = function()
		ap.leave()
		self:switchState("AP")
	end

	self.optionsList.x = project.res.cx
	self.optionsList.y = 200

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

st:setUpdate(function(self, dt) -- update function, called every frame
	if maininput:pressed("back") or mouse.altpress == -1 then
        -- Add a Are you sure you want to leave? prompt
		self.optionsList:callReturn()
	end

    self.optionsList:update()

	-- Background
	if self.bg then
		self.bg:update(dt)
	end
end)

st:setBgDraw(function(self) -- background draw function, called every frame
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

st:setFgDraw(function(self) -- foreground draw function, called every frame
	love.graphics.setFont(fonts.digitalDisco)
	color("black")

	-- local watermarkText = "Im stupid"
	-- love.graphics.print(watermarkText, project.res.cx * 2 - fonts.digitalDisco:getWidth(watermarkText) - 10, 6)

	-- local windowWidth = imgui.canvasScale and (project.res.x * imgui.canvasScale) or love.graphics.getWidth()
	-- local windowHeight = imgui.canvasScale and (project.res.y * imgui.canvasScale) or love.graphics.getHeight()

	-- local padding = 60

	-- helpers.SetNextWindowPos(padding * 2, padding)
	-- helpers.SetNextWindowSize(windowWidth - padding * 4, windowHeight - padding * 2)

	-- imgui.Begin("Ap Yaml", true, 295)

	-- imgui.SetWindowFontScale(2)

	-- imgui.SetCursorPosX(400)
	-- imgui.Text("Ap Yaml")
	-- imgui.Separator()

	-- -- Blank line
	-- imgui.Text("")

	-- imgui.Text("Ip:")
	-- imgui.SameLine(200 - imgui.GetCursorPosX())
	-- -- apip = helpers.InputText("##ip", apip)

	-- imgui.Text("Slot:")
	-- imgui.SameLine(200 - imgui.GetCursorPosX())
	-- -- apslot = helpers.InputText("##slot", apslot)

	-- imgui.Text("Password:")
	-- imgui.SameLine(200 - imgui.GetCursorPosX())
	-- -- appassword = helpers.InputText("##password", appassword)

	-- ---[[
	-- imgui.Text("Dont Reset:")
	-- imgui.SameLine(200 - imgui.GetCursorPosX())
	-- -- apreset = helpers.InputBool("##reset", apreset)
	-- imgui.SetWindowFontScale(1)
	-- imgui.SameLine(250 - imgui.GetCursorPosX())
	-- imgui.Text("Incase you lose connection")
	-- imgui.SetWindowFontScale(2)
	-- --]]

	-- imgui.End()

    -- draw options
	self.optionsList:draw()
end)

return st
