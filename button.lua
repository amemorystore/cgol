button = {}


button_meta = {__index = button}

button_pressed = false

local color = {
		back = {30/255, 30/255, 30/255, 255/255},
		fore = {80/255, 80/255, 80/255, 255/255},
		text = {255/255, 255/255, 255/255, 255/255}
	}

function button.new(text, x, y, w, h)
	return setmetatable({
			x = x,
			y = y,
			w = w,
			h = h,
			isSelected = false,
			isPressed = false,
			text = text,
		}, button_meta)
end



function button:draw()

	if self.isSelected then
		love.graphics.setColor(color.fore)
	else
		love.graphics.setColor(color.back)
	end
--	love.graphics.setColor(color.back)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)



	love.graphics.setColor(color.text)
	love.graphics.print(self.text, self.x, self.y)
end

--function button:mouseOver()
--	local x, y = love.mouse.getPosition()
--	if x > self.x and x < self.x + self.w and y > self.y and y < self.y + self.h then
--		self.isSelected = true
----		return true
--	else
--		self.isSelected = false
----		return false
--end


function button:mouseOver()
	local x, y = love.mouse.getPosition()
	local r = false
	if x > self.x and x < self.x + self.w and y > self.y and y < self.y + self.h then
		r = true
		self.isSelected = true
	else
		self.isSelected = false
	end
	return r
end

function button:mousePressed()
	self.isPressed = true
	button_pressed = true
end

function button:mouseReleased()
	self.isPressed = false
	button_pressed = false
end

--function button:mouseDown()
--	if self.isPressed then
--		return true
--	end
--end
