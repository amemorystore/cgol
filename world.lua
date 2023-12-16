--world.lua
-- Holds all game logic and methods related to the world

world = {}


world_meta = {__index = world}

local color = {
		cell = {
				alive = {255/255, 255/255, 255/255, 255/255},
				dead = {30/255, 30/255, 30/255, 255/255}
			}
	}


local function generate_cell_color ()
	local r = math.random (64,	255)
	local g = math.random (64,	255)
	local b = math.random (64,	255)
--	b = 128*4 - r - g
	local color = {r/255, g/255, b/255, 1}
	return color
end


function world.new(x, y, w, h, cellSize)
	local world = {
			x = x,
			y = y,
			w = w,
			h = h,
			cellSize = cellSize,
			n = 0,
			cell = {}
		}
	for y=0, h-1 do
		world.cell[y] = {}
		for x=0, w-1 do
			world.cell[y][x] = {state = {c = false, n = false}, n = 0}
		end
	end
	return setmetatable(world, world_meta)
end

function world.resize(map, x, y, w, h, cellSize)
	local world = {}
	world.x = x
	world.y = y
	world.w = w
	world.h = h
	world.cellSize = cellSize
	world.n = 0
	local cells = {}

	for y=0, h-1 do
		cells[y] = {}
		for x=0, w-1 do
			if map.cell and map.cell[y] and map.cell[y][x] then
--				local color = generate_cell_color ()
				cells[y][x] = map.cell[y][x]
--				cells[y][x].color = color
			else
				local color = generate_cell_color ()
				cells[y][x] = {state = {c = false, n = false}, n = 0, color = color}
			end
		end
	end

	world.cell = cells
	return setmetatable(world, world_meta)
end



function world:draw()
	for y=0, self.h-1 do
		for x=0, self.w-1 do
			if self.cell[y][x].state.c == true then
--				love.graphics.setColor(color.cell.alive)
				if self.cell[y][x].color then
					love.graphics.setColor(self.cell[y][x].color)
				else
					love.graphics.setColor(color.cell.alive)
				end
			else
				love.graphics.setColor(color.cell.dead)
			end

			love.graphics.rectangle("fill", self.x + x * self.cellSize, self.y + y * self.cellSize, self.cellSize-1, self.cellSize-1)
		end
	end
end


--CELL METHODS
function world:setCellState(x, y, state, set_new)
	if state then

		self.cell[y][x].state.c = state
		if set_new then
			self.cell[y][x].color = generate_cell_color ()
		end
	else
		self.cell[y][x].state.c = state
	end
end

function world:getWorldMouse()
	local x = math.floor((love.mouse.getX() - self.x) / self.cellSize)
	local y = math.floor((love.mouse.getY() - self.y) / self.cellSize)

	if x > self.w then
		x = self.w
	elseif x < 0 then
		x = 0
	end

	if y > self.h then
		y = self.h
	elseif y < 0 then
		y = 0
	end

	return x, y
end

function color_summ (a, b)
	b = b or {0,0,0,0}
	local summ = {}
	for i = 2, 4 do

		summ[i] = a[i]+b[i]
	end
	return summ
end

function normalize_color (color)
	local c = {}
	local min = 1
	local max = 0.5
	for i = 2, 4 do
--		local color[i]
		if color[i] > max then max = color[i] end
		if color[i] < min then min = color[i] end
	end
	max = max - min
--	for i, v in pairs (color) do
	c[1] = color[1]
	for i = 2, 4 do

		c[i] = 0.5 + (color[i] - min)/max
	end

--	print ('min: ' .. min .. ' max: ' .. max)
	return c
end

function color_dev (color, n)
	if n and n > 0 then
		local c = {}
		for i, v in ipairs (color) do
--		for i = 2, 4 do
--			local v = color[i]
--			print ('unpack: ' .. unpack (v))
			c[i] = v/n
		end
		c[1] = color[1]
		c = normalize_color (c)
		return c
	end
end

function world:update()
	--Individual cell update

--	print ('self.w: ' .. self.w .. ' self.h: ' .. self.h)
	local live_cells = 0
	for y=0, self.h-1 do
		for x=0, self.w-1 do
			local check = {
					{x = x + 1, y = y},
					{x = x - 1, y = y},
					{x = x, 	y = y + 1},
					{x = x, 	y = y - 1},
					{x = x - 1, y = y + 1},
					{x = x + 1, y = y - 1},
					{x = x + 1, y = y + 1},
					{x = x - 1, y = y - 1}
				}
			local n = 0 -- Cell Neighbours
			local rgbs = {}
			for i,v in ipairs(check) do
				local nx = (v.x + self.w)%self.w
				local ny = (v.y + self.h)%self.h
				if self.cell[ny][nx].state.c then
					n = n + 1
					local color = self.cell[ny][nx].color or generate_cell_color ()
					table.insert (rgbs, self.cell[ny][nx].color)
				end
			end

			local state = false
			if self.cell[y][x].state.c == true then -- Live cell
				if n == 2 or n == 3 then
					state = true
				else
					state = false
				end
			else -- Dead cell
				if n == 3 then -- birth cell
					state = true
					self.cell[y][x].color = {rgbs[math.random(#rgbs)][1], rgbs[math.random(#rgbs)][2], rgbs[math.random(#rgbs)][3]}
					if (math.random() > 0.99) then
						self.cell[y][x].color[math.random(3)] = math.random (64, 255)/255
					end
				else -- still dead
					state = false
				end
			end
			if state then
				live_cells = live_cells + 1
			end
			self.cell[y][x].state.n = state
		end
	end

	--Entire Map Update
	for y=0, self.h-1 do
		for x=0, self.w-1 do
			self:setCellState(x, y, self.cell[y][x].state.n)
		end
	end
	return live_cells
end


function world:random()
--	local bools = {true, false, false}
	for y=0, self.h-1 do
		for x=0, self.w-1 do
--			local c = bools[math.random(#bools)]
			if (math.random (10) == 1) then
				self.cell[y][x].state.c = true
				self.cell[y][x].color = generate_cell_color ()
			else
--				self.cell[y][x].state.c = falser
			end
		end
	end
end
