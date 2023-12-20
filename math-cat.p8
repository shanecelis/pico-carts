pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
#include lib/keyboard.p8:0

-- have fun, do math!
function game()
  local count = 0
  while count < 20 do
    subtract_question()
    count = count + 2
    add_question()
    print("count "..count)
  end
  cls(14)
  palt(0,false)
  spr(0,32,32,8,8)
  music(0)
end

function add_question()
  local a, b, c
  a = flr(rnd(90))
  b = flr(rnd(10))
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
  a = flr(rnd(90))
  b = flr(rnd(10))
  c = prompt("what is "..
             a.." - "..b.."? ")
  if c == "idk" then
    print("thats, okay.we'l tell you  it's \n"..
          (a - b)..".")
  else
	  c = tonum(c)
	  if c == a - b then
	    print("correct! 🐱")
	  else
	    print("oh, no. it's actually "..
	          (a - b)..".")
	  end
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
__gfx__
cccccccccccccccccccccc99eddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccc99eee9ddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccc9eeee999dddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccceeeeeeee99dd99999999dddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccc9eeeeeeee999999999999ddddddd999dddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc9eeeee999999999999999999999e9ddddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc9eeee9999999999999999999eeee9ddddddddddd0000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccccc9ee999999999999999999999ee9dddddddddddd0000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccccccee999999999999999999999ee9dddddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccc99999999999999999999999eeddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccccc99999999999999999999999999ddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccccc99999999999999999999999999ddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc9999999999999999999999999999dddddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc9999999911199999999999999999dddddddddddd0000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccc999999999111999999991119999999ddddddddddd0000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccc999999999111999999991119999999ddddddddddd0000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccc999999999999999999991119999999ddddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccc99999999999999999999999999999999dddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccc99999999999999999999999999999999dddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccc99999999999999999999999999999999dddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccc99999999999999999999999999999999dddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccc99999999999999999999999999999999dddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccc99999999999999999999999999999999dddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccc99999999999999444999999999999999dddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccc99999999999999444999999999999999dddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccc99999999999999444999999999999999dddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccc99999999999999999999999999999999dddddddddd0000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccc999999999999999999999999999999ddddddddddd0000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccc999999999999999999999999999999ddddddddddd0000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccc999999999999999999999999999999ddddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc9999999999999999999999999999dddddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc9999999999999999999999999999dddddddddddd0000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccccc9999999e999999999999e99999ddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccccc9999999e999999999999e99999ddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
cccc0000777777777c000ccccc9999999ee99999999ee99999dddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
cc77000077777770000007ccccc99999999eeeeeeee999999ddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
0000000007777770000007cccccc99999999999999999999dddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
0000000007777770007777ccccccc999999999999999999ddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
00000000077777777777777999cccc9999999999999999dddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
00000000077777777770007999cccccc999999999999dddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
00000000007777770000009999cccccccc999999999ddeeedddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
00000000007777770000009997ccccccccc9999999999eeeeddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
000000000077777700077799999cccccccc9999999999eeeeddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
0000000000077777777777c999999ccccc99999999999eeeeddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
0000000000077777777777ccc999999ccc99999999999eeeeddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
000000000007777777777cccccc99999999999999999eeeeeddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
00000000000777777777000cccccc999999999999999eeeeeddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
00000000000777770007000ccccccccc999999999999eeeeeddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
00000000000777770007000cccccccccccc99999999eeeeeeddddddddddddddd000000000000000000000000dddddddddddddddd000000000000000000000000
0000000000077777000777ccccccccccccc99999999eeeeeeddddddddddddddd000000000000000000000000dddddddddddddddd000000000000000000000000
0000000000077777777777ccccccccccccc99999999eeeeeeddddddddddddddd000000000000000000000000dddddddddddddddd000000000000000000000000
0000000000077777777777ccccccccccccc9999999eeeeeeeddddddddddddddd000000000000000000000000dddddddddddddddd000000000000000000000000
00000000000777700077000cccccccccccc9999999eeeeeedddddddddddddddd000000000000000000000000dddddddddddddddd000000000000000000000000
00000000000777700077000ccccccccccc9999999eeeeeeedddddddddddddddd000000000000000000000000ddddddd333dddddd000000000000000000000000
00000000000777700070000ccccccccccc99999eeeeeeeeddddddddddddddddd000000000000000000000000dddddd33333ddddd000000000000000000000000
cc000000000777777770000cccccccccc9999999eeeeeedddddddddddddddddd000000000000000000000000ddddd3333333dddd000000000000000000000000
cc000c0000077777ccc00000ccccccccc99eeeeeeeeeeddddddddddddddddddd000000000000000000000000dddd333333333ddd000000000000000000000000
cc0000cccccccccccccc0000ccccccccc99eeeeeeeeedddddddddddddddddddd000000000000000000000000dddd3333333333dd000000000000000000000000
cc0000cccccccccccccc0000ccccccccc99eeeeeeddddddddddddddddddddddd000000000000000000000000ddca333333333ddd000000000000000000000000
cc0000cccccccccccccc0000cccccceee99eeeeeeedddddddddddddddddddddd000000000000000000000000ddaa33333333dddd000000000000000000000000
cc0000cccccccccccccc0000cccccceeeeeeeeeeeeeddddddddddddddddddddd000000000000000000000000ddaaa3333333dddd000000000000000000000000
c0000ccccccccccccccc0000cccccceeeeeeeeeeeedddddddddddddddddddddd000000000000000000000000ddaaa3333333aaad000000000000000000000000
c0000ccccccccccccccc0000cccccc4bbbeeeebbb4dddddddddddddddddddddd000000000000000000000000ddaaaa3333aadddd000000000000000000000000
c0000ccccccccccccccc00000ccccc4bbbbbbbbbb4dddddddddddddddddddddd000000000000000000000000ddaaaaaaaaaadddd000000000000000000000000
__sfx__
00030000000003e7502875026750247502375022750227502275022750227503e7503d7503c7503b7503d7503f750213502235020350190502005025050280502e0502f0500d0500a05008050050500405003050
000c0000000000000000000000000000000000000000a3500f350143501a35023350293502b3502c3502d350000002d3502e350000002f3502f3503335037350383503f350033503e3501f3501f350253503f350
0010000000000000003f550285701b570105703e570395702657004570375703e57004570085700d550185501c55021550295502d550365503a5503e55016550185501e550255502d550385503e5500000000000
__music__
01 02414344
02 01424344
