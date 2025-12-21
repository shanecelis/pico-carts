pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- TODO
-- * money
#include lib/vector.p8
x=64 -- our needle's x position
y=64 -- our needle's y position
d=0.5 -- our direction
dd=0.01 -- our rotation speed
s=0 -- our speed
s_max=0.25 -- our max speed
score = 0

-- points we've sown.
sewn={{x,y}}

function _update()
  -- left
  if btn(0) then
    d += dd
  end
  -- right
  if btn(1) then
    d -= dd
  end
  -- up
  if btn(2) then
    s = s_max
  end
  -- down
  if btn(3) then
    s = 0
  end
  -- move in direction d at speed s
  x += s * cos(d)
  y += s * sin(d)
  -- add a point to sewn if not already there.
  if not v_eqish({x,y}, sewn[#sewn]) then
    local pt = {flr(x),flr(y)}
    if contains(sewn, pt) then
      -- we're overlapping
      s = 0
      local percent = score_percent()
      if percent > 90 then
        grade='a'
      elseif percent > 80 then
        grade='b'
      elseif percent > 70 then
        grade='c'
      elseif percent > 60 then
        grade='d'
      else
        grade='f'
      end
    else
      add(sewn, pt)
      score += score_pt(pt, shirt)
    end
  end
end

-- are vectors equal-ish?
-- e.g., {0,1}=={0,1} -> true
--       {2,3}=={4,5} -> false
--       {0,1}=={0.4,1.2} -> true
function v_eqish(a, b)
  return flr(a[1]) == flr(b[1])
    and flr(a[2]) == flr(b[2])
end

function _init()
  local right = dup(half_shirt)
  scale(1,-1,right)
  translate(x+w,y, right)
  local left = dup(half_shirt)
  scale(-1,-1,left)
  translate(x-w,y, left)
  shirt = concat(left, rev(right))
end


function _draw()
		cls()
		local f = time()
		if not btn(5) then
		  f = 0
		end
		draw_needle(x,y,f)
		--tline(10, 120,118, 120, 0, 1/8)
		--tline(10, 30, 10, 120, 0, 1/8)
		draw_tshirt(50,100)
		draw_line(sewn)
    print("score " .. score_percent(), 10, 110)

    if grade then
      print("\^w\^t"..grade, 80, 80, 8)
    end
end

function score_percent()
  return flr(100 - score/10)
end

w = 5
half_shirt={
{-w,0},
{15,0},{15,30},{26,24},{40,42},
{19,58},{9,60},{4,50},{-w,50}}

-- translate points by x,y
function translate(x,y,pts)
  for i=1,#pts do
    pts[i][1] += x
    pts[i][2] += y
  end
end

function score_pt(point, lines)
  local c = 32767 -- current point score
  for j = 1,#lines-1 do
    local l = dist_to_line(point, lines[j], lines[j+1])
    if l < c then
      c = l
    end
  end
  return c
end

-- return distance of point pt to line segment
function dist_to_line(pt, line_start, line_end)
  local p = vector.from_list(pt)
  local a = vector.from_list(line_start)
  local b = vector.from_list(line_end)
  local ba = b - a
  local pa = p - a
  local t = ba:dot(pa)/ba:sqlength()
  if t < 0 then
    return pa:length()
  elseif t > 1 then
    return (p - b):length()
  else
    local r = a + t * ba
    return (p - r):length()
  end
end

-- duplicate points
function dup(pts)
  a = {}
  for i=1,#pts do
    a[i] = {pts[i][1], pts[i][2]}
  end
  return a
end
function contains(t, value)
    for i = 1, #t do
      if t[i][1] == value[1] and t[i][2] == value[2] then
            return true
        end
    end
    return false
end

-- scale points
function scale(x,y,pts)
  for i=1,#pts do
    pts[i][1] *= x
    pts[i][2] *= y
  end
end

-- draw line
function draw_line(pts, dashed)
  for i=1,#pts - 1 do
    if dashed then
		    tline(pts[i][1],
		         pts[i][2],
		         pts[i+1][1],
		         pts[i+1][2], 
		         0, 1/8)
				else
		    line(pts[i][1],
		         pts[i][2],
		         pts[i+1][1],
		         pts[i+1][2])
    end
  end
end

function draw_tshirt(x,y)
  color(7)
  draw_line(shirt, true)
  --line(x,0,x,127,8)
end

function concat(a, b)
    local n = #a
    for i = 1, #b do
        a[n + i] = b[i]
    end
    return a
end

-- reverse a list inplace
function rev(t)
    local i, j = 1, #t
    while i < j do
        t[i], t[j] = t[j], t[i]
        i = i + 1
        j = j - 1
    end
    return t
end

-- given turns return direction vector
function dir(turns)
  return {cos(turns), sin(turns)}
end

-- get perpendicular vector
function perp(pt)
		return {pt[2],-pt[1]}
end

function draw_needle(x,y,t)
	--rectfill(x,y,x+10,y+5)
	local c = color()
	local w = 5
	local h = 5
	local p = {x,y}
	local i = dir(d)
	local j = perp(i)
 -- p - i*w - h*j, p+i*w-h*j
	line(x - w*i[1] - h*j[1], 
	     y - w*i[2] - h*j[2], 
	     x + w*i[1] - h*j[1], 
	     y + w*i[2] - h*j[2],8)
	local f = sin(t) * 5
	
 -- p - i*w + h*j, p+i*w+h*j

	line(x - w*i[1] + h*j[1], 
	     y - w*i[2] + h*j[2], 
	     x + w*i[1] + h*j[1], 
	     y + w*i[2] + h*j[2],8)
	--line(x - w*i, y + h*j, x + w*i, y + h*j,8)

	--line(x+5,y-5+f,x+5, y+5+f)
 color(c)
end
__gfx__
00000000070707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
