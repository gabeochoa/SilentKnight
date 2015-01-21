require 'class';

tile = class:new()
function tile:init(t, x, y) 

	self.type = t or "grass"
	self.img = love.graphics.newImage("textures/tiles/"..self.type..".png")
	self.img:setFilter("nearest")
	self.x = x
	self.y = y

	self.scale = 4

	self.w = self.img:getWidth()
	self.h = self.img:getHeight()

end

function tile:draw(dt) ------------------------------------------------ plugs into main.lua
	love.graphics.draw(self.img, self.x, self.y, 0, self.scale, self.scale) 
end

function tile:update(dt)

end -----------------------------------------------------------------------------------------

function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function tile:drawDebug(dt)
end