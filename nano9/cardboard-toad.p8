pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-- cardboard toad

-- todo: 
-- [x]musem text
-- [x ]  finesh game!
-- [x] credits scene
-- [x ] gray donkey running away
-- [x] hit pinata
-- [x] noise from hitting pinata
-- [x ] toad following
-- [x ] toad says il help you
-- [x] cart image
--#include message.p8
--https:--www.lexaloffle.com/bbs/?tid=33645
--shooting's ultimate text
--[[
    text codes:

   $u1 = underline text (0 for
           no underline)

   $b## = border color, ##= a
          number, 0-15

   $o## = outline color

   $c## = text color

   $d## = delay extra (0-99)
          if more delay is
          needed, use $f##
          and create a custom
          fx for it.
   $i## = display sprite inline

   $f## = special effects
   $sc  = spin character

   for any of these, you can use
   xx instead of a number to
   reset it to default (based
   on the default config you
   have set up)

   alternatively, you can use
   16 to set it to nil and
   remove it.
]]--
--[[
todo
====
* DONE remove skip elements
* TODO generalize fragment to hold whole string not just one character
* DONE generalize framework so that all outline, highlight, and such are just effects
* DONE highlighting obscured by outline (probably an ordering issue)
* TODO effect could do processing

changes
=======
* use a lua oo system instead of a 'msg_' prefix
* draw(x,y) lines up with print(s,x,y)
* fragment class only hold items changed from default
* parsing happens once
* many message instances may be used at the same time
* buttons and timing are handled in _update() instead of _draw()
* TODO make underline take a color

motivation
==========

shooting's ultimate text library is awesome first of all, so why change it? there were a few
reasons: i wanted to integrate it with my code that has a particular style.

]]--
--==configurations==--
--[[
  configure your defaults
  here
--]]

-- effect, fragment, and message

effect = {
  sigil = nil, -- 'c'
  arg_count = 2,
  val = nil,
  isolated = false,
}

function effect.new(class, o)
  o = o or {}
  setmetatable(o, class)
  class.__index = class
  return o
end

function effect:parse(chars, i)
  assert(chars[i+0].c == '$', "wrong start")
  if self.sigil then assert(chars[i+1].c == self.sigil, "wrong sigil") end
  chars[i].skip=true
  chars[i+1].skip=true

  local arg = ""
  for j=1, self.arg_count do
    chars[i+1+j].skip=true
    arg = arg..chars[i+1+j].c
  end
  return tonum(arg)
end

function effect:closure(val)
  return function(fragments, k)
    if self.isolated then
      self:setup(fragments[k], val)
    else
      for j=k,#fragments do
        self:setup(fragments[j], val)
      end
    end
  end
end

function effect:setup(fragment, val) end

message = {
  color = {
    foreground = 15,
    highlight = nil,
    outline = 1
  },
  spacing = {
    letter = 4,
    newline = 7
  },
  sound = {
    blip = 0,
    next_message = 1
  },
  next_message = {
    button = 5,
    char = '.',
    color = 9
  },
  effects = {
    c = effect:new{ sigil = 'c',
                    setup = function(self, fragment, val) fragment.color.foreground=val end
    },
    b = effect:new{ sigil = 'b',
                    setup = function(self, fragment, val) fragment.color.highlight=val end
    },
    o = effect:new{ sigil = 'o',
                     setup = function(self, fragment, val) fragment.color.outline=val end
                   },
    d = effect:new{ sigil = 'd',
                     setup = function(self, fragment, val) fragment.delay=val end,
                     parse = function(self, chars, i)
                       local val = effect.parse(self, chars, i)
                       -- if val then val = val /  30 end
                       return val and val/30 or nil
                     end
    },
    f = effect:new{ sigil = 'f',
                    parent = nil,
                    setup = function(self, fragment, val) fragment.update = self.subeffects[val] end,

                    subeffects = {
                      function(fragment, fxv)
                        local t = 1.5 * time()
                        fragment.dy=sin(t+fxv)
                      end,
                      function(fragment, fxv)
                        local t = 1.5 * time()
                        fragment.dy=sin(t+fxv)
                        fragment.dx = rnd(4) - 2
                      end,
                    },
    },
    s = effect:new{ sigil = 's',
                    parent = nil,
                    isolated = true,
                    arg_count = 0,
                    setup = function(self, fragment, val)
                      fragment.update = function(fragment, fxv)
                        local t = 1.6 * time()
                        fragment.dy=sin(t+fxv)
                        fragment.dx=cos(t+fxv)
                      end
                    end,
    },
    u = effect:new{ sigil = 'u',
                    arg_count = 1,
                    setup = function(self, fragment, val) fragment.underline=val end
                   },
    i = effect:new{ sigil = 'i',
                    isolated = true,
                    setup = function(self, fragment, val) fragment.image=val end
                   },
    r = effect:new{ arg_count = 1,
                    setup = function(self, fragment, val)
                      fragment.update = val and function(fragment, fxv)
                        local t = val * time() + fxv
                        fragment.color.foreground = t % 16
                      end
    end,
                  },
    -- prompt
    -- imagine a menu that looked like this;
    --
    -- would you like?
    -- $p> eggs
    -- $p> bacon
    -- $p> ham

    -- p = effect:new{ sigil = 'p',
    --                 arg_count = 0,
    --                 replacement = ' ',
    --                 isolated = true,
    --                 setup = function(self, fragment, val)
    --                   fragment.orig = fragment.c
    --                   fragment.prompt = true
    --                 end,
    --                 closure = function(self, fragments, k)
    --                   local c = effect.closure(self, fragments, k)

    --                   local i = 1
    --                   for f in all(fragments) do
    --                     if f.prompt then
    --                       f.prompt = 1
    --                     end
    --                   end
    --                 end
    -- },
    ['$'] = effect:new {
      sigil = '$',
      arg_count = 0,
      parse = function(self, chars, i) chars[i].skip=true end,
    },
  },
  delay = 1/30,
  last_press = true,
}

function clone(o)
  local c = {}
  for k,v in pairs(o) do
    c[k] = v
  end
  return c
end

function message.new(class, o, strings)
  o = o and clone(o) or {}
  -- if o.color then setmetatable(o.color, { __index = class.color }) end
  -- if o.color then class.color.__index = class.color end
  if o.spacing then setmetatable(o.spacing, class.spacing); class.spacing.__index = class.spacing end
  if o.sound then setmetatable(o.sound, class.sound); class.sound.__index = class.sound end
  if o.next_message then setmetatable(o.next_message, class.next_message); class.next_message.__index = class.next_message end
  setmetatable(o, class)
  class.__index = class
  o.fragments = {}
  for k,v in ipairs(strings or o) do
    add(o.fragments, o:parse(v))
  end
  o.istart = nil -- when we started displaying the ith message
  o.i = 0 -- where we our in our
  o.cur = 1 -- current string
  o.done = false
  return o
end

fragment = {
  color = {},
  c = nil,
  dx = 0,
  dy = 0,
  fxv = 0,
  delay = nil,
  image = nil,
  underline = nil,
  delay_accum = 0,
}


function fragment.new(class, o, message_instance)
  o = o or {}
  if (o.color) then setmetatable(o.color, { __index = (message_instance or message).color }) end
  setmetatable(o, class)
  class.__index = class
  return o
end

function fragment:update() end

function message:parse(string)
  -- ctx = {}
  local chars = {}
  for i=1,#string do
    add(chars, { c=sub(string, i, i), setup = nil, skip = false, fragment_index = nil })
  end
  for i=1,#chars - 1 do
    local fx = self.effects[chars[i+1].c]
    if chars[i].c=='$' and fx then
      chars[i].setup = fx:closure(fx:parse(chars, i))
    end
  end
  local fragments = {}
  fragments[0] = fragment:new()
  for char in all(chars) do
    if not char.skip then
      add(fragments, fragment:new({ color = {}, c = char.c }, self))
    end
    char.fragment_index = #fragments
  end
  for char in all(chars) do
    if char.setup then
      char.setup(fragments, char.fragment_index + 1)
    end
  end

  local accum = 0
  -- for f in all(fragments) do
  for i = 0, #fragments do
    local f = fragments[i]
    if not f.skip then
      accum = accum + (f.delay or self.delay or 0)
      f.delay_accum = accum
    end
  end
  return fragments
end

function message:is_complete()
  local done = self.done
  if not self.last_press then done = true end
  return self.cur >= #self.fragments and self.i >= #self.fragments[self.cur] and done
end

function message:update()
  local consume = false
  if not self.istart then self.istart = time() end
  local fragments = self.fragments[self.cur]
  if btnp(self.next_message.button) then
    if self.i < #fragments then
      self.i=#fragments
      consume=true
    elseif self.cur < #self.fragments then
      sfx(self.sound.next_message)
      self.i = 0
      self.cur = self.cur +  1
      self.istart = time()
      consume=true
    elseif self.last_press then
      if not self.done then
        -- we must be on the last thing.
        sfx(self.sound.next_message)
        consume=true
        self.done = true
      end
    end
  end
  --like seriously, its just vital function stuff.
  if time() - self.istart > fragments[self.i].delay_accum
    and self.i < #fragments then
      self.i = self.i + 1
      sfx(self.sound.blip)
  end
  return consume
end

function message:draw(x, y)
  local fragments = self.fragments[self.cur]
  --i mean, hey... if you want
  --to keep reading, go ahead.
  local _x=0
  local _y=0
  for i = 1, self.i do
    assert(self.i <= #fragments, "outside of fragments i " .. self.i .. " #f " .. #fragments)
    local f = fragments[i]
    --i wont try and stop you.
    -- local str = sub(f.c, 1, self.i)
    local str = f.c

    if f.image then
      spr(f.image, x+_x+f.dx, y+f.dy+_y)
    end
    --you're probably getting
    --bored now, right?
    local outline = f.color.outline
    if outline and outline ~= 16 then
      local __x=x+_x+f.dx
      local __y=y+_y+f.dy
      for i4=1,3 do
        for j4=1,3 do
          print(str, __x-2+i4, __y-2+j4, outline)
        end
      end
    end
    local highlight = f.color.highlight
    if highlight and highlight ~= 16 then
      rectfill(x+_x-1, y+_y-1, x+_x+self.spacing.letter-1,y+_y+5, highlight)
    end

    --yep, not much here...
    print(str, x+_x+f.dx, y+f.dy+_y, f.color.foreground)
    if f.underline == 1 then
      line(x+_x, y+_y+5, x+_x+self.spacing.letter, y+_y+5)
    end

    _x = _x + self.spacing.letter
    -- split by the newlines too?
    if f.c == '\n' then
      _x=0
      _y = _y + self.spacing.newline
    end
  end
  -- this is the dot
  if self.i>=#fragments and self.next_message.char then
    local _t = 1.6 * time()
    print(self.next_message.char, x+_x+cos(_t), y+_y+sin(_t), self.next_message.color)
  end
  --i mean, its not like
  --i care.
  for i=1,#fragments do
    fragments[i]:update(i/3)
  end

  --enjoy the script :)--
end

function message:reset()
end


-- choice box
message_choice = message:new({ choices = nil,
                               choices_values = nil
                            })
function message_choice:new(o, strings, choices, choices_values)
  o = message.new(self, o, strings)
  o.choices = choices or o.choices
  o.choices_values = choices_values or o.choices_values or {}
  assert(#o.choices ~= 0, "choices must have indexed keys")
  if strings then
  o.header = strings[#strings]
  else
  o.header = o[#o]
  end
  o.choice = 1
  o.canceled = false
  o.last_choice = nil
  o:update_strings()
  return o
end

function message_choice:reset()
  self.last_choice = nil
  self.canceled = false
  self:update_strings()
end


function message_choice:update_strings()
  local str = self.header
  local sep
  for i = 1, #self.choices do
    if i == self.choice then
      if self.last_choice == nil then
        sep=">"
      elseif self.canceled then
        sep=" "
      else
        sep="."
      end
    else
      sep=" "
    end
    str = str .. "\n" .. sep .. " " .. self.choices[i]
  end
  local c = #self.fragments
  self.fragments[c] = self:parse(str)
  if self.cur == c then
    self.i = min(self.i, #self.fragments[c])
  end
end

function message_choice:result()
  local i = self.last_choice
  local k = self.choices[i]
  local v = self.choices_values[k]
  return i, k, v
end

function message_choice:update()
  if not message.is_complete(self) then
    return message.update(self)
  else
    if self.last_choice ~= nil then
      return false
    elseif btnp(5) or btnp(4) or btnp(1) then
      self.last_choice = self.choice
      self:update_strings()
      return true
    elseif btnp(0) then
      self.canceled = true
      self:update_strings()
      return false
    elseif self.last_choice == nil then
      local _choice = self.choice
      if btnp(3) then _choice = _choice +  1 end
      if btnp(2) then _choice = _choice -  1 end
      local _choice = mod1(_choice, #self.choices)
      if _choice ~= self.choice then
        self.choice = _choice
        self:update_strings()
        return true
      end
      return false
    else
      return false
    end
  end
end

function message_choice:is_complete()
  return message.is_complete(self) and (self.last_choice or self.canceled)
end

--#include particles.p8
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
    itch: https:--maxwelldexter.itch.io/
    twitter: @KearneyMax
]]

-------------------------------------------------- globals

prev_time = nil -- for calculating dt
delta_time = nil -- the change in time

function update_time()
 delta_time = time()-prev_time
 prev_time = time()
end

ps_gravity = 50

function calc_ps_gravity(a)
 a.velocity.y = a.velocity.y + delta_time * ps_gravity
end

function vec(x,y)
 return {x = x, y = y}
end

-------------------------------------------------- particle
particle = {}
particle.__index = particle
function particle.create()
 local p = {}
 setmetatable (p, particle)
 return p
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

function emitters:update(delta_time)
  for e in all(self) do
    e:update(delta_time)
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
 self.life = self.life -  dt

 if (self.gravity) then
  calc_ps_gravity(self)
 end

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
  self.current_colour_time = self.current_colour_time -  dt
  if (self.current_colour_time < 0) then
   self.colours_index = self.colours_index +  1
   self.colour = self.colours[self.colours_index]
   self.current_colour_time = self.colour_time
  end
 end

 -- changing the sprite
 if (self.sprites ~= nil and #self.sprites > 1) then
  self.current_sprite_time = self.current_sprite_time -  dt
  if (self.current_sprite_time < 0) then
   self.sprites_index = self.sprites_index +  1
   self.sprite = self.sprites[self.sprites_index]
   self.current_sprite_time = self.sprite_time
  end
 end

 -- moving the particle
 if (self.life > 0) then
  self.pos.x = self.pos.x + self.velocity.x * dt
  self.pos.y = self.pos.y + self.velocity.y * dt
 else
  self.die(self) -- goodbye world
 end
end

-- draws a circle with it's values
function particle:draw()
 if (self.sprite ~= nil) then
  spr(self.sprite, self.pos.x, self.pos.y)
 elseif (self.colour ~= nil) then
  circfill(self.pos.x, self.pos.y, self.size, self.colour)
 end
end

-- sets flag so that the emitter knows to kill it
function particle:die()
 self.dead = true
end

-------------------------------------------------- particle emitter
emitter = {}
emitter.__index = emitter
function emitter.create(x,y, frequency, max_p, burst, gravity)
 local p = {
  particles = {},
  to_remove = {},

  -- emitter variables
  pos = vec(x,y),
  emitting = true,
  frequency = frequency,
  emit_time = 0,
  max_p = max_p,
  gravity = gravity or false,
  burst = burst or false,
  burst_amount = max_p,
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
 setmetatable (p, emitter)
 -- if (p.max_p < 1) then
 --   p.use_pooling = false end

 return p
end

-- tells all of the particles to update and removes any that are dead
function emitter:update(dt)
 self.emit(self, dt)
 for p in all(self.particles) do
  p.update(p, dt)
  if (p.dead) then
   self.remove(self, p)
  end
 end
 self.remove_dead(self)
end

-- tells of the particles to draw themselves
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
  x = x +  flr(rnd(width)) - (width / 2)
  y = y +  flr(rnd(height)) - (height / 2)
 end

 local p = nil
 if (self.use_pooling and #self.particles + #self.pool == self.max_p) then
  p = self.pool[1]
  del(self.pool, p)
 else
  p = particle.create()
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
    self.add_particle(self, self.get_new_particle(self))
   end
   self.emitting = false

  -- we're continuously emitting
  else
   self.emit_time = self.emit_time +  self.frequency
   if (self.emit_time >= 1) then
    local amount = self.get_amount_to_spawn(self, self.emit_time)
    for i=1, amount do
     self.add_particle(self, self.get_new_particle(self))
    end
    self.emit_time = self.emit_time -  amount
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

function emitter:add_particle(p)
 add(self.particles, p)
end

function emitter:add_multiple(ps)
 for p in all(ps) do
  add(self.particles, p)
 end
end

function emitter:remove(p)
 add(self.to_remove, p)
end

function emitter:remove_dead()
 for p in all(self.to_remove) do
  if (self.use_pooling) then
   add(self.pool, p)
  end
  del(self.particles, p)
 end
 self.to_remove = {}
end

-- will randomise even if it is negative
function get_rnd_spread(spread)
 return rnd(spread * sgn(spread)) * sgn(spread)
end

function emitter:start_emit()
 self.emitting = true
end

function emitter:stop_emit()
 self.emitting = false
end

function emitter:is_emitting()
 return self.emitting
end

function emitter:clone()
 local new = emitter.create(self.pos.x, self.pos.y, self.frequency, self.max_p)
 ps_set_burst(new, self.burst, self.burst_amount)
 ps_set_gravity(new, self.gravity)
 ps_set_rnd_colour(new, self.rnd_colour)
 ps_set_rnd_sprite(new, self.rnd_sprite)
 ps_set_area(new, self.area_width, self.area_height)
 ps_set_colours(new, self.p_colours)
 ps_set_sprites(new, self.p_sprites)
 ps_set_life(new, self.p_life, self.p_life_spread)
 ps_set_angle(new, self.p_angle, self.p_angle_spread)
 ps_set_speed(new, self.p_speed_initial, self.p_speed_final, self.p_speed_spread_initial, self.p_speed_spread_final)
 ps_set_size(new, self.p_size_initial, self.p_size_final, self.p_size_spread_initial, self.p_size_spread_final)
 ps_set_pooling(new, self.use_pooling)
 return new
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

-- #include timer.p8
-- timer

function wait_frames(f)
  for _=1,f do
    yield()
  end
end

function wait(t)
  local start = time()
  while time() - start < t do
    yield()
  end
end

coroutines = {}

function coroutines:start(f, ...)
  add(self, { co = cocreate(f), args = {...} })
end

-- https:--wiki.zlg.space/programming/pico8/recipes/coroutine
function coroutines:update()
  local s
  local t
  if #self > 0 then
    for c in all(self) do
      t = c.co
      s = costatus(t)
      if s ~= 'dead' then
        active, exception = coresume(t, unpack(c.args))
        if exception then
          printh(trace(t, exception))
          stop(trace(t, exception))
        end
      else
        del(coroutines, c)
      end
    end
  end
end


-- set ourselves up to get called each update.
if scene then add(scene, coroutines) end

-- #include _collision.p8
-- wall and actor collisions
-- by zep

scene = {
}

intro_message = intro_message or { "hi there" }
debug = debug or false
credits_text = [[cardboard toad

by ryland
]] or credits_text

room_color = {}
room_color[1] = 1
player_room = -1
toad_distance = 5

function scene:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function scene:enter()
end

function scene:update()
end

function scene:draw()
end

-- all actors
actors = {}

actor = {
	k = nil,
	x = nil,
	y = nil,
	width = 1,
	height = 1,
	dx = 0,
	dy = 0,
	frame = 0,
	t = 0,
	friction = 0.15,
	bounce  = 0.3,
	frames = 2,

	-- half-width and half-height
	-- slightly less than 0.5 so
	-- that will fit through 1-wide
	-- holes.
	w = 0.4,
	h = 0.4,
}

-- make an actor
-- and add to global collection
-- x,y means center of the actor
-- in map tiles
function actor:new(a, k, x, y)
  a = a or {}
  setmetatable(a, self)
  self.__index = self
  a.k = k or a.k
  a.x = x or a.x
  a.y = y or a.y
  -- if is_add == undefined or is_add then add(actors,a) end
  return a
end

function actor:update()
end

function actor.draw(a)
	local sx = (a.x * 8) - 4
	local sy = (a.y * 8) - 4
	spr(a.k + flr(a.frame) * a.width, sx, sy, a.width, a.height)
end


function actor.is_sprite(a, s)
	return s >= a.k and s < a.k + a.frames
end

function enter_room(room)
	if room == 12 then
		-- mario's room

	end

	if room == 1 then
		-- mario's room
		curr_scene.text = {
			[[hi, i'm a mario.]],
			[[let's hit this pinata!]]
		}
	end

end

--function page:new(o)
--  o = o or {}
--  setmetatable(o, self)
--  self.__index = self
--  return o
--end

function scan_map(f)
  local result = {}
  for x = 0,127 do
    for y = 0,31 do
      if f(mget(x,y)) then
        add(result, {x, y})
      end
    end
  end
  return result
end

function replace_actors(a)

  for place in all(scan_map(function (k) return a:is_sprite(k) end)) do
	if mget(place[1], place[2]) == 0 then return end
	for x=0,a.width - 1 do
		for y=0,a.height - 1 do
			mset(place[1] + x, place[2] + y, 0)
		end
	end
	o = a:new({})
	-- o = a.clone()
    -- o = {}
    -- setmetatable(o, a)
    -- o.__index = a
    o.x = place[1]
    o.y = place[2]

    add(actors,o)
  end
end

function confetti()

 local left = emitter.create(0, 0, 5, 10, false, false)
 ps_set_size(left, 0, 0, 1)
 ps_set_speed(left, 10, 20, 10)
 ps_set_colours(left, {7, 8, 9, 10, 11, 12, 13, 14, 15})
 ps_set_rnd_colour(left, true)
 ps_set_life(left, 0.4, 1)
 ps_set_angle(left, 30, 45)
 return left
end

function stars()

	local my_emitters = emitters:new()
  local front = emitter.create(0, 64, 0.2, 0)
  ps_set_area(front, 0, 128)
  ps_set_colours(front, {7})
  ps_set_size(front, 0)
  ps_set_speed(front, 34, 34, 10)
  ps_set_life(front, 3.5)
  ps_set_angle(front, 0, 0)
  add(my_emitters, front)
  local midfront = front.clone(front)
  ps_set_frequency(midfront, 0.15)
  ps_set_life(midfront, 4.5)
  ps_set_colours(midfront, {6})
  ps_set_speed(midfront, 26, 26, 5)
  add(my_emitters, midfront)
  local midback = front.clone(front)
  ps_set_life(midback, 6.8)
  ps_set_colours(midback, {5})
  ps_set_speed(midback, 18, 18, 5)
  ps_set_frequency(midback, 0.1)
  add(my_emitters, midback)
  local back = front.clone(front)
  ps_set_frequency(back, 0.07)
  ps_set_life(back, 11)
  ps_set_colours(back, {1})
  ps_set_speed(back, 10, 10, 5)
  add(my_emitters, back)
  local special = emitter.create(64, 64, 0.2, 0)
  ps_set_area(special, 128, 128)
  ps_set_angle(special, 0, 0)
  ps_set_frequency(special, 0.01)
  -- ps_set_sprites(special, {78, 79, 80, 81, 82, 83, 84})
  ps_set_sprites(special, {107, 108, 109, 110})
  ps_set_speed(special, 30, 30, 15)
  ps_set_life(special, 5)
  add(my_emitters, special)
  local front = emitter.create(0, 64, 0.2, 0)
  ps_set_area(front, 0, 128)
  ps_set_colours(front, {7})
  ps_set_size(front, 0)
  ps_set_speed(front, 34, 34, 10)
  ps_set_life(front, 3.5)
  ps_set_angle(front, 0, 0)
  add(my_emitters, front)
  return my_emitters
end

actor_with_particles = actor:new {
  emitter = nil
}

function actor_with_particles:new(o, k, x, y)
  o = actor.new(self, o, k, x, y)
  if o.emitter then o.emitter = o.emitter:clone() end
  return o
end

function actor_with_particles:update()
	actor.update(self)
	if self.emitter then
		self.emitter.pos.x = self.x * 8 - 4
		self.emitter.pos.y = self.y * 8 - 4
		self.emitter.p_angle = atan2(-self.dx, -self.dy)
		self.emitter:update(delta_time)
	end
end
function actor_with_particles:draw()
	actor.draw(self)
	if self.emitter then self.emitter:draw() end
end

function _init()

 prev_time = time()
	-- create some actors

	-- make player
	-- bunny
	pl = actor:new({},220,2,2,false)
	pl.frames=4
	pl.update=random_actor
	replace_actors(pl)
	-- add(actors, pl)


	-- donkey
	-- pl = actor:new({},107,2,2,false)
	-- pl.frames=4
	-- pl.update=random_actor
	-- replace_actors(pl)

	pl = actor:new({},41,2,2,false)
	pl.frames=4
	replace_actors(pl)

	pl = actor:new({},37,2,2,false)
	replace_actors(pl)

	-- pl = actor:new({},9,2,2)
	-- princess peach
	pl = actor:new({},96,2,2)
	-- pl = actor:new({},96,68,22)
	pl.height=2
	pl.width=2
	pl.w = pl.w *  2
	pl.h = pl.h *  2
	pl.frames=4
	add(actors, pl)
	-- replace_actors(pl)


	pinata = actor_with_particles:new({
			emitter = confetti(),

			follow = follow_actor(pl, -0.10)
					}, 107,2,2, false)
	-- pl = actor:new({},96,68,22)
	pinata.frames=4
	-- pinata.update=follow_actor(pl, -0.10)
	function pinata:update()
		actor_with_particles.update(self)
		local mhspd = abs(self.dx) + abs(self.dy)
		self.emitter.emitting = mhspd > 0.2
		self.follow(self)
	end
	function pinata:draw()
		actor_with_particles.draw(self)

	end
	replace_actors(pinata)


	bowser = actor:new({},165,2,2, false)
	-- bowser = actor:new({},96,68,22)
	bowser.height=2
	bowser.width=2
	bowser.w = bowser.w *  2
	bowser.h = bowser.h *  2
	bowser.frames=2
	bowser.update=random_actor
	replace_actors(bowser)

	luigi = actor:new({},208,2,2, false)
	luigi.height=3
	luigi.width=2
	luigi.w = luigi.w *  2
	luigi.h = luigi.h *  3
	luigi.frames=1
	-- luigi.update=random_actor
	replace_actors(luigi)

	mario = actor:new({},144,2,2, false)
	mario.height=3
	mario.width=2
	mario.w = mario.w *  2
	mario.h = mario.h *  3
	mario.frames=1
	-- mario.update=random_actor
	replace_actors(mario)

	toad = actor:new({},169,2,2, false)
	-- toad = actor:new({},96,68,22)
	toad.height=2
	toad.h = toad.h *  2
	toad.frames=4
	toad.follow=follow_actor(pl)
	toad.distance=5
	function toad:update()
		if mhdistance(pl, self) > toad_distance then self:follow() end
	end
	replace_actors(toad)

	-- bouncy ball
	ball = actor:new({},33,8.5,11)
	ball.dx=0.05
	ball.dy=-0.1
	ball.friction=0.02
	ball.bounce=1
	add(actors, ball)
	replace_actors(ball)

	-- red ball: bounce forever
	-- (because no friction and
	-- max bounce)
	ball = actor:new({},49,22,20)
	ball.dx=-0.1
	ball.dy=0.15
	ball.friction=0
	ball.bounce=1
	add(actors, ball)
--	?ball:is_sprite(50)
	replace_actors(ball)
--	stop()
--	break
	-- treasure
	-- for i=0,16 do
	local i = 0
	a = actor:new({},35,8+cos(i/16)*3,
						10+sin(i/16)*3)
		-- add(actors, a)
	a.w=0.25 a.h=0.25
	-- end
	replace_actors(a)

	a = actor:new({},52,8+cos(i/16)*3,
						10+sin(i/16)*3)
		-- add(actors, a)
	a.w=0.25 a.h=0.25
	a.frames = 1
	-- end
	replace_actors(a)

	-- blue peopleoids
	a = actor:new({},91,7,5)
	a.frames=4
	a.dx=1/8
	a.friction=0.1
	-- a.update=follow_actor(pl)
	a.update=follow_actor(ball)
	-- add(actors, a)
	replace_actors(a)

	-- purple guys
	a = actor:new({},204,7,5,false)
	a.frames=4
	a.update=follow_actor(ball)
	a.dx=1/8
	a.friction=0.1
	replace_actors(a)

	-- cool guy
	a = actor:new({},17,7,5,false)
	a.update=follow_actor(ball)
	a.dx=1/8
	a.friction=0.1
	replace_actors(a)


	-- for i=1,6 do
	--  a = actor:new({},91,20+i,24)
	--  a.update=follow_actor(ball)
	--  a.frames=4
	--  a.dx=1/8
	--  a.friction=0.1
	-- 	add(actors, a)
	-- end

end

-- for any given point on the
-- map, true if there is wall
-- there.

function solid(x, y)
	-- grab the cel value
	val=mget(x, y)

	-- check if flag 1 is set (the
	-- orange toggle button in the
	-- sprite editor)
	return fget(val, 1)

end

-- solid_area
-- check if a rectangle overlaps
-- with any walls

--(this version only works for
--actors less than one tile big)

function solid_area(x,y,w,h)
	return
		solid(x-w,y-h) or
		solid(x+w,y-h) or
		solid(x-w,y+h) or
		solid(x+w,y+h)
end


-- true if [a] will hit another
-- actor after moving dx,dy

-- also handle bounce response
-- (cheat version: both actors
-- end up with the velocity of
-- the fastest moving actor)

function solid_actor(a, dx, dy)
	for a2 in all(actors) do
		if a2 ~= a then

			local x=(a.x+dx) - a2.x
			local y=(a.y+dy) - a2.y

			if ((abs(x) < (a.w+a2.w)) and
					 (abs(y) < (a.h+a2.h)))
			then

				-- moving together?
				-- this allows actors to
				-- overlap initially
				-- without sticking together

				-- process each axis separately

				-- along x

				if (dx ~= 0 and abs(x) <
				    abs(a.x-a2.x))
				then

					v=abs(a.dx)>abs(a2.dx) and
					  a.dx or a2.dx
					a.dx,a2.dx = v,v

					local ca=
					 collide_event(a,a2) or
					 collide_event(a2,a)
					return not ca
				end

				-- along y

				if (dy ~= 0 and abs(y) <
					   abs(a.y-a2.y)) then
					v=abs(a.dy)>abs(a2.dy) and
					  a.dy or a2.dy
					a.dy,a2.dy = v,v

					local ca=
					 collide_event(a,a2) or
					 collide_event(a2,a)
					return not ca
				end

			end
		end
	end

	return false
end


-- checks both walls and actors
function solid_a(a, dx, dy)
	if solid_area(a.x+dx,a.y+dy,
				a.w,a.h) then
				return true end
	return solid_actor(a, dx, dy)
end

-- return true when something
-- was collected / destroyed,
-- indicating that the two
-- actors shouldn't bounce off
-- each other

function collide_event(a1,a2)

	-- player collects treasure
	if (a1==pl and a2.k==35) then
		del(actors,a2)
		sfx(3)
		return true
	end

	sfx(2) -- generic bump sound

	return false
end

function actor.move(a)
	local r = what_room(a)
	if (r == player_room
	    or is_adjacent(r, player_room)) then
		-- or mhdistance(a, pl) < 5 then
	-- if what_room(a) ~= player_room then return end

	-- only move actor along x
	-- if the resulting position
	-- will not overlap with a wall

	if not solid_a(a, a.dx, 0) then
		a.x = a.x +  a.dx
	else
		a.dx = a.dx *  -a.bounce
	end

	-- ditto for y

	if not solid_a(a, 0, a.dy) then
		a.y = a.y +  a.dy
	else
		a.dy = a.dy *  -a.bounce
	end

	-- apply friction
	-- (comment for no inertia)

	a.dx = a.dx *  (1-a.friction)
	a.dy = a.dy *  (1-a.friction)

	-- advance one frame every
	-- time actor moves 1/4 of
	-- a tile

	a.frame = a.frame +  abs(a.dx) * 4
	a.frame = a.frame +  abs(a.dy) * 4
	a.frame = a.frame %  a.frames

	a.t = a.t +  1

	a:update()
	end

end

function control_player(pl)

	accel = 0.05
	if btn(0) then pl.dx = pl.dx -  accel  end
	if btn(1) then pl.dx = pl.dx +  accel  end
	if btn(2) then pl.dy = pl.dy -  accel  end
	if btn(3) then pl.dy = pl.dy +  accel  end

end

function random_actor(a)
	if rnd(1) < 0.1  then
		accel = 0.05
		a.dx = a.dx +  accel * (rnd(2) - 1)
		a.dy = a.dy +  accel * (rnd(2) - 1)
	end
end


function follow_actor(follow, accel)
	return function(a)
		if rnd(1) < 0.1 then
			local x = sgn(follow.x - a.x)
			local y = sgn(follow.y - a.y)
			-- if what_room(a) ~= what_room(follow) then
			-- 	x = 0
			-- 	y = 0
			-- end
			accel = accel or 0.05
			a.dx = a.dx +  accel * (x + (rnd(2) - 1))
			a.dy = a.dy +  accel * (y + (rnd(2) - 1))
		end
	end
end

collision = scene:new({})

function is_adjacent(room1, room2)
	return (room1 == room2 - 1
		 or room1 == room2 + 1
		 or room1 == room2 + 8
		 or room1 == room2 - 8)
end

function collision:update()
	control_player(pl)
	local current_player_room = what_room(pl)
	if current_player_room ~= player_room then enter_room(current_player_room + 1) end
	player_room = current_player_room
	-- foreach(actors, actor.move)

	for a in all(actors) do
		a:move()
	end

end

-- function distance(a1, a2)
-- 	return sqrt((a1.x - a2.x)^2 + (a1.y - a2.y)^2)
-- end

-- function sqdistance(a1, a2)
-- 	return (a1.x - a2.x)^2 + (a1.y - a2.y)^2
-- end

function mhdistance(a1, a2)
	return abs(a1.x - a2.x) + abs(a1.y - a2.y)
end

function what_room(a)
	return flr(a.x/16) + 8 * flr(a.y/16)
end

function what_roomish(a)
	return (a.x/16) + 8 * (a.y/16)
end

function collision:draw()

	cls(room_color[player_room + 1] or background_color)

	room_x=flr(pl.x/16)
	room_y=flr(pl.y/16)
	camera(room_x*128,room_y*128)

	map()
	for a in all(actors) do
		a:draw()
	end
	-- foreach(actors,actor.draw)
	--replace_actors(actor[1])
end


dialog = collision:new({ text = nil, message = nil, origin = {0, 0} })

function dialog:update()
	local m = self:get_message()

	if (m == nil) then
		collision.update(self)
		return
	end
	m:update()
	if m:is_complete() then
		if self.on_complete then self:on_complete() end
		self.on_complete = nil
		self.message = nil
		self.text = nil
	end

end

function dialog:get_message()
	if self.message == nil and self.text ~= nil then
		self.message = message:new({}, self.text)
	end
	return self.message
end

function rectborder(x0, y0, w, h, fill, border)
	rectfill(x0, y0, x0 + w, y0 + h, fill)
	rect    (x0, y0, x0 + w, y0 + h, border)
end

function dialog:draw()
	collision.draw(self)
	camera(0, 0)
	local border = 10
	if debug then print("room " .. (what_room(pl) + 1), border, border, 7) end
	local m = self:get_message()
	if m == nil then return end

	rectborder(border + self.origin[1], border + self.origin[2], 128 - 2 * border, 44, 7, 6)
	m:draw(self.origin[1] + border * 1.5, self.origin[2] + 1.5 * border)
end


title = scene:new({})

cart_screen = false

function title:get_message()
	if self.message == nil then
		self.message = message:new({}, intro_message)
	end
	return self.message
end

function title:draw()
	cls()
	-- palt(0, true)
	camera(7 * 128, 0)
	map()
	camera(0, 0)
	local border = 10
	if cart_screen then
		print("by ryland von hunter", 24, 90, 7)
		print("(c) 2023-02-28", 24, 100, 7)
	else
		rectfill(border, 64 + border, 127 - border, 127 - border, 7)
		rect(border, 64 + border, 127 - border, 127 - border, 6)
		line(border, 64 + border,
			63, 64 + 3 * border, 6)

		line(63, 64 + 3 * border,
			127 - border, 64 + border, 6)

		title:get_message():draw(border * 1.5, 64 + 1.5 * border)
	end

end


function title:update()
	local m = title:get_message()
	m:update()
	-- if m:is_complete() and btnp(5) then curr_scene = collision end
	if m:is_complete() and btnp(5) then curr_scene = dialog end
end

credits = scene:new {
	emitter = stars(),
	-- x = 25,
	x = 35,
	y = 145,
	t = 0,
	f = 0,
	speed = -4,
}

function title:enter()
	music(4, 600)
end

function credits:enter()
	music(4, 600)
end

function credits:update()
	self.f = self.f +  1
	self.t = self.t +  self.speed * delta_time
	self.emitter:update(delta_time)
end

function credits:draw()
	cls(0)
	self.emitter:draw()
	if (self.f < 100) then
		rectfill(0,0, 128 - self.f, 128, 0)
		print("the end", 50, 64, 7)
	end
	print(credits_text, self.x, self.t + self.y)
end

curr_scene = title
curr_scene:enter()
-- curr_scene = credits

function _update()
 if curr_scene.text == nil then
	update_time()
	coroutines:update()
 end
	curr_scene:update()
end

function _draw()
	curr_scene:draw()
end

debug=false
background_color = 11
toad_distance = 0  

intro_message = {
[[you are inveted to marios 
birthday party.  

   push x to continue.   ]],
[[remember to goto marios
 house
and bring  birthday gifts
    press x to play]],
}


credits_text = [[
cardboard toad
by ryland von hunter
art by ryland
music by ryland
programing by 
  shane and ryland
if its your birthday
 dont let your
 pinata run away!
thank you for playing!
]]


-- uncomment to play credits
--curr_scene = credits

-- how many times the player
-- has entered each room
room_count = { 
0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0 }

-- the background color of 
-- each room
room_color = { 
11, 11, 11, 11, 6, 11, 11, 11,
11, 11, 11, 11, 13, 11, 11, 11,
}

function enter_room(room)
  room_count[room] = room_count[room] +  1
  if room == 1 and room_count[1] == 1 then
    music(0, 600)
    
  end
  if room == 13 
  and room_count[13] == 1 then
    curr_scene.text = {
    [[there you are!]],
    [[i was just about to
    hit the pinata.]],
    [[oh no its running 
    away! can you please
    catch it?.]]
    }
    coroutines:start(function() 
      wait(8)
      curr_scene.text = {
      [[i'l help you.  ]]
      }
    end)
  end
  if room == 12 
  and room_count[12] == 1 then
    curr_scene.text = {
    [[musem musem i
    love you.    ]],
    [[signed the
   yoshis ]],
     
 
    
    }
  end 
end

-- keep track of how many times
-- the player has been bumped
-- by other characters.
bump_count = {}
bump_time = {}
-- require 1 second between bumps
function bump_too_soon(a)
  local t = bump_time[a.k]
  bump_time[a.k] = time()
  if t then
    return time() - t > 1
  else
    return false
  end
end

function collide_event(a1, a2)
  if a1 == pl then
    local c = bump_count[a2.k] or 0
    bump_count[a2.k] = c + 1
  end
  if a1 == pl and a2.k == 35 then
    -- orange/red treasure
    del(actors, a2)
    sfx(3)
    return true
  end
  if a1 == pl and a2.k == 52 then
    -- pink treasure
    del(actors, a2)
    sfx(3)
    return true
  end
  if a1 == pl and a2.k == 165 and not bump_too_soon(a2) then
    sfx(3)
    curr_scene.text = {
    [[hi peach!   ]],
    [[ running after
    the pinata huh?    ]],
    [[ beter be quick
    i've heard donkeys
    are fast!  ]],
   [[good   
       luck!    ]]
       }
       return true
  end
  if a1 == pl and a2.k == 208 and not bump_too_soon(a2) then
    sfx(3)
    curr_scene.text = {
    [[hi peach.    ]],
    [[going to marios
    party huh.  ]],
    [[it's not here 
    it's  down there.   ]],
    }
    return true
  end
  if a1 == pl and a2.k == 144 and not bump_too_soon(a2) then
    -- mario talks
    sfx(3)
    curr_scene.text = {
    [[hi peach    ]],  
    [[hurry up dont want
    pinata cloads  ]],
    [[thank you for going
    after it.  ]],
    [[bye peach  ]]
    }
    return true
  end
  if a1 == pl and a2.k == 107 and not bump_too_soon(a2) then
    -- we hit the pinata
    sfx(9)
    music(-1, 600)
    if bump_count[107] >= 3 then
      -- let's end the game. maybe
      curr_scene.text = {
      [[ you got the pinata! ]]
      }
      -- wait 5 seconds then
      -- switch to credits
      function curr_scene:on_complete()
        a2.k = 192
        coroutines:start(function () 
          wait(2)
          curr_scene.text = {
            [[bye  donkey?]]
          }
          while curr_scene.text do
            yield()
          end
          wait(2)
          curr_scene = credits
          curr_scene:enter()
        end)
      end
    end
  end
  sfx(2)
  return false
end
__gfx__
000000003bbbbbb7030003b0003b3000000000000000000000000000000000000000000000009998888000000000000000000000000000000000000000000000
000000003000000b33303b3b03333b30101110100000000000000000000000000000000000009988888000000000000000000000000000000000000000113300
000000003000070b333333b303333330000000000000004444000000000000000000000000033338880000000000000000000111000000000000000003173330
000000003000000b33333333033333b30000000000000447444000000000000000000000eee333338811cc111001110000001111000000000000000003337730
000000003000000b33333333043333430000000000004444444400000000000000000000eee333331111cc13330111eee2221111000000000000000000337700
000000003000000b33333333000444400010110100004744444400000000000000000000e99923331111cc13330111eee222111e000000000000000000330000
000000003000000b333333330004040000000000000044444444000000000000000000002229255530111cc3333111ee1112eeee000000000000000000333300
0000000011111111044444400004000000000000000004444440000000000aaaa000000022212535999eeccc333111ee1112eeee000000000000000003030000
aaaaaaaa00ffff0000ffff0000000000cccccccc000004444440000000000a1f1000000022211139999ee555666111ee1112eee0000000000000000000000000
a000000a00dffd0000dffd0000000000cc777ccc00000ffffff0000000000affa0000000222111e999222555666111eeaaaaeeea000000000000000000000000
a000000a00ffff0000ffff0000000000c77777cc00000f1ff1f000000000feeee0000000888222499922255566611199aaaaaaaa000000000000000000000000
a000000a0882288ff882288000000000cc777ccc00000ffffff0000000000eecef000000888222499922205566611199aaaaaaaa000000444444000000000000
a000000af08228000082280f00000000cccccccc00000ddffdd0000000000eece0000000888222499922266666611199999911100000444ffff4000000000000
a000000a008558000085580000000000cc7777cc000ffddffddff00000000eeee0000000000000000022266666611111199011190004fffffff4000000000000
a000000a005005000500005000000000c777777c00000ddffdd0000000000eeee000000000000000000006660001110009011119004fff1ff1ff400000000000
aaaaaaaa066006606600006600000000cc7777cc00000f0000f0000000000f00f00000000000000000000000000555999401111900fffffffffff00000000000
0003b30000aaaa00007777000000000000000000087880008887800008878000087888000000000000000000000555444401111800fff4fffffff00000000000
03b333300a0000a00700007000000000000000000888700087888000078880000888780000000008888800000005554444411188000ff4444fff000000000000
03333330a000770a70007707000aa000000880000cffc0000cffc0000cffc0000cffc0000000000888aaa888ddd85544444400880000fffff4f0000000000000
3b333330a000770a7000770700aa7a00008888000f0ff0000ff0f0000ff0f0000f0ff0000000000888aaa888ddd855888444000000000fffff00000000000000
34333340a000000a7000000700aaaa000087880000cc000000cc000000cc000000cc00000000000111aaa888ddd8558889990011000444fff444000000000000
04444000a000000a70000007000aa000000880000fccf0000fcc00000fccf00000ccf00000000001110eee011100008888880011ff4444fff4444ff000000000
004040000a0000a007000070000000000000000000cc000000ccf00000cc00000fcc000000000011111eee011107770918880011ff4444fff4444ff000000000
0000400000aaaa000077770000000000000000000f0f000000f0000000f0f000000f000000000011111eee0111e777001888f0aa000444fff444000000000000
000000000088880000888800000000000000000009900099030003b0444444440aaaa00000000011111222000ee7770011fff0aa000444fff444000000000000
00000000088888800888888000000000000000000e90099e33303b3b441111140a1f100000000001110222dddeee000001fff0aa000444fff444000000000000
00000000888887788888877800000000000ee0000e9009e0333333b3441414140affa00000000004443332ddd0003333311eeeaa000444fff444000000000000
0000000088888778888887780000000000ee7e00099999903333333341141114feeee00000000004443330d3333333333aaeee00000444fff444000000000000
000000008e8888888e8888880000000000eeee000919919033333333333333330eecef000000000444336633333333333aaeeedd000440000044000000000000
000000008eee88888eee888800000000000ee0000099990033333333633333730eece0000000000454006633333333300aaa00dd000440000044000000000000
0000000008ee888008ee888000000000000000000999990033333333333333330eeee00000000004446666333333111111aaaddd0ff440000044ff0000000000
00000000008888000088880000000000000000000000090004444440333353330eeee00000000004446660333333111111aaaddd0ff440000044ff0000000000
0000000000000000000000000000000000000909090000000000000000000000000090000a0a0a00000000000000000000009000000900000000000000000000
000000000008000000000000000000000000099c99000000000000e000000000000090000aacaa00000000000000000000009000000900000000000000000000
00700700008880000000000000000000000aaaaaaaaa0000100000a900999000000090000999990009999900000000000000900000090000000aa00000000000
00077000008880000000000000000000000aafcffcaa00000ea9b9ce0900000000009000090000000900090000099000000090000009000000aaaa0000000000
00077000000000000000000000000000000aafffffaa000009b0cb000909999900009000090000000900090000090000099990000009999000aaaa0000000000
00700700000000000000000000000000000aafffffaa00000ea09e0009000000000090000900000009000900000900000900900000090090000aa00000000000
000000000000000000000000000000000000eeeceeee000000000000009990000000900009999900099999000009000009009000000900900000000000000000
000000000000000000000000000000000000eeeceeee000000000000000000000000900000000000000000900009000009999000000999900000000000000000
0000000000000000000000000000000000ffeeeeeee00000000000000000000000000000008878000000000000ccc70000ccc70000ccc70000ccc70000000000
00000000000000a00000000000000000000eeeeeeeeff000000000a000000000000000000078880009b9eb000cccccc00cccccc00cccccc00cccccc000000000
00000000500000910000000000000000000eeeeeeee00000100000930000000000000000000880000e0009000cffffc00cffffc00cffffc00cffffc000000000
000000000f13e384000000000000000000eeeeeeee0000000c93e3ce00000000000000000007800009000e000c5ff5c00c5ff5c00c5ff5c00c5ff5c000000000
000000000ea9f980000000000000000000eeeeeeee0000000ea9a9000001100000000000000880000c000c000cffffc00cffffcc0cffffc0ccffffc000000000
000000000130c300000000000000000000eeeeeeee0000000930c3000001100000000000000870000aebed00ccccccccccccccc0cccccccc0ccccccc00000000
000000000f609e000000000000000000000f000f000000000ea09e00000114400000000000088000000000000cccccc00cccccc00cccccc00cccccc000000000
00000000021021000000000000000000000f000f0000000000000000000114400000000000087000000000000c0000c0c00000c00c0000c00c00000c00000000
00000909090000000000090909000000000009090900000000000909090000000878800000000000000000000000000000000000000000000000000000000000
0000099c990000000000099c990000000000099c990000000000099c99000000088870000000000000000000000000a0000000a0000000a0000000a000000000
000aaaaaaaaa0000000aaaaaaaaa0000000aaaaaaaaa0000000aaaaaaaaa00000cffc00000000000000000001000009310000093100000931000009300000000
000aafcffcaa0000000aafffffaa0000000aafcffcaa0000000aafcffcaa00000f3ff00000000000000000000c93e3ce0c93e3ce0c93e3ce0c93e3ce00000000
000aafffffaa0000000aafffffaa0000000aafffffaa0000000aafffffaa000000cc000000000000000000000ea939000ea939000ea939000ea9390000000000
000aafffffaa0000000aafffffaa0000000aafffffaa0000000aafffffaa00000fccf00000000000000000000930c30009300c300930c3009300c30000000000
00f0eeeceeee00000000eeeceeee00000000eeeceeee00000000eeeceeee000000cc000000000000000000000ea09e000ea009e00ea09e00ea009e0000000000
000feeeceeee00000000eeeceeee00000000eeeceeee00000000eeeceeeef0000f0f000000000000000000000000000000000000000000000000000000000000
0000eeeeeee0000000ffeeeeeee0000000ffeeeeeee0000000ffeeeeeeef00000000000044444444bbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
0000eeeeeeeff000000eeeeeeeeff0000000eeeeeeeff000000eeeeeeee000000000000044444444bdbbbb9bbbbbbbbbbbbbbbbb000000000000000000000000
0000eeeeeee00000000eeeeeeee000000000eeeeeee00000000eeeeeeee000000000000044444444bbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
000eeeeeeee0000000eeeeeeee000000000eeeeeeee0000000eeeeeeee0000000000000044444444bbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
000eeeeeeeee000000eeeeeeee00000000eeeeeeeee0000000eeeeeeee0000000000000044444444bbb1bbbbbbb8bbbbbbbbbbbb000000000000000000000000
00eeeeeeeeee000000eeeeeeee00000000eeeeeeeee0000000eeeeeeee0000000000000044444444bbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
000f0000ff000000000f000f00000000000f000f000000000ff0000f000000000000000044444444bebbbb8bbbbbbbbbbebbbbbb000000000000000000000000
000f000000000000000f000f00000000000f000f000000000000000f000000000000000044444444bbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
00000000000000354444444444444444444444444444444400000000a88888888888888800000000888888888888888809900990990009900990099009900099
00030000000000004222222222222224499999999999999400000000a8888888888888880000000087000000000700780e9009e0e99009e00e9009e00e90099e
44413300000000004228888888882224499333333333999400000000a8888888888888880088880080700000007007080e9009e00e9009e00e9009e00e9009e0
00331330000000004222288778882224499993377333999400000000a88888888888888808878880800700000700700809999990099999900999999009999990
003331330000000042222888fff4222449999333fff4999408000000a88888888888888888888878800070007007000809199190091991900919919009199190
00003313000000004222241ff1f422244999941ff1f4999480000000a88888888888888887888888870007077770000800999900009999000099990000999900
0000033100000000422224fffff22224499994fffff9999400000000a88888888888888888888888807007707700000800999900009999900099990009999900
0000000000000000422222fffff22224499999fffff9999400000000a88888888888888808887880807770077000000809000900009000000090009000000900
00000000000000004222888118822224499933311339999400000000000000008888888a0888888080777077707000080000000000000000cccccccc00000000
00008888888800004222811118822224499931111339999400000000000000008888888a0ffffff087000700770000080000000000000000cc777ccc00000000
008888888888000042ff81111882222449ff31111339999400088000000000008888888a0f1ff1f080007770007000080000000000000000c77777cc00000000
00004fffff44000042228111118ff22449993111113ff99400870800000000008888888a0ffffff080070077000700080000000000000000cc777ccc00000000
0004fffffff400004222819191822224499931919139999400807800000000008888888a0ccffcc080700000700700080000000000000000cccccccc00000000
004fff1ff1ff40004222811111822224499931111139999400088000000000008888888afccffccf87000000070070080000000000000000cc7777cc00000000
00fffffffffff0004222811111822224499931111139999400000000000000008888888a0ccffcc080000000070007080000000000000000c777777c00000000
00fffffffffff0004444444444444444444444444444444400000000000000008888888a0f0000f080000000007000780000000000000000cc7777cc00000000
00ff4444fffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000fff444fff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000fffffff000000000000000000088880000000000000000000000000000000000000000888800008888000088880000888800000000000000000000000000
00000fffff0000000000000000000800008000000000000000080800000000000008080008878880088788800887888008878880000000000008080000000000
00018888888100000000000000008070000800000007777700033300000777770003330088888878888888788888887888888878000777770003330000000000
ff81888888818ff000000000000807070007800000073a33703313f000073a33703313f08788888887888888878888888788888800073a33703313f000000000
ff81888888818ff00000000000080070707080000073333373333ff00073333373333ff0888888888888888888888888888888880073333373333ff000000000
00011111111100000000000000080007070080000073333337333f000073333337333f00088878800888788008887880088878800073333337333f0000000000
00011a1111a100000000000000080000707080000073333337000000007333333700000008888880088888800888888008888880007333333700000000000000
0001111111110000000000000008000707078000007a333a37000000007a333a370000000ffffff00ffffff00ffffff00ffffff0007a333a3700000000000000
0001111111110000000000000000807000780000007333333700000000733333370000000f1ff1f00f1ff1f00f1ff1f00f1ff1f0007333333700000000000000
000111111111000000000000000008000080000000773333375a5a0000733333375a5a000ffffff00ffffff00ffffff00ffffff000733333375a5a0000000000
000110000011000000000000000000888800000003373a337000000003373a33700000000ccffcc00ccffcc00ccffcc00ccffcc003373a337000000000000000
000110000011000000000000000000000000000000373333700000000037333370000000fccffccffccffccffccffccffccffccf003733337000000000000000
0441100000114400000000000000000000000000000077770000000000007777000000000ccffcc00ccffcc00ccffcc00ccffcc0000077770000000000000000
04411000001144000000000000000000000000000000a000a00000000000a00a000000000f0000f0ff0000f00f0000f00f0000ff0000a00a0000000000000000
00000000000000000000000000000000000033300000000000999990000900000000000000000000000000000000000000dddc0000dddc0000dddc0000dddc00
0000005000000050000000500000005000003333333300000090009000099990000900000000000000000000000000000dddddd00dddddd00dddddd00dddddd0
1000005510000055100000551000005500333333333300000090009000090090000000000000000000000000999900000dffffd00dffffd00dffffd00dffffd0
0555555505555555055555550555555500004fffff4400000099999000090000000900000000000000990000900000000d5ff5d00d5ff5d00d5ff5d00d5ff5d0
055555000555550005555500055555000004fffffff400000090000000090000000900000090000000900000900000000dffffd00dffffdd0dffffd0ddffffd0
05505500055005500550550055005500004fff1ff1ff4000009000000009000000090000009999000099000099990000ddddddddddddddd0dddddddd0ddddddd
0550550005500550055055005500550000fffffffffff0000090000000090000000900000090009000900000000900000dddddd00dddddd00dddddd00dddddd0
0000000000000000000000000000000000fffffffffff0000090000000090000000900000090009000990000999900000d0000d0d00000d00d0000d00d00000d
000033300000000044444444444444440000bbb000000000057004700000000077777777ccc9c9c900000000bb4bb4bb07700770770007700770077007700077
00003333333300004bbbbbbbbbbbbbb40000bbbbbbbb000007700770000000007cccc77cc9cccccc00000000bb1441bb0e7007e0e77007e00e7007e00e70077e
00333333333300004bbbb9b9b9bbbbb400bbbbbbbbbb00000770077000000000cc44ccccccc999c900000000bb4444bb0e7007e00e7007e00e7007e00e7007e0
00004fffff4400004bbbb99c99bbbbb400004fffff4400000775757000000000c4444cccc9c999cc00000000bb4114bb07777770077777700777777007777770
0004fffffff400004bbaaaaaaaaabbb40004fffffff40000077777700000000074944777ccc999c900000000b449944b07177170071771700717717007177170
004fff1ff1ff40004bbaafcffcaabbb4004fff1ff1ff400007777f700000000074444c7cc9cccccc00000000bb4994bb00777700007777000077770000777700
00fffffffffff0004bbaafffffaabbb400fffffffffff0000007770000000000c4444cccccc9c9cc00000000bb4444bb00777700007777700077770007777700
00fffffffffff0004bbaafffffaabbb400fffffffffff0000007070000000000cc44cccccccccccc00000000bb4bb4bb07000700007000000070007000000700
00ff4444fffff0004bbbeeeceeeebbb400ff4444fffff00000000000000000000090000000000000000000000000000008788000888780000887800008788800
000fff444fff00004bbbeeeceeeebbb4000fff444fff000000000000000000000090000000000000000000000000000008887000878880000788800008887800
0000fffffff000004bffeeeeeeebbbb40000fffffff0000000000000009999000090000000000000000aaaa5aaa500000cffc0000cffc0000cffc0000cffc000
00000fffff0000004bbeeeeeeeeffbb400000fffff00000000000000009000000090000000000000000aafdffdaa00000f0ff0000ff0f0000ff0f0000f0ff000
00013333333100004bbeeeeeeeebbbb40001bbbbbbb1000000000000009000000099999000000000000aafffffaa000000cc000000cc000000cc000000cc0000
ff31333333313ff04beeeeeeeebbbbb4ffb1bbbbbbb1bff0000000000090000000900090000000000005afffffaa00000fccf0000fcc00000fccf00000ccf000
ff31333333313ff04beeeeeeeebbbbb4ffb1bbbbbbb1bff0000000000099990000900090000000000000544d4444000000cc000000ccf00000cc00000fcc0000
000111111111000044444444444444440001111111110000000000000000000000900090000000000000444d444400000f0f000000f0000000f0f000000f0000
00011a1111a10000000000000000000000011a1111a100000770077000000000000000000000000000ff44444445000000000000033333b00000000000000000
0001111111110000000000000000000000011111111100000e7007e000000000000000090000000000044444444ff0000000000033333b3b0000000000000000
0001111111110000000000000000000000011111111100000e7007e0000000000090009900090000000444444540000000000000333333b30000000000000000
00011111111100000000000000000000000111111111000007777770000000000909090900000000004444444400000000000000333333330000000000000000
00011000001100000000000000000000000110000011000007177170000000000900900900090000004444454400000000000000333333330000000000000000
00011000001100000000000000000000000110000011000000777700000000000900000900090000005444444400000000000000333333330000000000000000
04411000001144000000000000000000044110000011440000777700000000000900000900090000000f000f0000000000000000333333330000000000000000
04411000001144000000000000000000044110000011440000700070000000000900000900090000000f000f0000000000000000044444400000000000000000
__label__
030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0
33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b
333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
04444440044444400444444004444440044444400444444004444440044444400444444004444440044444400444444004444440044444400444444004444440
030003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030003b0
33303b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033303b3b
333333b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333b3
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
04444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444440
030003b0000000000a0a0a00000000000000000000009000000000000009000000000000000000000000000000009000000000000000000000000000030003b0
33303b3b000000000aacaa00000000000000000000009000000000000009000009b9eb0000000000000000000000900000000000000000000000000033303b3b
333333b3000000000999990009999900000000000000900000000000000900000e000900099999000000000000009000000000000000000000000000333333b3
333333330000000009000000090009000009900000009000000000000009000009000e0009000900000990000000900000000000000000000000000033333333
33333333000000000900000009000900000900000999900000000000000999900c000c0009000900000900000999900000000000000000000000000033333333
33333333000000000900000009000900000900000900900000000000000900900aebed0009000900000900000900900000000000000000000000000033333333
33333333000000000999990009999900000900000900900000000000000900900000000009999900000900000900900000000000000000000000000033333333
04444440000000000000000000000090000900000999900000000000000999900000000000000090000900000999900000000000000000000000000004444440
030003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030003b0
33303b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033303b3b
333333b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333b3
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
04444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444440
030003b00000000000000000000000000088780000000000000000000000900000000000000000000000000000000000000000000000000000000000030003b0
33303b3b0000000000000000000000000078880009b9eb0000000000000090000000000000000000000000a00000000000000000000000000000000033303b3b
333333b3000000000000000000000000000880000e000900099999000000900000000000000000001000009300000000000000000000000000000000333333b3
333333330000000000000000000000000007800009000e00090009000000900000000000000000000c93e3ce0000000000000000000000000000000033333333
33333333000000000000000000000000000880000c000c00090009000999900000000000000000000ea9a9000000000000000000000000000000000033333333
33333333000000000000000000000000000870000aebed00090009000900900000000000000000000930c3000000000000000000000000000000000033333333
333333330000000000000000000000000008800000000000099999000900900000000000000000000ea09e000000000000000000000000000000000033333333
04444440000000000000000000000000000870000000000000000090099990000000000000000000000000000000000000000000000000000000000004444440
030003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030003b0
33303b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033303b3b
333333b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333b3
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
04444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444440
030003b00000000000000000000000000000000000000000000000000000000000000909090000000000000000000000000000000000000000000000030003b0
33303b3b000000000000000000000000000000000000000000000000000000000000099c99000000000000000000000000000000000000000000000033303b3b
333333b300000000000000000000000000888800000000000000000000000000000aaaaaaaaa00000000000000000000000000000000000000000000333333b3
3333333300000000000000000000000008878880000000000000000000000000000aafcffcaa0000000000000000000000000000000000000000000033333333
3333333300000000000000000000000088888878000000000000000000000000000aafffffaa0000000000000000000000000000000000000000000033333333
3333333300000000000000000000000087888888000000000000000000000000000aafffffaa0000000000000000000000000000000000000000000033333333
33333333000000000000000000000000888888880000000000000000000000000000eeeceeee0000000000000000000000000000000000000000000033333333
04444440000000000000000000000000088878800000000000000000000000000000eeeceeee0000000000000000000000000000000000000000000004444440
030003b00000000000000000000000000888888000000000000000000000000000ffeeeeeee000000000000007700770000000000000000000000000030003b0
33303b3b0000000000000000000000000ffffff0000000000000000000000000000eeeeeeeeff000000000000e7007e000000000000000000000000033303b3b
333333b30000000000000000000000000f1ff1f0000000000000000000000000000eeeeeeee00000000000000e7007e0000000000000000000000000333333b3
333333330000000000000000000000000ffffff000000000000000000000000000eeeeeeee000000000000000777777000000000000000000000000033333333
333333330000000000000000000000000ccffcc000000000000000000000000000eeeeeeee000000000000000717717000000000000000000000000033333333
33333333000000000000000000000000fccffccf00000000000000000000000000eeeeeeee000000000000000077770000000000000000000000000033333333
333333330000000000000000000000000ccffcc0000000000000000000000000000f000f00000000000000000077770000000000000000000000000033333333
044444400000000000000000000000000f0000f0000000000000000000000000000f000f00000000000000000070007000000000000000000000000004444440
030003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030003b0
33303b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033303b3b
333333b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333b3
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
04444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444440
030003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030003b0
33303b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033303b3b
333333b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333b3
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
04444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444440
030003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030003b0
33303b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033303b3b
333333b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333b3
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
04444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444440
030003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030003b0
33303b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033303b3b
333333b30000000000000000777070700000777070707000777077007700000070700770770000007070707077007770777077700000000000000000333333b3
33333333000000000000000070707070000070707070700070707070707000007070707070700000707070707070070070007070000000000000000033333333
33333333000000000000000077007770000077007770700077707070707000007070707070700000777070707070070077007700000000000000000033333333
33333333000000000000000070700070000070700070700070707070707000007770707070700000707070707070070070007070000000000000000033333333
33333333000000000000000077707770000070707770777070707070777000000700770070700000707007707070070077707070000000000000000033333333
04444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444440
030003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030003b0
33303b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033303b3b
333333b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333b3
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000007000770070000007770777077707770000077707770000077707770000000000000000000000000000000000000000033333333
33333333000000000000000070007000007000000070707000700070000070700070000000707070000000000000000000000000000000000000000033333333
33333333000000000000000070007000007000007770707077700770777070707770777077707770000000000000000000000000000000000000000033333333
04444440000000000000000070007000007000007000707070000070000070707000000070007070000000000000000000000000000000000000000004444440
030003b00000000000000000070007700700000077707770777077700000777077700000777077700000000000000000000000000000000000000000030003b0
33303b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033303b3b
333333b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333b3
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
04444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444440
030003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030003b0
33303b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033303b3b
333333b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333b3
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
04444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444440
030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0030003b0
33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b33303b3b
333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
04444440044444400444444004444440044444400444444004444440044444400444444004444440044444400444444004444440044444400444444004444440

__gff__
0002020200020200000000000002020000000000000202000300000000020200000000000001010101000000000202000000000000000002000000000202020000000000000000000000000000000000000200000000000000000000000002000000000000000000020000000000000000000000000000000000000000000000
0000000000000000000200000000000002020000000000000002000000000200020200000001010303000000000000000202000000010103030000000000000000000000020200020000000000000000020200000202020200000000030303030202000002020002000002020000000002020002020200020000020200000000
__map__
02020202023636020202020202020202020202020202020202020202020202023636363636363636363636363636020202020202020202020202020202020202020202020202020202020202020202029e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e149e9e9e9e9e9e9e9e9e9e9e9e02020202020202020202020202020202
02000000002424003404000000000002020000000000000000000000000000020000000000000036000000000036000002000000000000000000000000000002020000000000000000000000000000021414141414141414141414141414149e1414141414141414141414141414149e02000000000000000000000000000002
02000000002400000000000000000002020000000000000000040400000000020000000000000000000000000036000002000000000000000000000000000002020000000000000000000000000000021414141414141414141414141414149e1414141414141414141414141414149e0200494a4b4c004d5a4a4b4c00000002
02000000002424000000005b00000002020000000000000000000000000000020200000000000000000000000036000002000000000000008283000000000002020000000000000000000000000000021414141414141414141414141414149e1414141414141414141414141414149e02000000000000000000000000000002
02000000342400343423000000000002020000000400000000000000000000020200000000000000000000000036000002000000000000009293000000000002020000000000000000000000000000021414141414141414141414141414149e1414141414141414141414141414149e02000000595a4a4c0000560000000002
02000000002424240000230000000002020000000000000000000000000000020202020202020000000000000036000002000000000000000000000000000002020000000000000000000000000000021414141414141414141414141414149e1414141414141414141414141414149e02000000000000000000000000000002
0200000024240000340000000000000202000000000002020202000000000002020000000002000000000023000000000200000000000000000000000000000202000000000000000000000000000002141414141414141414141414d914149e1414141414141414141414141414149e02000000894300004445000000000002
02000000002424000000000000000000000000000000020202020000000400200000000000020000240000000000000002000000000000000000000000000002020000000000000000000000000000021414141414141414141414141414149e1414141414141414141414141414149e0200000099530000545500f600000002
030400000000000000000000000000000000000000000202020200040000002000000000000200000000000024000000020000c6c7c8c9cbcacb00d2d3000002020000000000000000000000000000021414141414141414141414141414149e1414141414141414141414141414149e02000000000000000000000000000002
0200000000000000000400000000000000000000000002020202000000000002020202020202000000000000000000000200000000000000000000e2e3000002020000000000d0d100000000000000021414141414141414141414141414149e1414141414141414141414141414149e02000000000000000000000000000002
020000000000000000000000000000020200000000000000000000000000000202000000000000002300240000000000020000c6ca4ae7e80000000000000002020000000000e0e100000000000000021414141414141414141414141414149e1414141414141414141414141414149e02000000000000000000000000000002
02000004000000000000000000000002020004040400000000000000000000020200000000000000000000000000000002000000000000000000000000000002020000000000f0f100000000000000020202020202020214141414141414149e1414141414141414141414141414149e02000000000000000000000000000002
030000000000000000000000000000020200000000000000000000000000000200000000000000002400000000000000360000000000000000000000000000000000000000000000000000000000000000800000800002149e9e9e141414149e1414141414141414141414141414149e02000000000000000000000000000002
02000000000000000400000000000002020000000000040400000000000000020200000000000000000000020202020202000000000000000000000000000000000000000000000000000000000000000000a5a6000002149e9e14141414149e1414141414141414141414141414149e02000000000000000000000000000002
02000000000000000000000000000002020000000000000000000000000000020202020202020202020202000202020202020200000000000000000000000000000000000000000000000000000000000000b5b600000214141414141414149e1414141414141414149e14141414149e02000000000000000000000000000002
02020202020203020202023636363602020202020202000000000202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000002020202020202020202020214141414141414149e141414141414141414149e9e9e14149e02020202020202020202020202020202
02020000000000000000020000000000020202020202000000000202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000002020202021414141414141414141414141414149e14141414141414141414141414149e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e02
02028a8b0000a3a4000002232400340002000000000000000000000000000002020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202000002
02029a9b0000b3b4000002000000000002000000000000000000000404000002020000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000004700f84a4bf95a000000000000000000000000000000000000000000000000000002000000000031008a8b02000002
020200000000000000000200000000000200000000000000000000000000000202000000000000000000000000000002021d1e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000031000000009a9b02000002
020200000000000000000200000000000200000000000000000000000000000202000000000000000000000000000002022d2e00518788983c00000005060002020000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000002000000000000008a8b02000002
02028a8b0000000000000200000000000200000000000000000000000000000202000000000000000000000000000002023d3e00378788983700000015160002020000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000002000000000000009a9b02000002
02029a9b000000000000020000000000020000000000000000000000040000020200000000000000000000000000000202373700008788980000000037370002020000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000002000000000031009a9b02000002
02020000000000000000020000000000020000cc00005b00000000cccc000002020000000000000000000000000000020200000068878898d6000000eaeb0002020000000000000000000000005800020000000000000000000000000000000000000000000000000000000000000000000002000000000000008a8b02000002
02020000000000000000020000000000020000005b000000000000000000000202000000000000000000000000000002020000003787889837000000fafb0002020000000000000000000000000000020000000000000000000000000000000002020202020202020202020202020202020202020202020202029a9b02000002
02028a8b0000000000000200000000002000005b0000000000000000cc00000202020202020202000000000000000002020000000000000000000000370000020200000000000000000000000000000200000000000000000000000000000000020000000000000002024f4f4f4f4f4f4f02024f4f4f4f4f0000020202000002
02029a9b00000000000002000000000036000000000000000000000000000000000000007a7a36000000000000000002020000000000000000000000000000020200000000f84a4bf95a00000000000200000000000000000000000000000000020000000000000002024f4f4f4f4f4f4f02024f0000a3a40000000202000002
020200003100000000000202020202023600000004000000000000005b000000003434007a7a3600000000000000000202000000000000000000000000000002020000000000000000000000000000020000000000000000000000000000000000000000000000004f4f4f84854f82834f4f00000000b3b40000000000000002
0202000000000000000000000000000036000000000000000000000000000023000000007a7a3600000000000000000000000000000000000000000000000000000000000090910000006b0000000000808080000000004700f84a4bf95a000000000000000000004f4f4f94954f92934f4f4f00000000000000000000000002
02028a8b000000000000000000000000368a8b00000000000000040000000000002324247a7a36000000000000000000000000000000000000000000000000000000000000a0a100a9430000000000008080008000000000000000000000000000000000000000004f58584f4f4f4f4f4f4f4f00000000008a8b000000000002
02029a9b000000000000000000000000369a9b00000000000000000000000000240000007a7a36000000000000000000000000000000000000000000000000000000001135b0b100b9530000000000008080008000000000000000000000000000000000000000004f58585858584f4f6a4f4f00310000009a9b000000000002
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
__sfx__
00010000195300940008400074000540005400044000340004400054000640000000020000b00018000250002d000310003d0000000000000000003e0003f00000000000000000000000000000e7001270000000
000100000c55012540075100050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000100003073020750217201171000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000400002a3602e350313300030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
001000002305023050210502305021050260502605017050170501505000000000000000015050000000000000000130500000017050000001205028050230500000028050210501f05021050120502805021050
001000001d0501d0501a0501d0501c0501a0501d0501c0501a0501c0501d050000000000000000230500000000000000002805000000000002105000000000000000024050000001605000000120500000000000
001000001d050000000000021050100501c0501205000000230500000000000000002305000000000000000000000230500000000000000002305000000230500000000000000000000028050000000000000000
0010000015050150501d05028050280500e050180501a050260002800028000280501000012050000002605000000260002105000000230502600000000000000000015050150501d0501c0501c0501a05018050
00100000180500e0501d0001d0002105021050210502105021050210501d0501d0501d0501f0501f0501f0502105021050210500e050120501205011050100501105013050110501105013050110501105013050
001000002f55036550375500255003750042500525000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d0000120500e0501005011050130501305013050110501305011050110501305013050170501705000000000001d0501605015050170502105012050140501205014050150501f050210501f0501d0501f050
__music__
00 41420304
00 05424344
02 06424344
01 07424344
00 08424344
02 0a424344

