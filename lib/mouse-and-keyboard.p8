pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-- https://www.lexaloffle.com/bbs/?tid=31079
-- 288 tokens, original was 232. doh!
-- 285
-- 255
-- 253
-- 251
-- 250
-- 241
do
  -- private vars
  local _btn, _last_btn
  mouse = {
    -- public vars
    -- x = nil,
    -- y = nil,
  }

  function mouse:init(btn_emu, pointer_lock)
    poke(0x5f2d,  1 -- assume enable
                | (btn_emu      and 2 or 0)
                | (pointer_lock and 4 or 0))
  end

  -- return true if button pressed.
  -- buttons: left 0, right 1, middle 2
  function mouse:btn(i, flag)
    return band(shl(1, i), flag or _btn) > 0
  end

  -- return mouse wheel info.
  -- 1 roll up, 0 no roll, -1 roll down
  function mouse:wheel()
    return stat(36)
  end

  -- return true if button pressed this frame.
  function mouse:btnp(i)
    return mouse:btn(i) and not mouse:btn(i, _last_btn)
  end

  -- return true if button released this frame.
  function mouse:btnp_up(i)
    return not mouse:btn(i) and mouse:btn(i, _last_btn)
  end

  function mouse:update()
    _last_btn,self.x,self.y,_btn=_btn,stat(32),stat(33),stat(34)
  end
end


do
  local _co, _key
  keyboard = {
    -- if true, echo the input
    -- echo = true

    -- if true, disables the
    -- menu when return is
    -- pressed.
    -- enable_menu = nil,

    -- reader function runs as a
    -- coroutine. it receives a
    -- key at start and upon
    -- resumption.
    --
    -- the default reader is a
    -- cheap readline: it builds
    -- up a string until return
    -- is pressed. meant for you
    -- to substitute your own.
    reader = function(key)
      local buffer = ""
      while key ~= "\r" do
        -- end with \0 to not add newline
        if (keyboard.echo) print(key.."\0")
        if key == "\b" then
          buffer=sub(buffer,0,#buffer-1)
        else
          buffer..=key
        end
        key = yield()
      end
      return buffer
    end
  }

  function keyboard:init()
    -- if (peek(0x5f2d) == 0)
    poke(0x5f2d, 1)
  end

  -- update keyboard info.
  -- return the current
  -- coroutine's last yielded or
  -- returned value.
  function keyboard:update()
    local s, r = true
    _key = nil
    while stat(30) do
      _key = stat(31)
      if (_key == "\r" and not self.enable_menu) poke(0x5f30, 1)
      repeat
        if (not s or not _co) _co = cocreate(self.reader, _key)
        s, r = coresume(_co, _key)
      until s
    end
    return r
  end

  -- returns whether the key has
  -- been pressed.
  --
  -- note: this is not fool
  -- proof. multiple keys can be
  -- pressed per frame. this
  -- only tests against the last
  -- key.
  --
  -- for better handling,
  -- implement your own reader
  -- coroutine which'll catch
  -- all key presses.
  function keyboard:btnp(k)
    return _key == k
  end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
