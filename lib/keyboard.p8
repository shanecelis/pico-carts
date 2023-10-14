pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- https://www.lexaloffle.com/bbs/?tid=31079
-- 130 tokens

do
  local _co, _key
  keyboard = {
    --- if true, echo the input.
    -- echo = nil

    --- if true, disables the
    --- menu when return is
    --- pressed.
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
  -- returns the current
  -- reader's last yielded or
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

-->8
-- hi
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
