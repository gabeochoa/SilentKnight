cave_generator = { }

function cave_generator.create(world,x,y,air,times)
	local firstTime = love.timer.getTime( )
	if world[1]==nil or world[1][1]==nil then
		error("incorrect world! First Create a world.")
	end
	if world[1][1].type==nil then
		error("incorrect world! `.type` was edited.")
	end
	air = air or 15
	times = times or 999999
	cave_generator.restoreWorld(world,x,y)
	for i=1,times do
		ops1 = createWorld(world,air,x,y)
		ops2 = cave_generator.createHoles(world,x,y)
		if ops1==0 and ops2==0 then
			break
		end
	end
	local _deltatime = math.floor((love.timer.getTime()-firstTime)*10000)/10
	return true, _deltatime
end

function cave_generator.b(world,x,y)
	if world[x] and world[x][y] and world[x][y].type then
		return world[x][y].type
	end
end

function cave_generator.createHoles(world,x,y)
	local cave_generator_ops = 0
	for x=1,x do
		for y=1,y do
			if world[x][y].type==2 then
				local airs, nils = 0,0
				
				if cave_generator.b(world,x+1,y)==0 then
					nils = nils + 1
				end
				if cave_generator.b(world,x-1,y)==0 then
					nils = nils + 1
				end
				if cave_generator.b(world,x,y+1)==0 then
					nils = nils + 1
				end
				if cave_generator.b(world,x,y-1)==0 then
					nils = nils + 1
				end
				
				if cave_generator.b(world,x+1,y)==1 then
					airs = airs + 1
				elseif cave_generator.b(world,x-1,y)==1 then
					airs = airs + 1
				elseif cave_generator.b(world,x,y+1)==1 then
					airs = airs + 1
				elseif cave_generator.b(world,x,y-1)==1 then
					airs = airs + 1
				end
				
				if airs==1 and nils==3 then
					world[x][y].type = 1
					cave_generator_ops = cave_generator_ops + 1
				end
			end
		end
	end
	return cave_generator_ops
end

function createWorld(world,cavesize,x,y)
	local cave_generator_ops = 0
	for x=1,x do
		for y=1,y do
			if world[x][y].type==1 then
				if cave_generator.b(world,x,y+1)==0 then
					if love.math.random(1,cavesize)<=10 then
						world[x][y+1].type = 2
						cave_generator_ops = cave_generator_ops + 1
					else
						world[x][y+1].type = 1
						cave_generator_ops = cave_generator_ops + 1
					end
				end
				if cave_generator.b(world,x,y-1)==0 then
					if love.math.random(1,cavesize)<=10 then
						world[x][y-1].type = 2
						cave_generator_ops = cave_generator_ops + 1
					else
						world[x][y-1].type = 1
						cave_generator_ops = cave_generator_ops + 1
					end
				end
				if cave_generator.b(world,x+1,y)==0 then
					if love.math.random(1,cavesize)<=10 then
						world[x+1][y].type = 2
						cave_generator_ops = cave_generator_ops + 1
					else
						world[x+1][y].type = 1
						cave_generator_ops = cave_generator_ops + 1
					end
				end
				if cave_generator.b(world,x-1,y)==0 then
					if love.math.random(1,cavesize)<=10 then
						world[x-1][y].type = 2
						cave_generator_ops = cave_generator_ops + 1
					else
						world[x-1][y].type = 1
						cave_generator_ops = cave_generator_ops + 1
					end
				end
			end
		end
	end
	return cave_generator_ops
end

function cave_generator.restoreWorld(world,x,y)
	for _x=1,x do
		for _y=1,y do
			world[_x][_y].type = 0
		end
	end
	
	world[math.floor(x/2)+1][math.floor(y/2)+1].type = 1
end

function cave_generator.createWorld(x,y)
	world = { }
	for _x=1,x do
		world[_x] = { }
		for _y=1,y do
			world[_x][_y] = { }
			world[_x][_y].type = 0
		end
	end
	
	world[math.floor(x/2)+1][math.floor(y/2)+1].type = 1
	
	return world
end