function love.load()
	require 'camera'; require 'AnAL'; require 'player'; require 'knight'; require 'wall'
	local bump = require 'bump'
	------------------------------------------------------------------------------------------ System Setup
	love.keyboard.setKeyRepeat( false )
	love.graphics.setBackgroundColor( 200, 0, 0 )

	player = player:new("silver", 600, 200, nil, nil, nil, 5)
	entities = { player }

	currentlySelected = player

  -- [ Animations ] --
  --boom_anim = newAnimation(love.graphics.newImage("textures/anims/explosion.png"), 96, 96, 0.1, 0)
  --boom_anim:setMode("bounce")


  	-- Global stuff (not variables)
 	shadow_img = love.graphics.newImage("textures/misc/shadow.png"); shadow_img:setFilter("nearest")
  
  ------------------------------------------------------------------------------------------ Global Variables
	start_time = love.timer.getTime() -- Uptime of program
	isDebugging = true
	math.randomseed(os.time())
	windowW = love.graphics.getWidth()

	-- Mouse stuff
	cursor = love.mouse.newCursor("textures/misc/cursor_sword.png", 0, 0)
	love.mouse.setCursor(cursor)

  	----- bump world
  	world = bump.newWorld()

  	party = {player}
  	walls = {}

  	world:add(player, player.x, player.y, player.w, player.h)
  	for i=1, 10 do
  		local wall = wall:new(i * 300, 200, 200, 100)
  		table.insert(walls, wall)
  		 world:add(wall, wall.x, wall.y, wall.w, wall.h)
  	end
  	

end



function love.update(dt)
	--------------------

	updateAll(entities, dt)
	table.sort(entities, ysort) -- organizes all entities from least to greatest y-value


	--------------------
	camera:update(dt)
end

function love.draw(dt)
	camera:set()
	--------------------


	drawShadows()
	drawAll(walls, dt)
	drawAll(entities, dt)

	------------------------------------- GUI
	local xOff, yOff = 0, 0 -- offsets
	for i=1, #party do
		
		e = party[i]
		love.graphics.draw(e.img, camera.x + 10 + xOff, camera.y + 10, 0, 5, 5)
		love.graphics.rectangle("line", camera.x + 10 + xOff, camera.y + 70, e.health/2, 5)
		love.graphics.rectangle("line", camera.x + 10 + xOff, camera.y + 80, e.stamina/2, 5)

		xOff = xOff + 60
	end
	love.graphics.setColor( 0, 255, 255)
	
	love.graphics.setColor( 255, 255, 255)
	----------------------------------------

	--------------------
	love.graphics.print("FPS: "..love.timer.getFPS(), camera.x + 500, camera.y) -- 450
	love.graphics.line(love.graphics.getWidth()/2, 0, love.graphics.getWidth()/2, love.graphics.getHeight() )
	love.graphics.line(0, love.graphics.getHeight()/2, love.graphics.getWidth(), love.graphics.getHeight()/2 )
  	--if isDebugging then drawMainDebug() end

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

	if key == (' ') then
		local random = math.random(1,3); local color

		if (random == 1) then color = "gold"
		elseif (random == 2) then color = "silver"
		else color = "iron" end
		local knight = knight:new(color, love.mouse.getX(), love.mouse.getY(), math.random(.3 * player.origSpeed, .7 * player.origSpeed), math.random(1, 10), nil, love.graphics.newImage("textures/entities/knight_"..color..".png"):getHeight()/2)
		table.insert(entities, knight)
		table.insert(party, knight)
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