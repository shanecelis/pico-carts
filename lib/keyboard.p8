pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- keyboard.p8
--   page 1, library - 181 tokens
--   page 2, demo    - 256 tokens
--
-- this cart is principally a
-- library for interacting with
-- the user in a query and response
-- format using the keyboard.
--
-- you can include the library
-- in your own cart by including
-- only the first page:
--
-- #include keyboard.p8:1
--
-- the second page includes a
-- demo with an old kids' game
-- called lemons. the most
-- salient feature is that user
-- queries can be written
-- straightfowardly:
--
-- answer = prompt("what's 2+2?")
--
-- the magic--as it often
-- does--lies in a little thing
-- called coroutines.
--
-- # features
--
-- keyboard.p8
--
--  * handles backspace;
--
--  * does not accrue string
--    unless polled;
--
--  * ergonomic prompt
--    interaction code;
--
--  * echo can be on or off;
--
--  * substitute your own reader
--    function
--
--  * return and 'p' will not
--    pop up the pico-8 menu
--    when being polled (unless
--    enable_menu is set to
--    true)
--
-- # acknowlegments
--
-- many thanks to cabledragon
-- for their inspiring mklib[1],
-- a mouse and keyboard library,
-- project. their keyboard code
-- is only 62 tokens too.
--
-- [1]: https://www.lexaloffle.com/bbs/?tid=31079
-- [2]: https://www.wikihow.com/Play-Lemons

do
  local _co, _key
  keyboard = {
    --- if true, echo the input.
    -- echo = nil

    --- if false or nil,
    --- disables the menu when
    --- return is pressed.
    -- enable_menu = nil,

    -- coreader function runs as a
    -- coroutine. it receives a
    -- key at start and upon
    -- resumption.
    --
    -- the default coreader is a
    -- cheap readline: it builds
    -- up a string until return
    -- is pressed. meant for you
    -- to substitute your own.
    coreader = function(key)
      local buffer = ""
      while key ~= "\r" do
        if key == "\b" then
          -- backspace, overwrite space, backspace again
          -- to clear the previous character
          key=#buffer > 0 and "\b\^# \b" or ""
          buffer=sub(buffer,0,-2)
        else
          buffer..=key
        end
        -- end with \0 to not add newline
        if (keyboard.echo) print(key.."\0")
        key = yield()
      end
      return buffer
    end
  }

  function keyboard:init()
    -- if (peek(0x5f2d) == 0)
    poke(0x5f2d, 1)
  end

  -- poll keyboard.
  -- returns the current
  -- coreader's last yielded or
  -- returned value.
  --
  -- best not to run unless
  -- expecting input. otherwise
  -- a long string may build up
  -- of game button presses.
  function keyboard:poll()
    local s, r = true
    _key = nil
    while stat(30) do
      _key = stat(31)
      -- return and p both bring up the pico-8 menu.
      if ((_key == "\r" or _key == 'p') and not self.enable_menu) poke(0x5f30, 1)
      repeat
        if (not s or not _co) _co = cocreate(self.coreader, _key)
        s, r = coresume(_co, _key)
      until s
    end
    return r
  end

  -- returns true if the last
  -- key pressed this frame is
  -- the given key k. or if no
  -- key k is given, true if any
  -- keyboard key was pressed
  -- this frame.
  --
  -- note: this is not fool
  -- proof. multiple keys can be
  -- pressed per frame. this
  -- only tests against the last
  -- key.
  --
  -- for better handling,
  -- implement your own coreader
  -- coroutine which'll catch
  -- all key presses.
  --
  -- note: keyboard:poll() must
  -- run before keyboard:btnp().
  function keyboard:btnp(k)
    return k and _key == k or _key ~= nil
  end

end

-- solicit the user for input.
-- yields internally so it must
-- be called from within a
-- coroutine.
--
-- note: prompt() polls the
-- keyboard. if keyboard is
-- polled elsewhere, prompt()
-- may never acquire a response
-- and may never return.
function prompt(question)
  print(question)
  -- keyboard.echo = true
  local response
  repeat
    yield()
    response = keyboard:poll()
  until response
  -- keyboard.echo = false
  print("")
  return response
end

-->8
-- lemons game
-- demo for keyboard.p8
--
-- this is actually one of the
-- first computer games i ever
-- wrote, back then in gw-basic.
-- it was a pen-and-paper game i
-- had learned that i decided to
-- try my hand at digitizing
-- because i didn't know how to
-- do anything graphical yet.
--
-- note: if you're including
-- this library, be sure to only
-- include the first page, so
-- this demo won't take up
-- tokens or overwrite
-- variables.
function _init()
  keyboard:init()
  keyboard.echo = true
  cls()
  -- create the game coroutine.
  game = cocreate(lemons_game)
  coresume(game)
end

function _update()

  -- resume the game coroutine.
  coresume(game)
end

-- an old kids' game written to
-- demonstrate the keyboard
-- prompt function.
function lemons_game()
  spr(1, 56, 10, 2, 2)
  print("\^d1lemons game\n", 0, 30)

  local count
  repeat
      count = tonum(prompt("\^d1you're making lemonade for how \nmany pairs of people? \0"))
  until count
  -- local count = tonum(prompt("how many pairs? \0"))
  boys = {}
  for i=1, count do
    local name = prompt(i.."\^d1) name of person? \0")
    add(boys, name)
  end

  actions = {}
  for i=1, count do
    local name = prompt(i.."\^d1) what would you do to a\n lemon (past tense)? \0")
    add(actions, name)
  end

  girls = {}
  for i=1, count do
    local name = prompt(i.."\^d1) name of a person or \ncelebrity? \0")
    add(girls, name)
  end

  bodyparts = {}
  for i=1, count do
    local name = prompt(i.."\^d1) name of a body part? \0")
    add(bodyparts, name)
  end

  cls()
  print("\^d4squeezing lemons...\n")
  wait(0.5)
  spr(3, 100, 10, 2, 2)
  print("\^d4making lemonade...\n")
  wait(0.5)
  shuffle(boys)
  shuffle(girls)
  shuffle(actions)
  shuffle(bodyparts)

  local prefix="\^d4\^t\^w"
  for i=1, count do
    print(prefix.."\fc"..boys[i])
    print(prefix.." \f7"..actions[i])
    print(prefix.."  \fe"..girls[i].."'s")
    print(prefix.."   \f7"..bodyparts[i].."!")
    wait(0.25)
  end
  wait(0.5)

  print("\^d4\nthanks for playing!")
  stop()
end

function wait(t)
  local start = time()
  while time() - start < t do
    yield()
  end
end

-- shuffle a table.
-- https://gist.github.com/Uradamus/10323382#file-shuffle-lua
function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = flr(rnd(i)) + 1
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
end

__gfx__
00000000000000000003330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000003bb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000000000000003bb30ccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000000000000003b300c7ccccccc0cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000000000999999030000c77777cccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000000009aaaaaa300000cccccc77c00cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009aa7aaaaa90000caaaacccc00cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000009aaaaaaaaa9000ca9aaaaaacc0cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000009a7aaaaaaa9000caa999999ac0cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000009a7aaaaaaa900caaaaaaaaaaccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000009a7aaaaaaa900caaaaaaaaaaac000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000009aaaaaaa99000caaaaaaaaaaac000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009aaa99900000caaaaaaaaaaac000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000999000000000caaaaaaaaac0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000caaaaaaac00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000ccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
