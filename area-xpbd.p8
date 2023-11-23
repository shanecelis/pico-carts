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
  steps = 10,
  solver_steps = 1,
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
    end_step = function(self, dt)
      self.vel = (self.pos - self.prev_pos) / dt
    end,
  }
  
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

  is_violated = function(self, ...)
    local c = self:eval(...)
    return not (self.is_inequality and c<0 or c == 0)
  end,

  project = function(self, dt, lambda, ...)
    local c = self:eval(...)
    if (self.is_inequality and c<0 or c == 0) return 0
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
    -- local deltas = {}
    for i=1,self.cardinality do

      -- print("project delta "..repr(s * self[i].w * grads[i]).." c ".. c)
      -- stop()
      particles[i].pos -= s * particles[i].w * grads[i]
      -- deltas[i] = s * particles[i].w * grads[i]
    end
    return s
  end,
  draw = function() end,
}

plane_constraint = constraint:new {
  n = vec(0, -1),
  r = vec(0, 120),
  is_inequality = true,
  -- restitution = 1,
  restitution = 0.8,
  damping = 0.5,
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
  resolve_collision = function(self, n, p)
    p = p or self[1]
    n = n or self.n
    -- p.vel -= (1 - self.restitution) * n:dot(p.vel) * n
    p.vel = n:dot(p.vel)*self.damping * self.restitution * n + (1 - self.damping) * p.vel
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
  local list = {}
  for p in all(ps) do
    if plane_constraint:is_violated(p) then
      add(list,
          plane_constraint:new { p })
    end
  end
  return list
end

function tri_area(x1,x2,x3)
  return abs((x2 - x1):cross(x3 - x1))/2
end

function square_area(x1,x2,x3,x4)
  return tri_area(x1,x2,x3) + tri_area(x4,x2,x3)
end

function _init()
  beads = {
    -- bead:new { pos = vec(64,64), w = 0 },
    bead:new { pos = vec(64,64), w = 1 },
    bead:new { pos = vec(74,64) },
    bead:new { pos = vec(64,74) },
    bead:new { pos = vec(74,74) }
  }
  -- what compliance? http://blog.mmacklin.com
  -- local alpha = 0
  -- local alpha = 0.0001
  local alpha = 0.001
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

  local dt = 1/stat(8)
  local sdt, lambda = dt / physics.steps, {}
  local collisions = detect_collisions(beads)
  for step = 1, physics.steps do
    for bead in all(beads) do
      bead:start_step(sdt, physics.gravity)
    end
    for i=1,physics.solver_steps do
      local j = 1

      for constraint in all(constraints) do
        local l = lambda[j] or 0
        -- assert(l ~= nil)
        lambda[j] = l + constraint:project(sdt, l)
        j+=1
      end

      for constraint in all(collisions) do
        local l = lambda[j] or 0
        lambda[j] = l + constraint:project(sdt, l)
        -- constraint:project(sdt, 0)
        j+=1
      end
    end

    for bead in all(beads) do
      bead:end_step(sdt)
    end

    for constraint in all(collisions) do
      constraint:resolve_collision()
    end
  end
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
