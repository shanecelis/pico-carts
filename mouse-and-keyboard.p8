pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-- https://www.lexaloffle.com/bbs/?tid=31079

mouse = {
  x = nil,
  y = nil,
  _btn = nil,
  last_btn = nil,
}

function mouse:init(enable, btn_emu, pointer_lock)
  poke(0x5f2d,(enable   and 1 or 0)
             |(btn_emu  and 2 or 0)
             |(pointer_lock and 4 or 0))
end

-- buttons left 0, right 1, middle 2
function mouse:btn(i)
  return band(shl(1, i),self._btn)>0
end

function mouse:wheel()
  return stat(36)
end

function mouse:btnp(i)
  return (band(shl(1, i),self._btn)>0) and not (band(shl(1, i),self.last_btn)>0)
end

function mouse:btnp_up(i)
  return (band(shl(1, i),self._btn)==0) and not (band(shl(1, i),self.last_btn)==0)
end

function mouse:update()
  self.last_btn = self._btn
  self.x,self.y,self._btn=stat(32),stat(33),stat(34)
end


keyboard = {
  key = nil,
  buffer = "",
  _input = {},
  sentinel = "\r",
  disable_menu = false
}

function keyboard:init()
  if (peek(0x5f2d) == 0) poke(0x5f2d, 1)
end

function keyboard:update()
  while stat(30) do
    self.key = stat(31)
    if(self.key == "\r" and self.disable_menu) poke(0x5f30, 1)
    if(self.key == self.sentinel) then
      add(self._input, self.buffer)
      self.buffer = ""
    elseif(self.key =="\b") then
      self.buffer=sub(self.buffer,0,#self.buffer-1)
    else
      self.buffer=self.buffer..self.key
    end
  end
end

function keyboard:input()
  if (#self._input == 0) return nil
  local v = self._input[1]
  deli(self._input, 1)
  return v
end


function _init()
  -- poke(0x5f30, 1)
  -- self.buffer=""
  -- mouse:listen(true)
  mouse:init(true,false,false)
  keyboard:init()
  keyboard.disable_menu = true
end

function _keyboard()
    self.key =stat(31)
  while stat(30) do
    if(self.key =="\r") then
      if (self._disable_menu) poke(0x5f30, 1)
      _kbt=self.buffer
      self.buffer=""
    elseif(self.key =="\b") then
      self.buffer=sub(self.buffer,0,#self.buffer-1)
    else
      self.buffer=self.buffer..self.key
    end
  end
end

function _mouse()
  _mx,_my,_mb=stat(32),stat(33),stat(34)
  _mbld,_mblu,_mbru,_mbrd,_mbmu,_mbmd=false,false,false,false,false,false
  _mbld=_mbl==0 and band(0b0001,_mb)>0
  _mblu=_mbl!=0 and band(0b0001,_mb)==0
  _mbl=band(0b0001,_mb)
  _mbrd=_mbr==0 and band(0b0010,_mb)>0
  _mbru=_mbr!=0 and band(0b0010,_mb)==0
  _mbr=band(0b0010,_mb)
  _mbmd=_mbm==0 and band(0b0100,_mb)>0
  _mbmu=_mbm!=0 and band(0b0100,_mb)==0
  _mbm=band(0b0100,_mb)
end
function _update()
  _demo()
  keyboard:update()
  mouse:update()
end

function _demo()


  local line = keyboard:input()
  if line then
    print(line)
  end
  if (keyboard.key == "l") then
    print("listen")
    mouse:init(true, false, false)
  end

  if (keyboard.key == ";") then
    print("No listen")
    mouse:init(false, false, false)
  end
  if (mouse:btnp(0)) print("left down!")
  if (mouse:btnp_up(0)) print("left up!")
  -- if (mouse:btn(0)) print("left down!!!")

  if(_mbld) print("left down!")
  if(_mbrd) print("right down!")
  if(_mbmd) print("middle down!")
  if(_mblu) print("left up!")
  if(_mbru) print("right up!")
  if(_mbmu) print("middle up!")
  end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
