pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-- actor.p8

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
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
