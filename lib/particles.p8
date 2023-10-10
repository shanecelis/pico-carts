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

-------------------------------------------------- globals

pool = {
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
  release = function (self, e)
    add(self, e)
  end
}

function pool:new(o, create)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.create = create or o.create
  return o
end


nopool = pool:new({
    get = function(p) return p.create() end,
    release = function(p) end })

variate = {}
function variate:new(o, value, spread)
  o = o or {}
  o.value = value or o.value
  o.spread = spread or o.spread
  setmetatable(o, self)
  self.__index = self
  return o
end

function variate:set(v, s)
  self.value, self.spread = v, s
end

function variate:eval()
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

-------------------------------------------------- particle
particle = {
  prev_time = time(), -- for calculating dt
  delta_time = nil, -- the change in time
}

function particle.update_time()
  particle.delta_time = time()-particle.prev_time
  particle.prev_time = time()
end

vec = {
  __add = function(a,b)
    return vec:new(a.x + b.x, a.y + b.y)
  end,

  __sub = function(a,b)
    return vec:new(a.x - b.x, a.y - b.y)
  end,

  __mul = function(a,b)
    if type(a) == 'number' then
      return vec:new(a * b.x, a * b.y)
    elseif type(b) == 'number' then
      return vec:new(a.x * b, a.y * b)
    else
      return vec:new(a.x * b.x, a.y * b.y)
    end
  end,

  __div = function(a,b)
    assert(type(b) == 'number' and type(a) ~= 'number')
    return vec:new(a.x / b, a.y / b)
  end,

  map = function(a, f)
    return vec:new(f(a.x), f(a.y))
  end
}

function vec:new(x,y)
  local v = {x = x, y = y}
  setmetatable(v, self)
  self.__index = self
  return v
end

function particle:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function particle:set_values(x, y, external_force, colours, sprites, life, angle, speed_initial, speed_final, size_initial, size_final)
  self.pos = vec:new(x,y)
  self.life_initial, self.life, self.dead, self.external_force = life, life, false, external_force

  -- the 1125 number was 180 in the original calculation,
  -- but i set it to 1131 to make the angle pased in equal to 360 on a full revolution
  -- don't ask me why it's 1131, i don't know. maybe it's odd because i rounded pi?
  -- local angle = angle * 3.14159 / 1131
  self.velocity = vec:new(speed_initial*cos(angle), speed_initial*sin(angle))
  self.vel_initial = vec:new(self.velocity.x, self.velocity.y)
  self.vel_final = vec:new(speed_final*cos(angle), speed_final*sin(angle))

  self.size, self.size_initial, self.size_final = size_initial, size_initial, size_final

  self.sprites = sprites
  if self.sprites then
    self.sprite_time = (1 / #self.sprites) * self.life_initial
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
end

-- update: handles all of the values changing like life, gravity, size/life, vel/life, movement and dying
function particle:update(dt)
  self.life -= dt

  if (self.external_force) self.velocity += particle.delta_time * self.external_force
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
    self.dead = true -- goodbye world
  end
  end

-- draws a circle with its values
function particle:draw()
  if (self.sprite ~= nil) then
    spr(self.sprite, self.pos.x, self.pos.y)
  elseif (self.colour ~= nil) then
    circfill(self.pos.x, self.pos.y, self.size, self.colour)
  end
end

-------------------------------------------------- particle emitter
emitter = {
  -- emitter variables
  -- pos = nil,
  emitting = true,
  -- frequency = nil,
  emit_time = 0,
  max_p = 100,
  gravity = false,
  -- burst = nil,

  -- particle factory stuff
  -- p_sprites = nil,
}

function emitter:new(o, x, y, frequency, max_p, burst, gravity)
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

  o.pos = o.pos or vec:new(x,y)
  o.frequency = frequency or o.frequency
  o.max_p = max_p or o.max_p
  o.burst = burst or o.burst
  o.gravity = gravity or o.gravity
  o.pool = nopool:new({}, function() return particle:new() end)
  o.p_speed_final = o.p_speed_final or o.p_speed:new()
  o.p_size_final = o.p_size_final or o.p_size:new()
  -- if (o.max_p < 1) then
  --   o.use_pooling = false end

  return o
end

function emitter:get_pos()
  return self.pos
end

-- tells all of the particles to
-- update and removes any that
-- are dead.
function emitter:update()
  local dt = particle.delta_time
  self:emit(dt)
  for p in all(self.particles) do
    p:update(dt)
    if (p.dead) self.pool:release(p)
    end
  table_remove(self.particles, function(p) return p.dead end)
  -- handle subemitters
  for e in all(self) do
    e:update()
  end
end

function emitter:add(e)
  add(self, e)
  e.get_pos = function(eself)
    return self.pos + eself.pos
  end

end

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

-- tells of the particles to
-- draw themselves.
function emitter:draw()
  foreach(self.particles, function(obj) obj:draw() end)

  -- handle subemitters
  for e in all(self) do
    e:draw()
  end
end

-- factory method, creates a new
-- particle based on the values
-- set + random. this is why the
-- emitter has to know about the
-- properties of the particle
-- it's emmitting.
function emitter:get_new_particle()
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
    self.gravity and vec:new(0, 50) or nil, -- gravity a and b or c === a ? b : c
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
end

function emitter:emit(dt)
  if self.emitting then
    -- burst!
    if self.burst then
      if self.max_p <= 0 then
        self.max_p = 50
      end
      for i=1, self:get_amount_to_spawn(self.burst) do
        add(self.particles, self:get_new_particle())
      end
      self.emitting = false

      -- we're continuously emitting
    else
      self.emit_time += self.frequency
      if self.emit_time >= 1 then
        local amount = self:get_amount_to_spawn(self.emit_time)
        for i=1, amount do
          add(self.particles, self:get_new_particle())
        end
        self.emit_time -= amount
      end
    end
  end
end

function emitter:get_amount_to_spawn(spawn_amount)
  if (self.max_p ~= 0 and #self.particles + flr(spawn_amount) >= self.max_p) then
    return self.max_p - #self.particles
  end
  return flr(spawn_amount)
end

function emitter:clone()
  local o = self:new({})
  -- o.p_colours = self.p_colors:new()
  o.p_life = self.p_life:new()
  o.p_angle = self.p_angle:new()
  o.p_speed = self.p_speed:new()
  o.p_size = self.p_size:new()
  return o
end

function confetti()
  local left = emitter:new({}, 0, 0, 5, 10, false, false)
  left.p_size:set(0, 1)
  left.p_size_final:set(0)
  left.p_speed:set(10, 20)
  left.p_speed_final:set(10)
  left.p_colours:set({7, 8, 9, 10, 11, 12, 13, 14, 15})
  left.p_life:set(0.4, 1)
  -- left.p_angle:set(30, 45)
  -- local right = left:clone()
  -- right.pos = vec:new(30, 0)
  -- left:add(right)
  return left
end

-- stars credits
function stars()
  -- local my_emitters = emitters:new()
  local front = emitter:new({}, 0, 64, 0.2, 0)
  front.area = vec:new(0, 128)
  front.p_colours:set({7})
  front.p_size:set(0)
  front.p_speed:set(34, 10)
  front.p_speed_final:set(34)
  front.p_life:set(3.5)
  front.p_angle:set(0)

  -- add(my_emitters, front)
  local midfront = front:clone()
  midfront.frequency = 0.15
  midfront.p_life:set(4.5)
  midfront.p_colours:set({6})
  midfront.p_speed:set(26, 5)
  midfront.p_speed_final:set(26)
  front:add(midfront)
  -- add(my_emitters, midfront)
  local midback = front:clone()
  midback.p_life:set(6.8)
  midback.p_colours:set({5})
  midback.p_speed:set(18, 5)
  midback.p_speed_final:set(18)
  midback.frequency = 0.1
  front:add(midback)
  -- add(my_emitters, midback)
  local back = front:clone()
  back.frequency = 0.7
  back.p_life:set(11)
  back.p_colours:set({1})
  back.p_speed:set(10, 5)
  back.p_speed_final:set(10)
  -- add(my_emitters, back)
  front:add(back)
  local special = emitter:new({}, 64, 64, 0.2, 0)

  special.area = vec:new(128, 128)
  special.p_angle:set(0)
  special.frequency = 0.01
  -- ps_set_sprites(special, {78, 79, 80, 81, 82, 83, 84})
  -- special.p_sprites = variate:new(nil, {107, 108, 109, 110})
  special.p_sprites = {107, 108, 109, 110}
  special.p_speed:set(30, 15)
  special.p_speed_final:set(30)
  special.p_life:set(5)
  front:add(special)
  -- add(my_emitters, special)
  return front
end
