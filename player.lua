player = {}
player.grid_x = tile_size
player.grid_y = tile_size
player.act_x = player.grid_x
player.act_y = player.grid_y
player.speed = 10
player.dir = 3 -- 1/N  2/E  3/S  3/W
player.name = "snorlax"
player.image = love.graphics.newImage("sprites/"..player.name.."_s.png")
player.image_n = love.graphics.newImage("sprites/"..player.name.."_n.png")
player.image_e = love.graphics.newImage("sprites/"..player.name.."_e.png")
player.image_s = love.graphics.newImage("sprites/"..player.name.."_s.png")
player.image_w = love.graphics.newImage("sprites/"..player.name.."_w.png")




people = {}