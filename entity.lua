require 'class';

entity = class:new()

function entity:init(class, demeanor, x, y, spd, s, w, h) 

	self.index = 0 -- used to remove from table when dead

	self.img = love.graphics.newImage("textures/entities/"..class..".png")
	self.img:setFilter("nearest")
	self.x, self.y = x, y
	self.scale = s or 4

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

	self.state = "idle" -- idle OR walking OR attacking OR dead
	self.dir = "right"
	self.demeanor = demeanor or "enemy" -- enemy OR neutral OR friendly
	self.name = "BK Randy"

	self.currentTarget = player
	self.canRun = true -- if stamina is depleted you must wait to get back to 100 to run again

	--imgs
	self.atk_img = love.graphics.newImage("textures/entities/"..class.."_attack.png"); self.atk_img:setFilter("nearest")
	-- animations
	self.walk_img = love.graphics.newImage("textures/anims/"..class.."_walk.png"); self.walk_img:setFilter("nearest")
	self.walk_anim = newAnimation(self.walk_img, 10, 10, 0.1, 0)
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
		if (love.mouse.getX() >= windowW/2) then self.dir = "right" else self.dir = "left" end -- turns player toward mouse
	end

	-- draws state animation --
	if self.state == "walking" then
		if (self.dir == "right") then self.walk_anim:draw(self.x, self.y - self.h, 0, self.scale, self.scale) else
		self.walk_anim:draw(self.x, self.y - self.h, 0, -self.scale, self.scale, self.w/self.scale) end

	elseif self.state == "attacking" then
		if (self.dir == "right") then love.graphics.draw(self.atk_img, self.x, self.y - self.h, 0, self.scale, self.scale) else
		love.graphics.draw(self.atk_img, self.x, self.y -self.h, 0, -self.scale, self.scale, self.w/self.scale) end

	elseif self.state == "idle" then
		if (self.dir == "right") then love.graphics.draw(self.img, self.x, self.y - self.h, 0, self.scale, self.scale) else
		love.graphics.draw(self.img, self.x, self.y - self.h, 0, -self.scale, self.scale, self.w/self.scale) end
	
	elseif self.state == "dead" then
		love.graphics.draw(gravestone_img, self.x, self.y -self.h, 0, -self.scale, self.scale, self.w/self.scale) end

	-- draws HEALTH and STAMINA bars above --
	love.graphics.setColor(255, 0, 0, hud_opacity)
	love.graphics.rectangle("fill", self.x, self.y - self.h - 15, self.health * self.w/100, 5)
	love.graphics.setColor(0, 0, 255, hud_opacity)
	love.graphics.rectangle("fill", self.x, self.y - self.h - 10, self.stamina * self.w/100, 5)
	love.graphics.setColor(255, 255, 255, 255)
	


  if (isDebugging) then self:drawDebug(dt) end
end

function entity:update(dt)
	-- animations ------------
	self.state = "idle"
	self.walk_anim:update(dt)

	-- death condition --------
	if (self.health <= 0) then
		self.state = "dead"
		self.dx, self.dy = 0, 0
	end

	-- movement ----------------------------------------------------
	-- ai --
	if (self ~= player) and (self.state ~= "dead")then
		if (self.demeanor == "enemy") then
			self:followTarget(self.currentTarget)
		elseif (self.demeanor == "friendly") then
			self:doFriendlyAI()
		else
			self.dx = 0
			self.dy = 0
		end
	-- player controls --
	elseif (self == player) and (self.state ~= "dead") then
		self.dx, self.dy = 0, 0
		if love.keyboard.isDown('a') then self.dx = -self.speed; self.state = "walking" end
		if love.keyboard.isDown('d') then self.dx = self.speed; self.state = "walking" end
		if love.keyboard.isDown('w') then self.dy = -self.speed; self.state = "walking" end
		if love.keyboard.isDown('s') then self.dy = self.speed; self.state = "walking" end
		-- sprint --
		if love.keyboard.isDown('lshift') and (self.stamina > 0) then 
			self.speed = self.origSpeed + 200
			self.stamina = self.stamina - 20 * love.timer.getDelta()
		else
			self.speed = self.origSpeed
		end
	end

	-- regens --
	if (self.health < 100) then self.health = self.health + 10 * love.timer.getDelta() end
	if (self.stamina < 100) then self.stamina = self.stamina + 10 * love.timer.getDelta() end
	


	-- collision detection ------------------------------------------
	local goalX, goalY = self.x + self.dx * dt, self.y + self.dy * dt
	local actualX, actualY, cols, len = world:move(self, goalX, goalY)
	self.x, self.y = actualX, actualY

	for i=1,len do
		print('collided with ' .. tostring(cols[i].other))
		local other = cols[i].other
			if (other.id == "wall") then -- check other.id

	    elseif (other.id == "entity") then
	    	if (self.demeanor == "enemy") and (other.demeanor ~= "enemy") then
	    		self.state = "attacking"
	      	other.health = other.health - self.damage * love.timer.getDelta()
	    	elseif (self.demeanor == "friendly") and (other.demeanor == "enemy") then
	    		self.currentTarget = other
	      	other.health = other.health - 10 * love.timer.getDelta()
	    	end

	    end -- end check other.id
	end

	self.ox, self.oy = self.x + self.hw, self.y + self.hh
	
end -----------------------------------------------------------------------------------------




function entity:doFriendlyAI()
	if (distanceBetween(self, self.currentTarget) > 200 ) then
		if (self.stamina > 0) and (self.canRun) then
			self.speed = self.origSpeed + 100
			self.stamina = self.stamina - 40 * love.timer.getDelta()
		else
			if (self.stamina < 100) then self.canRun = false else self.canRun = true end
			self.speed = self.origSpeed
			self.stamina = self.stamina + 10 * love.timer.getDelta()
		end
		self:followTarget(self.currentTarget)
	else
		self:stopMoving()
	end
end

function entity:stopMoving()
	self.dx = 0
	self.dy = 0
	self.state = "idle"
end



function entity:followTarget(target)
	if target.ox < self.ox then self.dx = -self.speed; self.state = "walking" end
	if self.ox < target.ox then self.dx = self.speed; self.state = "walking" end
	if self.oy > target.oy then self.dy = -self.speed; self.state = "walking" end
	if target.oy > self.oy then self.dy = self.speed; self.state = "walking" end

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

