require 'class';

entity = class:new()

function entity:init(class, demeanor, x, y, spd, s, w, h) 

	self.index = 0 -- used to remove from ENTITIES table when dead

	self.img = love.graphics.newImage("textures/entities/"..class..".png")
	self.img:setFilter("nearest")
	self.x, self.y = x, y
	self.scale = s or 2

	-- w & h should be custom set only for entities whose weapons/armor skew their hitboxes 
	self.w = ( w or self.img:getWidth() ) *self.scale
	self.h = ( h or self.img:getHeight() ) *self.scale

	self.hw, self.hh = self.w/2, self.h/2

	self.ox, self.oy = self.x + self.hw, self.y + self.hh

	self.speed = spd or 100
	self.origSpeed = self.speed
	self.dx = self.speed
	self.dy = self.speed

	self.health = 100
	self.stamina = 100
	self.damage = 50
	self.range = 50

	self.class = class or "gold_knight"
	self.id = "entity"

	self.state = "idle" -- idle OR moving OR attacking OR dead
	self.dir = "right"
	self.demeanor = demeanor or "hostile" -- enemy OR neutral OR friendly
	self.name = "BK Randy"

	self.currentTarget = player
	self.canRun = true -- if stamina is depleted you must wait to get back to 100 to run again

	--imgs
	self.atk_img = love.graphics.newImage("textures/entities/"..class.."_attack.png"); self.atk_img:setFilter("nearest")
	-- animations
	self.walk_img = love.graphics.newImage("textures/anims/"..class.."_walk.png"); self.walk_img:setFilter("nearest")
	self.walk_anim = newAnimation(self.walk_img, 10, 10, 0.125, 0)
	self.attack_img = love.graphics.newImage("textures/anims/"..class.."_attack.png"); self.attack_img:setFilter("nearest")
	self.attack_anim = newAnimation(self.attack_img, 16, 10, .125, 0)
end

function entity:draw(dt) ------------------------------------------------ plugs into main.lua
	-- sprite direction --
	if (self ~= player) then
		if (player.ox < self.ox + 3) then -- faces player
			self.dir = "left"
		else
			self.dir = "right"
		end -- end faces player
	elseif (self == player) then
		if (love.mouse.getX() >= self.ox) then self.dir = "right" else self.dir = "left" end -- turns player toward mouse
	end

	-- draws state animation --
	if self.state == "moving" then
		if (self.dir == "right") then self.walk_anim:draw(self.x, self.y - self.h, 0, self.scale, self.scale) else
		self.walk_anim:draw(self.x, self.y - self.h, 0, -self.scale, self.scale, self.w/self.scale) end

	elseif self.state == "attacking" then
		if (self.dir == "right") then self.attack_anim:draw(self.x, self.y - self.h, 0, self.scale, self.scale) else
		self.attack_anim:draw(self.x, self.y - self.h, 0, -self.scale, self.scale, self.w/self.scale) end
		--[[love.graphics.draw(self.atk_img, self.x, self.y - self.h, 0, self.scale, self.scale) else
		love.graphics.draw(self.atk_img, self.x, self.y -self.h, 0, -self.scale, self.scale, self.w/self.scale) end]]

	elseif self.state == "idle" then
		if (self.dir == "right") then love.graphics.draw(self.img, self.x, self.y - self.h, 0, self.scale, self.scale) else
		love.graphics.draw(self.img, self.x, self.y - self.h, 0, -self.scale, self.scale, self.w/self.scale) end
	
	elseif self.state == "dead" then
		love.graphics.draw(gravestone_img, self.x, self.y -self.h, 0, -self.scale, self.scale, self.w/self.scale) end

	if (self.state ~= "dead") then
	-- draws HEALTH and STAMINA bars above --
	love.graphics.setColor(255, 0, 0, hud_opacity)
	love.graphics.rectangle("fill", self.x, self.y - self.h - 15, self.health * self.w/100, 5)
	love.graphics.setColor(98,166,231, hud_opacity)
	love.graphics.rectangle("fill", self.x, self.y - self.h - 10, self.stamina * self.w/100, 5)
	love.graphics.setColor(255, 255, 255, 255)
	end


  if (isDebugging) then self:drawDebug(dt) end
end

function entity:update(dt)
	-- animations ------------
	self.walk_anim:update(dt)
	self.attack_anim:update(dt)

	-- death condition --------
	if (self.health <= 0) then
		self.state = "dead"
		table.remove(entities, self.index)
		world:remove(self)
	end

	-- movement ----------------------------------------------------
	-- ai --
	if (self.state ~= "dead") then
		if (self.demeanor == "hostile") then
			self:doHostileAI()
		elseif (self.demeanor == "friendly") then
			self:doFriendlyAI()
		end
	elseif (self.state == "dead") then
		self.dx = 0
		self.dy = 0
	end

	-- regens --
	if (self.health < 100) and (self.state ~= "dead") then self.health = self.health + 10 * love.timer.getDelta() end
	if (self.stamina < 100) and (self.state ~= "dead") then self.stamina = self.stamina + 10 * love.timer.getDelta() end
	


	-- collision detection ------------------------------------------
	if (self.state ~= "dead") then
		local goalX, goalY = self.x + self.dx * dt, self.y + self.dy * dt
		local actualX, actualY, cols, len = world:move(self, goalX, goalY)
		self.x, self.y = actualX, actualY

		for i=1,len do
			print('collided with ' .. tostring(cols[i].other))
			local other = cols[i].other
			
			--[[if (self.demeanor == "hostile") and (other.demeanor ~= "hostile") then
    	    	other.health = other.health - 20 * love.timer.getDelta()
    	    end]]
		end
	end
	self.ox, self.oy = self.x + self.hw, self.y + self.hh
	
end -----------------------------------------------------------------------------------------




function entity:doFriendlyAI()
	--[[self.state = "idle"
	if (distanceBetween(self, self.currentTarget) > 100 ) then
		if (distanceBetween(self, self.currentTarget) > 200) then
			self.health = self.health - 50 * love.timer.getDelta()
		end
		self:followTarget(self.currentTarget)
	else
		self:stopMoving()
	end]]
end

function entity:doHostileAI()
	if (distanceBetween(self, self.currentTarget) > (self.hw + self.currentTarget.hw + 10) ) then
		self.state = "moving"
		if (distanceBetween(self, self.currentTarget) > (self.hw + self.currentTarget.hw + 200) ) then
			if (self.stamina < 100) then
				self.speed = self.origSpeed
				self.stamina = self.stamina + 10 * love.timer.getDelta()
			elseif (self.stamina > 0) then
				self.speed = self.origSpeed + 60
				self.stamina = self.stamina - 50 * love.timer.getDelta()
			end
		end
	else 
		self.state = "idle"
	end

	if (self.state == "idle") then
		self:stopMoving()
	elseif (self.state == "moving") then
		self:followTarget(self.currentTarget)
	end

	-- attacking
	if (distanceBetween(self, self.currentTarget) < (self.hw + self.currentTarget.hw + 30)) then
		self.state = "attacking"
		self.currentTarget.health = self.currentTarget.health - 50 * love.timer.getDelta()
	end

end

function entity:stopMoving()
	self.dx = 0
	self.dy = 0
	self.state = "idle"
end



function entity:followTarget(target)
	if target.ox < self.ox then self.dx = -self.speed; self.state = "moving" end
	if self.ox < target.ox then self.dx = self.speed; self.state = "moving" end
	if self.oy > target.oy then self.dy = -self.speed; self.state = "moving" end
	if target.oy > self.oy then self.dy = self.speed; self.state = "moving" end

end

function entity:drawDebug(dt)
	local x, y = self.x + self.w + 5, self.y

	local debugInfo = {
		"Index: "..self.index,
		--[["Pos: ("..self.x..","..self.y..")",
		"W, H: "..self.w..", "..self.h,
		"hW, hH: "..self.hw..", "..self.hh,
		"oX, oY: "..self.ox..","..self.oy,]]
		"",
		"demeanor: "..self.demeanor,
		"HEALTH: "..self.health,
		"SPEED: "..self.speed
	}
	for i = 1, #debugInfo do
  	love.graphics.print(debugInfo[i], x, y)
  	y = y + 15
  end
  -- hitbox --
  love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
  -- range radius --
  love.graphics.circle( "line", self.ox, self.oy - self.hh/2, self.range, nil )
end

