pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-- scaling pico sprites
-- by @mykie on twitter
-- https://mishkabear.itch.io/pico-8-rotate

function sprr(n,x,y,w,h,flip_x,flip_y,s,a,ax,ay)
 w = w or 1
 h = h or 1
 a = a or 0
 ax = ax or 0
 ay = ay or 0
 local vs = mulv(translate(-1/2, -1/2), box(1))
 local m = mulm(rotate(-a/360),scale(s or 1))
 local big = mulm(m, translate(-ax, -ay))
 local v1 = {}
 local m1 = {}
 local ws = {}
 local sx = n % 16 * 8
 local sy = flr(n/16) * 16
 for yy=1,8*h do
  for xx=1,8*w do
    local c = sget(flip_x and sx + 8*w - xx or sx + xx,
                   flip_y and sy + 8*h - yy or sy + yy)
    -- debug: render each pixel with a different color.
    -- c = (xx + yy - 1) % 16
    mulv(big, {xx, yy, 1}, v1)
    mulm(translate(x + v1[1] + ax, y + v1[2] + ay), m, m1)
    mulv(m1, vs, ws)
    render_poly(ws, c)
    -- fill_rect(ws, c)
  end
 end
end

-- function scalespr2(posx,posy,s,a)
--  local vs = mulv(translate(-1/2, -1/2), box(1))
--  local m = mulm(rotate(-ang/360),scale(s))
--  local big = mulm(m, translate(-4, -4))
--  local v1 = {}
--  local m1 = {}
--  local w = {}
--  local n = 1
--  for y=1,8 do
--   for x=1,8 do
--     local c = sget(n % 16 * 8 + x - 1, flr(n/16) * 16 + y - 1)
--     mulv(big, {x, y, 1}, v1)
--     mulm(translate(posx + v1[1], posy + v1[2]), m, m1)
--     -- render_poly(mulv(m1, vs, w), sprite[x][y])
--     render_poly(mulv(m1, vs, w), c)
--     -- render_poly(mulv(m1, vb, w), (x + y - 1) % 16)
--   end
--  end
-- end

function scale(x, y)
  return {x, 0,      0,
          0, y or x, 0,
          0, 0,      1 }
end

function translate(x, y)
  return {1, 0, x,
          0, 1, y,
          0, 0, 1 }
end

function rotate(a)
  local c = cos(a)
  local s = sin(a)
  return {c, -s, 0,
          s,  c, 0,
          0,  0, 1 }
end

function mulv(m, v, r)
  r = r or {}
  for i = 1,#v,3 do
    r[i + 0] = m[1] * v[i] + m[2] * v[i + 1] + m[3] * v[i + 2]
    r[i + 1] = m[4] * v[i] + m[5] * v[i + 1] + m[6] * v[i + 2]
    r[i + 2] = m[7] * v[i] + m[8] * v[i + 1] + m[9] * v[i + 2]
  end
  return r
end

function mulm(m, n, r)
  r = r or {}
  r[1] = m[1]*n[1] + m[2]*n[4] + m[3]*n[7]
  r[2] = m[1]*n[2] + m[2]*n[5] + m[3]*n[8]
  r[3] = m[1]*n[3] + m[2]*n[6] + m[3]*n[9]

  r[4] = m[4]*n[1] + m[5]*n[4] + m[6]*n[7]
  r[5] = m[4]*n[2] + m[5]*n[5] + m[6]*n[8]
  r[6] = m[4]*n[3] + m[5]*n[6] + m[6]*n[9]

  r[7] = m[7]*n[1] + m[8]*n[4] + m[9]*n[7]
  r[8] = m[7]*n[2] + m[8]*n[5] + m[9]*n[8]
  r[9] = m[7]*n[3] + m[8]*n[6] + m[9]*n[9]
  return r
end


function box(w, h)
 return {0, 0,      1,
         w, 0,      1,
         w, h or w, 1,
         0, h or w, 1}
end

-- polyfill from user scgrn on
--  lexaloffle forums
--  https://www.lexaloffle.com/bbs/?tid=28312
-- draws a filled convex polygon
-- v is an array of vertices
-- {x1, y1, x2, y2} etc
function render_poly(v,col)
 col=col or 5

 -- initialize scan extents
 -- with ludicrous values
 local x1,x2={},{}
 for y=0,127 do
  x1[y],x2[y]=128,-1
 end
 local y1,y2=128,-1

 -- scan convert each pair
 -- of vertices
 for i=1, #v/3 do
  local next=i+1
  if (next>#v/3) next=1

  -- alias verts from array
  local vx1=flr(v[i*3-2])
  local vy1=flr(v[i*3-1])
  local vx2=flr(v[next*3-2])
  local vy2=flr(v[next*3-1])

  if vy1>vy2 then
   -- swap verts
   local tempx,tempy=vx1,vy1
   vx1,vy1=vx2,vy2
   vx2,vy2=tempx,tempy
  end

  -- skip horizontal edges and
  -- offscreen polys
  if vy1~=vy2 and vy1<128 and
   vy2>=0 then

   -- clip edge to screen bounds
   if vy1<0 then
    vx1=(0-vy1)*(vx2-vx1)/(vy2-vy1)+vx1
    vy1=0
   end
   if vy2>127 then
    vx2=(127-vy1)*(vx2-vx1)/(vy2-vy1)+vx1
    vy2=127
   end

   -- iterate horizontal scans
   for y=vy1,vy2 do
    if (y<y1) y1=y
    if (y>y2) y2=y

    -- calculate the x coord for
    -- this y coord using math!
    x=(y-vy1)*(vx2-vx1)/(vy2-vy1)+vx1

    if (x<x1[y]) x1[y]=x
    if (x>x2[y]) x2[y]=x
   end
  end
 end

 -- render scans
 for y=y1,y2 do
  local sx1=flr(max(0,x1[y]))
  local sx2=flr(min(127,x2[y]))

  local c=col*16+col
  local ofs1=flr((sx1+1)/2)
  local ofs2=flr((sx2+1)/2)
  memset(0x6000+(y*64)+ofs1,c,ofs2-ofs1)
  pset(sx1,y,c)
  pset(sx2,y,c)
 end
end
