require 'class';

wall = class:new()

function wall:init(x, y, w, h) 

	self.x = x
	self.y = y
	self.w = w or 100
	self.h = h or 100

	self.hw = self.w/2
	self.hh = self.h/2

	self.ox = self.x + self.hw
	self.oy = self.y + self.hh

	self.id = "wall"
	
end

function wall:draw(dt) ------------------------------------------------ plugs into main.lua
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

function wall:update(dt)
	
end -----------------------------------------------------------------------------------------


function wall:drawDebug(dt)
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

