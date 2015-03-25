function love.load()
	love.keyboard.setKeyRepeat( true )
	love.graphics.setBackgroundColor( 115, 115, 115)
	math.randomseed(os.time())

	-- global variables --
	scale = 1
	dx, dy = 0, 0
	tile_size = 32
	game_state = "game"
	map_size_x, map_size_y = 50, 50

	timer = 0
	delay = 0.13
	-- world generation --
	-- 0/Open	1/Wall
	map = {}
	for i=1,map_size_y do
    	map[i] = {}
    	for j=1,map_size_x do
			if (math.random() < .7) then
				map[i][j] = 0
			else
				map[i][j] = 1
			end
    	end
    end

	-- entities --
	--require 'entities'
	require 'player'
	require 'entity'
	require 'camera'
	camera.focus = player

	enemy1 = entity:new("snorlax",3,2)
	entities = {enemy1}

	walltile = love.graphics.newImage("sprites/walltile.png")
end


function love.update(dt)
	timer = timer + dt
	if timer >= delay and love.keyboard.isDown("w") then
		timer = 0
		player.image = player.image_n
		if testMap(0, -1) then
			player.grid_y = player.grid_y - tile_size
		end
	elseif timer >= delay and love.keyboard.isDown("a") then
		timer = 0
		player.image = player.image_w
		if testMap(-1, 0) then
			player.grid_x = player.grid_x - tile_size
		end
	elseif timer >= delay and love.keyboard.isDown("s") then
		timer = 0
		player.image = player.image_s
		if testMap(0, 1) then
			player.grid_y = player.grid_y + tile_size
		end
	elseif timer >= delay and love.keyboard.isDown("d") then
		timer = 0
		player.image = player.image_e
		if testMap(1, 0) then
			player.grid_x = player.grid_x + tile_size
		end
	end

	-- smooths player movement --
	player.act_y = player.act_y - ((player.act_y - player.grid_y) * player.speed * dt)
	player.act_x = player.act_x - ((player.act_x - player.grid_x) * player.speed * dt)

	for y=1, map_size_y do
		for x=1, map_size_x do
			if map[y][x] == 2 then
				map[y][x] = 0
			end
		end
	end
	-- smooths entities's movement --
	for k,v in pairs (entities) do
		v.act_y = v.act_y - ((v.act_y - v.grid_y) * v.speed * dt)
		v.act_x = v.act_x - ((v.act_x - v.grid_x) * v.speed * dt)
		map[v.grid_y/tile_size][v.grid_x/tile_size] = 2
	end


	-- camera position --s 
	camera:update(dt)
end

function love.draw(dt)
	camera:set()
	-----------------------------------------------------------------------------------------------
	if game_state == "game" then

		-- map --
		for y=1, map_size_y do
			for x=1, map_size_x do
				if map[y][x] == 1 or map[y][x] ==2 then
					love.graphics.draw(walltile, x * tile_size, y * tile_size, 0, tile_size/25, tile_size/25)
					love.graphics.print(map[y][x], x * tile_size, y * tile_size)
				end
			end
		end
		love.graphics.rectangle("line", tile_size, tile_size, tile_size*map_size_x, tile_size*map_size_y)
		-- player --
		love.graphics.draw(player.image, player.act_x, player.act_y)
		-- entities --
		for k,v in ipairs(entities) do
			v:draw(dt)
		end


	end
	-----------------------------------------------------------------------------------------------
	camera:unset()

	-- debug UI --
	love.graphics.print("FPS: "..love.timer.getFPS(), 5, 5)
	love.graphics.print("Player Pos: ("..(player.grid_x)..", "..(player.grid_y)..")", 5, 20)
	love.graphics.print("(1)Regen Map", 200, 5)
end


function love.keypressed( key, unicode ) -- checks for key presses that should only happen ONCE until re-pressed
	if key == ('1') then
		love.load()
	end
	if key == ('2') then
		if (camera.focus ~= player) then
			camera.focus = player
		else
			camera.focus = camera
		end
	end
end 

function love.keyreleased( key, unicode )

end

function love.mousepressed( x, y, button )

end

function love.mousereleased( x, y, button )

end

function love.focus(bool)

end

function love.quit()

end

function checkKeys()

end

function move(person)

end

function turn(ent, dir)
   if dir == "left" then
		if (ent.dir == 0) then
			ent.dir = 4
		else
			ent.dir = ent.dir - 1
		end
   end
end

function testMap(x, y)
	if (map[(player.grid_y / tile_size) + y][(player.grid_x / tile_size) + x] == 1) or
		(map[(player.grid_y / tile_size) + y][(player.grid_x / tile_size) + x] == 2) then
		return false
	end
	return true
end