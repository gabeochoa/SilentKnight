require 'class';

entity = class:new()

function entity:init(color, x, y, spd, s, w, h) 

	self.img = love.graphics.newImage("textures/entities/knight_"..color..".png")
	self.img:setFilter("nearest")
	self.x, self.y = x, y
	self.scale = s or 6

	-- w & h should be custom set only for entitys whose weapons/armor skew their hitboxes 
	self.w = ( w or self.img:getWidth() ) *self.scale
	self.h = ( h or self.img:getHeight() ) *self.scale

	self.hw, self.hh = self.w/2, self.h/2

	self.ox, self.oy = self.x + self.hw, self.y + self.hh

	self.speed = spd or 50
	self.origSpeed = self.speed
end

function entity:draw(dt) ------------------------------------------------ plugs into main.lua
	if (entity.ox < love.mouse.getX()) then
		love.graphics.draw(self.img, self.x, self.y, 0, -self.scale, self.scale, self.w/self.scale)
	else
		love.graphics.draw(self.img, self.x, self.y, 0, self.scale, self.scale)
	end
  if (isDebugging) then self:drawDebug(dt) end
end

function entity:update(dt)
	if (currentlySelected == self) then
		if love.keyboard.isDown('a') then
			self.x = self.x - self.speed * dt
		elseif love.keyboard.isDown('d') then
			self.x = self.x + self.speed * dt
		end
		if love.keyboard.isDown('w') then
			self.y = self.y - self.speed * dt
		elseif love.keyboard.isDown('s') then
			self.y = self.y + self.speed * dt
		end
		if love.keyboard.isDown('lshift') then -- sprint while holding LSHIFT
			entity.speed = entity.origSpeed + 100
		end
		
	else -- If NOT entity, then move toward entity
		if self.x ~= destX then
  		self.x = self.x + (dt*self.speed)*((destX-self.x)/math.abs(destX-self.x))
  	end
  	if self.y ~= destY then
  		self.y = self.y + (dt*self.speed)*((destY-self.y)/math.abs(destY-self.y))
  	end
  end

	self.ox, self.oy = self.x + self.hw, self.y + self.hh
	
end -----------------------------------------------------------------------------------------

function entity:drawDebug(dt)
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

