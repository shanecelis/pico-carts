pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
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
  delay = 4/30,
}

function message:new(o)
  o = o or {}
  setmetatable(o, self)
  if (o.color) setmetatable(o.color, self.color); self.color.__index = self.color
  if (o.spacing) setmetatable(o.spacing, self.spacing); self.spacing.__index = self.spacing
  if (o.sound) setmetatable(o.sound, self.sound); self.sound.__index = self.sound
  if (o.next_message) setmetatable(o.next_message, self.next_message); self.next_message.__index = self.next_message
  self.__index = self
  o.fragments = {}
  for k,v in ipairs(o) do
    -- add(o.fragments, o:split(v))
    add(o.fragments, o:parse(v))
  end
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

-- We should be able to write a fragment that is longer than one character
function message:new_split(string)
  local fragments={}
  -- Eek. This is per character.
  -- for i=1,#string do
  --add characters
  add(fragments,
      fragment:new
      -- we should just index the config for all these default values
      { color = {},
        --character
        c=string
  })
  -- end
  self:parse(fragments)
  return fragments
end

function message:split(string)
  local fragments={}
  -- Eek. This is per character.
  for i=1,#string do
    --add characters
    add(fragments,
        fragment:new
        -- we should just index the config for all these default values
        { color = {},
          --character
          c=sub(string, i, i),
    })
  end
  self:parse(fragments)
  local accum = 0
  for k,f in ipairs(fragments) do
    if not f.skp then
      accum += f.delay or self.delay
      f.delay_accum = accum
    end
  end
  return fragments
end

--parse entire message :u
function message:parse(string)
  chars = {}
  for i=1,#string do
    add(chars, { c=sub(string, i, i), _action = nil, skp = false, fragment_index = nil })
  end
  for i=1,#chars - 1 do
    local t=chars[i].c
    local c=chars[i+1].c
    if t=='$' and (c=='c' or c=='b' or c=='f' or c=='d' or c=='o' or c=='i') then
      chars[i].skp=true
      chars[i+1].skp=true
      chars[i+2].skp=true
      chars[i+3].skp=true
    do
      local val=tonum(chars[i+2].c..chars[i+3].c)
      chars[i+3]._action = function(fragments, k)
        printh("c" .. c .. " val " .. (val or 'nil'))
        if c == 'i' then
          fragments[k].image=val
        else
          for j=k,#fragments do
            if c=='c' then
              fragments[j].color.foreground=val
            elseif c=='b' then
              fragments[j].color.highlight=val
            elseif c=='f' then
              fragments[j].update=self.effects[val]
            elseif c=='d' then
              -- delay is in terms of frames (could be 60 though &shrug;)
              if (val) val /= 30
              fragments[j].delay=val
            elseif c=='o' then
              fragments[j].color.outline=val
            end
          end
        end
      end
      end
    elseif t == '$' and c == '$' then
      -- $$ becomes $
      chars[i+1].skp = true
    end

    if t=='$' and c=='u' then
      chars[i].skp=true
      chars[i+1].skp=true
      chars[i+2].skp=true

      local val = tonum(chars[i+2].c)
      chars[i+2]._action = function(fragments, k)
        for j=k,#fragments do
          fragments[j].underline=val
        end
      end
    end
  end
  local fragments = {}
  for char in all(chars) do
    if not char.skp then
      add(fragments, fragment:new { color = {}, c = char.c })
    end
    char.fragment_index = #fragments
  end
  for char in all(chars) do
    if char._action then
      char._action(fragments, char.fragment_index + 1)
    end
  end

  local accum = 0
  for k,f in ipairs(fragments) do
    if not f.skp then
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
  -- if fragments[self.i].skp then self.i+=1 end
  local delay = self.delay
  -- if (self.i <= #fragments) delay += fragments[self.i].delay

  if time() - self.istart > fragments[self.i].delay_accum then
    self.i+=1
    if (self.i <= #fragments and not fragments[self.i].skp) sfx(self.sound.blip)
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
    if not fragments[i].skp then
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

-->8

msg_cnf = {
  --default color 1
  15,
  --default highlight 2
  nil,
  --default outline 3
  1,
  --letter spacing 4
  4,
  --new line spacing 5
  7,
  --blip sound 6
  0,
  --next msg sound 7
  1,

  ---------------------

  --skip text/fast finish
  --button 8
  5,
  --next action character 9
  '.',
  --next action character color 10
  9
}

--[[
  standard variables,dont edit
--]]
msg_i=1
msg_t=0
msg_del=4
msg_cur=1
  --==edit special fx here==--
  --[[
   special effects can be
   applied to all text after
   the fx code: $fid
   
   where id=a number starting
   with 1. in this sample,
   $f01 gives a wavy text
   effect. its auto-indexed,
   so make sure you comment
   similar to what i did
   to avoid confusion.
   
   self values:
     _dx (draw x)
     _dy (draw y)
     _fxv (fx value)
     _c (color)
     c (character)
     _b (border color, nil for
         none)
     _o (outline color, nil for
         none)
     _img (image index from
           sprite list)
    _upd (function, dont mod
          this)
    _id  (index id of the 
          character)
  --]]
msg_fx = {
  --$f0
  function(i, fxv)
    --floaty effect
    --[[
      first, we get the self
      value (i) by using
      local self=msg_str[i].

      self._fxv = fx value
      self._dy = draw y, adds
      to the already rendering
      y position.
    --]]
    local self=msg_str[i]
    self._dy=sin(self._fxv+fxv)
    self._fxv+=0.05
  end,
  --$f02
  function(i, fxv)
    --floaty effect 2
    --[[
      this time with random x
      locations.
    --]]
    local self=msg_str[i]
    self._dy=sin(self._fxv+fxv)
    self._dx=rnd(4)-rnd(2)
    self._fxv+=0.05
  end

}

--[[
  store your messages here
  in this variable. make sure
  to comment the number to
  avoid confusion. empty text
  will end the text
  displaying. when you press
  the configured 'next' key,
  it auto-continues to the
  next string.
--]]
msg_ary={
  'this is\nplain',
  'this $f02is a$fxx $c14pink cat$c15',
  '$c09welcome$cxx to the text demo!',
  'you can draw sprites\n$i01   like this, and you can\nadd a delay$d08...$dxxlike this!',
  'looking for $d08$f01spooky$fxx$dxx effects?$d30\n$dxxhmm, how about some\n$oxx$o16$c01$b10highlighting$bxx',
  '$o16$u1underlining?$u0$d30$oxx $dxx geeze, you\'re\na $f02hard one to please!',
}



--string storage--
msg_str={}

--function to set message
--id=index in msg_ary
function msg_set(id)
  --sine variable
  msg_sin=0
  msg_cur=id
  --reset message string
  msg_str={}
  --reset index counter
  msg_i=1
  local __id=0
  if (id > #msg_ary) return
  -- Eek. This is per character.
  for i=1,#msg_ary[id] do
    --add characters
    add(msg_str, {
          --character
          c=sub(msg_ary[id], i, i),
          --color
          _c=msg_cnf[1],
          --bg color
          _b=msg_cnf[2],
          --outline color
          _o=msg_cnf[3],
          --draw_x and draw_y
          _dx=0,
          _dy=0,
          --fx value
          _fxv=0,
          --image to draw
          _img=nil,
          --extra delay
          _del=0,

          --update function for fx
          _upd=function() end,
          _id=__id
    })
    __id+=1
  end
  msgparse(msg_str)
end

--parse entire message :u
function msgparse(msg_str)
  for i=1,#msg_str do
    if not msg_str[i+1] then return end
    local t=msg_str[i].c
    local c=msg_str[i+1].c
    if t=='$' and (c=='c' or c=='b' or c=='f' or c=='d' or c=='o' or c=='i') then
      msg_str[i].skp=true
      msg_str[i+1].skp=true
      msg_str[i+2].skp=true
      msg_str[i+3].skp=true
      local val=tonum(msg_str[i+2].c..msg_str[i+3].c)
      for j=i,#msg_str do
        if c=='c' then
          msg_str[j]._c=val or msg_cnf[1]
        elseif c=='b' then
          msg_str[j]._b=val or nil
        elseif c=='f' then
          msg_str[j]._upd=msg_fx[val] or function() end
        elseif c=='d' then
          msg_str[j]._del=val or 0
        elseif c=='o' then
          msg_str[j]._o=val or msg_cnf[3]
        elseif c=='i' then
          msg_str[i+4]._img=val or nil
        end
      end
    end


    if t=='$' and c=='u' then
      msg_str[i].skp=true
      msg_str[i+1].skp=true
      msg_str[i+2].skp=true
      for j=i,#msg_str do
        msg_str[j]._un=tonum(msg_str[i+2].c) or 0
      end
    end
  end
end
--function to draw msg
function msg_draw(x, y)
  --return if text is empty
  if (msg_cur > #msg_ary or msg_ary[msg_cur] == '') return
  --set a btnp value
  if not btn(msg_cnf[8]) then msg_btnp=false end
  --loop...
  while msg_i<#msg_str do
    --idk why you're trying to
    --read this
    if btnp(msg_cnf[8]) then
      msg_i=#msg_str-1
      msg_btnp=true
    end
    --like seriously, its just
    --vital function stuff.
    msg_t+=1
    if msg_str[msg_i].skp then msg_i+=1 end
    if msg_t>=msg_del+msg_str[msg_i]._del then
      msg_i+=1
      sfx(0)
      msg_t=0
    end
    break;
  end
  --i mean, hey... if you want
  --to keep reading, go ahead.
  local i=1
  local _x=0
  local _y=0
  while i<msg_i do
    if not msg_str[i] then return end
    if not msg_str[i].skp then
      --i wont try and stop you.
      _x+=msg_cnf[4]
      if msg_str[i]._b and msg_str[i]._b != 16 then
        rectfill(x+_x, y+_y-1, x+_x+msg_cnf[4], y+_y+5, msg_str[i]._b)
      end

      if msg_str[i]._img then
        spr(msg_str[i]._img, x+_x+msg_str[i]._dx, y+msg_str[i]._dy+_y)
      end
      --you're probably getting
      --bored now, right?
      if msg_str[i]._o and msg_str[i]._o != 16 then
        local __x=x+_x+msg_str[i]._dx
        local __y=y+msg_str[i]._dy+_y
        for i4=1,3 do
          for j4=1,3 do
            print(msg_str[i].c, __x-2+i4, __y-2+j4, msg_str[i]._o)
          end
        end
      end

      --yep, not much here...
      print(msg_str[i].c, x+_x+msg_str[i]._dx, y+msg_str[i]._dy+_y, msg_str[i]._c)
      if msg_str[i]._un == 1 then
        line(x+_x, y+_y+5, x+_x+msg_cnf[4], y+_y+5)
      end

      if msg_str[i].c == '\n' then
        _x=0
        _y+=msg_cnf[5]
      end
    else
      --why am ☉ even trying
      --to get you to not read it?
    end
    i+=1
  end

  if msg_i>=#msg_str then
    print(msg_cnf[9], x+msg_cnf[4]+_x+cos(msg_sin), y+_y+sin(msg_sin), msg_cnf[10])
    msg_sin+=0.05
    if btnp(msg_cnf[8]) and msg_btnp != true then
      sfx(1)
      msg_cur+=1
      msg_set(msg_cur)
    end
  end
  --i mean, its not like
  --i care.
  for ii=1,#msg_str do
    msg_str[ii]._upd(ii, ii/3)
  end

  --enjoy the script :)--
end
-->8
--sample
function _init()
  -- m = message:new {
  -- 'this $f02is a$fxx $c14pink cat$cxx',
  -- }
  m = message:new(msg_ary)
  msg_set(1)
end

function _draw()
  cls()
  msg_draw(4, 4)
  m:draw(4, 40)
  -- print(msg_ary[1], 4, 40, 3)
  -- print('this is\n plain', 4, 50, 3)
  if m:is_complete() then
    print('done', 8, 40)
  end
end

function _update()
  m:update()
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000d000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000c00000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000c00000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001111111111100111111111111111100011111111100011111111111110001111111111111111100011111111111111111000000000000000000000000
0000000191919991910119911991999199910001fff11ff10001fff1f1f1fff10001fff1fff1f1f1fff10001ff11fff1fff11ff1000000000000000000000000
00000001919191119101911191919991911100011f11f1f100011f11f1f1f11100011f11f111f1f11f110001f1f1f111fff1f1f1000000000000000000000000
00000001919199119101910191919191991000001f11f1f100001f11fff1ff1000001f11ff111f111f100001f1f1ff11f1f1f1f1000000000000000000000000
00000001999191119111911191919191911100001f11f1f100001f11f1f1f11100001f11f111f1f11f100001f1f1f111f1f1f1f1000000000000000000000000
00000001999199919991199199119191999100001f11ff1100001f11f1f1fff100001f11fff1f1f11f100001fff1fff1f1f1ff11900000000000000000000000
00000001111111111111111111111111111100001111111000001111111111110000111111111111111000011111111111111110000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
0002000036050320401d0201d0001d0001d0001d0001d0002500028000000003c0003c00000000000003400000000000002d0002c0002b0002a00000000000000000000000000000000000000000000000000000
000100002f1502c1502a1500f110091000510001100291002b1002d10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
