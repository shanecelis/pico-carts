pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- area-xpbd.p8

#include lib/vector.p8
#include lib/actor.p8
#include lib/repr.p8

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
      self.vel = self.vel + dt * self.w * force
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
  compliance = 0,
  particles = {},
  new = function(class, o)
    o = o or {}
    setmetatable(o, class)
    class.__index = class
    return o
  end,

  project = function(self, dt, lambda, ...)
    local c = self:eval(...)
    if (self.is_inequality and c<0 or c == 0) return
    local particles = select('#', ...) > 0 and {...} or self
    local grads = self:grad(...)
    assert(#grads == self.cardinality)
    -- assert(#self == self.cardinality)
    local s = 0
    local w = 0
    
    for i=1,self.cardinality do
      w += particles[i].w
      s += particles[i].w 
         * grads[i]:dot(grads[i])
    end
    local alpha = self.compliance / dt / dt
    s = (c - alpha * lambda) / (s + alpha)
    for i=1,self.cardinality do

      -- print("project delta "..repr(s * self[i].w * grads[i]).." c ".. c)
      -- stop()
      particles[i].pos -= s * particles[i].w * grads[i]
    end
  end,
  draw = function() end,
}

plane_constraint = constraint:new {
  n = vec(0, -1),
  r = vec(0, 120),
  is_inequality = true,
  eval = function(self, p)
    p = p or self[1]
    return self.n:dot(self.r - p.pos)
  end,
  grad = function(self, p)
    --p = p or self[1]
    -- stop("grad plane for "..tostr(self:eval(p)))
    return {-self.n}
  end,
  find_y = function(self, x)
    return (self.n:dot(self.r) - x * self.n.x) / self.n.y
  end,
  draw = function(self)
    local x1,x2 = 0, 128 * 8
    local y1,y2 = self:find_y(x1), self:find_y(x2)
    line(x1, y1, x2, y2)
  end,
}

distance_constraint = constraint:new {
  rest_length = 1,
  cardinality = 2,
  eval = function(self, a, b)
    a = a or self[1]
    b = b or self[2]
    return (a.pos - b.pos):length() - self.rest_length
  end,
  grad = function(self, a, b)
    a = a or self[1]
    b = b or self[2]
    local n = a.pos - b.pos
    n:normalize()
    return {n, -n}
  end,
  draw = function(self, a, b)
    a = a or self[1]
    b = b or self[2]
    line(a.pos.x, a.pos.y, b.pos.x, b.pos.y)
  end
}

area_constraint = constraint:new {
  rest_area = 1,
  cardinality = 4,
  eval = function(self, a, b, c, d)
    a = a or self[1]
    b = b or self[2]
    c = c or self[3]
    d = d or self[4]
    return square_area(a.pos, b.pos, c.pos, d.pos) - self.rest_area
  end,

  grad = function(self, a, b, c, d)
    a = a or self[1]
    b = b or self[2]
    c = c or self[3]
    d = d or self[4]
    local x1,x2,x3,x4 = a.pos,b.pos,c.pos,d.pos
    local grads = {(2 * x1 - x3 - x2),
            -(2 * x3 - x1 - x4),
            -(2 * x2 - x1 - x4),
            (2 * x4 - x3 - x2)}
    for grad in all(grads) do
      grad:normalize()
    end
    return grads
  end

}

function detect_collisions(ps)
  for p in all(ps) do
    plane_constraint:project(1/stat(8), 0, p)
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
    -- bead:new { pos = vec(64,64), w = 0 },
    bead:new { pos = vec(64,64), w = 1 },
    bead:new { pos = vec(74,64) },
    bead:new { pos = vec(64,74) },
    bead:new { pos = vec(74,74) }
  }
  local alpha = 0.0001
  -- active = { beads[2], beads[3], beads[4] }
  constraints = {
    distance_constraint:new {rest_length = 10, compliance = alpha, beads[1], beads[2]},
    distance_constraint:new {rest_length = 10, compliance = alpha, beads[1], beads[3]},
    distance_constraint:new {rest_length = 10, compliance = alpha, beads[2], beads[4]},
    distance_constraint:new {rest_length = 10, compliance = alpha, beads[3], beads[4]},
    area_constraint:new { 
    rest_area = 100, 
    compliance = alpha,
    beads[1], beads[2], beads[3], beads[4] }
  }
end

function _update()
  local sdt, lambda = physics.dt / physics.steps
  for step = 1, physics.steps do
    for bead in all(beads) do
      bead:start_step(sdt, physics.gravity)
    end
    for constraint in all(constraints) do
      constraint:project(1/stat(8), 0)
    end
    detect_collisions(beads)
    -- distance_joint(10, beads[1], beads[2])
    -- distance_joint(10, beads[1], beads[3])
    -- distance_joint(10, beads[2], beads[4])
    -- distance_joint(10, beads[3], beads[4])
    -- conserve_area(100, beads)
    --lambda = bead:keep_on_wire(physics.wire_center,
    for bead in all(beads) do
      bead:end_step(sdt)
    end
    --beads[1].pos = vec(64,64)
  end

  tick += 1
end

function _draw()
  cls()
  for bead in all(beads) do
    bead:draw()
  end

  for constraint in all(constraints) do
    constraint:draw()
  end
  plane_constraint:draw()
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
