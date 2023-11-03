pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- xpbd.p8

#include vector.p8

xpbd = {
  gravity = vec(0, 10),
  -- dt = 1 / 30,
  steps = 10,
  solver_steps = 1,
  -- particles = {},
  -- constraints = {},

  new = function(class, o)
    o = o or {}
    setmetatable(o, class)
    class.__index = class
    return o
  end,

  update = function(self)
    local dt,particles,constraints = 1/stat(8), self.particles, self.constraints
    local sdt, lambda = dt / self.steps, {}
    local collisions = detect_collisions(particles)
    for step = 1, self.steps do
      for particle in all(particles) do
        particle:start_step(sdt, self.gravity)
      end
      for i=1,self.solver_steps do
        local j = 1

        for constraint in all(constraints) do
          local l = lambda[j] or 0
          if #constraint > 0 then
            lambda[j] = l + constraint:project(sdt, l)
          else

          end
          j+=1
        end

        for constraint in all(collisions) do
          local l = lambda[j] or 0
          lambda[j] = l + constraint:project(sdt, l)
          j+=1
        end
      end

      for particle in all(particles) do
        particle:end_step(sdt)
      end

      for constraint in all(collisions) do
        constraint:resolve_collision()
      end
    end
  end
}

particle = {
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
    assert(#grads == self.cardinality, "grad did not match cardinality")
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


circle_constraint = constraint:new {
  radius = 100,
  pos = vec(64,64),
  -- is_inequality = true,
  -- restitution = 1,
  restitution = 0.8,
  damping = 0.5,
  eval = function(self, p)
    p = p or self[1]
    return (self.pos - p.pos):length() - self.radius
  end,
  grad = function(self, p)
    p = p or self[1]
    local dir = (self.pos - p.pos)
    dir:normalize()
    --p = p or self[1]
    -- stop("grad plane for "..tostr(self:eval(p)))
    return {-dir}
  end,
  draw = function(self)
    circ(self.pos.x, self.pos.y, self.radius, 7)
  end,
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

-->8
--

bead = particle:new {
    radius = 4,
    color = 8,

    draw = function(self)
      circfill(self.pos.x, self.pos.y, self.radius, self.color)
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
  -- what compliance? http://blog.mmacklin.com
  local alpha = 0.001 -- compliance
  local particles = {
    -- particle:new { pos = vec(64,64), w = 0 },
    particle:new { pos = vec(64,64), w = 1 },
    particle:new { pos = vec(74,64) },
    particle:new { pos = vec(64,74) },
    particle:new { pos = vec(74,74) }
  }
  squishy_sim = xpbd:new {
    particles = particles,
    constraints = {
      distance_constraint:new {rest_length = 10, compliance = alpha, particles[1], particles[2]},
      distance_constraint:new {rest_length = 10, compliance = alpha, particles[1], particles[3]},
      distance_constraint:new {rest_length = 10, compliance = alpha, particles[2], particles[4]},
      distance_constraint:new {rest_length = 10, compliance = alpha, particles[3], particles[4]},
      area_constraint:new {
      rest_area = 100,
      compliance = alpha,
      particles[1], particles[2], particles[3], particles[4] }
    }
  }

  local a_bead = bead:new {
    pos = vec(96, 64)
  }
  bead_sim = xpbd:new {
    particles = { a_bead },
    constraints = {
      circle_constraint:new { radius = 32, a_bead }
    }
  }

  local bead_count = 4
  local beads = {}
  local circle = circle_constraint:new { radius = 32 }
  for i =1, bead_count do
    local angle = rnd()
    local r = flr(rnd(3)) + 2
    local pos = circle.pos + circle.radius * vec(cos(angle), sin(angle))
    local b = bead:new { pos = pos, radius = r, w = 1/(3.14 * r * r), color = flr(rnd(15)) + 1 }
    add(beads, b)
    add(circle, b)
  end
  add(circle, a_bead)
  beads_sim = xpbd:new {
    particles = {a_bead},
    -- constraints = {}
    constraints = { circle },
  }

  sim = beads_sim
  -- sim = bead_sim
  -- sim = squishy_sim

end


function _update()
  sim:update()
end

function _draw()
  cls()
  for constraint in all(sim.constraints) do
    constraint:draw()
  end

  for particle in all(sim.particles) do
    particle:draw()
  end

end
