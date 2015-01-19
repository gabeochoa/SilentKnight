require 'class';

knight = class:new()

function knight:init(color, x, y, spd, s, w, h) 


	self.img = love.graphics.newImage("textures/entities/knight_"..color..".png")
	self.img:setFilter("nearest")
	self.x, self.y = x, y
	self.scale = s or 6

	-- w & h should be custom set only for knights whose weapons/armor skew their hitboxes 
	self.w = ( w or self.img:getWidth() ) *self.scale
	self.h = ( h or self.img:getHeight() ) *self.scale

	self.hw, self.hh = self.w/2, self.h/2

	self.ox, self.oy = self.x + self.hw, self.y + self.hh

	self.speed = spd or 50
	self.origSpeed = self.speed
	self.dx = self.speed
	self.dy = self.speed

	self.health = 100
	self.stamina = 100

	self.type = "enemy"
end

function knight:draw(dt) ------------------------------------------------ plugs into main.lua
	if (player.ox < self.ox+1) then
		love.graphics.draw(self.img, self.x, self.y - self.h, 0, -self.scale, self.scale, self.w/self.scale)
	else
		love.graphics.draw(self.img, self.x, self.y - self.h, 0, self.scale, self.scale)
	end
  if (isDebugging) then self:drawDebug(dt) end
end

function knight:update(dt)

	-- move toward player position
	if player.ox < self.ox then self.dx = -self.speed end
	if self.ox < player.ox then self.dx = self.speed end
	if self.oy > player.oy then self.dy = -self.speed end
	if player.oy > self.oy then self.dy = self.speed end


	local goalX, goalY = self.x + self.dx * dt, self.y + self.dy * dt
	local actualX, actualY, cols, len = world:move(self, goalX, goalY)
	self.x, self.y = actualX, actualY
	-- deal with the collisions
	for i=1,len do
		print('collided with ' .. tostring(cols[i].other))
		local other = cols[i].other
    if other == player then
      player.health = player.health - 20 * love.timer.getDelta()
    end
	end

	self.ox, self.oy = self.x + self.hw, self.y + self.hh
	
end -----------------------------------------------------------------------------------------


function knight:drawDebug(dt)
	local x, y = self.x + self.w + 5, self.y

	local debugInfo = {
		"Pos: ("..self.x..","..self.y..")",
		"W, H: "..self.w..", "..self.h,
		"hW, hH: "..self.hw..", "..self.hh,
		"oX, oY: "..self.ox..","..self.oy
	}
	for i = 1, #debugInfo do
  	love.graphics.print(debugInfo[i], x, y)
  	y = y + 15
  end
  -- Hitbox
  love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

