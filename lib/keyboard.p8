pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- https://www.lexaloffle.com/bbs/?tid=31079
-- 139 tokens

do
  local _co, _key
  keyboard = {
    --- if true, echo the input.
    -- echo = nil
    --- resume this coroutine if it exists
    -- awaiter = nil

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
    if (r and self.awaiter and not coresume(self.awaiter, r)) self.awaiter = nil
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
-- lemons game
function _init()
  keyboard:init()
  cls()
  game = cocreate(lemons_game)
  coresume(game)
  -- lemons_game()
end

function _draw()

end

function _update()
  -- coroutines:update()
  local result = keyboard:update()
  if (result) coresume(game, result)
end

function prompt(message)
  print(message)
  keyboard.echo = true
  local result = yield()
  keyboard.echo = false
  print("")
  return result
end

function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = flr(rnd(i)) + 1
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
end

function lemons_game()
  print("lemons game")
  local count = tonum(prompt("how many pairs? \0"))
  boys = {}
  for i=1, count do
    local name = prompt(i..") name of person? \0")
    add(boys, name)
  end

  actions = {}
  for i=1, count do
    local name = prompt(i..") what have you done to a\n lemon? \0")
    add(actions, name)
  end

  girls = {}
  for i=1, count do
    local name = prompt(i..") name of a person or \ncelebrity? \0")
    add(girls, name)
  end

  bodyparts = {}
  for i=1, count do
    local name = prompt(i..") name of a body part? \0")
    add(bodyparts, name)
  end

  cls()
  print("mixing lemons...\n")
  shuffle(boys)
  shuffle(girls)
  shuffle(actions)
  shuffle(bodyparts)

  for i=1, count do
    print(boys[i].." "..actions[i].." "..girls[i].."'s "..bodyparts[i].."!")
  end

  print("\nthanks for playing!")
  -- stop()
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
