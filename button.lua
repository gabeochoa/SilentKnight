require 'class';

button = class:new()

function button:init(img, x, y)
	self.img = love.graphics.newImage("textures/buttons/"..img..".png")

	self.x = x or love.window.getWidth()/2 - self.img:getWidth()/2
	self.y = y or love.window.getHeight()/2 - self.img:getHeight()/2

	self.w = self.img:getWidth()
	self.h = self.img:getHeight()

	self.selected = false
end

function button:draw(dt) ------------------------------------------------ plugs into main.lua
 	love.graphics.draw(self.img, self.x, self.y)
 
  self:drawDebug(dt)
end

function button:update(dt)
	if (self:isHovered()) then currentlySelected = self end
	
end -----------------------------------------------------------------------------------------

function button:click()
	self.y = self.y + 20 * love.timer.getDelta()
end

function button:isHovered()
	return 
	(love.mouse.getX() >= self.x ) and 
	(love.mouse.getX() <= (self.x + self.w)) and 
	(love.mouse.getY() >= self.y ) and 
	(love.mouse.getY() <= (self.y + self.h))
end

function button:drawDebug(dt)
	love.graphics.setFont(love.graphics.setNewFont(10))
	local x, y = self.x + self.w, self.y

	debugInfo = {
		"Pos: ("..self.x..","..self.y..")",
		"Hovered? "..tostring(self:isHovered()),
		"Selected? "..tostring(currentlySelected == self)
	}
	for i = 1, #debugInfo do
  	love.graphics.print(debugInfo[i], x, y)
  	y = y + 10
  end

  love.graphics.setFont(love.graphics.setNewFont(12))
end

