function love.load()
	-- requires ----------------------------------------------------------------------
	require 'camera'; require 'AnAL'; require 'entity'; require 'wall'; require 'tile'
	local bump = require 'bump'
	-- love settings -----------------------------------------------------------------
	love.keyboard.setKeyRepeat( false )
	love.graphics.setBackgroundColor( 200, 0, 0 )
	math.randomseed(os.time())
	-- mouse stuff --
	cursor = love.mouse.newCursor("textures/misc/cursor_sword.png", 0, 0)
	love.mouse.setCursor(cursor)
  	-- global variables --------------------------------------------------------------
	isDebugging = true
	windowW = love.graphics.getWidth()
	minimapScale = 50
	hud_opacity = 255
	-- global resources --------------------------------------------------------------
	shadow_img = love.graphics.newImage("textures/misc/shadow.png"); shadow_img:setFilter("nearest")
	gravestone_img = love.graphics.newImage("textures/misc/gravestone.png"); gravestone_img:setFilter("nearest")
	
	-- world creation ----------------------------------------------------------------
	world = bump.newWorld() -- creates collision world
	player = entity:new("silver_knight", "friendly", 600, 200, nil, nil, nil, 5) -- creates player
	world:add(player, player.x, player.y, player.w, player.h) -- adds player to the world
  	-- tables ------------------------------------------------------------------------
	entities = { player } -- all "living things" that move
	party = { player } -- current team
	tiles = {} -- graphics background for map, only drawn, no calculations
  	walls = {} -- boundaries, only for calculation, not actually drawn


  	-- walls ------------------------------------------------------------------------- !! TO BE REPLACED WITH MAP GENERATION !!
  	table.insert(walls, wall:new(0, 0, 4000, 200)) -- topmost wall
  	table.insert(walls, wall:new(0, 0, 200, 2000)) -- leftmost wall
  	table.insert(walls, wall:new(0, 1800, 4000, 200)) -- bottom wall
  	table.insert(walls, wall:new(3800, 0, 200, 2000)) -- rightmost wall

 	for i=1, #walls do -- adds all walls to collision world
 		local w = walls[i]
 		world:add(w, w.x, w.y, w.w, w.h)
 	end 	
  	



  	canvas = love.graphics.newCanvas(10000, 10000)
    -- Rectangle is drawn to the canvas with the alpha blend mode.
    love.graphics.setCanvas(canvas)
        canvas:clear()
        for i=0, 19 do -- creates background of stones
	        for j=0, 19 do
	  			local tile = tile:new("stone_tile",j * 200, i * 200)
	  			tile:draw(dt)
	  		end
	  	end 

	  	-- !! TO BE REPLACED BY MAP GENERATOR !! --

	  	for i=0, 20 - 1 do -- background for TOP of walls
  			local tile = tile:new("wall_tile",i * 200, 0)
  			tile:draw(dt)
  			local tile = tile:new("wall_tile",i * 200, 1800)
  			tile:draw(dt)
	  	end
	  	for i=0, 20 - 1 do -- background for SIDE of walls
  			local tile = tile:new("wall_tile_side", 0, i* 200)
  			tile:draw(dt)
  			local tile = tile:new("wall_tile_side", 4000, i*200)
  			tile:draw(dt)
	  	end

    love.graphics.setCanvas()
  	
  	-- misc --
  	camera.focus = player
end



function love.update(dt)

	updateAll(entities, dt) -- updates the positions of all entities
	table.sort(entities, ysort) -- preps to draw entities farther back behind those in front
	for i=1, #entities do
		entities[i].index = i
	end

	drawMinimap(dt)
	-----------------
	camera:update(dt)
end

function love.draw(dt)
	camera:set()
	------------
	love.graphics.draw(canvas)
	drawShadows()
	if isDebugging then drawAll(walls, dt) end
	drawAll(entities, dt)

	------------------------------------- HUD 
	local xOff, yOff = 0, 0 -- offsets
	for i=1, #party do
		
		e = party[i]
		love.graphics.draw(e.img, camera.x + 10 + xOff, camera.y + 10, 0, 5, 5)
		love.graphics.rectangle("line", camera.x + 10 + xOff, camera.y + 70, e.health/2, 5)
		love.graphics.rectangle("line", camera.x + 10 + xOff, camera.y + 80, e.stamina/2, 5)

		xOff = xOff + 60
	end
	love.graphics.setColor( 0, 255, 255)
	drawMinimap(dt)
	love.graphics.setColor( 255, 255, 255)
	-------------------------------------- HUD

  	


	--------------------
	love.graphics.print("FPS: "..love.timer.getFPS(), camera.x + 500, camera.y) -- 450
	love.graphics.circle("line", love.graphics.getWidth()/2, love.graphics.getHeight()/2, 5)
  	--if isDebugging then drawMainDebug() end

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

end 

function love.keyreleased( key, unicode )

	if key == (' ') then -- spawns KNIGHT_GOLD ENEMY at mouse location
		local rand = math.random(-1, 1) -- 1=Friend -1=Enemy
		local demeanor = nil
		if (rand >= -1) then
			demeanor = "friendly"
		else
			demeanor = "enemy"
		end

		local knight = entity:new("silver_knight", demeanor, player.ox + 50, player.oy + 50, math.random(.3 * player.origSpeed, .7 * player.origSpeed), math.random(1, 10), nil, love.graphics.newImage("textures/entities/silver_knight.png"):getHeight()/2)
		table.insert(entities, knight)
		if (demeanor == "friendly") then table.insert(party, knight) end
		world:add(knight, knight.x, knight.y, knight.w, knight.h)
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
  	--[[if ( (player.y + player.h) > (table[i].y + table[i].h) ) then -- draws player on top if below entity
  		player:draw()
  	end]]
  end
end
function updateAll(table, dt)
	for i = 1, #table do
  	table[i]:update(dt)
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
  		love.graphics.rectangle("fill", camera.x+10+ w.x/minimapScale, camera.y+100+w.y/minimapScale, w.w/minimapScale, w.h/minimapScale)
  	end
  	for i=1, #entities do
  		local e = entities[i]
  		if (e == player) then
  			love.graphics.setColor(0, 0, 0, hud_opacity)
  		elseif (e.demeanor == "friendly") then
  			love.graphics.setColor(0, 255, 0, hud_opacity) 
  		elseif (e.demeanor == "enemy") then
  			love.graphics.setColor(255, 0, 0, hud_opacity)
  		else
  			love.graphics.setColor(255, 255, 255, hud_opacity)
  		end

  		love.graphics.circle("fill", camera.x + 10 + e.ox/minimapScale, camera.y + 100 + e.oy/minimapScale, 2)
  	end
  	love.graphics.setColor(0, 0, 0, hud_opacity)
  	love.graphics.setColor(255, 255, 255, 255)
end


function drawShadows()
	for i = 1, #entities do
		love.graphics.draw(shadow_img, entities[i].ox, entities[i].y + entities[i].h, 0, entities[i].scale, entities[i].scale, 4, 1.5) -- shadow
	end
end

function ysort(entityA, entityB)
    return (entityA.y + entityA.h) < (entityB.y + entityB.h)
end

function getAngle(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1)
end

function drawMainDebug(dt)
	local x, y = camera.x, camera.y

	debugInfo = {
		"FPS: "..love.timer.getFPS(),
		"#entities"..#entities,
		"MouseX: "..love.mouse.getPosition(),
		"playerX: "..player.x
	}
	for i = 1, #debugInfo do
  	love.graphics.print(debugInfo[i], x, y)
  	y = y + 15
  end
end