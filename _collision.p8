pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-- wall and actor collisions
-- by zep

scene = {
}

function scene:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function scene:update()
end

function scene:draw()
end

--curr_scene

actor = {} -- all actors

-- make an actor
-- and add to global collection
-- x,y means center of the actor
-- in map tiles
function make_actor(k, x, y, is_add)
	a={
		k = k,
		x = x,
		y = y,
		width = 1,
		height = 1,
		dx = 0,
		dy = 0,		
		frame = 0,
		t = 0,
		friction = 0.15,
		bounce  = 0.3,
		frames = 2,
		
		-- half-width and half-height
		-- slightly less than 0.5 so
		-- that will fit through 1-wide
		-- holes.
		w = 0.4,
		h = 0.4,
		update = function(a) end,
		is_sprite = function(a, s)
			return s >= a.k and s < a.k + a.frames
		end
	}
	
	if (is_add == undefined or is_add)	add(actor,a)
	
	return a
end

--function page:new(o)
--  o = o or {}
--  setmetatable(o, self)
--  self.__index = self
--  return o
--end

function scan_map(f)
  local result = {}
  for x = 0,127 do
    for y = 0,31 do
      if f(mget(x,y)) then
        add(result, {x, y})
      end
    end
  end
  return result
end

function replace_actors(a)
 
  for place in all(scan_map(function (k) return a:is_sprite(k) end)) do
    mset(place[1], place[2], 0)
    o = {}
    setmetatable(o, a)
    a.__index = a
    o.x = place[1]
    o.y = place[2]

    add(actor,o)
  end
end

function _init()
	-- create some actors
	
	-- make player
	-- bunny
	pl = make_actor(21,2,2,false)
	pl.frames=4
	pl.update=random_actor
	replace_actors(pl)

	-- donkey
	pl = make_actor(107,2,2,false)
	pl.frames=4
	pl.update=random_actor
	replace_actors(pl)

	pl = make_actor(41,2,2,false)
	pl.frames=4
	replace_actors(pl)

	pl = make_actor(37,2,2,false)
	replace_actors(pl)

	-- pl = make_actor(9,2,2)
	-- princess peach
	pl = make_actor(96,2,2)
	-- pl = make_actor(96,68,22)
	pl.height=2
	pl.width=2
	pl.w *= 2
	pl.h *= 2
	pl.frames=4
	replace_actors(pl)

	-- bouncy ball
	local ball = make_actor(33,8.5,11)
	ball.dx=0.05
	ball.dy=-0.1
	ball.friction=0.02
	ball.bounce=1
	replace_actors(ball)

	-- red ball: bounce forever
	-- (because no friction and
	-- max bounce)
	local ball = make_actor(49,22,20)
	ball.dx=-0.1
	ball.dy=0.15
	ball.friction=0
	ball.bounce=1
--	?ball:is_sprite(50)
	replace_actors(ball)
--	stop()
--	break
	-- treasure
	
	for i=0,16 do
		a = make_actor(35,8+cos(i/16)*3,
		    10+sin(i/16)*3)
		a.w=0.25 a.h=0.25
	end
	replace_actors(a)

	-- blue peopleoids
	
	a = make_actor(5,7,5)
	a.frames=4
	a.dx=1/8
	a.friction=0.1
	-- a.update=follow_actor(pl)
	a.update=follow_actor(ball)
	replace_actors(a)

	-- purple guys
	a = make_actor(204,7,5,false)
	a.frames=4
	a.update=follow_actor(ball)
	a.dx=1/8
	a.friction=0.1
	replace_actors(a)


	a = make_actor(17,7,5,false)
	a.update=follow_actor(ball)
	a.dx=1/8
	a.friction=0.1
	replace_actors(a)


	for i=1,6 do
	 a = make_actor(5,20+i,24)
	 a.update=follow_actor(ball)
	 a.frames=4
	 a.dx=1/8
	 a.friction=0.1
	end
	
end

-- for any given point on the
-- map, true if there is wall
-- there.

function solid(x, y)
	-- grab the cel value
	val=mget(x, y)
	
	-- check if flag 1 is set (the
	-- orange toggle button in the 
	-- sprite editor)
	return fget(val, 1)
	
end

-- solid_area
-- check if a rectangle overlaps
-- with any walls

--(this version only works for
--actors less than one tile big)

function solid_area(x,y,w,h)
	return 
		solid(x-w,y-h) or
		solid(x+w,y-h) or
		solid(x-w,y+h) or
		solid(x+w,y+h)
end


-- true if [a] will hit another
-- actor after moving dx,dy

-- also handle bounce response
-- (cheat version: both actors
-- end up with the velocity of
-- the fastest moving actor)

function solid_actor(a, dx, dy)
	for a2 in all(actor) do
		if a2 != a then
		
			local x=(a.x+dx) - a2.x
			local y=(a.y+dy) - a2.y
			
			if ((abs(x) < (a.w+a2.w)) and
					 (abs(y) < (a.h+a2.h)))
			then
				
				-- moving together?
				-- this allows actors to
				-- overlap initially 
				-- without sticking together    
				
				-- process each axis separately
				
				-- along x
				
				if (dx != 0 and abs(x) <
				    abs(a.x-a2.x))
				then
					
					v=abs(a.dx)>abs(a2.dx) and 
					  a.dx or a2.dx
					a.dx,a2.dx = v,v
					
					local ca=
					 collide_event(a,a2) or
					 collide_event(a2,a)
					return not ca
				end
				
				-- along y
				
				if (dy != 0 and abs(y) <
					   abs(a.y-a2.y)) then
					v=abs(a.dy)>abs(a2.dy) and 
					  a.dy or a2.dy
					a.dy,a2.dy = v,v
					
					local ca=
					 collide_event(a,a2) or
					 collide_event(a2,a)
					return not ca
				end
				
			end
		end
	end
	
	return false
end


-- checks both walls and actors
function solid_a(a, dx, dy)
	if solid_area(a.x+dx,a.y+dy,
				a.w,a.h) then
				return true end
	return solid_actor(a, dx, dy) 
end

-- return true when something
-- was collected / destroyed,
-- indicating that the two
-- actors shouldn't bounce off
-- each other

function collide_event(a1,a2)
	
	-- player collects treasure
	if (a1==pl and a2.k==35) then
		del(actor,a2)
		sfx(3)
		return true
	end
	
	sfx(2) -- generic bump sound
	
	return false
end

function move_actor(a)
	if (what_room(a) != player_room) return

	-- only move actor along x
	-- if the resulting position
	-- will not overlap with a wall

	if not solid_a(a, a.dx, 0) then
		a.x += a.dx
	else
		a.dx *= -a.bounce
	end

	-- ditto for y

	if not solid_a(a, 0, a.dy) then
		a.y += a.dy
	else
		a.dy *= -a.bounce
	end
	
	-- apply friction
	-- (comment for no inertia)
	
	a.dx *= (1-a.friction)
	a.dy *= (1-a.friction)
	
	-- advance one frame every
	-- time actor moves 1/4 of
	-- a tile
	
	a.frame += abs(a.dx) * 4
	a.frame += abs(a.dy) * 4
	a.frame %= a.frames

	a.t += 1

	a:update()
	
end

function control_player(pl)

	accel = 0.05
	if (btn(0)) pl.dx -= accel 
	if (btn(1)) pl.dx += accel 
	if (btn(2)) pl.dy -= accel 
	if (btn(3)) pl.dy += accel 
	
end

function random_actor(a)
	if rnd(1) < 0.1  then
		accel = 0.05
		a.dx += accel * (rnd(2) - 1)
		a.dy += accel * (rnd(2) - 1)
	end
end


function follow_actor(follow)
	return function(a)
		if rnd(1) < 0.1 then
			local x = sgn(follow.x - a.x)
			local y = sgn(follow.y - a.y)
			if what_room(a) != what_room(follow) then
				x = 0
				y = 0
			end
			accel = 0.05
			a.dx += accel * (x + (rnd(2) - 1))
			a.dy += accel * (y + (rnd(2) - 1))
		end
	end
end

collision = scene:new()

function collision:update()
	control_player(pl)
	player_room = what_room(pl)
	foreach(actor, move_actor)
end

function draw_actor(a)
	local sx = (a.x * 8) - 4
	local sy = (a.y * 8) - 4
	spr(a.k + flr(a.frame) * a.width, sx, sy, a.width, a.height)
end

function what_room(a)
	return flr(a.x/16) + 8 * flr(a.y/16)
end

function collision:draw()
	cls(background_color)
	
	room_x=flr(pl.x/16)
	room_y=flr(pl.y/16)
	camera(room_x*128,room_y*128)
	
	map()
	foreach(actor,draw_actor)
	--replace_actors(actor[1])
end

title = scene:new()


function title:draw()
	camera(7 * 128, 0)
	map()
end


function title:update()
--	if (btnp()) curr_scene = collision
end

curr_scene = title

function _update()
	curr_scene:update()
end

function _draw()
	curr_scene:draw()
end
