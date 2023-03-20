pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-- scaling pico sprites
-- by @mykie on twitter
-- https://mishkabear.itch.io/pico-8-rotate
function _init()
 ang=0
 scale=1
 scale_adjust=0.1

 -- this indexes a single sprite which
 --  is a 2d array of color ids
 cls()
 spr(1,0,0)
 sprite={}
 for x=1,8 do
  sprite[x]={}
  for y=1,8 do
   sprite[x][y]=pget(x-1,y-1)
  end
 end
 cls()
end

function _draw()
 cls()
 print((stat(1)*100).."% cpu",0,0,9)
 print((stat(0)).." mem",0,6,9)
 print((stat(7)).." fps",0,12,9)
 -- scalespr(32,64,scale/2,ang)
 -- scalespr2(96,64,scale,ang)
 -- scalespr2(64,64,scale,ang)
 -- sprr(1,64,64,1,1,false,false,scale,ang,4,4)
 -- sprr(1,64,64,2,2,false,false,scale,ang,8,8)
 -- sprr(1,64,64,2,2,nil,false,nil,45,8,8)
 -- sprr(1,64,64,2,2)
 -- spr(1,64,64,2,2)
 -- render_poly(mulv(mulm(translate(64,64),mulm(_scale(scale),rotate(0/360))), box(16)))
 -- fill_rect(mulv(mulm(translate(64,64),mulm(_scale(scale),rotate(45/360))), box(16)), 7)
 -- fill_rect(mulv(mulm(translate(64,64),mulm(_scale(1),rotate(45/360))), box(16)), 7)
 -- fill_rect(mulv(mulm(translate(64,64),mulm(_scale(1),rotate(290/360))), box(16)), 7)
 -- render_poly(mulv(mulm(translate(64,64),mulm(_scale(scale),rotate(-ang/360))), box(16)))
 -- sprr(1,64,64,2,2,false,false,scale,ang, 4, 4)
 -- drawpixel(32,32, 10, ang, 7)
 local vs = mulv(translate(32,64),box(16))
 raster({vs[1], vs[2]}, {vs[7], vs[8]}, {vs[4], vs[5]}, 7)
 local vs = mulv(translate(64,64),box(16))
 raster({vs[1], vs[2]}, {vs[7], vs[8]}, {vs[4], vs[5]}, {8,0}, {16,8}, {16,0})
end

-- draws a sprite at posx,posy with
--  the origin in the center
--  s is the scale, a is angle
function scalespr(posx,posy,s,a)
 -- these nine lines set origin
 local ax=posx
 local ay=posy
 local xdist=abs((posx+s/2)-posx)*8
 local ydist=abs((posy+s/2)-posy)*8
 local xsq=xdist*xdist
 local ysq=ydist*ydist
 local rad=sqrt(xsq+ysq)
 local x0=angle(ax,ay,rad,a+225).x
 local y0=angle(ax,ay,rad,a+225).y
 -- set x1 to posx and y1 to posy to
 --  move the origin to the top left
 local x1=x0
 local y1=y0
 -- local vs = box(s)
 -- local m = rotate(-ang/360)
 for y=1,8 do
  for x=1,8 do
   drawpixel(x1,y1,s,ang,sprite[x][y])
   -- render_poly(mulv(mulm(translate(x1, y1), m), vs), sprite[x][y])
   local angles=angle(x1,y1,s,a)
   y1=angle(x1,y1,s,a).y
   x1=angle(x1,y1,s,a).x
  end
  y1=angle(x0,y0,y*s,a+90).y
  x1=angle(x0,y0,y*s,a+90).x
 end
end

function sprr(n,x,y,w,h,flip_x,flip_y,s,a,ax,ay)
 w = w or 1
 h = h or 1
 a = a or 0
 ax = ax or 0
 ay = ay or 0
 local vs = mulv(translate(-1/2, -1/2), box(1))
 local m = mulm(rotate(-a/360),_scale(s or 1))
 local big = mulm(m, translate(-ax, -ay))
 local v1 = {}
 local m1 = {}
 local ws = {}
 local sx = n % 16 * 8 - 1
 local sy = flr(n/16) * 16 - 1
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

function scalespr2(posx,posy,s,a)
 local vs = mulv(translate(-1/2, -1/2), box(1))
 local m = mulm(rotate(-ang/360),_scale(s))
 local big = mulm(m, translate(-4, -4))
 local v1 = {}
 local m1 = {}
 local w = {}
 local n = 1
 for y=1,8 do
  for x=1,8 do
    local c = sget(n % 16 * 8 + x - 1, flr(n/16) * 16 + y - 1)
    mulv(big, {x, y, 1}, v1)
    mulm(translate(posx + v1[1], posy + v1[2]), m, m1)
    -- render_poly(mulv(m1, vs, w), sprite[x][y])
    render_poly(mulv(m1, vs, w), c)
    -- render_poly(mulv(m1, vb, w), (x + y - 1) % 16)
  end
 end
end

function _scale(x, y)
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
-- draws a single pixel at pos x,y
--  with the origin at the top left
--  w is the width/height of pixel
--  a is the angle
--  c is the color
function drawpixel(x,y,w,a,c)
 -- local x1=x
 -- local y1=y
 -- local x2=angle(x1,y1,w,a).x
 -- local y2=angle(x1,y1,w,a).y
 -- local x3=angle(x2,y2,w,a+90).x
 -- local y3=angle(x2,y2,w,a+90).y
 -- local x4=angle(x1,y1,w,a+90).x
 -- local y4=angle(x1,y1,w,a+90).y
 local v={0, 0, 1,
          w, 0, 1,
          w, w, 1,
          0, w, 1}
 v = mulv(mulm(translate(x,y), rotate(-a/360)), v)
 -- render_poly(strip_third(v),c)
 render_poly(v,c)
end

function strip_third(v)
  r = {}
  for i = 1,#v,3 do
    add(r, v[i])
    add(r, v[i + 1])
  end
  return r
end

--returns an x and y position based
-- on a vector, r=radius, 
-- a=angle in degrees
function angle(x,y,r,a)
 local x2=x+r*cos(a/360)
 local y2=y+r*sin(a/360)*-1
 return {x=x2,y=y2}
end

function _update()
 ang+=3
 scale+=scale_adjust
 if scale>=10 then
  scale_adjust=-0.1
 elseif scale<=1 then
  scale_adjust=0.1
 end
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

fill_rect = function(v, col)
  a={x=v[1], y=v[2]}
  b={x=v[4], y=v[5]}
  c={x=v[7], y=v[8]}
  fill_tri(a, b, c, col)
  -- fill_tri({x=v[1], y=v[2]}, {x=v[4], y=v[5]}, {x=v[7], y=v[8]}, col)
  -- fill_tri(v[2], v[3], v[4], col)
end

-- https://www.lexaloffle.com/bbs/?tid=2171
fill_tri = function(a,b,c,col)
    if (b.y-a.y > 0) dx1=(b.x-a.x)/(b.y-a.y) else dx1=0;
    if (c.y-a.y > 0) dx2=(c.x-a.x)/(c.y-a.y) else dx2=0;
    if (c.y-b.y > 0) dx3=(c.x-b.x)/(c.y-b.y) else dx3=0;
    local e = {x=a.x, y=a.y};
    local s = {x=a.x, y=a.y}
    if (dx1 > dx2) then
        while(s.y<=b.y) do
            s.y+=1;
            e.y+=1;
            s.x+=dx2;
            e.x+=dx1;
            line(s.x,s.y,e.x,s.y);
            --good
        end
        e.x = b.x
        e.y = b.y
        while(s.y<=c.y) do
            s.y+=1;
            e.y+=1;
            s.x+=dx2;
            e.x+=dx3;
            line(s.x,s.y,e.x,s.y);
            -- good
        end
    else
        while(s.y<b.y)do
            s.y+=1;e.y+=1;s.x+=dx1;e.x+=dx2;
            line(s.x,s.y,e.x,e.y);
            assert(false)
        end
        s.x=b.x
        s.y=b.y
        while(s.y<=c.y)do
            s.y+=1;e.y+=1;s.x+=dx3;e.x+=dx2;
            line(s.x,s.y,e.x,e.y);
            -- bad
            -- assert(false)
        end
    end
end

-- https://www.scratchapixel.com/lessons/3d-basic-rendering/rasterization-practical-implementation/rasterization-stage.html
function edge(a, b, c)
 return (c[1] - a[1]) * (b[2] - a[2]) - (c[2] - a[2]) * (b[1] - a[1])
end

function raster(v0,v1,v2,c0,c1,c2)
  local lx = min(v0[1], min(v1[1], v2[1]))
  local ux = max(v0[1], max(v1[1], v2[1]))
  local ly = min(v0[2], min(v1[2], v2[2]))
  local uy = max(v0[2], max(v1[2], v2[2]))
  local area = edge(v0,v1,v2)
  local c = c0

  for j=ly,uy do
    for i=lx,ux do
      p = {i + 0.5, j + 0.5};
      w0 = edge(v1, v2, p);
      w1 = edge(v2, v0, p);
      w2 = edge(v0, v1, p);
      if w0 >= 0 and w1 >= 0 and w2 >= 0 then
        w0 /= area;
        w1 /= area;
        w2 /= area;
        if c1 and c2 then
          local ci = w0 * c0[1] + w1 * c1[1] + w2 * c2[1];
          local cj = w0 * c0[2] + w1 * c1[2] + w2 * c2[2];
          c = sget(flr(ci), flr(cj))
        end
        pset(i, j, c)
      end
    end
  end
end

function render_poly_tex(v,s)
 -- col=col or 5

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

__gfx__
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000822882280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700822222280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000828228280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000822222280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700882222880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000882882880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
99900000999099909990999090900000099099909090000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90900000009000909090009000900000900090909090000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90900000009000909990999009000000900099909090000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90900000009000909090900090000000900090009090000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99900900009000909990999090900000099090000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99909990000099909990999099900000999099909990000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00909090000090909090900000900000999090009990000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09909090000090909990999000900000909099009090000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00909090000090900090009000900000909090009090000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99909990090099900090999000900000909099909090000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99909990000099909990099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00909090000090009090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09909090000099009990999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00909090000090009000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99909990000090009000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000088880000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000088888880000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000008888888880000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000088888888888888000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000088888888888888888000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000888888888888888888888000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000008888888888888888888888888000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000008888888888888888888888888888800000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000888888888888888888888888888888800000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000088888888888888888888888888888888800000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000888888888888888888888888822228888888800000000000000000000000000000000000000000
00000000000000000000000000000000000000000000008888888888888888888888888222222228888888880000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888888888888888888888888222222222228888888880000000000000000000000000000000000000000
00000000000000000000000000000000000000000888888888888888888888888822222222222222888888880000000000000000000000000000000000000000
00000000000000000000000000000000000000088888888888888888888888882222222222222222888888888000000000000000000000000000000000000000
00000000000000000000000000000000000888888888888888888888888888882222222222222222888888888000000000000000000000000000000000000000
00000000000000000000000000000000888888888888888888888888888888882222222222222222288888888000000000000000000000000000000000000000
00000000000000000000000000008888888888888888888888888888888888882222222222222222288888888800000000000000000000000000000000000000
00000000000000000000000088888888888888888888888888888888888888888222222222222222288888888800000000000000000000000000000000000000
00000000000000000000000088888888888888888888888888888888888888888222222222222222288888888880000000000000000000000000000000000000
00000000000000000000000088888888888888888888822228888888888888888222222222222222228888888880000000000000000000000000000000000000
00000000000000000000000008888888888888888222222228888888888888888822222222222222228888888888000000000000000000000000000000000000
00000000000000000000000008888888888882222222222228888888888888822222222222222222228888888888000000000000000000000000000000000000
00000000000000000000000008888888882222222222222222888888888882222222222222222222228888888888000000000000000000000000000000000000
00000000000000000000000000888888882222222222222222888888888222222222222222222222222888888888000000000000000000000000000000000000
00000000000000000000000000888888882222222222222222888882222222222222222222222222222888888888800000000000000000000000000000000000
00000000000000000000000000088888882222222222222222222222222222222222222222222222222888888888800000000000000000000000000000000000
00000000000000000000000000088888888222222222222222222222222222222222222228882222222288888888800000000000000000000000000000000000
00000000000000000000000000088888888222222222222222222222222222222222222888882222222288888888800000000000000000000000000000000000
00000000000000000000000000088888888222222222222222222222222222222222288888882222222228888888880000000000000000000000000000000000
00000000000000000000000000008888888222222222222222222222222222222222288888888222222228888888880000000000000000000000000000000000
00000000000000000000000000008888888822222222222222222222222222222222288888888222222222888888880000000000000000000000000000000000
00000000000000000000000000008888888822222222222222222222222222222222288888888222222222888888888000000000000000000000000000000000
00000000000000000000000000000888888822222222222222222222222222222222228888888222222222888888888000000000000000000000000000000000
00000000000000000000000000000888888882222222222222288822222222222222228888888822222222888888888800000000000000000000000000000000
00000000000000000000000000000888888882222222222288888822222222222222228888222222222222288888888800000000000000000000000000000000
00000000000000000000000000000888888888222222228888888822222222222222222222222222222222288888888880000000000000000000000000000000
00000000000000000000000000000088888888222222228888888882222222222222222222222222222222288888888880000000000000000000000000000000
00000000000000000000000000000088888888822222228888888882222222222222222222222222222222288888888880000000000000000000000000000000
00000000000000000000000000000088888888822222222888888882222222222222222222222222222222228888888880000000000000000000000000000000
00000000000000000000000000000088888888822222222888888882222222222222222222222222222288888888888888000000000000000000000000000000
00000000000000000000000000000008888888822222222288888888222222222222222222222222288888888888888888000000000000000000000000000000
00000000000000000000000000000008888888882222222288882222222222222222222222222222288888888888888888000000000000000000000000000000
00000000000000000000000000000008888888882222222222222222222222222222222222222222288888888888888888000000000000000000000000000000
00000000000000000000000000000000888888882222222222222222222222222222222222222222288888888888888888800000000000000000000000000000
00000000000000000000000000000000888888882222222222222222222222222222222222222222228888888888888888800000000000000000000000000000
00000000000000000000000000000000088888888222222222222222222222222222222222222222228888888888888888800000000000000000000000000000
00000000000000000000000000000000088888888222222222222222222222222222222222222222228888888888888888800000000000000000000000000000
00000000000000000000000000000000008888888222222222222222222222222222222222222222228888888888888888880000000000000000000000000000
00000000000000000000000000000000008888888822222222222222222222222222222222222222222888888888888888880000000000000000000000000000
00000000000000000000000000000000008888888822222222222222222222222222222222222222222888888888888888880000000000000000000000000000
00000000000000000000000000000000008888888882222222222222222222222222222222222222222888888888888888888000000000000000000000000000
00000000000000000000000000000000000888888882222888822222222222222222222288882222222288888888888888888000000000000000000000000000
00000000000000000000000000000000000888888888888888822222222222222222888888882222222288888888888888888000000000000000000000000000
00000000000000000000000000000000000888888888888888822222222222222888888888882222222228888888888888888800000000000000000000000000
00000000000000000000000000000000000888888888888888882222222222288888888888888222222228888888888888888800000000000000000000000000
00000000000000000000000000000000000088888888888888882222222228888888888888888222222222888888888888888800000000000000000000000000
00000000000000000000000000000000000088888888888888882222222228888888888888888222228888888888888888888880000000000000000000000000
00000000000000000000000000000000000088888888888888888222222228888888888888888888888888888888888888888880000000000000000000000000
00000000000000000000000000000000000008888888888888888222222228888888888888888888888888888888888888888888000000000000000000000000
00000000000000000000000000000000000008888888888888888222222222888888888888888888888888888888888888880000000000000000000000000000
00000000000000000000000000000000000000888888888888888822222222888888888888888888888888888888888800000000000000000000000000000000
00000000000000000000000000000000000000888888888888888822222222888888888888888888888888888888000000000000000000000000000000000000
00000000000000000000000000000000000000088888888888888822222222288888888888888888888888888000000000000000000000000000000000000000
00000000000000000000000000000000000000088888888888888882222288888888888888888888888888000000000000000000000000000000000000000000
00000000000000000000000000000000000000088888888888888882228888888888888888888888888800000000000000000000000000000000000000000000
00000000000000000000000000000000000000088888888888888888888888888888888888888888880000000000000000000000000000000000000000000000
00000000000000000000000000000000000000008888888888888888888888888888888888888800000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000008888888888888888888888888888888888000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000008888888888888888888888888888888000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000888888888888888888888888888800000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000888888888888888888888888880000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000888888888888888888888800000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000888888888888888888000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000088888888888880000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000088888888880000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000088888880000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

