pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- number munchers
--
-- original cart[1] by hinicholas
-- modified by shane celis[2]
--
-- inspired by the original 1986
-- number munchers video game by
-- r. philip bouchard.
--
-- changes
-- -------
--
-- * add menu and game modes:
--   even, odd, lesser, greater,
--   primes, factors

--game

#include lib/scene.p8:0
#include lib/actor.p8:0
#include lib/menu.p8:0

-- globals
step=0
gameover=false
troggles={}
level=1
levelup=false

-- utility

-- return a random number [l,h]
function rand(l,h)
  return l+flr(rnd(h-l+1))
end

-- provides a numerical menu item or toggle.
menu_item = {
  index = 0,
  value = 0,
  increment = 1,
  selected = true,
  label = "",

  new = function(class, o)
    o = o or {}
    setmetatable(o, class)
    class.__index = class
    o:update()
    return o
  end,

  update = function(s)
    menuitem(s.index,  s:display(), function(b) return s:callback(b) end)
  end,

  callback = function(s, b)
    if(b&1 > 0) s.value -= s.increment
    if(b&2 > 0) s.value += s.increment
    if(b&32 > 0) s.selected = not s.selected
    s:update()
    return true -- stay open
  end,

  display = function(s)
    return s.label..s.value--..(s.selected and " on" or " off")
  end
}

hints_menu = menu_item:new {
  index = 1,
  label = "hints ",
  selected = false,
  display = function(s)
    return s.label..(s.selected and "on" or "off")
  end
}

min_menu = menu_item:new {
  index = 2,
  value = 0,
  increment = 10,
  label = "min ",
  update = function(s)
    if (max_menu) s.value = min(s.value, max_menu.value - s.increment)
    menu_item.update(s)
  end
}

max_menu = menu_item:new {
  index = 3,
  value = 20,
  increment = 10,
  label = "max ",
  update = function(s)
    s.value = max(s.value, min_menu.value + s.increment)
    menu_item.update(s)
  end
}
poke(0x5f2c, 3) -- small screen 64x64

game = scene:new {
  new = function(class, o)
    o = scene.new(class, o)
    step = 0
    nu.min = min_menu.value
    nu.max = max_menu.value
    nu:gen()
    pl=player:new()
    troggles={}
    troggle.gen()
    if gameover then
      gameover=false
      level=1
    elseif levelup then
      levelup=false
      level+=1
    end
    return o
  end,

  update = function (s)
    step+=1
    if gameover then
      if (btnp(❎) or btnp(🅾️)) return game_menu
      return
    end

    if levelup then
      if (btnp(❎) or btnp(🅾️)) return game:new()
    else
      pl:update()
    end
    for t in all(troggles) do
      t:update()
      if (not t:is_visible()) del(troggles,t)
      if #troggles<min(10,level) then
        troggle.gen()
      end
    end
  end,

  draw = function (s)
    cls(1)

    -- title
    rectfill(0,0,64,7,1)
    print(nu:title(),0,1,6)
    -- grid:draw()
    nu:draw()
    pl:draw()

    for t in all(troggles) do
      t:draw()
    end

    print("l "..level,46,59,13)

    if gameover then
      rectfill(9,33,55,47,1)
      print("game over",15,34,7)
      print("❎ replay",15,42,13)
    end

    if levelup then
      rectfill(9,17,55,55,1)
      print("stage clear",11,19,7)
      print("❎ next",18,48,7)
      pl:draw()
    end

    if(hints_menu.selected)print("hint: "..(nu:next_answer() or ""),2,59,13)
  end
}

title = scene:new {
  update = function (s)
    step+=1
    if btnp(❎) or btnp(🅾️) then
      sfx(1)
      -- return game:new()
      return game_menu:new()
    end
  end,
  draw = function (s)
    cls()
    map(8,0,0,0,8,8)
    print("❎ start",16,54,1)
  end
}

--player
player = actor:new {
  sprite = 16,
  frames = 5,
  i=0,
  j=0,

  new = function (class,s)
    s = actor.new(class, s)
    if (s.i and s.j and nu) s.x,s.y = nu.grid:trans(s.i, s.j, 2, 2)
    s.tx=s.x
    s.ty=s.y
    s.flip=false
    s.co = cocreate(s.coupdate)
    return s
  end,

  draw = function (a)
    spr(a.sprite + (flr(a.frame) % a.frames) * a.w / 8, a.x, a.y, a.w / 8, a.h / 8, a.flip)
  end,

  input = function (s)
    if btnp(⬆️) and s.j>0 then
      s.ty-=nu.grid.h
      s.j-=1
    elseif btnp(⬇️) and s.j<4 then
      s.ty+=nu.grid.h
      s.j+=1
    elseif btnp(➡️) and s.i<5 then
      s.tx+=nu.grid.w
      s.i+=1
      s.flip=false
    elseif btnp(⬅️) and s.i>0 then
      s.tx-=nu.grid.w
      s.i-=1
      s.flip=true
    end

    if btnp(❎) or btnp(🅾️) then
      sfx(1)
      s:eating()
      nu:eat(s.i, s.j)
    end
  end,

  coupdate = function(s)
    while true do
      if (s.input) s:input()

      s:moving()
      yield()
    end
  end,

  update = function(s)
    coresume(s.co, s)
  end,

  moving = function (s)
    while s.y != s.ty do
      s.frame=3+step%2
      dy = s.ty - s.y
      s.y = s.y + sgn(dy)
      yield()
    end
    while s.x != s.tx do
      s.frame=3+step%2
      dx = s.tx - s.x
      s.x = s.x + sgn(dx)
      yield()
    end
    s.frame=0
  end,

  eating = function (s)
    for i=1,15 do
      if step%3==0 then
        s.frame=1+step%2
      end
      yield()
    end
    s.frame=0
  end,

  --box to box intersection
  intersects = function(s, o)
    return s.x < o.x + o.w and o.x < s.x  + o.w and s.y < o.y + o.h and o.y < s.y + s.h
  end

}

grid = {
  -- count
  xc = 6,
  yc = 5,
  -- width and height of cells in grid
  w = 10,
  h = 10,
  -- start
  x = 2,
  y = 7,
  color = 14,

  new = function(class, o)
    o = o or {}
    setmetatable(o, class)
    class.__index = class
    return o
  end,

  -- draw the grid
  draw = function(self)
    xc,yc,w,h,x,y,c = self.xc,self.yc,self.w,self.h,self.x,self.y,self.color
    for i=0,xc do
      line(x + w * i, y, x + w * i, y + h * yc, c)
    end
    for j=0,yc do
      line(x, y + h * j, x + w * xc, y + h * j, c)
    end
  end,

  -- return cell position + (x,y) for the ith column and jth row, zero-based
  trans = function(self, i, j, x, y)
    return self.x + self.w * i + x, self.y + self.h * j + y
  end,

  -- return the closest ith column and jth row for position (x,y).
  trans_inv = function(self, x, y)
    return flr((x - self.x)/self.w), flr((y - self.y)/self.h)
  end,
}

numbers = {
  min = 1,
  max = 99,
  answer_count=6,
  grid = grid:new(),

  new = function(class, o)
    o = o or {}
    o.nums = {}
    setmetatable(o, class)
    class.__index = class
    return o
  end,

  index = function(s,i,j)
    return j*s.grid.xc+i+1
  end,

  eat = function(s,i,j)
    local k = s:index(i, j)
    n=s.nums[k]
    if (not n) return
    if s:is_answer(n) then
      s.nums[k]=nil
      if (s:next_answer()) return
      -- if there's no more answers, level is complete.
      levelup=true
      troggles={}
      sfx(3)
    else
      -- ate the wrong thing.
      gameover=true
      pl.x=-100
      sfx(4)
    end
  end,

  gen = function(s)
    if (not s.fixed_topic) s.topic = rand(2,9)
    -- generate answers
    for i=1,s.answer_count do
      s.nums[i]=s:gen_answer()
    end
    for i=s.answer_count+1,s.grid.xc*s.grid.yc do
      -- add numbers that aren't answers.
      s.nums[i] = s:gen_non_member()
    end
    -- shuffle
    for i=#s.nums,1,-1 do
      rn=ceil(rnd(i))
      s.nums[i],s.nums[rn]=s.nums[rn],s.nums[i]
    end
  end,

  gen_non_member = function(s)
    -- add numbers that aren't answers.
    local n
    repeat
      n=rand(s.min,s.max)
    until not s:is_answer(n)
    return n
  end,

  display = function(s, n)
    -- don't print zeros. pad with a space if < 10.
    if (n) return (n >= 10) and n or " "..n
  end,

  draw = function(s)
    s.grid:draw()
    for j=0,s.grid.yc - 1 do
      for i=0,s.grid.xc - 1 do
        local n=s:display(s.nums[s:index(i,j)])
        -- assert(n, "i ".. i .. "j" ..j)
        local x,y=s.grid:trans(i, j, 2, 3)
        -- don't print zeros. pad with a space if < 10.
        if (n) print(n,x,y,13)
      end
    end
  end,

  next_answer = function(s)
    for n in all(nu.nums) do
      if (n and s:is_answer(n)) return n
    end
  end,
}

multiples = numbers:new {
  title = function(s)
    return " multiples of "..s.topic
  end,
  gen_answer = function(s)
    return s.topic*rand(1,10)
  end,
  is_answer = function(s,n)
    return n%s.topic == 0
  end
}

greater = numbers:new {
  title = function(s)
    return " greater than "..s.topic
  end,
  gen_answer = function(s)
    return s.topic+rand(1,10)
  end,
  is_answer = function(s,n)
    return n > s.topic
  end
}

lesser = numbers:new {
  title = function(s)
    return " less than "..s.topic
  end,
  gen_answer = function(s)
    return rand(1,s.topic-1)
  end,
  is_answer = function(s,n)
    return n < s.topic
  end
}

evens = multiples:new {
  fixed_topic=true,
  topic=2,
  title = function(s)
    return " even numbers"
  end,
}

odds = evens:new {
  title = function(s)
    return " odd numbers"
  end,
  gen_answer = function(s)
    return s.topic*rand(1,10) + 1
  end,
  is_answer = function(s,n)
    return n%s.topic == 1
  end
}

factors = numbers:new {
  count = 4,
  title = function(s)
    return " factors of "..s.topic
  end,
  find_factors = function(n)
    local accum = {}
    for i=1,flr(sqrt(n)) do
      if n%i == 0 then
        add(accum, i)
        if (flr(n/i) ~= i) then
          add(accum, flr(n/i))
        end
      end
    end
    return accum
  end,
  gen = function(s)
    local accum
    repeat
      s.topic = rand(s.min + 1, s.max)
      s.factors = s.find_factors(s.topic)
    until #s.factors > 2
    numbers.gen(s)
  end,
  gen_answer = function(s)
    return s.factors[rand(1, #s.factors)]
  end,
  is_answer = function(s,n)
    for x in all(s.factors) do
      if (x == n) return true
      end
    return false
  end
}

primes = numbers:new {
  title = function(s)
    return " prime numbers"
  end,
  gen_answer = function(s)
    local n = rand(s.min, s.max)
    while not s:is_answer(n) do
      n -= 1
    end
    return n
  end,
  is_answer = function(s,n)
    if (n == 1) return false
    for i = 2, n^(1/2) do
      if (n % i) == 0 then
        return false
      end
    end
    return true
  end
}

equals = numbers:new {

  grid = grid:new {
    x = 4,
    xc = 3,
    yc = 5,
    -- width and height of cells in grid
    w = 18,
    h = 10,
  },
  title = function(s)
    return " equals "..s.topic
  end,
  display = function(s, n)
    if (n) return n[2]
  end,
  is_answer = function(s,n)
    if (n) return n[1] == s.topic
  end,
  gen_answer = function(s)
    -- local n = rand(s.min, s.max)
    local n = rand(1, 9)
    local x = s.topic - n
    if x >= 0 then
      return {s.topic, (x >= 10 and x or " "..x).."+"..n}
    else
      return {s.topic, (x <= -10 and n or " "..n).."-"..abs(x)}
    end
  end,

  gen_non_member = function(s)
    local n = rand(s.min, s.max)
    local x = rand(1, 9)
    return {x + n, (n>=10 and "" or " ")..n.."+"..x}
  end,
}

game_menu = menu:new {
  y=1,
  x=0,
  line_height=8,
  items = {"evens",
           "odds",
           "greater",
           "lesser",
           "equals",
           "multiples",
           "factors",
           "primes"},

  objects = { evens,
              odds,
              greater,
              lesser,
              equals,
              multiples,
              factors,
              primes },

  selected = function(s, i)
    nu = (s.objects[i]):new()
    return game:new()
  end
}

--troggle
troggle = player:new {
  sprite = 32,
  frames = 5,
  wait=20,

  new = function (class, s)
    s = player.new(class, s)
    s.x,s.y = nu.grid:trans(s.i, s.j, 2, 2)
    s.dx=s.dx*nu.grid.w
    s.dy=s.dy*nu.grid.h
    s.i=i
    s.j=j
    s.flip=s.dx<0 or s.dy<0
    s.input=nil
    s.co = cocreate(s.brain)
    return s
  end,

  gen = function ()
    local dir=rand(1,4)
    local min=(step < 10) and 1 or 0
    local i,j=rand(min,nu.grid.xc-1),rand(min,nu.grid.yc-1)

    local dx, dy = 0,0
    if (dir==1) i,dx = -1,1
    if (dir==2) i,dx = nu.grid.xc + 1,-1
    if (dir==3) j,dy = -1,1
    if (dir==4) j,dy = nu.grid.yc + 1,-1
    add(troggles,troggle:new({i=i,j=j,dx=dx,dy=dy}))
  end,

  is_visible = function(s)
    return ((s.x + s.w) > 0 and s.x < 64) and ((s.y + s.h) > 0 and s.y < 64)
  end,

  moving = function(s)
    player.moving(s)
    s.i,s.j=nu.grid:trans_inv(s.x, s.y)
  end,

  rest = function(s)
    for i=1,s.wait do
      yield()
    end
  end,

  brain = function(s)
    while true do
      s:rest()
      s.tx+=s.dx
      s.ty+=s.dy
      s:moving()
      s:attack()
    end
  end,

  attack = function (s)
    if s:intersects(pl) then
      printh("blah pl "..pl.x.." "..pl.y.." s "..s.x.." "..s.y)
      pl.x=-100
      gameover=true
      sfx(2)
      sfx(4)
      s:eating()
      return
    end
    for t in all(troggles) do
      if t!=s and s:intersects(t) then
        t.x=s.x
        t.y=s.y
        printh("blah 2")
        s:eating()
        sfx(2)
        del(troggles,t)
      end
    end
  end
}

-- start with the title scene
scene.install(title)

__gfx__
0000000011111111eeeeeeeeeeeeeeeeeeeeeeeee1111111e1111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
0000000011111111e111111111111111e1111111e111111111111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
0070070011111111e111111111111111e1111111e111111111111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
0007700011111111e111111111111111e1111111e111111111111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
0007700011111111e111111111111111e1111111e111111111111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
0070070011111111e111111111111111e1111111e111111111111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
0000000011111111e111111111111111e1111111e111111111111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
0000000011111111e111111111111111e1111111e111111111111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
07707700077077000770770007707700077077000000000000000000fffffffff77f77ffffffffffffffffffffffffffffffffffffffffffffffffff00000000
07507500075075000750750007507500075075000000000000000000fffffffff75f75ffffffffffffffffffffffffffffffffffffffffffffffffff00000000
bbbbbb00bbbbbbbbbbbbbbbbbbbbbb00bbbbbb000000000000000000ffffffffbbbbbbbbffffffffffffffffffffffffffffffffffffffffffffffff00000000
b1bbbb1bbbbbbbbbbbbbbbbbb616161bb616161b0000000000000000ffffffffbbfbbbbbffffffffffffffffffffffffffffffffffffffffffffffff00000000
b161616bbb616161b1616161bbbbbbbbbbbbbbbb0000000000000000ffffffffbbf7f7f7ffffffffffffffffffffffffffffffffffffffffffffffff00000000
bbbbbbbbbb111111bbbbbbbb0b00b0000b00b0000000000000000000ffffffffbbffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
0b000b00bbbbbbbb0b000b000b00bb000bb0b0000000000000000000ffffffffbbbbbbbbffffffffffffffffffffffffffffffffffffffffffffffff00000000
0bbb0bbb0bb00bbb0bb00bbb0bbb00000000bbb00000000000000000fffffffffbbffbbfffffffffffffffffffffffffffffffffffffffffffffffff00000000
08888888088888880888888808888888088888880000000000000000fffffffffcccccffffffffffffcccccfffffffffffccccffffffffffffffffff00000000
87587588875875888758758887587588875875880000000000000000fffffffffccccccffffffffffccfcfcffffffffffccfffffffffffffffffffff00000000
88888888888888888888888888888888888888880000000000000000fffffffffccffccffccffccffccfcfcffcccccfffccffffffcccccffffffffff00000000
81888888886161718888888887171716861616160000000000000000fffffffffccffccffccffccffccfcfcffccffccffccccffffccffccfffffffff00000000
81611616881111118717171788888888888888880000000000000000fffffffffccffccffccffccffccfcfcffccffccffccffffffccffccfffffffff00000000
88888880881111118888888888888888888888880000000000000000fffffffffccffccffccffccffccfcfcffcccccfffcccccfffcccccffffffffff00000000
88888880888888888888888808008800088080000000000000000000fffffffffffffffffccccccffffffffffccffccffffffffffccffccfffffffff00000000
08880888088008880880088808880000000088800000000000000000ffffffffffffffffffccccfffffffffffccccccffffffffffccffccfffffffff00000000
0eeeeeee0eeeeeee0eeeeeee0eeeeeee0eeeeeee0000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
e75e75eee75e75eee75e75eee75e75eee75e75ee0000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000ffffffffffffffffffffffffffffffffffffffffff77f77fffffffffffffffff00000000
e1eeeeeeee616161eeeeeeeee6161616e61616160000000000000000ffffffffffffffffffffffffffffffffffffffffff57f57fffffffffffffffff00000000
e1616161ee111111e6161616eeeeeeeeeeeeeeee0000000000000000ffffffffffffffffffffffffffffffffffffffffffbbbbbbffffffffffffffff00000000
eeeeeee0ee111111eeeeeeeeeeeeeeeeeeeeeeee0000000000000000ffffffffffffffffffffffffffffffffffffffffbfbbbbfbffffffffffffffff00000000
eeeeeee0eeeeeeeeeeeeeeee0e00ee000ee0e0000000000000000000ffffffffffffffffffffffffffffffffffffffffb7f7f7fbffffffffffffffff00000000
0eee0eee0ee00eee0ee00eee0eee00000000eee00000000000000000ffffffffffffffffffffffffffffffffffffffffbbbbbbbbffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffeeeeeffffffffffeeeeefffffffffffeeffeefffbfffbffeeeeeffffffffff00000000
00000000000000000000000000000000000000000000000000000000feefefeffffffffffeeeeeeffffffffffeeffeefbbbfbbbffeeffeefffffffff00000000
00000000000000000000000000000000000000000000000000000000feefefeffeeffeeffeeffeefffeeeefffeeffeefffeeeefffeeffeefffeeeeff00000000
00000000000000000000000000000000000000000000000000000000feefefeffeeffeeffeeffeeffeeffffffeeeeeeffeeffffffeeeeefffeeeeeff00000000
00000000000000000000000000000000000000000000000000000000feefefeffeeffeeffeeffeeffeeffffffeeeeeeffeeffffffeeffeeffeefffff00000000
00000000000000000000000000000000000000000000000000000000feefefeffeeffeeffeeffeeffeeffffffeeffeeffeeeeffffeeffeefffeeeeff00000000
00000000000000000000000000000000000000000000000000000000fffffffffeeeeeeffffffffffeeffffffffffffffeefffffffffffffffffeeef00000000
00000000000000000000000000000000000000000000000000000000ffffffffffeeeeffffffffffffeeeefffffffffffeeeeefffffffffffeeeeeff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
__label__
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffff7777ff7777ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffff7777ff7777ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffff7755ff7755ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffff7755ff7755ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffbbbbbbbbbbbbbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffbbbbbbbbbbbbbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffbbbbffbbbbbbbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffbbbbffbbbbbbbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffbbbbbbbbbbbbbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffbbbbbbbbbbbbbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffbbbbffffbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffbbbbffffbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffccccccccccffffffffffffffffffffffffccccccccccffffffffffffffffffffffccccccccffffffffffffffffffffffffffffffffffff
ffffffffffffffffffccccccccccffffffffffffffffffffffffccccccccccffffffffffffffffffffffccccccccffffffffffffffffffffffffffffffffffff
ffffffffffffffffffccccccccccccffffffffffffffffffffccccffccffccffffffffffffffffffffccccffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffccccccccccccffffffffffffffffffffccccffccffccffffffffffffffffffffccccffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffccccffffccccffffccccffffccccffffccccffccffccffffccccccccccffffffccccffffffffffffccccccccccffffffffffffffffffff
ffffffffffffffffffccccffffccccffffccccffffccccffffccccffccffccffffccccccccccffffffccccffffffffffffccccccccccffffffffffffffffffff
ffffffffffffffffffccccffffccccffffccccffffccccffffccccffccffccffffccccffffccccffffccccccccffffffffccccffffccccffffffffffffffffff
ffffffffffffffffffccccffffccccffffccccffffccccffffccccffccffccffffccccffffccccffffccccccccffffffffccccffffccccffffffffffffffffff
ffffffffffffffffffccccffffccccffffccccffffccccffffccccffccffccffffccccffffccccffffccccffffffffffffccccffffccccffffffffffffffffff
ffffffffffffffffffccccffffccccffffccccffffccccffffccccffccffccffffccccffffccccffffccccffffffffffffccccffffccccffffffffffffffffff
ffffffffffffffffffccccffffccccffffccccffffccccffffccccffccffccffffccccccccccffffffccccccccccffffffccccccccccffffffffffffffffffff
ffffffffffffffffffccccffffccccffffccccffffccccffffccccffccffccffffccccccccccffffffccccccccccffffffccccccccccffffffffffffffffffff
ffffffffffffffffffffffffffffffffffccccccccccccffffffffffffffffffffccccffffccccffffffffffffffffffffccccffffccccffffffffffffffffff
ffffffffffffffffffffffffffffffffffccccccccccccffffffffffffffffffffccccffffccccffffffffffffffffffffccccffffccccffffffffffffffffff
ffffffffffffffffffffffffffffffffffffccccccccffffffffffffffffffffffccccccccccccffffffffffffffffffffccccffffccccffffffffffffffffff
ffffffffffffffffffffffffffffffffffffccccccccffffffffffffffffffffffccccccccccccffffffffffffffffffffccccffffccccffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7777ff7777ffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7777ff7777ffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5577ff5577ffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5577ff5577ffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbbbbbbbbffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbbbbbbbbffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbffbbbbbbbbffbbffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbffbbbbbbbbffbbffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbffffffffffffbbffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbffffffffffffbbffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbbbbbbbbbbbbffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbbbbbbbbbbbbffffffffffffffffffffffffffffffff
ffffeeeeeeeeeeffffffffffffffffffffeeeeeeeeeeffffffffffffffffffffffeeeeffffeeeeffffffbbffffffbbffffeeeeeeeeeeffffffffffffffffffff
ffffeeeeeeeeeeffffffffffffffffffffeeeeeeeeeeffffffffffffffffffffffeeeeffffeeeeffffffbbffffffbbffffeeeeeeeeeeffffffffffffffffffff
ffeeeeffeeffeeffffffffffffffffffffeeeeeeeeeeeeffffffffffffffffffffeeeeffffeeeeffbbbbbbffbbbbbbffffeeeeffffeeeeffffffffffffffffff
ffeeeeffeeffeeffffffffffffffffffffeeeeeeeeeeeeffffffffffffffffffffeeeeffffeeeeffbbbbbbffbbbbbbffffeeeeffffeeeeffffffffffffffffff
ffeeeeffeeffeeffffeeeeffffeeeeffffeeeeffffeeeeffffffeeeeeeeeffffffeeeeffffeeeeffffffeeeeeeeeffffffeeeeffffeeeeffffffeeeeeeeeffff
ffeeeeffeeffeeffffeeeeffffeeeeffffeeeeffffeeeeffffffeeeeeeeeffffffeeeeffffeeeeffffffeeeeeeeeffffffeeeeffffeeeeffffffeeeeeeeeffff
ffeeeeffeeffeeffffeeeeffffeeeeffffeeeeffffeeeeffffeeeeffffffffffffeeeeeeeeeeeeffffeeeeffffffffffffeeeeeeeeeeffffffeeeeeeeeeeffff
ffeeeeffeeffeeffffeeeeffffeeeeffffeeeeffffeeeeffffeeeeffffffffffffeeeeeeeeeeeeffffeeeeffffffffffffeeeeeeeeeeffffffeeeeeeeeeeffff
ffeeeeffeeffeeffffeeeeffffeeeeffffeeeeffffeeeeffffeeeeffffffffffffeeeeeeeeeeeeffffeeeeffffffffffffeeeeffffeeeeffffeeeeffffffffff
ffeeeeffeeffeeffffeeeeffffeeeeffffeeeeffffeeeeffffeeeeffffffffffffeeeeeeeeeeeeffffeeeeffffffffffffeeeeffffeeeeffffeeeeffffffffff
ffeeeeffeeffeeffffeeeeffffeeeeffffeeeeffffeeeeffffeeeeffffffffffffeeeeffffeeeeffffeeeeeeeeffffffffeeeeffffeeeeffffffeeeeeeeeffff
ffeeeeffeeffeeffffeeeeffffeeeeffffeeeeffffeeeeffffeeeeffffffffffffeeeeffffeeeeffffeeeeeeeeffffffffeeeeffffeeeeffffffeeeeeeeeffff
ffffffffffffffffffeeeeeeeeeeeeffffffffffffffffffffeeeeffffffffffffffffffffffffffffeeeeffffffffffffffffffffffffffffffffffeeeeeeff
ffffffffffffffffffeeeeeeeeeeeeffffffffffffffffffffeeeeffffffffffffffffffffffffffffeeeeffffffffffffffffffffffffffffffffffeeeeeeff
ffffffffffffffffffffeeeeeeeeffffffffffffffffffffffffeeeeeeeeffffffffffffffffffffffeeeeeeeeeeffffffffffffffffffffffeeeeeeeeeeffff
ffffffffffffffffffffeeeeeeeeffffffffffffffffffffffffeeeeeeeeffffffffffffffffffffffeeeeeeeeeeffffffffffffffffffffffeeeeeeeeeeffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffff1111111111ffffffffffffff1111ff111111ff111111ff111111ff111111ffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffff1111111111ffffffffffffff1111ff111111ff111111ff111111ff111111ffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffff1111ff11ff1111ffffffffff11ffffffff11ffff11ff11ff11ff11ffff11ffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffff1111ff11ff1111ffffffffff11ffffffff11ffff11ff11ff11ff11ffff11ffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffff111111ff111111ffffffffff111111ffff11ffff111111ff1111ffffff11ffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffff111111ff111111ffffffffff111111ffff11ffff111111ff1111ffffff11ffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffff1111ff11ff1111ffffffffffffff11ffff11ffff11ff11ff11ff11ffff11ffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffff1111ff11ff1111ffffffffffffff11ffff11ffff11ff11ff11ff11ffff11ffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffff1111111111ffffffffffff1111ffffff11ffff11ff11ff11ff11ffff11ffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffff1111111111ffffffffffff1111ffffff11ffff11ff11ff11ff11ffff11ffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff

__map__
01010101010101010708090a0b0c0d0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101011718191a1b1c1d1e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040404040404052728292a2b2c2d2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040404040404053738393a3b3c3d3e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040404040404054748494a4b4c4d4e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040204040404055758595a5b5c5d5e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040404040404056768696a6b6c6d6e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030303030303067778797a7b7c7d7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000115050170501a0501c0501f050210502305025050250502505024050210501f0501f0502105026050280502b0502d0502d0502d0502c0502a050280502605025050210501e050000000000000000
00010000000002005020050210502205023050210501e0501c0501c0501d0501f050220502405023050250500000027050290502b0502b0500100000000000000000000000000000000000000000000000000000
000100001d4501b45018450154501345012450104500e450104500e4500c4500b4500b4500d45011450164501b4501e4500e50017400174002450000000000000000000000000000000000000000000000000000
000200001c7501d7501d7501c7501975017750157501575014750127501375013750147501475016750197501b7501d7501f7502275025750287502c7502e7502f75031750327503375033750347003370033700
000200002d7502c750287502475021750227502475024750207501e7501a7501875016750177501775018750187501775013750127500e7500e750107500f7500b75009750047500275000750147001370013700
