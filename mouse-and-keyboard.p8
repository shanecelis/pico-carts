pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-- https://www.lexaloffle.com/bbs/?tid=31079
-- 288 tokens, original was 232. doh!

mouse = {
  x = nil,
  y = nil,
  _btn = nil,
  last_btn = nil,
}

function mouse:init(enable, btn_emu, pointer_lock)
  poke(0x5f2d,(enable       and 1 or 0)
             |(btn_emu      and 2 or 0)
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
      self.buffer..=self.key
    end
  end
end

function keyboard:input()
  if (#self._input == 0) return nil
  local v = self._input[1]
  deli(self._input, 1)
  return v
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
