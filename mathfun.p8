pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
#include lib/keyboard.p8:0

-- have fun, do math!
function game()
  while true do
    subtract_question()
    add_question()
  end
end

function add_question()
  local a, b, c
  a = flr(rnd(3))
  b = flr(rnd(3))
  c = prompt("what is "..
             a.." + "..b.."? ")
  c = tonum(c)
  if c == a + b then
    print("correct! 🐱")
  else
    print("oh, no. it's actually "..
          (a + b)..".")
  end
end

function subtract_question()
  local a, b, c
  a = flr(rnd(300))
  b = flr(rnd(300))
  c = prompt("what is "..
             a.." - "..b.."? ")
  c = tonum(c)
  if c == a - b then
    print("correct! 🐱")
  else
    print("oh, no. it's actually "..
          (a - b)..".")
  end
end

function wait(t)
  local start = time()
  while time() - start < t do
    yield()
  end
end

function _init()
  keyboard:init()
  keyboard.echo = true
  cls()
  -- create the game coroutine.
  game = cocreate(game)
  coresume(game)
end

function _update()

  -- resume the game coroutine.
  coresume(game)
end
