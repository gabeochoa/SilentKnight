require 'class';

entity = class:new()

function entity:init(name, x, y) 

		self.grid_x = x*tile_size
		self.grid_y = y*tile_size
		self.act_x = x*tile_size
		self.act_y = y*tile_size
		self.speed = 10
        self.dir = 3 -- 1/N  2/E  3/S  3/W
        self.image = love.graphics.newImage("sprites/"..name.."_n.png")
        self.image_n = love.graphics.newImage("sprites/"..name.."_n.png")
        self.image_e = love.graphics.newImage("sprites/"..name.."_e.png")
        self.image_s = love.graphics.newImage("sprites/"..name.."_s.png")
        self.image_w = love.graphics.newImage("sprites/"..name.."_w.png")

end

function entity:draw(dt) ------------------------------------------------ plugs into main.lua
	love.graphics.draw(self.image, self.act_x, self.act_y)
end

function entity:update(dt)
	
end -----------------------------------------------------------------------------------------