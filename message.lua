
--https://www.lexaloffle.com/bbs/?tid=33645
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
  if (self.sigil) assert(chars[i+1].c == self.sigil, "wrong sigil")
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
                       -- if (val) val /= 30
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
  -- if (o.color) setmetatable(o.color, { __index = class.color })
  -- if (o.color) class.color.__index = class.color
  if (o.spacing) setmetatable(o.spacing, class.spacing); class.spacing.__index = class.spacing
  if (o.sound) setmetatable(o.sound, class.sound); class.sound.__index = class.sound
  if (o.next_message) setmetatable(o.next_message, class.next_message); class.next_message.__index = class.next_message
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
  if (o.color) setmetatable(o.color, { __index = (message_instance or message).color })
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
      accum += f.delay or self.delay
      f.delay_accum = accum
    end
  end
  return fragments
end

function message:is_complete()
  local done = self.done
  if (not self.last_press) done = true
  return self.cur >= #self.fragments and self.i >= #self.fragments[self.cur] and done
end

function message:update()
  local consume = false
  if (not self.istart) self.istart = time()
  local fragments = self.fragments[self.cur]
  if btnp(self.next_message.button) then
    if self.i < #fragments then
      self.i=#fragments
      consume=true
    elseif self.cur < #self.fragments then
      sfx(self.sound.next_message)
      self.i = 0
      self.cur += 1
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
      self.i+=1
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

    _x+=self.spacing.letter
    -- split by the newlines too?
    if f.c == '\n' then
      _x=0
      _y+=self.spacing.newline
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
      if (btnp(3)) _choice += 1
      if (btnp(2)) _choice -= 1
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
