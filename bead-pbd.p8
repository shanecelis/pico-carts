pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- bead-pbd.p8

#include lib/vector.p8

physics = {
  gravity = vec(0, 1000),
  dt = 1 / 30,
  steps = 10,
  wire_center = vec(64,64),
  wire_radius = 32,
  restitution = 1
}
tick = 0
bead_count = 4

bead = {
    pos = vec(64 + 32, 64),
    prev_pos = vec(0),
    vel = vec(0),
    radius = 4,
    mass = 1,
    color = 8,

    new = function(class, o)
      o = o or {}
      setmetatable(o, class)
      class.__index = class
      return o
    end,

    draw = function(self)
      circfill(self.pos.x, self.pos.y, self.radius, self.color)
      -- spr(self.sprite, self.pos.x - 4, self.pos.y - 4)
    end,

    start_step = function(self, dt, force)
      self.vel = self.vel + force * dt

      self.prev_pos = vec(self.pos.x, self.pos.y)
      -- self.prev_pos.x, self.prev_pos.y = self.pos.x, self.pos.y
      self.pos = self.pos + self.vel * dt
    end,

    keep_on_wire = function(self, center, radius)
      local dir, len, lambda
      dir = self.pos - center
      len = dir:length()
      if (len == 0) return nil;
      dir /= len
      lambda = radius - len
      self.pos += lambda * dir
      return lambda
    end,

    end_step = function(self, dt)
      self.vel = 1 / dt * (self.pos - self.prev_pos)
    end,

    collide = function(bead1, bead2)
      local restitution = physics.restitution
      local dir = bead1.pos - bead2.pos
      local d = dir:length()
      if (d == 0.0 or d > bead1.radius + bead2.radius) return
      dir /= d
      local corr = (bead1.radius - bead2.radius - d) / 2
      bead1.pos += -corr * dir
      bead2.pos +=  corr * dir
      local v1, v2 = bead1.vel:dot(dir), bead2.vel:dot(dir)
      local m1, m2 = bead1.mass, bead2.mass
      local v1p = (m1 * v1 + m2 * v2 - m2 * (v1 - v2) * restitution) / (m1 + m2)
      local v2p = (m1 * v1 + m2 * v2 - m1 * (v2 - v1) * restitution) / (m1 + m2)
      bead1.vel += (v1p - v1) * dir
      bead2.vel += (v2p - v2) * dir
    end
  }

function _init()
  beads = {}
  for i =1, bead_count do
    local angle = rnd()
    local r = flr(rnd(3)) + 2
    local pos = physics.wire_center + physics.wire_radius * vec(cos(angle), sin(angle))
    add(beads, bead:new { pos = pos, radius = r, mass = 3.14 * r * r, color = flr(rnd(15)) + 1 })
  end

end

function _update60()
  local dt = 1 / stat(8)
  local sdt, lambda = dt / physics.steps
  for step = 1, physics.steps do
    for bead in all(beads) do
      bead:start_step(sdt, physics.gravity)
    end
    for bead in all(beads) do
      lambda = bead:keep_on_wire(physics.wire_center,
                                 physics.wire_radius)
    end
    for bead in all(beads) do
      bead:end_step(sdt)
    end
    for i=2,#beads do
      for j=1, i - 1 do
        -- print("collide "..i.." "..j)
        beads[i]:collide(beads[j])
      end
    end
    -- stop()
  end

  tick += 1
end

function _draw()
  cls()
  circ(physics.wire_center.x,
       physics.wire_center.y,
       physics.wire_radius,
       7)

  for bead in all(beads) do
    bead:draw()
  end

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
