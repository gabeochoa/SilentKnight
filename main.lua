function love.load()
	-- requires ----------------------------------------------------------------------
	require 'camera'; require 'AnAL'; require 'entity'; require 'wall'; require 'tile'
	local bump = require 'bump'
	-- love settings -----------------------------------------------------------------
	love.keyboard.setKeyRepeat( false )
	love.graphics.setBackgroundColor( 115, 115, 115)
	math.randomseed(os.time())
	-- mouse stuff --
	cursor = love.mouse.newCursor("textures/misc/cursor_sword.png", 0, 0)
	love.mouse.setCursor(cursor)
  	-- global variables --------------------------------------------------------------
	isDebugging = true
	windowW = love.graphics.getWidth()
	minimapScale = 50
	hud_opacity = 255
	current_wave = 1
	current_state = "game"

	-- global resources --------------------------------------------------------------
	shadow_img = love.graphics.newImage("textures/misc/shadow.png"); shadow_img:setFilter("nearest")
	gravestone_img = love.graphics.newImage("textures/misc/gravestone.png"); gravestone_img:setFilter("nearest")
	
	-- world creation ----------------------------------------------------------------
	world = bump.newWorld() -- creates collision world
	player = entity:new("silver_knight", "friendly", 600, 200, nil, nil, nil, 5) -- creates player
	world:add(player, player.x, player.y, player.w, player.h) -- adds player to the world
  	-- tables ------------------------------------------------------------------------
	entities = { player } -- all "living things" that move
	party = { player } -- entities that are friendly
	enemies = {  } -- entities that are hostile
	tiles = {} -- graphics background for map, only drawn, no calculations
  	walls = {} -- boundaries, only for calculation, not actually drawn


  	-- walls ------------------------------------------------------------------------- !! TO BE REPLACED WITH MAP GENERATION !!
  	table.insert(walls, wall:new(0, 0, love.graphics.getWidth(), 50)) -- topmost wall
  	table.insert(walls, wall:new(0, 50, 50, love.graphics.getHeight() - 100)) -- leftmost wall
  	table.insert(walls, wall:new(0, love.graphics.getHeight() - 50, love.graphics.getWidth(), 50)) -- bottom wall
  	table.insert(walls, wall:new(love.graphics.getWidth() - 50, 50, 50, love.graphics.getHeight() - 100)) -- rightmost wall

  	-- randomly placed walls --
  	for i=0, 50 do
  		table.insert(walls, wall:new(math.random(1, 18)*50, math.random(1, 14)*50, 50, 50))
  	end


 	for i=1, #walls do -- adds all walls to collision world
 		local w = walls[i]
 		world:add(w, w.x, w.y, w.w, w.h)
 	end 	
  	
  	canvas = love.graphics.newCanvas(10000, 10000)
    -- Rectangle is drawn to the canvas with the alpha blend mode.
    love.graphics.setCanvas(canvas)
        canvas:clear()

        for j=1, 18, 1 do
	      	for i=1, 14, 1 do
	      		local tile = tile:new("stone_tile_center", 50 * j, 50*i)
	  			tile:draw(dt)
	  		end
	  	end
      	
      	for i=1, #walls do
      		local tile = tile:new("wall_tile_center",walls[i].x, walls[i].y)
  			tile:draw(dt)

  			local o = 1
  			while (walls[i].w > o * 50) do
  				local tile = tile:new("wall_tile_center",walls[i].x + (o * 50), walls[i].y)
  				tile:draw(dt)
  				o = o + 1
  			end
  			local o = 1
  			while (walls[i].h > o * 50) do
  				local tile = tile:new("wall_tile_center",walls[i].x, walls[i].y + (o * 50))
  				tile:draw(dt)
  				o = o + 1
  			end
      	end

	  	--[[for i=0, 10 do -- background for TOP of walls
  			local tile = tile:new("wall_tile_center",i * 200, 0)
  			tile:draw(dt)
  			local tile = tile:new("wall_tile_center",i * 200, 1800)
  			tile:draw(dt)
	  	end
	  	for i=1, 8 do -- background for SIDE of walls
  			local tile = tile:new("wall_tile_center", 0, i* 200)
  			tile:draw(dt)

  			local tile = tile:new("wall_tile_center", 2000, i*200)
  			tile:draw(dt)
	  	end]]

    love.graphics.setCanvas()
  	-- misc --
end



function love.update(dt)

	updateAll(entities, dt) -- updates the positions of all entities
	table.sort(entities, ysort) -- preps to draw entities farther back behind those in front
	for i=1, #entities do
		entities[i].index = i
	end
	checkKeys(dt)
	drawMinimap(dt)
	-----------------
	camera:update(dt)
end

function love.draw(dt)
	camera:set()
	------------
	love.graphics.draw(canvas)
	love.graphics.arc( "line", player.ox, player.oy, 100, getAngle(player.ox, player.oy, camera:mousePosition()) - .5, getAngle(player.ox, player.oy, camera:mousePosition())+.5, 20 )
	drawShadows()
	if isDebugging then drawAll(walls, dt) end
	drawAll(entities, dt)
	

	--love.graphics.draw(ontop_canvas)

	------------------------------------- HUD 
	--drawMinimap(dt)
	-------------------------------------- HUD

  	love.graphics.print("Wave # "..current_wave, camera.x + 10, camera.y + 10)
  	love.graphics.print("Enemies # "..#enemies, camera.x + 10, camera.y + 20)

	--------------------
	love.graphics.print("FPS: "..love.timer.getFPS(), camera.x + 500, camera.y) -- 450
	love.graphics.circle("line", love.graphics.getWidth()/2, love.graphics.getHeight()/2, 5)
  	if isDebugging then drawMainDebug() end

  	--------------
  	camera:unset()  	
end




function love.keypressed( key, unicode ) ------------------------------------- checks for key presses that should only happen ONCE until re-pressed

	if key == ('`') then -- toggles debugging info (boosts FPS)
		isDebugging = not isDebugging
	end
	if key == ('1') then
		if (camera.focus ~= player) then
			camera.focus = player
		else
			camera.focus = camera
		end
	end
	if key == ('0') then
		love.load()
	end
end 

function love.keyreleased( key, unicode )

	if key == (' ') then -- spawns KNIGHT_GOLD ENEMY at mouse location
		local rand = math.random(-1, 1) -- 1=Friend -1=Enemy
		local demeanor = nil
		if (rand >= 100) then
			demeanor = "friendly"
		else
			demeanor = "hostile"
		end

		local knight = entity:new("silver_knight", demeanor, player.ox + 50, player.oy + 50, math.random(.3 * player.origSpeed, .6 * player.origSpeed), math.random(3, 6), nil, love.graphics.newImage("textures/entities/silver_knight.png"):getHeight()/2)
		table.insert(entities, knight)
		world:add(knight, knight.x, knight.y, knight.w, knight.h)
	end

	if key == ('r') then
		love.load()
	end
end

function love.mousepressed( x, y, button )

end

function love.mousereleased( x, y, button )

end

function love.focus(bool)

end

function love.quit()

end

function distanceFrom(x1,y1,x2,y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end

function distanceBetween(entA, entB)
	return math.sqrt((entB.ox - entA.ox) ^ 2 + (entB.y - entA.y) ^ 2)
end


function drawAll(table, dt)
	for i = 1, #table do
  		table[i]:draw(dt)
  	end
end
function updateAll(table, dt)
	for i = 1, #table do
	if (table[i] ~= nil) and (table[i].state ~= "dead") then
  		table[i]:update(dt)
  	end
  end
end
function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function drawMinimap(dt)
	love.graphics.setColor(255, 255, 255, hud_opacity)
	for i=1, #walls do
  		local w = walls[i]
  		love.graphics.rectangle("fill", camera.x+10+ w.x/minimapScale, camera.y+50+w.y/minimapScale, w.w/minimapScale, w.h/minimapScale)
  	end
  	for i=1, #entities do
  		local e = entities[i]
  		if (e == player) then
  			love.graphics.setColor(255, 255, 255, hud_opacity)
  		elseif (e.demeanor == "friendly") then
  			love.graphics.setColor(0, 255, 0, hud_opacity) 
  		elseif (e.demeanor == "enemy") then
  			love.graphics.setColor(255, 0, 0, hud_opacity)
  		else
  			love.graphics.setColor(255, 255, 255, hud_opacity)
  		end

  		love.graphics.circle("fill", camera.x + 10 + e.ox/minimapScale, camera.y + 50 + e.oy/minimapScale, 2)
  	end
  	love.graphics.setColor(0, 0, 0, hud_opacity)
  	love.graphics.setColor(255, 255, 255, 255)
end





function checkKeys()
	player.state = "idle"
	player.dx, player.dy = 0, 0
	if love.keyboard.isDown('a') then player.dx = -player.speed; player.state = "moving" end
	if love.keyboard.isDown('d') then player.dx = player.speed; player.state = "moving" end
	if love.keyboard.isDown('w') then player.dy = -player.speed; player.state = "moving" end
	if love.keyboard.isDown('s') then player.dy = player.speed; player.state = "moving" end
	-- sprint --
	if love.keyboard.isDown('lshift') and (player.stamina > 0) then 
		player.speed = player.origSpeed + 200
		player.stamina = player.stamina - 50 * love.timer.getDelta()
	else
		player.speed = player.origSpeed
	end


end


function drawArc (x, y, r, s_ang, e_ang, numLines)

   local step = ((math.pi * 2) / numLines)

   local ang1 = s_ang
   local ang2 = 0
   
   while (ang1 < e_ang) do
      -- increment angle
      ang2 = ang1 + step

      -- draw a line from 'previous' angle to 'actual' angle
      love.graphics.line(x + (math.cos(ang1) * r), y - (math.sin(ang1) * r),
                         x + (math.cos(ang2) * r), y - (math.sin(ang2) * r))
      
                -- update 'previous' angle
      ang1 = ang2
   end

end

function drawShadows()
	for i = 1, #entities do
		love.graphics.draw(shadow_img, entities[i].ox, entities[i].y + entities[i].h, 0, entities[i].scale, entities[i].scale, 4, 1.5) -- shadow
	end
end

function loadWave(num)
	for i=1, num do
		local knight = entity:new("silver_knight", "hostile", player.ox + 50, player.oy + 50, math.random(.3 * player.origSpeed, .6 * player.origSpeed), math.random(6, 20), nil, love.graphics.newImage("textures/entities/silver_knight.png"):getHeight()/2)
			table.insert(entities, knight)
			table.insert(enemies, knight)
			world:add(knight, knight.x, knight.y, knight.w, knight.h)
	end
end

function ysort(entityA, entityB)
    return (entityA.y + entityA.h) < (entityB.y + entityB.h)
end

function getAngle(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1)
end

function drawMainDebug(dt)
	local x, y = camera.x, camera.y + 100
	local mx, my = camera:mousePosition()
	debugInfo = {
		"FPS: "..love.timer.getFPS(),
		"#entities"..#entities,
		"MouseX: "..mx,
		"playerX: "..player.x
	}
	for i = 1, #debugInfo do
  	love.graphics.print(debugInfo[i], x, y)
  	y = y + 15
  end
end