pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-- wall and actor collisions
-- by zep

scene = {
}

intro_message = intro_message or { "hi there" }
debug = debug or false
credits_text = [[cardboard toad

by ryland
]] or credits_text

room_color = {}
room_color[1] = 1
player_room = -1
toad_distance = 5

function scene:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function scene:enter()
end

function scene:update()
end

function scene:draw()
end

-- all actors
actors = {}

actor = {
	k = nil,
	x = nil,
	y = nil,
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
}

-- make an actor
-- and add to global collection
-- x,y means center of the actor
-- in map tiles
function actor:new(a, k, x, y)
  a = a or {}
  setmetatable(a, self)
  self.__index = self
  a.k = k or a.k
  a.x = x or a.x
  a.y = y or a.y
  -- if (is_add == undefined or is_add) add(actors,a)
  return a
end

function actor:update()
end

function actor.draw(a)
	local sx = (a.x * 8) - 4
	local sy = (a.y * 8) - 4
	spr(a.k + flr(a.frame) * a.width, sx, sy, a.width, a.height)
end


function actor.is_sprite(a, s)
	return s >= a.k and s < a.k + a.frames
end

function enter_room(room)
	if room == 12 then
		-- mario's room

	end

	if room == 1 then
		-- mario's room
		curr_scene.text = {
			[[hi, i'm a mario.]],
			[[let's hit this pinata!]]
		}
	end

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
	if (mget(place[1], place[2]) == 0) return
	for x=0,a.width - 1 do
		for y=0,a.height - 1 do
			mset(place[1] + x, place[2] + y, 0)
		end
	end
	o = a:new({})
	-- o = a.clone()
    -- o = {}
    -- setmetatable(o, a)
    -- o.__index = a
    o.x = place[1]
    o.y = place[2]

    add(actors,o)
  end
end

function confetti()

 local left = emitter.create(0, 0, 5, 10, false, false)
 ps_set_size(left, 0, 0, 1)
 ps_set_speed(left, 10, 20, 10)
 ps_set_colours(left, {7, 8, 9, 10, 11, 12, 13, 14, 15})
 ps_set_rnd_colour(left, true)
 ps_set_life(left, 0.4, 1)
 ps_set_angle(left, 30, 45)
 return left
end


function stars()

  local my_emitters = emitters:new()
  local front = emitter.create(0, 64, 0.2, 0)
  ps_set_area(front, 0, 128)
  ps_set_colours(front, {7})
  ps_set_size(front, 0)
  ps_set_speed(front, 34, 34, 10)
  ps_set_life(front, 3.5)
  ps_set_angle(front, 0, 0)
  add(my_emitters, front)
  local midfront = front.clone(front)
  ps_set_frequency(midfront, 0.15)
  ps_set_life(midfront, 4.5)
  ps_set_colours(midfront, {6})
  ps_set_speed(midfront, 26, 26, 5)
  add(my_emitters, midfront)
  local midback = front.clone(front)
  ps_set_life(midback, 6.8)
  ps_set_colours(midback, {5})
  ps_set_speed(midback, 18, 18, 5)
  ps_set_frequency(midback, 0.1)
  add(my_emitters, midback)
  local back = front.clone(front)
  ps_set_frequency(back, 0.07)
  ps_set_life(back, 11)
  ps_set_colours(back, {1})
  ps_set_speed(back, 10, 10, 5)
  add(my_emitters, back)
  local special = emitter.create(64, 64, 0.2, 0)
  ps_set_area(special, 128, 128)
  ps_set_angle(special, 0, 0)
  ps_set_frequency(special, 0.01)
  -- ps_set_sprites(special, {78, 79, 80, 81, 82, 83, 84})
  ps_set_sprites(special, {107, 108, 109, 110})
  ps_set_speed(special, 30, 30, 15)
  ps_set_life(special, 5)
  add(my_emitters, special)
  local front = emitter.create(0, 64, 0.2, 0)
  ps_set_area(front, 0, 128)
  ps_set_colours(front, {7})
  ps_set_size(front, 0)
  ps_set_speed(front, 34, 34, 10)
  ps_set_life(front, 3.5)
  ps_set_angle(front, 0, 0)
  add(my_emitters, front)
  return my_emitters
end

actor_with_particles = actor:new {
  emitter = nil
}

function actor_with_particles:new(o, k, x, y)
  o = actor.new(self, o, k, x, y)
  if (o.emitter) o.emitter = o.emitter:clone()
  return o
end

function actor_with_particles:update()
	actor.update(self)
	if self.emitter then
		self.emitter.pos.x = self.x * 8 - 4
		self.emitter.pos.y = self.y * 8 - 4
		self.emitter.p_angle = atan2(-self.dx, -self.dy)
		self.emitter:update(delta_time)
	end
end
function actor_with_particles:draw()
	actor.draw(self)
	if (self.emitter) self.emitter:draw()
end

function _init()


 prev_time = time()
	-- create some actors

	-- make player
	-- bunny
	pl = actor:new({},220,2,2,false)
	pl.frames=4
	pl.update=random_actor
	replace_actors(pl)
	-- add(actors, pl)


	-- donkey
	-- pl = actor:new({},107,2,2,false)
	-- pl.frames=4
	-- pl.update=random_actor
	-- replace_actors(pl)

	-- pl = actor:new({},41,2,2,false)
	-- pl.frames=4
	-- replace_actors(pl)

	pl = actor:new({},37,2,2,false)
	replace_actors(pl)

	-- pl = actor:new({},9,2,2)
	-- princess peach
  -- peach_sprite = peach_sprite or 96
	pl = actor:new({},23,2,2)
	-- pl = actor:new({},96,68,22)
	pl.height=1
	pl.width=1
	pl.w *= 1
	pl.h *= 1
	pl.frames=1
	add(actors, pl)
	-- replace_actors(pl)

	fairy = actor:new({},14)
	fairy.frames=2
	-- add(actors, fairy)
	replace_actors(fairy)


	pinata = actor_with_particles:new({
			emitter = confetti(),

			follow = follow_actor(pl, -0.10)
					}, 107,2,2, false)
	-- pl = actor:new({},96,68,22)
	pinata.frames=4
	-- pinata.update=follow_actor(pl, -0.10)
	function pinata:update()
		actor_with_particles.update(self)
		local mhspd = abs(self.dx) + abs(self.dy)
		self.emitter.emitting = mhspd > 0.2
		self.follow(self)
	end
	function pinata:draw()
		actor_with_particles.draw(self)

	end
	replace_actors(pinata)


	bowser = actor:new({},165,2,2, false)
	-- bowser = actor:new({},96,68,22)
	bowser.height=2
	bowser.width=2
	bowser.w *= 2
	bowser.h *= 2
	bowser.frames=2
	bowser.update=random_actor
	replace_actors(bowser)

	luigi = actor:new({},208,2,2, false)
	luigi.height=3
	luigi.width=2
	luigi.w *= 2
	luigi.h *= 3
	luigi.frames=1
	-- luigi.update=random_actor
	replace_actors(luigi)

	mario = actor:new({},144,2,2, false)
	mario.height=3
	mario.width=2
	mario.w *= 2
	mario.h *= 3
	mario.frames=1
	-- mario.update=random_actor
	replace_actors(mario)

	-- toad = actor:new({},169,2,2, false)
	-- -- toad = actor:new({},96,68,22)
	-- toad.height=2
	-- toad.h *= 2
	-- toad.frames=4
	-- toad.follow=follow_actor(pl)
	-- toad.distance=5
	-- function toad:update()
	-- 	if (mhdistance(pl, self) > toad_distance) self:follow()
	-- end
	-- replace_actors(toad)

	-- bouncy ball
	ball = actor:new({},33,8.5,11)
	ball.dx=0.05
	ball.dy=-0.1
	ball.friction=0.02
	ball.bounce=1
	add(actors, ball)
	replace_actors(ball)

	-- red ball: bounce forever
	-- (because no friction and
	-- max bounce)
	ball = actor:new({},49,22,20)
	ball.dx=-0.1
	ball.dy=0.15
	ball.friction=0
	ball.bounce=1
	add(actors, ball)
--	?ball:is_sprite(50)
	replace_actors(ball)
--	stop()
--	break
	-- treasure
	-- for i=0,16 do
	local i = 0
	a = actor:new({},35,8+cos(i/16)*3,
						10+sin(i/16)*3)
		-- add(actors, a)
	a.w=0.25 a.h=0.25
	-- end
	replace_actors(a)

	a = actor:new({},52,8+cos(i/16)*3,
						10+sin(i/16)*3)
		-- add(actors, a)
	a.w=0.25 a.h=0.25
	a.frames = 1
	-- end
	replace_actors(a)

	-- blue peopleoids
	a = actor:new({},91,7,5)
	a.frames=4
	a.dx=1/8
	a.friction=0.1
	-- a.update=follow_actor(pl)
	a.update=follow_actor(ball)
	-- add(actors, a)
	replace_actors(a)

	-- purple guys
	a = actor:new({},204,7,5,false)
	a.frames=4
	a.update=follow_actor(ball)
	a.dx=1/8
	a.friction=0.1
	replace_actors(a)

	-- cool guy
	a = actor:new({},17,7,5,false)
	a.update=follow_actor(ball)
	a.dx=1/8
	a.friction=0.1
	replace_actors(a)


	-- for i=1,6 do
	--  a = actor:new({},91,20+i,24)
	--  a.update=follow_actor(ball)
	--  a.frames=4
	--  a.dx=1/8
	--  a.friction=0.1
	-- 	add(actors, a)
	-- end

	if (my_init) my_init()
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
	for a2 in all(actors) do
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
		del(actors,a2)
		sfx(3)
		return true
	end
	
	sfx(2) -- generic bump sound
	
	return false
end

function actor.move(a)
	local r = what_room(a)
	if (r == player_room
	    or is_adjacent(r, player_room)) then
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


function follow_actor(follow, accel)
	return function(a)
		if rnd(1) < 0.1 then
			local x = sgn(follow.x - a.x)
			local y = sgn(follow.y - a.y)
			-- if what_room(a) != what_room(follow) then
			-- 	x = 0
			-- 	y = 0
			-- end
			accel = accel or 0.05
			a.dx += accel * (x + (rnd(2) - 1))
			a.dy += accel * (y + (rnd(2) - 1))
		end
	end
end

collision = scene:new({})

function is_adjacent(room1, room2)
	return (room1 == room2 - 1
		 or room1 == room2 + 1
		 or room1 == room2 + 8
		 or room1 == room2 - 8)
end

function collision:update()
	control_player(pl)
	local current_player_room = what_room(pl)
	if (current_player_room != player_room) enter_room(current_player_room)
	player_room = current_player_room
	-- foreach(actors, actor.move)

	for a in all(actors) do
		a:move()
	end

end

-- function distance(a1, a2)
-- 	return sqrt((a1.x - a2.x)^2 + (a1.y - a2.y)^2)
-- end

-- function sqdistance(a1, a2)
-- 	return (a1.x - a2.x)^2 + (a1.y - a2.y)^2
-- end

function mhdistance(a1, a2)
	return abs(a1.x - a2.x) + abs(a1.y - a2.y)
end

function what_room(a)
	return flr(a.x/16) + 8 * flr(a.y/16) + 1
end

function what_roomish(a)
	return (a.x/16) + 8 * (a.y/16)
end

function collision:draw()

	cls(room_color[player_room] or background_color)
	
	room_x=flr(pl.x/16)
	room_y=flr(pl.y/16)
	camera(room_x*128,room_y*128)

	map()
	for a in all(actors) do
		a:draw()
	end
	-- foreach(actors,actor.draw)
	--replace_actors(actor[1])
end


dialog = collision:new({ text = nil, message = nil, origin = {0, 0} })

function dialog:update()
	local m = self:get_message()

	if (m == nil) then
		collision.update(self)
		return
	end
	m:update()
	if m:is_complete() then
		if (self.on_complete) self:on_complete()
		self.on_complete = nil
		self.message = nil
		self.text = nil
	end

end

function dialog:get_message()
	if self.message == nil and self.text ~= nil then
		self.message = message:new({}, self.text)
	end
	return self.message
end

function rectborder(x0, y0, w, h, fill, border)
	rectfill(x0, y0, x0 + w, y0 + h, fill)
	rect    (x0, y0, x0 + w, y0 + h, border)
end

function dialog:draw()
	collision.draw(self)
	camera(0, 0)
	local border = 10
	if (debug) print("room " .. what_room(pl), border, border, 7)
	local m = self:get_message()
	if (m == nil) return

	rectborder(border + self.origin[1], border + self.origin[2], 128 - 2 * border, 44, 7, 6)
	m:draw(self.origin[1] + border * 1.5, self.origin[2] + 1.5 * border)
end


title = scene:new({})

cart_screen = false

function title:get_message()
	if self.message == nil then
		self.message = message:new({}, intro_message)
	end
	return self.message
end

function title:draw()
	cls()
	-- palt(0, true)
	camera(7 * 128, 0)
	map()
	camera(0, 0)
	local border = 10
	if cart_screen then
		print("by ryland von hunter", 24, 90, 7)
		print("(c) 2023-02-28", 24, 100, 7)
	else
		rectfill(border, 64 + border, 127 - border, 127 - border, 7)
		rect(border, 64 + border, 127 - border, 127 - border, 6)
		line(border, 64 + border,
			63, 64 + 3 * border, 6)

		line(63, 64 + 3 * border,
			127 - border, 64 + border, 6)

		title:get_message():draw(border * 1.5, 64 + 1.5 * border)
	end

end


function title:update()
	local m = title:get_message()
	m:update()
	-- if (m:is_complete() and btnp(5)) curr_scene = collision
	if (m:is_complete() and btnp(5)) curr_scene = dialog
end

credits = scene:new {
	emitter = stars(),
	-- x = 25,
	x = 35,
	y = 145,
	t = 0,
	f = 0,
	speed = -4,
}

function title:enter()
	music(4, 600)
end

function credits:enter()
	music(4, 600)
end

function credits:update()
	self.f += 1
	self.t += self.speed * delta_time
	self.emitter:update(delta_time)
end

function credits:draw()
	cls(0)
	self.emitter:draw()
	if (self.f < 100) then
		rectfill(0,0, 128 - self.f, 128, 0)
		print("the end", 50, 64, 7)
	end
	print(credits_text, self.x, self.t + self.y)
end

curr_scene = title
curr_scene:enter()
-- curr_scene = credits

function _update()
 if curr_scene.text == nil then
	update_time()
	coroutines:update()
 end
	curr_scene:update()
end

function _draw()
	curr_scene:draw()
end
