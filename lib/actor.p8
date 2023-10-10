pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- actor.p8

actor = {
	k = nil, -- start sprite
	x = nil,
	y = nil,
	width = 1,
	height = 1,
	frame = 0,
	frames = 1,
}

-- make an actor
-- x,y means center of the actor
-- in map tiles
function actor:new(a, k, x, y)
  a = a or {}
  setmetatable(a, self)
  self.__index = self
  a.k = k or a.k
  a.x = x or a.x
  a.y = y or a.y
  return a
end

function actor:update()
end

function actor.draw(a)
	spr(a.k + (flr(a.frame) % a.frames) * a.width, a.x, a.y, a.width, a.height)
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