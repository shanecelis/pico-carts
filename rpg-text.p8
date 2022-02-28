pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
--https://www.lexaloffle.com/bbs/?tid=33645
--shooting's ultimate text
-- is used as my signature.
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
--==configurations==--

-- local m = msg:new(nil, { "Some messages." })
-- m:update()
-- m:draw()
-- m:is_complete()

--[[
  configure your defaults
  here
--]]
message = {
  color = {
    foreground = 15,
    highlight = nil,
    outline = 3
  },
  spacing = {
    letter = 4,
    newline = 5
  },
  sound = {
    blip = 0,
    next_message = 1
  },
  next_message = {
    button = 5,
    char = '.',
    color = 9
  }
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
    add(o.fragments, o:split(v))
  end
  o.i = 1 -- where we our in our
  o.cur = 1 -- current string
  o.msg_btnp = false
  o.t = 0

  return o
end

function message:split(string)
  local fragments={}
  -- Eek. This is per character.
  for i=1,#string do
    --add characters
    add(fragments,
        -- we should just index the config for all these default values
        {

          --color
          _c=msg_cnf[1],
          --bg color
          _b=msg_cnf[2],
          --outline color
          _o=msg_cnf[3],

          --character
          c=sub(string, i, i),
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
          _id=i - 1
    })
  end
  msgparse(fragments)
  return fragments
end

function message:update()
  self.msg_btnp = btnp(self.next_message.button)
  self.t += 1
  local fragments = self.fragments[self.cur]

  if (not fragments) return
  if self.msg_btnp then
    self.i=#fragments
  end
  if (self.i > #fragments) return
  --like seriously, its just
  --vital function stuff.
  if fragments[self.i].skp then self.i+=1 end
  local delay = msg_del
  if (self.i <= #fragments) delay += fragments[self.i]._del

  if self.t >= delay then
    self.i+=1
    sfx(0)
    self.t=0
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
      _x+=self.spacing.letter
      if fragments[i]._b and fragments[i]._b != 16 then
        rectfill(x+_x, y+_y-1, x+_x+self.spacing.letter,y+_y+5, fragments[i]._b)
      end

      if fragments[i]._img then
        spr(fragments[i]._img, x+_x+fragments[i]._dx, y+fragments[i]._dy+_y)
      end
      --you're probably getting
      --bored now, right?
      if fragments[i]._o and fragments[i]._o != 16 then
        local __x=x+_x+fragments[i]._dx
        local __y=y+fragments[i]._dy+_y
        for i4=1,3 do
          for j4=1,3 do
            print(fragments[i].c, __x-2+i4, __y-2+j4, fragments[i]._o)
          end
        end
      end

      --yep, not much here...
      print(fragments[i].c, x+_x+fragments[i]._dx, y+fragments[i]._dy+_y, fragments[i]._c)
      if fragments[i]._un == 1 then
        line(x+_x, y+_y+5, x+_x+self.spacing.letter, y+_y+5)
      end

      if fragments[i].c == '\n' then
        _x=0
        _y+=self.spacing.newline
      end

    else
      --why am ☉ even trying
      --to get you to not read it?
    end
  end

  -- this is the dot
  if self.i>=#fragments then
    print(self.next_message.char, x+self.spacing.letter+_x+cos(msg_sin), y+_y+sin(msg_sin), self.next_message.color)
    msg_sin+=0.05
    if msg_btnp then
      sfx(1)
      self.cur+=1
      fragments = self.fragments[self.cur]
      if (not fragments) return
    end
  end
  --i mean, its not like
  --i care.
  for ii=1,#fragments do
    fragments[ii]._upd(ii, ii/3)
  end

  --enjoy the script :)--
end


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
msg_del=1
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
  'this is a $c14pink cat$c15 ',
  'this is plain ',
  --1
  '$c09welcome$cxx to the text demo!',
  --2
  'you can draw sprites\n$i01   like this, and you can\n\nadd a delay$d04...$dxxlike this!',
  --3
  'looking for $d08$f01spooky$fxx$dxx effects?$d30\n$dxxhmm, how about some\n$oxx$o16$c01$b10highlighting$bxx',
  --
  '$o16$u1underlining?$u0$d30$oxx $dxx geeze, you\'re\na $f02hard one to please!',
  --5
  ''
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
  if msg_ary[msg_cur] == '' then return end
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
  m = message:new { 'a' }
  msg_set(1)
end

function _draw()
  cls()
  msg_draw(4, 4)
  m:draw(4, 40)
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
