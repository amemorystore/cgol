--[[#.       #]]--

screen = {
		w = love.graphics.getWidth(),
		h = love.graphics.getHeight()
	}


--Settings
game_started = false
game_updateRate = 12
game_tick = 0
game_cellSize = 10

local color = {
		text = {255/255, 255/255, 255/255, 255/255}
	}

require "world"
require "slider"
require "button"

function love.load()
	--Creating World
	local map_offset_x = 256
	local map_offset_y = 32
	local map_offset_y2 = 32


	m = world.new(map_offset_x, map_offset_y,
		math.floor((screen.w - map_offset_x) / game_cellSize), math.floor((screen.h - map_offset_y - map_offset_y2) / game_cellSize),
		game_cellSize)

	local slider_x = 32
	local slider_y = 32
	local slider_offset = 40

	sliders = {
		slider.new("rate", 	slider_x, slider_y +   map_offset_y, 				256 - (slider_x * 2), 13, 15, 				1, 100), -- update Rate
		slider.new("cell size", 	slider_x, slider_y + 2*slider_offset, 256 - (slider_x * 2), 13, game_cellSize, 	2, 64),
	}

	buttons = {
		button.new("start/pause", slider_x, slider_y +  3*slider_offset, 	192, 13), -- (text, x, y, w, h)
		button.new("clear", slider_x, slider_y +  4*slider_offset, 	192, 13), -- (text, x, y, w, h)
		button.new("random", slider_x, slider_y + 5*slider_offset, 	192, 13), -- (text, x, y, w, h)
	}

	live_cells = 0
	love.graphics.setBackgroundColor( 0/255, 0/255, 10/255, 1 )
end

function love.update(dt)
	--Updating world
	if game_started then
		game_tick = game_tick + dt
		if game_tick > 1 / game_updateRate then
			live_cells = m:update()
			game_tick = 0
		end
	end

	-- new cell size; new cells amount
	if not (m.cellSize == game_cellSize) then
		resize()
	end


	--world manipulation
	local x, y = m:getWorldMouse()
	if not slider_pressed or button_pressed then
		-- add white
		if love.mouse.isDown(1) and love.mouse.getX() > m.x then
			m:setCellState(x, y, true, true)
		-- add black
		elseif love.mouse.isDown(2) and love.mouse.getX() > m.x then
			m:setCellState(x, y, false)
		end
	else -- slider and button shit
		for i,v in ipairs(sliders) do
			if v.isPressed then
				v:mouseDown()
			end
		end
--		for i,v in ipairs(buttons) do
--			if v.isPressed then
--				v:mouseDown()
--			end
--		end
	end
end

function love.draw()
	--Drawing world
	m:draw()

	--UI

	--Sliders
	for i,v in ipairs(sliders) do
		v:draw()
	end

	--Buttons
	for i,v in ipairs(buttons) do
		v:mouseOver()
		v:draw()
	end

	--Debug
	love.graphics.setColor(color.text)
	love.graphics.print("Update Rate: "..game_updateRate
		.."\nSimaltion Running: "..tostring(game_started)
		.."\nFPS: "..love.timer.getFPS()
		.."\nCells: "..m.w * m.h .. "; Live cells:" .. live_cells
		.."\nW: "..m.w .. " H: " .. m.h
		, 12, screen.h - (64+25+32))
end


function love.mousepressed(x, y, k)
--	if k == "l" then
	if k == 1 then
		for i,v in ipairs(sliders) do
			if v:mouseOver() then
				v:mousePressed()
--				print ('Pressed: ' .. v.text)
			end
		end
		for i,v in ipairs(buttons) do
			if v:mouseOver() then
				v:mousePressed()
--				print ('Pressed: ' .. v.text)
			end
		end
	end
end


function love.mousereleased(x, y, k)
	if k == 1 then
		for i,v in ipairs(sliders) do
			v:mouseReleased()
		end

		game_updateRate = sliders[1].val.c
		game_cellSize = sliders[2].val.c

		for i,v in ipairs(buttons) do
			if v.isPressed and v.text == "start/pause" then
				game_started = not game_started
			elseif v.isPressed and v.text == "clear" then
				clear_world ()
			elseif v.isPressed and v.text == "random" then
				m:random()

			elseif v.isPressed then
				print ('Pressed: ' .. v.text)
			end
			v:mouseReleased()
		end
	end
end


function clear_world ()
	for y=0, m.h-1 do
		for x=0, m.w-1 do
			m:setCellState(x, y, 0)
		end
	end
end


function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push("quit")
	end
	if key == "space" then
		game_started = not game_started
	elseif key == "s" then
		m:update()
	elseif key == "c" then
		clear_world ()
	elseif key == "i" then
		for y=0, m.h-1 do
			for x=0, m.w-1 do
				m:setCellState(x, y, not m.cell[y][x].state.c)
			end
		end
	elseif key == "r" then
		m:random()
	end
end


function resize() -- was "reload"
--	m = world.new(256, 0, math.floor((screen.w - 256) / game_cellSize), math.floor(screen.h / game_cellSize), game_cellSize)
	m = world.resize(m, 256, 0, math.floor((screen.w - 256) / game_cellSize), math.floor(screen.h / game_cellSize), game_cellSize)
end


function love.keyreleased(key)

end
