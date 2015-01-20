require 'class'; require 'entity'

player = class:new()

function player:init(color, x, y, spd, s, w, h) 


	self.img = love.graphics.newImage("textures/entities/knight_"..color..".png")
	self.img:setFilter("nearest")
	self.x, self.y = x, y
	self.scale = s or 4

	-- w & h should be custom set only for players whose weapons/armor skew their hitboxes 
	self.w = ( w or self.img:getWidth() ) *self.scale
	self.h = ( h or self.img:getHeight() ) *self.scale

	self.hw, self.hh = self.w/2, self.h/2

	self.ox, self.oy = self.x + self.hw, self.y + self.hh

	self.speed = spd or 200
	self.origSpeed = self.speed
	self.dx = self.speed
	self.dy = self.speed

	self.health = 100
	self.stamina = 100

	self.status = "idle"
	self.dir = "right"

	--imgs
	self.atk_img = love.graphics.newImage("textures/entities/knight_"..color.."_attack.png"); self.atk_img:setFilter("nearest")
	-- animations
	self.walk_img = love.graphics.newImage("textures/anims/knight_"..color.."_walk.png"); self.walk_img:setFilter("nearest")
	self.walk_anim = newAnimation(self.walk_img, 10, 10, 0.1, 0)
end

function player:draw(dt) ------------------------------------------------ plugs into main.lua
	

	--[[if (self.ox < love.mouse.getX()) then
		love.graphics.draw(self.img, self.x, self.y - self.h, 0, self.scale, self.scale)
		self.walk_anim:draw(self.x, self.y - self.h, 0, self.scale, self.scale)
	else
		love.graphics.draw(self.img, self.x, self.y - self.h, 0, -self.scale, self.scale, self.w/self.scale)
	end]]
	

  if (isDebugging) then self:drawDebug(dt) end
end

function player:update(dt)
	--animations
	self.status = "idle"
	self.walk_anim:update(dt)



	self.dx, self.dy = 0, 0

	if love.keyboard.isDown('a') then self.dx = -self.speed; self.status = "walking" end
	if love.keyboard.isDown('d') then self.dx = self.speed; self.status = "walking" end
	if love.keyboard.isDown('w') then self.dy = -self.speed; self.status = "walking" end
	if love.keyboard.isDown('s') then self.dy = self.speed; self.status = "walking" end

	-- sprint
	if love.keyboard.isDown('lshift') and (self.stamina > 0) then 
		self.speed = self.origSpeed + 200
		self.stamina = self.stamina - 20 * love.timer.getDelta()
	else
		self.speed = self.origSpeed
		if (self.stamina < 100) then self.stamina = self.stamina + 10 * love.timer.getDelta() end
	end

	if love.mouse.isDown('l') then self.status = "attacking" end
	-- collision movement
	local goalX, goalY = self.x + self.dx * dt, self.y + self.dy * dt
	local actualX, actualY, cols, len = world:move(self, goalX, goalY)
	self.x, self.y = actualX, actualY
	-- deal with the collisions
	for i=1,len do
		print('collided with ' .. tostring(cols[i].other))
		local other = cols[i].other
	end -- end collision movement

	for i=1, #entities do
		if (self.status == "attacking") and entities[i] ~= self and distanceFrom(player.ox, player.oy, entities[i].ox, entities[i].oy) <= 200 then
			entities[i].health = entities[i].health - 20 * love.timer.getDelta()
		end
	end


	self.ox, self.oy = self.x + self.hw, self.y + self.hh
	
end -----------------------------------------------------------------------------------------

function player:drawDebug(dt)
	local x, y = self.x + self.w + 5, self.y

	local debugInfo = {
		"Pos: ("..self.x..","..self.y..")",
		"W, H: "..self.w..", "..self.h,
		"hW, hH: "..self.hw..", "..self.hh,
		"oX, oY: "..self.ox..","..self.oy,
		"",
		"Health: "..self.health,
		"Stamina: "..self.stamina,
		"Speed: "..self.speed
	}
	for i = 1, #debugInfo do
  	love.graphics.print(debugInfo[i], x, y)
  	y = y + 15
  end
  -- Hitbox
  local a,b,c,d = world:getRect(self)
  love.graphics.rectangle("line", a,b,c,d)
end

