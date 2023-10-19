pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- bead-pbd.p8

#include lib/vector.p8
#include lib/actor.p8

physics = {
  gravity = vec(0, 1000),
  dt = 1 / 30,
  steps = 10,
  wire_center = vec(64,64),
  wire_radius = 32,
}
tick = 0

bead = actor:new(
  {
    pos = vec(64 + 32, 64),
    prev_pos = vec(0),
    vel = vec(0),
    draw = function(self)
      spr(self.sprite, self.pos.x - 4, self.pos.y - 4)
    end,
    start_step = function(self, dt, force)
      self.vel = self.vel + (dt * force)
      self.prev_pos = vec(self.pos.x, self.pos.y)
      self.pos += dt * self.vel
    end,
    keep_on_wire = function(self, center, radius)
      local dir, len, lambda
      dir = self.pos - center
      len = dir:length()
      if (len == 0) return nil;
      dir /= len
      lambda = physics.wire_radius - len
      self.pos += lambda * dir
      return lambda
    end,

    end_step = function(self, dt)
      self.vel = 1 / dt * (self.pos - self.prev_pos)
    end,
  },
  1,
  64 + 32, 64)

function _update()
  local sdt, lambda = physics.dt / physics.steps
  for step = 1, physics.steps do
    bead:start_step(sdt, physics.gravity)
    lambda = bead:keep_on_wire(physics.wire_center,
                               physics.wire_radius)
    bead:end_step(sdt)
  end

  tick += 1
end

function _draw()
  cls()
  circ(physics.wire_center.x,
       physics.wire_center.y,
       physics.wire_radius)
  bead:draw()
  -- print("tick "..tick, 0,0)

end

__gfx__
00000000008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
