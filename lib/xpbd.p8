pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- copyright (c) 2023 shane celis[1]
-- released under the mit license[2]
--
-- xpbd.p8
--   page 0, library - 1368 tokens
--   page 1, demo    -  698 tokens
--
-- eXtended Position Based
-- Dynamics (xpbd)
--
-- # demo
--
-- * a single bead on a ring
-- * multiple beads on a ring
-- * a squishy square
-- * an about page with particles
--
-- the bead examples are ports
-- of matthias muller's [ten
-- minute physics][10min]
-- examples.
--
-- # usage
--
-- include the first page for
-- the library contents without
-- any demo code.
--
-- ```
-- #include xpbd.p8:0
-- ```
--
-- see demos for how to setup.
-- after setup, call
-- sim:update() to simulate and
-- sim:draw() to draw.
--
-- # acknowlegments
--
-- many thanks to matthias
-- muller and his collaborators
-- for xpbd papers, code,
-- examples, and videos that
-- illucidate a refreshingly
-- simple way to simulate
-- physics.
--
-- [1]: https://mastodon.gamedev.place/@shanecelis
-- [2]: https://opensource.org/licenses/MIT
-- [10min]: https://matthias-research.github.io/pages/tenMinutePhysics/index.html

#include vector.p8

-- an xpbd physics simulator
xpbd = {
  gravity = vec(0, 10),
  -- dt = 1 / 30,
  steps = 10,
  --- particles in this simulation.
  -- particles = {},
  --- constraints in this simulation.
  -- constraints = {},
  --- collision detectors in this simulation.
  -- detectors = {},

  -- note: this fields are
  -- commented out to save
  -- tokens.

  new = function(class, o)
    o = o or {}
    setmetatable(o, class)
    class.__index = class
    return o
  end,

  -- run the simulation.
  update = function(self)
    local dt,particles,constraints = 1/stat(8), self.particles, self.constraints
    local sdt = dt / self.steps
    local collisions = {}

    for d in all(self.detectors) do
      d:add_collisions(self, collisions)
    end
    for step = 1, self.steps do
      for p in all(particles) do
        p:start_step(sdt, self.gravity)
      end
      for c in all(constraints) do
        if #c > 0 then
          c:project(sdt, 0, unpack(c))
        else
          for p in all(particles) do
            c:project(sdt, 0, p)
          end
        end
      end

      for c in all(collisions) do
        c:project(sdt, 0)
      end

      for p in all(particles) do
        p:end_step(sdt)
      end

      for c in all(collisions) do
        c:resolve_collision()
      end
    end
  end,

  -- draw the constraints and particles.
  draw = function(self)
    for c in all(self.constraints) do
      c:draw()
    end

    for p in all(self.particles) do
      p:draw()
    end
  end
}

-- an xpbd particle
particle = {
  pos = vec(0, 0),
  -- prev_pos = vec(0),
  vel = vec(0),
  -- w is the inverse mass of the particle
  w = 1,
  new = function(class, o)
    o = o or {}
    setmetatable(o, class)
    class.__index = class
    return o
  end,
  start_step = function(self, dt, force)
    self.vel = self.vel + dt * self.w * force
    self.prev_pos = vec(self.pos.x, self.pos.y)
    self.pos += dt * self.vel
  end,
  end_step = function(self, dt)
    self.vel = (self.pos - self.prev_pos) / dt
  end,
  draw = function(self)
    circfill(self.pos.x, self.pos.y, 2)
  end,
}

-- an xpbd constraint
constraint = {
  -- if true, eval() >= 0
  -- satisfies the constraint.
  -- otherwise only eval() = 0
  -- satisfies the constraint.
  is_inequality = false,
  cardinality = 1,
  -- compliance is the inverse
  -- of stiffness k. a
  -- compliance of 0 is
  -- infinitely stiff.
  -- compliance is oftenly a
  -- surprisingly small number.
  compliance = 0,

  new = function(class, o)
    o = o or {}
    setmetatable(o, class)
    class.__index = class
    return o
  end,

  --- eval returns the constraint value c.
  -- eval = function(self, ...) return c end,
  --
  --- return the gradients of c: del_c1, del_c2, ....
  -- grad = function(self, ...) return [del_c1, del_c2, ...] end,

  -- equality constraints are violated if c ~= 0
  -- inequality constraints are violated if c < 0
  is_violated = function(self, ...)
    local c = self:eval(...)
    if (self.is_inequality) return c < 0
    return c ~= 0
  end,

  -- project particles to satisfy this constraint.
  project = function(self, dt, lambda, ...)
    local c = self:eval(...)

    if (self.is_inequality and c >= 0) return 0
    if (not self.is_inequality and c == 0) return 0
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

-- a 2d plane is a line, yes?
-- can be used to construct an
-- infinite ground for instance.
plane_constraint = constraint:new {
  -- normal points up from the plane
  n = vec(0, -1),
  pos = vec(0, 128),
  is_inequality = true,
  restitution = 1,
  damping = 0.5,
  -- evaluate the constraint for c.
  eval = function(self, p)
    p = p or self[1]
    return self.n:dot(p.pos - self.pos)
  end,
  -- return the del_c or gradients of c.
  grad = function(self, p)
    -- p = p or self[1]
    return {self.n}
  end,
  -- given an x find the y. used for drawing.
  find_y = function(self, x)
    return (self.n:dot(self.pos) - x * self.n.x) / self.n.y
  end,

  draw = function(self)
    local x1,x2 = 0, 128 * 8
    local y1,y2 = self:find_y(x1), self:find_y(x2)
    line(x1, y1, x2, y2)
  end,
  -- collisions ought to do a little something
  -- in the loop, but this is the most poorly
  -- fleshed out right now.
  resolve_collision = function(self, n, p)
    p = p or self[1]
    n = n or self.n
    -- p.vel -= (1 - self.restitution) * n:dot(p.vel) * n
    p.vel = n:dot(p.vel)*self.damping * self.restitution * n + (1 - self.damping) * p.vel
  end,
  -- this constraint is also a
  -- collision detector add
  -- found collisions to the
  -- list.
  add_collisions = function(self, xpbd, list)
    for p in all(xpbd.particles) do
      if self:is_violated(p) then
        add(list, self:new { p })
      end
    end
  end
}

-- keep two particles separated
-- a certain distance.
--
-- use compliance to make it
-- hard or soft.
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

-- keep two particles with radii separated.
particle_constraint = distance_constraint:new {
  is_inequality = true,
  restitution = 1,
  eval = function(self, a, b)
    a = a or self[1]
    b = b or self[2]
    return (a.pos - b.pos):length() - (a.radius + b.radius)
  end,

  add_collisions = function(self, xpbd, list)
    local beads = xpbd.particles
    for i=2,#beads do
      for j=1, i - 1 do
        if self:is_violated(beads[i], beads[j]) then
          add(list, self:new { beads[i], beads[j] })
        end
      end
    end
  end,

  resolve_collision = function(self, a, b)
    a = a or self[1]
    b = b or self[2]
    -- local dir = a.pos - b.pos
    -- local d = dir:length()
    -- dir /= d
    -- local corr = (a.radius - b.radius - d) / 2
    -- a.pos += -corr * dir
    -- b.pos +=  corr * dir
    -- local v1, v2 = a.vel:dot(dir), b.vel:dot(dir)
    -- local m1, m2 = 1/a.w, 1/b.w
    -- local v1p = (m1 * v1 + m2 * v2 - m2 * (v1 - v2) * self.restitution) / (m1 + m2)
    -- local v2p = (m1 * v1 + m2 * v2 - m1 * (v2 - v1) * self.restitution) / (m1 + m2)
    -- a.vel += (v1p - v1) * dir
    -- b.vel += (v2p - v2) * dir
    a.vel *= self.restitution
    b.vel *= self.restitution
  end,
}

-- preserve an area. (like a
-- volume constraint but for
-- 2d.)
area_constraint = constraint:new {
  rest_area = 1,
  cardinality = 4,
  eval = function(self, a, b, c, d)
    a = a or self[1]
    b = b or self[2]
    c = c or self[3]
    d = d or self[4]
    return quad_area(a.pos, b.pos, c.pos, d.pos) - self.rest_area
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

-- keep a particle on a circle.
circle_constraint = constraint:new {
  radius = 100,
  pos = vec(64,64),
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
    return {-dir}
  end,
  draw = function(self)
    circ(self.pos.x, self.pos.y, self.radius, 7)
  end,
}

-- returns area of triangle.
function tri_area(x1,x2,x3)
  return abs((x2 - x1):cross(x3 - x1))/2
end

-- returns area of a quadrilateral.
function quad_area(x1,x2,x3,x4)
  return tri_area(x1,x2,x3) + tri_area(x4,x2,x3)
end

-->8
-- demo

-- remove items from a table efficiently.
-- note: reorders table.
function table_remove(t, fn)
  local j = 1
  for i=1,#t do
    if fn(t[i]) then
      -- toss this one
      t[i] = nil
    else
      -- keep this one
      if (i ~= j) t[j], t[i] = t[i], nil
      j += 1
    end
  end
end

about = xpbd:new {
  name = "about",
  particles = {},

  draw = function(self)
    print([[




xpbd examples by shane celis.
released under the mit license.

informed by matthias muller's
ten minute physics and eXtended
Position Based Dynamics (xpbd)
papers.

]])
    xpbd.draw(self)
  end,
  update = function(self)

    -- why not add a little particle simulation?
    if rnd() < 0.2 then
      local angle = 0.0 + rnd(0.5)
      local r = ceil(rnd(3))
      local p = vec(64, 128)
      local v = 30 * vec(cos(angle), sin(angle))

      add(self.particles, bead:new { pos = p, radius = r, vel = v, color = flr(rnd(15)) + 1 })
      table_remove(self.particles, function(p) return p.pos.y > 128 end)
    end
    xpbd.update(self)
  end
}

bead = particle:new {
    radius = 4,
    color = 8,

    draw = function(self)
      circfill(self.pos.x, self.pos.y, self.radius, self.color)
    end,
  }

-- print centered
function printc(str, y, c)
  print(str, (128 - #str * 4)/2, y, c)
end

function _init()
  -- what compliance? http://blog.mmacklin.com
  local alpha = 0.05 -- compliance
  local x, y = 59, 59
  local particles = {
    -- particle:new { pos = vec(64,64), w = 0 },
    particle:new { pos = vec(x     , y     ), w = 1 },
    particle:new { pos = vec(x + 10, y     ) },
    particle:new { pos = vec(x     , y + 10) },
    particle:new { pos = vec(x + 10, y + 10) }
  }
  squishy_sim = xpbd:new {
    name = "squishy square",
    particles = particles,
    constraints = {
      distance_constraint:new {rest_length = 10, compliance = alpha, particles[1], particles[2]},
      distance_constraint:new {rest_length = 10, compliance = alpha, particles[1], particles[3]},
      distance_constraint:new {rest_length = 10, compliance = alpha, particles[2], particles[4]},
      distance_constraint:new {rest_length = 10, compliance = alpha, particles[3], particles[4]},
      area_constraint:new {
      rest_area = 100,
      compliance = alpha,
      particles[1], particles[2], particles[3], particles[4] },
      plane_constraint:new { pos = vec(0, 120), restitution = 0.8 }
    }
  }

  local a_bead = bead:new {
    pos = vec(96, 64)
  }
  bead_sim = xpbd:new {
    name = "one bead on circle",
    particles = { a_bead },
    constraints = {
      circle_constraint:new { radius = 32 },
    }
  }

  local bead_count = 4
  local beads = {}
  local circle = circle_constraint:new { radius = 32 }
  for i =1, bead_count do
    local angle = rnd()
    local r = flr(rnd(3)) + 2
    local p = circle.pos + circle.radius * vec(cos(angle), sin(angle))
    local b = bead:new { pos = p, radius = r, w = 100/(3.14 * r * r), color = flr(rnd(15)) + 1 }
    add(beads, b)
  end
  beads_sim = xpbd:new {
    name = "many beads on circle",
    particles = beads,
    -- steps = 20,
    constraints = { circle },
    detectors = { particle_constraint:new { restitution = 0.8 } },
  }
  sims = { bead_sim, beads_sim, squishy_sim, about }
  sim_index = 1
  sim = sims[sim_index + 1]
end

function _update()
  if (btnp(1)) sim_index += 1; sim = sims[sim_index % #sims + 1]
  if (btnp(0)) sim_index -= 1; sim = sims[sim_index % #sims + 1]
  sim:update()
end

function _draw()
  cls()
  sim:draw()
  printc("xpbd example "..tostr(sim_index % #sims + 1).."/"..tostr(#sims), 0, 7)
  print(sim.name, 64 - #sim.name/2 * 4 , 10, 7)
end
