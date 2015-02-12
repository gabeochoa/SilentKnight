camera = {}
camera.x = 0
camera.y = 0
camera.w, camera.h = love.graphics.getWidth(), love.graphics.getHeight()
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0
camera.speed = 100
camera.focus = camera

function camera:set()
	love.graphics.push()
	love.graphics.rotate(-self.rotation)
	love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
	love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
	love.graphics.pop()
end

function camera:move(dx, dy)
	self.x = self.x + (dx or 0) * love.timer.getDelta()
	self.y = self.y + (dy or 0) * love.timer.getDelta()
end

function camera:rotate(dr)
	self.rotation = self.rotation + dr
end

function camera:scale(sx, sy)
	sx = sx or 1
	self.scaleX = self.scaleX * sx
	self.scaleY = self.scaleY * (sy or sx)
end

function camera:setPosition(x, y)
	self.x = x or self.x
	self.y = y or self.y
end

function camera:setScale(sx, sy)
	self.scaleX = sx or self.scaleX
	self.scaleY = sy or self.scaleY
end

function camera:getFocusName()
	if (self.focus == camera) then return "camera" end
	if (self.focus == player) then return "player" end
end

function camera:mousePosition()
  return love.mouse.getX() * self.scaleX + self.x, love.mouse.getY() * self.scaleY + self.y
end

function camera:update(dt)
	if love.keyboard.isDown('q') then
		camera:scale(.999, .999)
	elseif love.keyboard.isDown('e') then
		camera:scale(1.001, 1.001)
	end


	camera.x = self.focus.x
	camera.y = self.focus.y
	if (self.focus ~= camera) then
		camera.x = camera.x - love.window.getWidth()/2 + self.focus.hw
		camera.y = camera.y - love.window.getHeight()/2 + self.focus.hh
	end
end


