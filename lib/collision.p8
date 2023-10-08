pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-- wall and actor collisions
-- by zep

bouncy_actor = actor:new {
  dx = 0,
  dy = 0,
  t = 0,
  friction = 0.15,
  bounce  = 0.3,
  -- half-width and half-height
  -- slightly less than 0.5 so
  -- that will fit through 1-wide
  -- holes.
  w = 0.4, -- the physics width
  h = 0.4, -- the physics height
  collides_with = 1,
  bump_sfx = 2,
  actors = nil
}

-- for any given point on the
-- map, true if there is wall
-- there.

function bouncy_actor:is_solid(x, y)
  -- grab the cel value
  val=mget(x, y)

  -- check if flag 1 is set (the
  -- orange toggle button in the
  -- sprite editor)
  return fget(val, self.collides_with)
end

-- is_solid_area
-- check if a rectangle overlaps
-- with any walls

--(this version only works for
--actors less than one tile big)

function bouncy_actor:is_solid_area(x,y,w,h)
  return
    self:is_solid(x-w,y-h) or
    self:is_solid(x+w,y-h) or
    self:is_solid(x-w,y+h) or
    self:is_solid(x+w,y+h)
end


function bouncy_actor:add(actors)
  add(actors, self)
  self.actors = actors
end

function bouncy_actor:remove(actors)
  del(actors, self)
  self.actors = nil
end
-- true if [a] will hit another
-- actor after moving dx,dy

-- also handle bounce response
-- (cheat version: both actors
-- end up with the velocity of
-- the fastest moving actor)

function bouncy_actor.will_hit_solid_actor(a, dx, dy)
  for a2 in all(a.actors) do
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
            a:on_collision(a2) or
            a2:on_collision(a)
          return not ca
        end

        -- along y

        if (dy != 0 and abs(y) <
            abs(a.y-a2.y)) then
          v=abs(a.dy)>abs(a2.dy) and
            a.dy or a2.dy
          a.dy,a2.dy = v,v

          local ca=
            a:on_collision(a2) or
            a2:on_collision(a)
          return not ca
        end

      end
    end
  end

  return false
end


-- checks both walls and actors
function bouncy_actor.will_hit_solid(a, dx, dy)
  if a:is_solid_area(a.x+dx, a.y+dy,
                     a.w,    a.h)
  then
    return true
  else
    return a:will_hit_solid_actor(dx, dy)
  end
end

-- return true when something
-- was collected / destroyed,
-- indicating that the two
-- actors shouldn't bounce off
-- each other

function bouncy_actor.on_collision(a1,a2)

  -- -- player collects treasure
  -- if (a1==pl and a2.k==35) then
  --   del(actors,a2)
  --   sfx(3)
  --   return true
  -- end

  sfx(a1.bump_sfx) -- generic bump sound

  return false
end

function bouncy_actor.update(a)

  -- only move actor along x
  -- if the resulting position
  -- will not overlap with a wall

  if not a:will_hit_solid(a.dx, 0) then
    a.x += a.dx
  else
    a.dx *= -a.bounce
  end

  -- ditto for y

  if not a:will_hit_solid(0, a.dy) then
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

end

function control_player(pl)
  bouncy_actor.update(pl)

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

function is_adjacent(room1, room2)
  return (room1 == room2 - 1
       or room1 == room2 + 1
       or room1 == room2 + 8
       or room1 == room2 - 8)
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
  return flr(a.x/16) + 8 * flr(a.y/16)
end

function what_roomish(a)
  return (a.x/16) + 8 * (a.y/16)
end

-- function collision:draw()

--   cls(room_color[player_room + 1] or background_color)

--   room_x=flr(pl.x/16)
--   room_y=flr(pl.y/16)
--   camera(room_x*128,room_y*128)

--   map()
--   for a in all(actors) do
--     a:draw()
--   end
--   -- foreach(actors,actor.draw)
--   --replace_actors(actor[1])
-- end
