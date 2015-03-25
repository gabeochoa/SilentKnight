camera = {}
camera.act_x = 0
camera.act_y = 0
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
	camera.x = self.focus.act_x
	camera.y = self.focus.act_y
	if (self.focus ~= camera) then
		camera.x = camera.x - love.window.getWidth()/2 + tile_size/2
		camera.y = camera.y - love.window.getHeight()/2 + tile_size/2
	end
end


