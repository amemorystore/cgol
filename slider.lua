slider = {}


slider_meta = {__index = slider}

slider_pressed = false

local color = {
		back = {30/255, 30/255, 30/255, 255/255},
		fore = {80/255, 80/255, 80/255, 255/255},
		text = {255/255, 255/255, 255/255, 255/255}
	}

function slider.new(text, x, y, w, h, val, minV, maxV)
	return setmetatable({
			x = x,
			y = y,
			w = w,
			h = h,
			isPressed = false,
			val = {c = val, n = val, mi = minV, ma = maxV},
			text = text
		}, slider_meta)
end



function slider:draw()
	love.graphics.setColor(color.back)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

	love.graphics.setColor(color.fore)
	--love.graphics.rectangle("fill", self.x, self.y, self.w / self.val.ma * self.val.n, self.h)
	love.graphics.rectangle("fill", self.x, self.y, self.w / self.val.ma * self.val.n, self.h)

	love.graphics.setColor(color.text)
	love.graphics.print(self.text..": "..self.val.n, self.x, self.y - 16)
end

function slider:mouseOver()
	local x, y = love.mouse.getPosition()
	local r = false
	if x > self.x and x < self.x + self.w and y > self.y and y < self.y + self.h then
		r = true
	end
	return r
end

function slider:mousePressed()
	self.isPressed = true
	slider_pressed = true
end

function slider:mouseReleased()
	self.isPressed = false
	slider_pressed = false
	self.val.c = self.val.n
end

function slider:mouseDown()
	local x, y = love.mouse.getPosition()
	local val = 0

	x = x - self.x

	val = math.floor(x / self.w * self.val.ma)
--	print ('slider mouseDown' .. val)
	if val > self.val.ma then
		val = self.val.ma
	elseif val < self.val.mi then
		val = self.val.mi
	end

	self.val.n = val
end
