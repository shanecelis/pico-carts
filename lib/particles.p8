pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
--hi
---------------------------
--        pico-ps        --
--    particle system    --
--  author: max kearney  --
--  created: april 2019  --
--  updated: october 2020   --
---------------------------

--[[
    feel free to contact me if you have any questions.
    itch: https://maxwelldexter.itch.io/
    twitter: @KearneyMax
]]

-------------------------------------------------- globals

-------------------------------------------------- particle
particle = {
  prev_time = nil, -- for calculating dt
  delta_time = nil, -- the change in time
  gravity = 50
}

function particle.update_time()
 particle.delta_time = time()-prev_time
 particle.prev_time = time()
end


function particle.apply_gravity(a)
 a.velocity.y = a.velocity.y + delta_time * a.gravity
end

function vec(x,y)
 return {x = x, y = y}
end

function particle:new(o)
 o = o or {}
 setmetatable(o, self)
 self.__index = self
 return o
end

emitters = {}

function emitters:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function emitters:draw()
  for e in all(self) do
    e:draw()
  end
end

function emitters:update()
  for e in all(self) do
    e:update(particle.delta_time)
  end
end

function particle:set_values(x, y, gravity, colours, sprites, life, angle, speed_initial, speed_final, size_initial, size_final)
 self.pos = vec(x,y)
 self.life_initial, self.life, self.dead, self.gravity = life, life, false, gravity

 -- the 1125 number was 180 in the original calculation,
 -- but i set it to 1131 to make the angle pased in equal to 360 on a full revolution
 -- don't ask me why it's 1131, i don't know. maybe it's odd because i rounded pi?
 -- local angle_radians = angle * 3.14159 / 1131
 local angle_radians = angle
 self.velocity = vec(speed_initial*cos(angle_radians), speed_initial*sin(angle_radians))
 self.vel_initial = vec(self.velocity.x, self.velocity.y)
 self.vel_final = vec(speed_final*cos(angle_radians), speed_final*sin(angle_radians))

 self.size, self.size_initial, self.size_final = size_initial, size_initial, size_final

 self.sprites = sprites
 if (self.sprites ~= nil) then
  self.sprite_time = (1 / #self.sprites) * self.life_initial
  self.current_sprite_time = self.sprite_time
  self.sprites_index = 1
  self.sprite = self.sprites[self.sprites_index]
 else
  self.sprite = nil
 end

 self.colours = colours
 if (colours ~= nil) then
  self.colour_time = (1 / #self.colours) * self.life_initial
  self.current_colour_time = self.colour_time
  self.colours_index = 1
  self.colour = self.colours[self.colours_index]
  if (self.colour == nil) then stop() end -- TODO: somehow the colour ends up being nil
 else
  self.colour = nil
 end
end

-- update: handles all of the values changing like life, gravity, size/life, vel/life, movement and dying
function particle:update(dt)
 self.life -= dt

 if (self.gravity) self:apply_gravity()

 -- size over lifetime
 if (self.size_initial ~= self.size_final) then
  -- take the difference of original and future, divided by time, multiplied by delta time
  self.size = self.size - ((self.size_initial-self.size_final)/self.life_initial)*dt
 end

 -- velocity over lifetime
 if (self.vel_initial.x ~= self.vel_final.x) then
  -- take the difference of original and future, divided by time, multiplied by delta time
  self.velocity.x = self.velocity.x - ((self.vel_initial.x-self.vel_final.x)/self.life_initial)*dt
  self.velocity.y = self.velocity.y - ((self.vel_initial.y-self.vel_final.y)/self.life_initial)*dt
 end

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
  self.pos.x = self.pos.x + self.velocity.x * dt
  self.pos.y = self.pos.y + self.velocity.y * dt
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
  particles = {},
  to_remove = {},

  -- emitter variables
  pos = nil,
  emitting = true,
  frequency = nil,
  emit_time = 0,
  max_p = 100,
  gravity = false,
  burst = false,
  burst_amount = nil,
  use_pooling = false,
  pool = {},
  rnd_colour = false,
  rnd_sprite = false,
  use_area = false,
  area_width = 0,
  area_height = 0,

  -- particle factory stuff
  p_colours = {1},
  p_sprites = nil,
  p_life = 1,
  p_life_spread = 0,
  p_angle = 0,
  p_angle_spread = 360,
  p_speed_initial = 10,
  p_speed_final = 10,
  p_speed_spread_initial = 0,
  p_speed_spread_final = 0,
  p_size_initial = 1,
  p_size_final = 1,
  p_size_spread_initial = 0,
  p_size_spread_final = 0
}
function emitter:new(o, x,y, frequency, max_p, burst, gravity)
 o = o or {}
 setmetatable(o, self)
 self.__index = self

 if (o.pos == nil) o.pos = vec(x,y)
 o.frequency = frequency or o.frequency
 o.max_p = max_p or o.max_p
 o.burst = burst or o.burst
 o.gravity = gravity or o.gravity
 -- if (o.max_p < 1) then
 --   o.use_pooling = false end

 return o
end

-- tells all of the particles to
-- update and removes any that
-- are dead.
function emitter:update()
 local dt = particle.delta_time
 self:emit(dt)
 for p in all(self.particles) do
  p:update(dt)
  if (p.dead) then
   self:remove(p)
  end
 end
 self:remove_dead()
end

-- tells of the particles to
-- draw themselves
function emitter:draw()
 foreach(self.particles, function(obj) obj:draw() end)
end

function emitter:get_colour()
 if (self.rnd_colour) then
  if (#self.p_colours > 1) then
   return {self.p_colours[flr(rnd(#self.p_colours))+1]}
  else
   return {flr(rnd(16))}
  end
 else
  return self.p_colours
 end
end

-- factory method, creates a new particle based on the values set + random
-- this is why the emitter has to know about the properties of the particle it's emmitting
function emitter:get_new_particle()
 local sprites = self.p_sprites
 -- select random sprite from the sprites list
 if (self.rnd_sprite and self.p_sprites ~= nil) then
  sprites = {self.p_sprites[flr(rnd(#self.p_sprites))+1]}
 end

 local x = self.pos.x
 local y = self.pos.y
 if (self.use_area) then
  -- center it
  local width = self.area_width
  local height = self.area_height
  x += flr(rnd(width)) - (width / 2)
  y += flr(rnd(height)) - (height / 2)
 end

 local p = nil
 if (self.use_pooling and #self.particles + #self.pool == self.max_p) then
  p = self.pool[1]
  del(self.pool, p)
 else
  p = particle:new()
 end

 -- (x, y, gravity, colours, sprites, life, angle, speed_initial, speed_final, size_initial, size_final)
 p.set_values (p, -- self
  x, y, -- pos
  self.gravity, -- gravity
  self.get_colour(self), sprites, -- graphics
  self.p_life + get_rnd_spread(self.p_life_spread), -- life
  self.p_angle + get_rnd_spread(self.p_angle_spread), -- angle
  self.p_speed_initial + get_rnd_spread(self.p_speed_spread_initial), self.p_speed_final + get_rnd_spread(self.p_speed_spread_final), -- speed
  self.p_size_initial + get_rnd_spread(self.p_size_spread_initial), self.p_size_final + get_rnd_spread(self.p_size_spread_final) -- size
 )
 return p
end

function emitter:emit(dt)
 if (self.emitting) then
  -- burst!
  if (self.burst) then
   if (self.max_p <= 0) then
    self.max_p = 50
   end
   for i=1, self.get_amount_to_spawn(self, self.burst_amount) do
    add(self.particles, self.get_new_particle(self))
   end
   self.emitting = false

  -- we're continuously emitting
  else
   self.emit_time += self.frequency
   if (self.emit_time >= 1) then
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

function emitter:remove(p)
 add(self.to_remove, p)
end

function emitter:remove_dead()
 for p in all(self.to_remove) do
  if (self.use_pooling) add(self.pool, p)
  del(self.particles, p)
 end
 self.to_remove = {}
end

-- will randomise even if it is negative
function get_rnd_spread(spread)
 return rnd(spread * sgn(spread)) * sgn(spread)
end

function emitter:clone()
  return self:new({})
end

-- setter functions

function ps_set_pos(e, x, y)
 e.pos = vec(x,y)
end

function ps_set_frequency(e, frequency)
 e.frequency = frequency
end

function ps_set_max_p(e, max_p)
 e.max_p = max_p
end

function ps_set_gravity(e, gravity)
 e.gravity = gravity
end

function ps_set_burst(e, burst, burst_amount)
 e.burst = burst
 e.burst_amount = burst_amount or e.max_p
end

function ps_set_pooling(e, pooling)
 e.use_pooling = pooling
 e.pool = {}
 if (e.use_pooling and e.max_p < 1) then
  e.max_p = 20
 end
end

function ps_set_rnd_colour(e, rnd_colour)
 e.rnd_colour = rnd_colour
end

function ps_set_rnd_sprite(e, rnd_sprite)
 e.rnd_sprite = rnd_sprite
end

function ps_set_area(e, width, height)
 e.use_area = width ~= nil and height ~= nil and (width > 0 or height > 0)
 e.area_width = width or 0
 e.area_height = height or 0
end

function ps_set_colours(e, colours)
 e.p_colours = colours
end

function ps_set_sprites(e, sprites)
 e.p_sprites = sprites
end

function ps_set_life(e, life, life_spread)
 e.p_life = life
 e.p_life_spread = life_spread or 0
end

function ps_set_angle(e, angle, angle_spread)
 e.p_angle = angle
 e.p_angle_spread = angle_spread or 0
end

function ps_set_speed(e, speed_initial, speed_final, speed_spread_initial, speed_spread_final)
 e.p_speed_initial = speed_initial
 e.p_speed_final = speed_final or speed_initial
 e.p_speed_spread_initial = speed_spread_initial or 0
 e.p_speed_spread_final = speed_spread_final or e.p_speed_spread_initial
end

function ps_set_size(e, size_initial, size_final, size_spread_initial, size_spread_final)
 e.p_size_initial = size_initial
 e.p_size_final = size_final or size_initial
 e.p_size_spread_initial = size_spread_initial or 0
 e.p_size_spread_final = size_spread_final or e.p_size_spread_initial
end

function confetti()
  local left = emitter:new({}, 0, 0, 5, 10, false, false)
 ps_set_size(left, 0, 0, 1)
 ps_set_speed(left, 10, 20, 10)
 ps_set_colours(left, {7, 8, 9, 10, 11, 12, 13, 14, 15})
 ps_set_rnd_colour(left, true)
 ps_set_life(left, 0.4, 1)
 ps_set_angle(left, 30, 45)
 return left
end

-- stars credits
function stars()
  local my_emitters = emitters:new()
  local front = emitter:new({}, 0, 64, 0.2, 0)
  ps_set_area(front, 0, 128)
  ps_set_colours(front, {7})
  ps_set_size(front, 0)
  ps_set_speed(front, 34, 34, 10)
  ps_set_life(front, 3.5)
  ps_set_angle(front, 0, 0)
  add(my_emitters, front)
  local midfront = front:clone()
  ps_set_frequency(midfront, 0.15)
  ps_set_life(midfront, 4.5)
  ps_set_colours(midfront, {6})
  ps_set_speed(midfront, 26, 26, 5)
  add(my_emitters, midfront)
  local midback = front:clone()
  ps_set_life(midback, 6.8)
  ps_set_colours(midback, {5})
  ps_set_speed(midback, 18, 18, 5)
  ps_set_frequency(midback, 0.1)
  add(my_emitters, midback)
  local back = front:clone()
  ps_set_frequency(back, 0.07)
  ps_set_life(back, 11)
  ps_set_colours(back, {1})
  ps_set_speed(back, 10, 10, 5)
  add(my_emitters, back)
  local special = emitter:new({}, 64, 64, 0.2, 0)
  ps_set_area(special, 128, 128)
  ps_set_angle(special, 0, 0)
  ps_set_frequency(special, 0.01)
  -- ps_set_sprites(special, {78, 79, 80, 81, 82, 83, 84})
  ps_set_sprites(special, {107, 108, 109, 110})
  ps_set_speed(special, 30, 30, 15)
  ps_set_life(special, 5)
  add(my_emitters, special)
  local front = emitter:new({}, 0, 64, 0.2, 0)
  ps_set_area(front, 0, 128)
  ps_set_colours(front, {7})
  ps_set_size(front, 0)
  ps_set_speed(front, 34, 34, 10)
  ps_set_life(front, 3.5)
  ps_set_angle(front, 0, 0)
  add(my_emitters, front)
  return my_emitters
end
