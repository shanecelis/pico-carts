pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-------------------------------
--        pico-ps            --
--    particle system        --
--  author: max kearney      --
--  modified by: shane celis --
--  created: april 2019      --
--  updated: october 2023    --
-------------------------------

--[[
  feel free to contact me if you have any questions.
  itch: https://maxwelldexter.itch.io/
  twitter: @KearneyMax
]]
-- #include vector.p8
-------------------------------------------------- globals

-- efficiently remove all
-- entries that fn returns true.
-- https://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating
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

-- an object pool
pool = {
  -- eg: pool:new(nil, function() some-object:new() end)
  new = function (self, o, create)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.create = create or o.create
    return o
  end,

  -- get an item from the pool
  get = function (self)
    if #self <= 0 then
      return self.create()
    else
      -- take item from last position.
      local e = self[#self]
      self[#self] = nil
      return e
    end
  end,

  -- return an item to the pool
  release = function (self, e)
    add(self, e)
  end
}

-- a drop-in replacement for pool that
-- is not a pool but a factory.
nopool = pool:new {
  get = function(p) return p.create() end,
  release = function(p) end
}

variate = {
  new = function (self, o, value, spread)
    o = o or {}
    o.value = value or o.value
    o.spread = spread or o.spread
    setmetatable(o, self)
    self.__index = self
    return o
  end,

  set = function (self, v, s)
    self.value, self.spread = v, s
  end,

  eval = function (self)
    if type(self.value) == "table" then
      if (#self.value == 0) return nil
      return self.value[flr(rnd(#self.value))+1]
      elseif self.spread then
        local sign = sgn(self.spread)
        return self.value + sign * rnd(self.spread * sign) - self.spread / 2
      else
        return self.value
      end
  end
}

rachet = {
  new = function (self, o)
    o = o or {}
    o.t = 0
    o.k = 1
    setmetatable(o, self)
    self.__index = self
    return o
  end,

  update = function (o, dt)
    o.t += o.k * dt
  end,

  eval = function (o)
    -- assert(#self ~= 0)
    o.t %= #o
    return o[flr(o.t) + 1]
  end,
}


-------------------------------------------------- particle
particle = {

  new = function (self, o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
  end,

  delta_time = function()
    local fps = stat(8)
    return 1 / fps
  end,

  set_values = function (self, x, y, external_force, colours, sprites, life, angle, speed_initial, speed_final, size_initial, size_final)
    self.pos = vec(x,y)
    self.life_initial, self.life, self.external_force = life, life, external_force

    self.velocity = speed_initial * vec(cos(angle), sin(angle))
    self.vel_initial = 1 * self.velocity
    self.vel_final = speed_final * vec(cos(angle), sin(angle))

    self.size, self.size_initial, self.size_final = size_initial, size_initial, size_final

    self.sprites = sprites
    if self.sprites then
      self.sprite_time = self.life_initial / #self.sprites
      self.current_sprite_time = self.sprite_time
      self.sprites_index = 1
      self.sprite = self.sprites[self.sprites_index]
    else
      self.sprite = nil
    end

    self.colours = colours
    if colours then
      self.colour_time = (1 / #self.colours) * self.life_initial
      self.current_colour_time = self.colour_time
      self.colours_index = 1
      self.colour = self.colours[self.colours_index]
      if (not self.colour) stop() -- TODO: somehow the colour ends up being nil
      else
        self.colour = nil
      end
  end,

  -- update: handles all of the values changing like life, gravity, size/life, vel/life, movement and dying
  update = function (self, dt)
    dt = dt or particle.delta_time()
    self.life -= dt

    if (self.external_force) self.velocity += dt * self.external_force
    -- if (self.gravity) self:apply_gravity()

    -- size over lifetime
    if (self.size_initial ~= self.size_final) then
      -- take the difference of original and future, divided by time, multiplied by delta time
      self.size = self.size - ((self.size_initial-self.size_final)/self.life_initial)*dt
    end

    self.velocity -= ((self.vel_initial-self.vel_final)/self.life_initial)*dt

    -- changing the colour
    if (self.colours ~= nil and #self.colours > 1) then
      self.current_colour_time -= dt
      if (self.current_colour_time < 0) then
        self.colours_index += 1
        self.colour = self.colours[self.colours_index]
        self.current_colour_time = self.colour_time
      end
    end

    -- changing the sprite
    if (self.sprites ~= nil and #self.sprites > 1) then
      self.current_sprite_time -= dt
      if (self.current_sprite_time < 0) then
        self.sprites_index += 1
        self.sprite = self.sprites[self.sprites_index]
        self.current_sprite_time = self.sprite_time
      end
    end

    -- moving the particle
    if (self.life > 0) then
      self.pos += self.velocity * dt
    else
      -- self.dead = true -- goodbye world
    end
  end,

  -- draws a circle with its values
  draw = function (self)
    if (self.sprite ~= nil) then
      spr(self.sprite, self.pos.x, self.pos.y)
    elseif (self.colour ~= nil) then
      circfill(self.pos.x, self.pos.y, self.size, self.colour)
    end
  end
}

-------------------------------------------------- particle emitter
emitter = {
  -- emitter variables
  -- pos = nil,
  emitting = true,
  -- frequency = nil,
  emit_time = 0,
  max_p = 100,
  gravity = false,
  particle_class = particle,
  -- burst = nil,

  -- particle factory stuff
  -- p_sprites = nil,
  --
  new = function (self, o, x, y, frequency, max_p, burst, gravity)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- table members should be set up in new
    o.particles = {}
    o.p_colours = variate:new({}, {1})
    o.p_life = variate:new({}, 1, 0)
    o.p_angle = variate:new({}, 0, 360)
    o.p_speed = variate:new({}, 10, 0)
    o.p_size = variate:new({}, 1, 0)

    o.pos = o.pos or vec(x,y)
    o.frequency = frequency or o.frequency
    o.max_p = max_p or o.max_p
    o.burst = burst or o.burst
    o.gravity = gravity or o.gravity
    o.pool = nopool:new({}, function() return o.particle_class:new() end)
    -- o.pool = pool:new({}, function() return particle:new() end)
    o.p_speed_final = o.p_speed_final or o.p_speed:new()
    o.p_size_final = o.p_size_final or o.p_size:new()
    -- if (o.max_p < 1) then
    --   o.use_pooling = false end

    return o
  end,

  get_pos = function (self)
    return self.pos
  end,

  -- tells all of the particles to
  -- update and removes any that
  -- are dead.
  update = function (self, dt)
    dt = dt or particle.delta_time()
    self:emit(dt)
    for p in all(self.particles) do
      p:update(dt)
      if (p.life < 0) self.pool:release(p)
      end
    table_remove(self.particles, function(p) return p.life < 0 end)
    -- handle subemitters
    for e in all(self) do
      e:update()
    end
  end,

  add = function (self, e)
    add(self, e)
    e.get_pos = function(eself)
      return self.pos + eself.pos
    end
  end,


  -- tells of the particles to
  -- draw themselves.
  draw = function (self)
    foreach(self.particles, function(obj) obj:draw() end)

    -- handle subemitters
    for e in all(self) do
      e:draw()
    end
  end,

  -- factory method, creates a new
  -- particle based on the values
  -- set + random. this is why the
  -- emitter has to know about the
  -- properties of the particle
  -- it's emmitting.
  get_new_particle = function (self)
    local sprites = self.p_sprites
    -- select random sprite from the sprites list
    if sprites and sprites.value then
      -- it's a variate.
      sprites = {sprites:eval()}
    end

    local pos, area = self:get_pos(), self.area
    if area then
      -- center it
      pos += area:map(rnd) - area / 2
    end

    local p = self.pool:get()

    -- (x, y, gravity, colours, sprites, life, angle, speed_initial, speed_final, size_initial, size_final)
    p:set_values (
      pos.x, pos.y, -- pos
      self.gravity and vec(0, 50) or nil, -- gravity a and b or c === a ? b : c
      {self.p_colours:eval() or flr(rnd(16))}, -- color
      sprites, -- graphics
      self.p_life:eval(), -- life
      self.p_angle:eval() / 360, -- angle
      self.p_speed:eval(),
      self.p_speed_final:eval(), -- speed
      self.p_size:eval(),
      self.p_size_final:eval() -- size
    )
    return p
  end,

  emit = function (self, dt)
    if self.emitting then
      -- burst!
      if self.burst then
        if self.max_p <= 0 then
          self.max_p = 50
        end
        for i=1, self:spawn_count(self.burst) do
          add(self.particles, self:get_new_particle())
        end
        self.emitting = false

        -- we're continuously emitting
      else
        self.emit_time += self.frequency
        if self.emit_time >= 1 then
          local amount = self:spawn_count(self.emit_time)
          for i=1, amount do
            add(self.particles, self:get_new_particle())
          end
          self.emit_time -= amount
        end
      end
    end
  end,

  spawn_count = function (self, spawn_amount)
    if self.max_p ~= 0 and #self.particles + flr(spawn_amount) >= self.max_p then
      return self.max_p - #self.particles
    else
      return flr(spawn_amount)
    end
  end,

  clone = function (self)
    local o = self:new({})
    -- o.p_colours = self.p_colors:new()
    o.p_life = self.p_life:new()
    o.p_angle = self.p_angle:new()
    o.p_speed = self.p_speed:new()
    o.p_size = self.p_size:new()
    return o
  end
}


function confetti()
  local left = emitter:new({}, 0, 0, 5, 10, false, false)
  left.p_size:set(0, 1)
  left.p_size_final:set(0)
  left.p_speed:set(10, 20)
  left.p_speed_final:set(10)
  left.p_colours:set({7, 8, 9, 10, 11, 12, 13, 14, 15})
  left.p_life:set(0.4, 1)
  return left
end

-- stars credits
function stars()
  local front = emitter:new({}, 0, 64, 0.2, 0)
  front.area = vec(0, 128)
  front.p_colours:set({7})
  front.p_size:set(0)
  front.p_speed:set(34, 10)
  front.p_speed_final:set(34)
  front.p_life:set(3.5)
  front.p_angle:set(0)

  local midfront = front:clone()
  midfront.frequency = 0.15
  midfront.p_life:set(4.5)
  midfront.p_colours:set({6})
  midfront.p_speed:set(26, 5)
  midfront.p_speed_final:set(26)
  front:add(midfront)
  local midback = front:clone()
  midback.p_life:set(6.8)
  midback.p_colours:set({5})
  midback.p_speed:set(18, 5)
  midback.p_speed_final:set(18)
  midback.frequency = 0.1
  front:add(midback)
  local back = front:clone()
  back.frequency = 0.7
  back.p_life:set(11)
  back.p_colours:set({1})
  back.p_speed:set(10, 5)
  back.p_speed_final:set(10)
  front:add(back)
  local special = emitter:new({}, 64, 64, 0.2, 0)

  special.area = vec(128, 128)
  special.p_angle:set(0)
  special.frequency = 0.01
  special.p_sprites = {107, 108, 109, 110}
  special.p_speed:set(30, 15)
  special.p_speed_final:set(30)
  special.p_life:set(5)
  front:add(special)
  return front
end
