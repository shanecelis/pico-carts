pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- area-xpbd.p8

#include lib/vector.p8
#include lib/actor.p8

physics = {
  gravity = vec(0, 10),
  dt = 1 / 30,
  steps = 1,
  wire_center = vec(64,64),
  wire_radius = 32,
}
tick = 0
bead =
  {
    pos = vec(64 + 32, 64),
    prev_pos = vec(0),
    vel = vec(0),
    w = 1,
    new = function(class, o)
      o = o or {}
      setmetatable(o, class)
      class.__index = class
      return o
    end,
    draw = function(self)
      circfill(self.pos.x, self.pos.y, 2)
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
  }
  
function distance_joint(rest_length, a, b)
  local d = a.pos - b.pos
  local l = d:length()
  local c = l - rest_length
  local n = d/l
  local w = a.w + b.w
  a.pos -= a.w / w * c * n
  b.pos += b.w / w * c * n
end

constraint = {
  -- if true, eval() >= 0, otherwise eval(...) = 0.
  is_inequality = false,
  --eval = function(...) return c end,
  k = 0,
  cardinality = 1,
  particles = {},
  new = function(class, o)
    o = o or {}
    setmetatable(o, class)
    class.__index = class
    return o
  end,
}

plane_constraint = constraint:new {
  n = vec(0, -1),
  r = vec(0, 64),
  is_inequality = true,
  eval = function(self, p)
      return p.pos:dot(self.n - self.r)
  end,
  grad = function(self, p)
    return self.n
  end
}

function detect_collisions(ps)

  for p in all(ps) do
    if p.pos:dot(plane_n) - d >= 0 then
      -- add(constraints,
    end
  end
end
  
function conserve_area(a_rest, beads)
  local x1,x2,x3,x4 = beads[1].pos, beads[2].pos, beads[3].pos, beads[4].pos
  local del_c, c = calc_del_c(x1,x2,x3,x4)
  c = square_area(x1,x2,x3,x4) - a_rest
  local lambda = 0
--  for i=2,4 do
--    local absdc = del_c[i]:length()
--    lambda += absdc * absdc
--  end
  local w = 0
  for i=1,4 do
    w += beads[i].w
  end
  
  local alpha = 0.01
  lambda += alpha
  lambda = c
  for i=1,4 do
    local p = beads[i].pos
    local d = p + 10 * del_c[i]
--    line(p.x, p.y, d.x, d.y)
    beads[i].pos += lambda * beads[i].w / w * del_c[i]
  end
--  x1 += c * del_c[1]
--  x2 += c * del_c[2]
--  x3 += c * del_c[3]
--  x4 += c * del_c[4]
  return c
end
  
function tri_area(x1,x2,x3)
  return abs((x2 - x1):cross(x3 - x1))/2
end

function square_area(x1,x2,x3,x4)
  return tri_area(x1,x2,x3) + tri_area(x4,x2,x3)
end

function calc_del_c(x1, x2, x3, x4)
  local del_c = {}
  
  del_c[1] = -(2 * x1 - x3 - x2)
  del_c[2] = 2 * x3 - x1 - x4
  del_c[3] = 2 * x2 - x1 - x4
  del_c[4] = -(2 * x4 - x3 - x2)
  for dc in all(del_c) do
    dc:normalize()
  end
  return del_c
end

function _init()
  beads = {
    bead:new { pos = vec(64,64), w = 0 },
    bead:new { pos = vec(74,64) },
    bead:new { pos = vec(64,74) },
    bead:new { pos = vec(74,74) }
  }
  active = { beads[2], beads[3], beads[4] }
end

function _update()
  local sdt, lambda = physics.dt / physics.steps
  for step = 1, physics.steps do
    for bead in all(active) do
      bead:start_step(sdt, physics.gravity)
    end
    distance_joint(10, beads[1], beads[2])
    distance_joint(10, beads[1], beads[3])
    distance_joint(10, beads[2], beads[4])
    distance_joint(10, beads[3], beads[4])
    conserve_area(100, beads)
    --lambda = bead:keep_on_wire(physics.wire_center,
    for bead in all(active) do
      bead:end_step(sdt)
    end
    --beads[1].pos = vec(64,64)
  end

  tick += 1
end

function _draw()
  cls()
  circ(physics.wire_center.x,
       physics.wire_center.y,
       physics.wire_radius)
  for bead in all(beads) do
    bead:draw()
  end
--      conserve_area(100, beads)

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
