pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

#include lib/scene.p8:0
#include lib/actor.p8:0

-->8
--game
-- globals
step=0
gameover=true
troggles={}
level=1
level_text="01"
levelup=false
hints=false

-- utility
function rand(l,h)
  return l+flr(rnd(h-l+1))
end

function toggle_hints()
  hints = not hints
end
menuitem(1, "toggle hints",toggle_hints)
poke(0x5f2c, 3) -- small

game = scene:new {
  new = function(class, o)
    o = scene.new(class, o)
    nu=multiples:new {
      max = 20,
      mult = rand(2,9),
    }
    -- nu=factors:new {
    --   max = 20,
    -- }
    --  nu=primes:new {
    --    max = 20,
    --  }
    nu:gen()
    step=0
    pl=player:new()
    troggles={}
    troggle.gen()
    if gameover then
      gameover=false
      level=1
      level_text="01"
    elseif levelup then
      levelup=false
      level+=1
      level_text=level
      if (level<10) level_text="0"..level
    end
    return o
  end,

  update = function (s)
    step+=1
    if gameover then
      if (btnp(❎) or btnp(🅾️)) return game:new()
      return
    end

    if levelup then
      if (btnp(❎) or btnp(🅾️)) return game:new()
    else
      pl:update()
    end
    for t in all(troggles) do
      t:update()
      if t.x<-8 or t.x>72 or
        t.y<-8 or t.y>72 then
        del(troggles,t)
      end
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
    grid:draw()
    nu:draw()
    pl:draw()

    --print(pl.i.." "..pl.j,1,58,13)
    for t in all(troggles) do
      t:draw()
    end

    print(level_text,57,58,13)

    if gameover then
      rectfill(9,33,55,47,1)
      print("game over",15,34,7)
      print("❎ replay",15,42,13)
      -- _update=title_update
    end

    if levelup then
      rectfill(9,17,55,55,1)
      print("stage clear",11,19,7)
      print("❎ next",18,58,7)
      pl:draw()
    end

    if(hints)print(nu:hint() or "",0,58,13)
  end
}

title = scene:new {
  update = function (s)
    step+=1
    if btnp(❎) or btnp(🅾️) then
      sfx(1)
      return game:new()
    end
  end,
  draw = function (s)
    cls()
    map(8,0,0,0,8,8)
    print("❎ start",16,54,1)
  end
}

scene.install(title)

grid = {
  xc = 6,
  yc = 5,
  w = 10,
  h = 10,
  sx = 2,
  sy = 7,
  color = 14,

  draw = function(self)
    xc,yc,w,h,sx,sy,c = self.xc,self.yc,self.w,self.h,self.sx,self.sy,self.color
    for i=0,xc do
      line(sx + w * i, sy, sx + w * i, sy + h * yc, c)
    end
    for j=0,yc do
      line(sx, sy + h * j, sx + w * xc, sy + h * j, c)
    end
  end,

  trans = function(self, i, j, x, y)
    return self.sx + self.w * i + x, self.sy + self.h * j + y
  end,

  trans_inv = function(self, x, y)
    return flr((x - self.sx)/self.w), flr((y - self.sy)/self.h)
  end,
}

-->8
--player

player = actor:new {
  sprite = 16,
  frames = 5,
  i=0,
  j=0,

  new = function (class,s)
    s = actor.new(class, s)
    if (s.i and s.j) s.x,s.y = grid:trans(s.i, s.j, 2, 2)
    s.tx=s.x
    s.ty=s.y
    s.flip=false
    return s
  end,

  draw = function (a)
    spr(a.sprite + (flr(a.frame) % a.frames) * a.w / 8, a.x, a.y, a.w / 8, a.h / 8, a.flip)
  end,

  input = function (s)
    if btnp(⬆️) and s.j>0 then
      s.ty-=grid.h
      s.j-=1
    elseif btnp(⬇️) and s.j<4 then
      s.ty+=grid.h
      s.j+=1
    elseif btnp(➡️) and s.i<5 then
      s.tx+=grid.w
      s.i+=1
      s.flip=false
    elseif btnp(⬅️) and s.i>0 then
      s.tx-=grid.w
      s.i-=1
      s.flip=true
    end

    if btnp(❎) or btnp(🅾️) then
      s.co=cocreate(s.eating)
      sfx(1)
    end
  end,

  update = function(s)
    if s.co then
      if coresume(s.co, s) then
        return
      else
        s.co = nil
      end
    end
    if (s.input) s:input()

    if s.x!=s.tx or s.y!=s.ty then
      s.co = cocreate(s.moving)
    end
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
    nu:eat(s.i,s.j)
    s.frame=0
  end,
}

-->8

numbers = {
  min = 1,
  max = 99,
  answer_count=6,

  new = function(class, o)
    o = o or {}
    o.nums = {}
    setmetatable(o, class)
    class.__index = class
    return o
  end,

  eat = function(s,i,j)
    n=s.nums[(j*grid.xc)+i+1]
    if s:is_answer(n) then
      s.nums[(j*grid.xc)+i+1]=0
      if (s:hint()) return
        levelup=true
      _update=title_update
      troggles={}
      sfx(3)
      else
        gameover=true
        pl.x=-100
        sfx(4)
      end
  end,

  gen = function(s)
    -- generate answers
    for i=1,s.answer_count do
      s.nums[i]=s:gen_answer()
    end
    for i=s.answer_count+1,grid.xc*grid.yc do
      s.nums[i]=rand(s.min,s.max)
    end
    for i=1,grid.xc*grid.yc do
      if s.nums[i]<10 then
        -- s.nums[i]=" "..s.nums[i]
      end
    end
    -- shuffle
    for i=#s.nums,1,-1 do
      rn=ceil(rnd(i))
      s.nums[i],s.nums[rn]=s.nums[rn],s.nums[i]
    end
  end,

  draw = function(s)
    for j=0,4 do
      for i=0,5 do
        local n=s.nums[(j*grid.xc)+i+1]
        assert(n, "i ".. i .. "j" ..j)
        local x,y=grid:trans(i, j, 2, 3)
        -- if (n!=0) print(n,1+x*8,18+y*8,13)
        if (n==0) goto continue
        if n >= 10 then
          print(n,x,y,13)
        else
          print(" "..n,x,y,13)
        end
        ::continue::
        end
    end
  end,

  hint = function(s)
    for n in all(nu.nums) do
      if (n!=0 and s:is_answer(n)) return n
      end
  end
}

multiples = numbers:new {
  title = function(s)
    return " multiples of "..s.mult
  end,
  gen_answer = function(s)
    return s.mult*rand(1,10)
  end,
  is_answer = function(s,n)
    return n%s.mult == 0
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

-- equality = numbers:new {
--   max=9,
--   title = function(s)
--     return " equals "..s.topic
--   end,
--   gen = function(s)
--     for i=1,s.answer_count do
--       s.nums[i]=s:gen_answer()
--     end
--     for i=s.answer_count+1,grid.xc*grid.yc do
--       s.nums[i]=rand(s.min,s.max)
--     end
--     for i=1,grid.xc*grid.yc do
--       if s.nums[i]<10 then
--         s.nums[i]=" "..s.nums[i]
--       end
--     end
--     -- shuffle
--     for i=#s.nums,1,-1 do
--       rn=ceil(rnd(i))
--       s.nums[i],s.nums[rn]=s.nums[rn],s.nums[i]
--     end
--   end,
--   gen_answer = function(s)
--     local n = rand(s.min, s.max)
--     while not s:is_answer(n) do
--       n -= 1
--     end
--     return n
--   end,
--   is_answer = function(s,n)
--     for i = 2, n^(1/2) do
--         if (n % i) == 0 then
--             return false
--         end
--     end
--     return true
--   end
-- }

-->8
--troggle
troggle = player:new {
  sprite = 32,
  frames = 5,
  wait=20,

  new = function (class, s)
    s = player.new(class, s)
    -- assert(i ~= nil)
    s.x,s.y = grid:trans(s.i, s.j, 2, 2)
    -- s.x=x
    -- s.y=y
    s.dx=s.dx*grid.w
    s.dy=s.dy*grid.h
    s.i=i
    s.j=j
    s.flip=s.dx<0 or s.dy<0
    s.input=nil
    s.cobrain = cocreate(s.brain)
    return s
  end,

  gen = function ()
    local dir=rand(1,4)
    local i,j=rand(0,4),rand(0,5)
    -- i,j=3,j

    local dx, dy = 0,0
    if (dir==1) i,dx = -1,1
    if (dir==2) i,dx = grid.xc + 1,-1
    if (dir==3) j,dy = -1,1
    if (dir==4) j,dy = grid.yc + 1,-1
    add(troggles,troggle:new({i=i,j=j,dx=dx,dy=dy}))
  end,

  moving = function(s)
    player.moving(s)
    s.i,s.j=grid:trans_inv(s.x, s.y)
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

  update = function (s)
    coresume(s.cobrain, s)
    -- s.co=rest()

    -- player.update(s)
    -- s.rest-=1
    -- if s.rest==0 then
    --   s.co=s.moving
    --   s.rest=s.wait
    --   s.tx+=s.dx
    --   s.ty+=s.dy
    -- end
    -- s:attack()
  end,

  attack = function (s)
    if pl.x>=s.x and
      pl.y>=s.y and
      pl.x<=s.x+7 and
      pl.y<=s.y+7 then
      pl.x=s.x
      pl.y=s.y
      -- pl.update=function() end
      -- pl.draw=function() end
      pl.x=-100
      s.update=troggle_eating
      s.eating=20
      gameover=true
      sfx(2)
      sfx(4)
      return
    end
    for t in all(troggles) do
      if t!=s and
        t.x>=s.x and
        t.y>=s.y and
        t.x<=s.x+7 and
        t.y<=s.y+7 then
        t.x=s.x
        t.y=s.y
        -- t.update=function() end
        -- t.draw=function() end
        s.update=troggle_eating
        s.eating=20
        sfx(2)
        del(troggles,t)
      end
    end
  end
}

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
b161616bbb616161b1616161bbbbbbbbbbbbbbbb0000000000000000ffffffffbbffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
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
eeeeeee0eeeeeeeeeeeeeeee0e00ee000ee0e0000000000000000000ffffffffffffffffffffffffffffffffffffffffbffffffbffffffffffffffff00000000
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
