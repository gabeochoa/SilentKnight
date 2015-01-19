require 'class';

tile = class:new()
function tile:init(type, x, y, w, h, n) 

	self.type = type or "grass"
	self.x = x
	self.y = y

	self.w = w or 100
	self.h = h or 100

	self.n = n or 0

end

function tile:draw(dt) ------------------------------------------------ plugs into main.lua
		if (self.type == "grass") then 
			love.graphics.setColor( 0, 255, 0 )
		elseif (self.type == "stone") then
			love.graphics.setColor( 100, 100, 100 )
		else
			love.graphics.setColor( 0, 0, 0 )
		end
		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.print("X: "..self.x, self.x, self.y)
		love.graphics.print("Y: "..self.y, self.x, self.y + 10)
		love.graphics.print("#"..self.n, self.x, self.y + 20)
		end

function tile:update(dt)

	if (checkCollision(self.x, self.y, self.w, self.h,  player.x, player.y, player.w, player.h)) then
		self.type = "stone"
	else
		self.type = "grass"
	end
	
end -----------------------------------------------------------------------------------------

function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function tile:drawDebug(dt)
end

