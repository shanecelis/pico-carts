
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
* remove skip elements
* generalize fragment to hold whole string not just one character
* generalize framework so that all outline, highlight, and such are just effects
* highlighting obscured by outline (probably an ordering issue)

changes
=======
* use's lua's oo system instead of a 'msg_' prefix
* draw(x,y) lines up with print(s,x,y)
* fragment class only hold items changed from default
* parsing happens once
* many messages may be used at the same time
* buttons and timing are handled in _update() instead of _draw()
*

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

effect = {
  sigil = 'c',
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
  assert(chars[i+1].c == self.sigil, "wrong sigil")
  chars[i].skip=true
  chars[i+1].skip=true

  local arg = ""
  for j=1, self.arg_count do
    chars[i+1+j].skip=true
    arg = arg..chars[i+1+j].c
  end
  local val=tonum(arg)
  return val
end

function effect:closure(val)
  return function(fragments, k)
    if self.isolated then
        self:action(fragments[k], val)
    else
        for j=k,#fragments do
        self:action(fragments[j], val)
        end
    end
  end
end

function effect:action(fragment, val)
  fragment.color.foreground=val
end
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
    function(fragment, fxv)
      local t = 1.5 * time()
      fragment.dy=sin(t+fxv)
    end,
    function(fragment, fxv)
      local t = 1.5 * time()
      fragment.dy=sin(t+fxv)
      fragment.dx = rnd(4) - 2
    end
  },
  _effects = {
    c = effect:new(), -- color
    b = effect:new{ sigil = 'b',
                     action = function(self, fragment, val) fragment.color.highlight=val end
                   },

    o = effect:new{ sigil = 'o',
                     action = function(self, fragment, val) fragment.color.outline=val end
                   },

    d = effect:new{ sigil = 'd',
                     action = function(self, fragment, val) fragment.delay=val end,
                     parse = function(self, chars, i)
                       local val = effect.parse(self, chars, i)
                       if (val) val /= 30
                       return val
                       end
    },

    f = effect:new{ sigil = 'f',
                    parent = nil,
                    action = function(self, fragment, val) fragment.update = self.subeffects[val] end,

                    subeffects = {
                      function(fragment, fxv)
                        local t = 1.5 * time()
                        fragment.dy=sin(t+fxv)
                      end,
                      function(fragment, fxv)
                        local t = 1.5 * time()
                        fragment.dy=sin(t+fxv)
                        fragment.dx = rnd(4) - 2
                      end
                    },
    },

    u = effect:new{ sigil = 'u',
                    arg_count = 1,
                    action = function(self, fragment, val) fragment.underline=val end
                   },

    i = effect:new{ sigil = 'i',
                    isolated = true,
                    action = function(self, fragment, val) fragment.image=val end
                   },
    ['$'] = effect:new {
      sigil = '$',
      arg_count = 0,
      parse = function(self, chars, i) chars[i].skip=true end,
      action = function(self, fragment, val) end,
    },
    -- effect:new{ sigil = nil,
    --                  action = function(self, fragment, val) fragment.color.outline=val end
    --                };

  },
  delay = 1/30,
}

function message:new(o)
  o = o or {}
  setmetatable(o, self)
  if (o.color) setmetatable(o.color, self.color); self.color.__index = self.color
  if (o.spacing) setmetatable(o.spacing, self.spacing); self.spacing.__index = self.spacing
  if (o.sound) setmetatable(o.sound, self.sound); self.sound.__index = self.sound
  if (o.next_message) setmetatable(o.next_message, self.next_message); self.next_message.__index = self.next_message
  if (o.sound) setmetatable(o.sound, self.sound); self.sound.__index = self.sound
  self.__index = self
  o.fragments = {}
  for k,v in ipairs(o) do
    -- add(o.fragments, o:split(v))
    add(o.fragments, o:parse(v))
  end
  o._effects.f.parent = o
  o.istart = nil -- when we started displaying the ith message
  o.i = 1 -- where we our in our
  o.cur = 1 -- current string
  return o
end

fragment = {
  color = message.color,
  c = nil,
  dx = 0,
  dy = 0,
  fxv = 0,
  delay = nil,
  image = nil,
  underline = nil,
  delay_accum = 0
}


function fragment.new(class, o)
  o = o or {}
  if (o.color) setmetatable(o.color, message.color); message.color.__index = message.color
  setmetatable(o, class)
  class.__index = class
  return o
end

function fragment:update()
end

function message:parse(string)
  chars = {}
  local colorfx = effect:new()
  for i=1,#string do
    add(chars, { c=sub(string, i, i), action = nil, skip = false, fragment_index = nil })
  end
  for i=1,#chars - 1 do
    local t=chars[i].c
    local c=chars[i+1].c
    local fx = self._effects[c]
    if t=='$' and fx then -- (c=='c') then -- or c=='b' or c=='f' or c=='d' or c=='o' or c=='i') then
      -- chars[i].skip=true
      -- chars[i+1].skip=true
      chars[i].action = fx:closure(fx:parse(chars, i))


    --   chars[i+2].skip=true
    --   chars[i+3].skip=true
    --   local val=tonum(chars[i+2].c..chars[i+3].c)
    --   chars[i+3].action = function(fragments, k)
    --     if c == 'i' then
    --       fragments[k].image=val
    --     else
    --       for j=k,#fragments do
    --         if c=='c' then
    --           fragments[j].color.foreground=val
    --         elseif c=='b' then
    --           fragments[j].color.highlight=val
    --         elseif c=='f' then
    --           fragments[j].update=self.effects[val]
    --         elseif c=='d' then
    --           -- delay is in terms of frames (could be 60 though &shrug;)
    --           local t = val
    --           if (t) t /= 30
    --           fragments[j].delay=t
    --         elseif c=='o' then
    --           fragments[j].color.outline=val
    --         end
    --       end
    --     end
    --   end
    -- elseif t == '$' and c == '$' then
    --   -- $$ becomes $
    --   chars[i+1].skip = true
    -- end

    -- if t=='$' and c=='u' then
    --   chars[i].skip=true
    --   chars[i+1].skip=true
    --   chars[i+2].skip=true

    --   local val = tonum(chars[i+2].c)
    --   chars[i+2].action = function(fragments, k)
    --     for j=k,#fragments do
    --       fragments[j].underline=val
    --     end
    --   end
    end
  end
  local fragments = {}
  for char in all(chars) do
    if not char.skip then
      add(fragments, fragment:new { color = {}, c = char.c })
    end
    char.fragment_index = #fragments
  end
  for char in all(chars) do
    if char.action then
      char.action(fragments, char.fragment_index + 1)
    end
  end

  local accum = 0
  for k,f in ipairs(fragments) do
    if not f.skip then
      accum += f.delay or self.delay
      f.delay_accum = accum
    end
  end
  return fragments
end

function message:is_complete()
  return self.cur > #self.fragments
end

function message:update()
  if (not self.istart) self.istart = time()
  local fragments = self.fragments[self.cur]
  if (not fragments) return
  if btnp(self.next_message.button) then
    if self.i < #fragments then
      self.i=#fragments
      return
    else
      sfx(self.sound.next_message)
      self.cur += 1
      self.i = 1
      self.istart = time()
    end
  end

  if (self.i > #fragments) return
  --like seriously, its just
  --vital function stuff.
  local delay = self.delay
  -- if (self.i <= #fragments) delay += fragments[self.i].delay

  if time() - self.istart > fragments[self.i].delay_accum then
    self.i+=1
    if (self.i <= #fragments) sfx(self.sound.blip)
  end

end

function message:draw(x, y)
  local fragments = self.fragments[self.cur]
  if (not fragments) return
  --loop...
  --i mean, hey... if you want
  --to keep reading, go ahead.
  local _x=0
  local _y=0
  for i = 1, self.i do
    if not fragments[i] then break end
    --i wont try and stop you.
    -- local str = sub(fragments[i].c, 1, self.i)
    local str = fragments[i].c
    local highlight = fragments[i].color.highlight
    if highlight and highlight ~= 16 then
      rectfill(x+_x-1, y+_y-1, x+_x+self.spacing.letter-1,y+_y+5, highlight)
    end

    if fragments[i].image then
      spr(fragments[i].image, x+_x+fragments[i].dx, y+fragments[i].dy+_y)
    end
    --you're probably getting
    --bored now, right?
    local outline = fragments[i].color.outline
    if outline and outline ~= 16 then
      local __x=x+_x+fragments[i].dx
      local __y=y+_y+fragments[i].dy
      for i4=1,3 do
        for j4=1,3 do
          print(str, __x-2+i4, __y-2+j4, outline)
        end
      end
    end

    --yep, not much here...
    print(str, x+_x+fragments[i].dx, y+fragments[i].dy+_y, fragments[i].color.foreground)
    if fragments[i].underline == 1 then
      line(x+_x, y+_y+5, x+_x+self.spacing.letter, y+_y+5)
    end

    _x+=self.spacing.letter
    -- split by the newlines too?
    if fragments[i].c == '\n' then
      _x=0
      _y+=self.spacing.newline
    end
  end

  -- this is the dot
  if self.i>=#fragments then
    -- local _t = -0.05 * self.t
    -- local _t = 1.5 * time()
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
