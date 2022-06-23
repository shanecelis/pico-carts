pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- robo.
-- by ryland.
pages = {

title = 
[[
robo

by ryland
]],
-- p1
{
[[where to go?]],
choices = {
 "go to the pond", 2,
 "go to the bridge", 3
 },
}, 
-- p2
[[pond]],
-- p3
[[bridge]],
-- p4
[[]]
}
      

-->8
#include text-box.p8
#include plist.p8
#include page.p8
#include message.lua
#include util.p8
-- book code

function _init()

--_book = book:new({ page_class = cardinal_page }, pages)
_book = book:new({}, pages)
for i, p in pairs(_book.pages) do
  if type(i) == 'number' and i > 100 then
    local default_page = flr(i/100)
    if (not p.scene or p.scene == i) p.scene = default_page
    if (not p.nextpage) p.nextpage = default_page
  end
end
records = nil
--  scan_sprites()
  l = plist:new(nil, {1, 2, 3, 4})
  printh(dump(l))
  printh(dump(l.keys))
  printh("count " ..#l)
  l['a'] = 5
  printh(dump(l))
--  print(pages.title[1])
--  print(_book._page.title)
  --stop()
end

function _update()
  _book._page:update()
end


function _draw()
  _book._page:draw()
  -- if records ~= nil and frame % 20 == 0 then
	-- 	  anim_map(records)
	-- end
end

__gfx__
000000000ccc0000000000000000ccc000000000bbbbbbbb3333333300000000cccccccc00000000000000000000000000000000000000000000000000000000
000000000c5c0000000000000000c5c000000000bbbbbbbb3333333300000000cccccccc00000000000000000000000000000000000000000000000000000000
007007000ccc0000000000000000ccc000000000bbbbbbbb3333333300000000cccccccc00000000000000000000000000000000000000000000000000000000
0007700000500000000000000000050000000000bbbbbbbb3333333300000000cccccccc00000000000000000000000000000000000000000000000000000000
000770000cccc00000000000000cccc000000000bbbbbbbb3333333300000000cccccccc00000000000000000000000000000000000000000000000000000000
007007000ccccc500000000005ccccc000000000bbbbbbbb3333333300000000cccccccc00000000000000000000000000000000000000000000000000000000
000000000cccc00000000000000cccc000000000bbbbbbbb3333333300000000cccccccc00000000000000000000000000000000000000000000000000000000
0000000009000900000000000090009000000000bbbbbbbb3333333300000000cccccccc00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000222000000000022200000000000000000000000000000000000000000000bbbbbbbb00000000cccccccc0000000000000000
0000000000000000000000000000252000000000025200000000000000000000070070000000000000000000bbbbbbbb00000000cccccccc0000000000000000
0000000000000000000000000000222000000000022200000000000000000000007700000000000000000000bbbbbbbb00000000cccccccc0000000000000000
0000000000000000000000000000050000000000005000000000000000000000007700000000000000000000bccccccb00000000ccc9cccc0000000000000000
0000000000000000000000000002222000000000022220000000000000000000070070000000000000000000bccccbcb00000000cccc99cc0000000000000000
0000000000000000000000000522222000000000022222500000000000000000000000000000000000000000bccccccb00000000ccc9cccc0000000000000000
0000000000000000000000000002222000000000022220000000000000000000000000000000000000000000bccccccb00000000cccccccc0000000000000000
0000000000000000000000000090009000000000090009000000000000000000000000000000000000000000bbbbbbbb00000000cccccccc0000000000000000
00000000cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc8888cc0000000000000000000000000050000000000000000000000000000000000000000500000000000000000000000000000000000000000000
00000000cc8888cc0000000000555500000000000050000000000000000000000000000000000000000500000500050000000000000000000000000000000000
00000000cc8888cc0000000000500500055555000050000000000000000000000000000000000000000500000050500000000000000000000000000000000000
00000000cc4444cc0000000000555500050005000055555000000000055555000000000000000000000555500005000000000000000000000000000000000000
00000000cc4aa4cc0000000000500000050005000050005000000000050005000000000000000000000500500005000000000000000000000000000000000000
00000000cc4a54cc0000000000555000050005000050005000000000050005000000000000000000000500500005000000000000000000000000000000000000
00000000bb4aa4bb0000000000505000055555000055555000000000055555000000000000000000000555500005000000000000000000000000000000000000
000000000000000000000000000000000000000000500000000000000000000000000000cccccccc000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000500000000000000000000000000000cccccccc000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000500000000000000000000000050000cccccc9c000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000500000005500000000000000050000ccccc5cc000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000500000005550000555050055550000cc488ccc000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000500000005050000505050050050000cc488ccc000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000500000005555000505550050050000bc4ccccc000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000555500005005500505550055550000bb4bbbbb000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111222222223333333300000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111222222223333333300000000
00777700000770000077770000777700007007000077770000777700007777000077770000777700007777000000000011111111222222223333333300000000
00700700000070000000070000000700007007000070000000700000000007000070070000700700007007000000000011111111222222223333333300000000
00777700000070000077770000777700007777000077770000777700000007000077770000777700007007000000000011111111222222223333333300000000
00700000000070000070000000000700000007000000070000700700000007000070070000000700007007000000000011111111222222223333333300000000
00700000007777000077770000777700000007000077770000777700000007000077770000777700007777000000000011111111222222223333333300000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111222222223333333300000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444444455555555666666667777777700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444444455555555666666667777777700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444444455555555666666667777777700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444444455555555666666667777777700000000
00006666666666666666000000000000000000000000000000000000000000000000000000000000000000004444444455555555666666667777777700000000
00006666666666666666000000000000000000000000000000000000000000000000000000000000000000004444444455555555666666667777777700000000
00006677777777777766000000000000000000000000000000000000000000000000000000000000000000004444444455555555666666667777777700000000
00006677777777777766000000000000000000000000000000000000000000000000000000000000000000004444444455555555666666667777777700000000
00006677000000007766000000000000000000000000000000000000000000000000000000000000000000008888888899999999aaaaaaaabbbbbbbb00000000
00006677000000007766000000000000000000000000000000000000000000000000000000000000000000008888888899999999aaaaaaaabbbbbbbb00000000
00006677000000007766000000000000000000000000000000000000000000000000000000000000000000008888888899999999aaaaaaaabbbbbbbb00000000
00006677000000007766000000000000000000000000000000000000000000000000000000000000000000008888888899999999aaaaaaaabbbbbbbb00000000
00006677000000007766000000000000000000000000000000000000000000000000000000000000000000008888888899999999aaaaaaaabbbbbbbb00000000
00006677000000007766000000000000000000000000000000000000000000000000000000000000000000008888888899999999aaaaaaaabbbbbbbb00000000
00006677000000007766000000000000000000000000000000000000000000000000000000000000000000008888888899999999aaaaaaaabbbbbbbb00000000
00006677000000007766000000000000000000000000000000000000000000000000000000000000000000008888888899999999aaaaaaaabbbbbbbb00000000
0000667777777777776600000000000000000000000000000000000000000000000000000000000000000000ccccccccddddddddeeeeeeeeffffffff00000000
0000667777777777776600000000000000000000000000000000000000000000000000000000000000000000ccccccccddddddddeeeeeeeeffffffff00000000
0000666666666666666600000000000000000000000000000000000000000000000000000000000000000000ccccccccddddddddeeeeeeeeffffffff00000000
0000666666666666666600000000000000000000000000000000000000000000000000000000000000000000ccccccccddddddddeeeeeeeeffffffff00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccddddddddeeeeeeeeffffffff00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccddddddddeeeeeeeeffffffff00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccddddddddeeeeeeeeffffffff00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccddddddddeeeeeeeeffffffff00000000
__map__
d0d1d1d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c2d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c3d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c4d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c5d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c6d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c7d1d1d1d1d1d1d1d1d1d1d1d1d2
e00000232425270000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e000002a2b00232b35363738000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00001000000000000001300000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000100000000000000e2e00505050505080805050505050505e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e0eeeeeeeeeeeeeeeeeeeeeeeeeeeee2e00505050505050505050505050505e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2
d0c0c8d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c9d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1cad1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c2d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c3d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c4d1d1d1d1d1d1d1d1d1d1d1d2d000c1c5d1d1d1d1d1d1d1d1d1d1d1d2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2
d0c0c1c6d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c7d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c8d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c9d1d1d1d1d1d1d1d1d1d1d1d2d0c0c2cad1d1d1d1d1d1d1d1d1d1d1d2d0c0c2c1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c2c2d1d1d1d1d1d1d1d1d1d1d1d2d0c0c2c3d1d1d1d1d1d1d1d1d1d1d1d2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2
d0c0c2c4d1d1d1d1d1d1d1d1d1d1d1d2d0c0c2c5d1d1d1d1d1d1d1d1d1d1d1d2d0c0c2c6d1d1d1d1d1d1d1d1d1d1d1d2d0c0c2c7d1d1d1d1d1d1d1d1d1d1d1d2d0c0c2c8d1d1d1d1d1d1d1d1d1d1d1d2d0c0c2c9d1d1d1d1d1d1d1d1d1d1d1d2d0c0c3cad1d1d1d1d1d1d1d1d1d1d1d2d0c0c3c1d1d1d1d1d1d1d1d1d1d1d1d2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2
__sfx__
00010000371203815038150381503815038150081500a1500c14013140171301c1103e110231502a1502f1103211036130391503e1603a270291702b1403b1503c170371703b1703d170391703d1703f1702e170
001000001e05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000011020110202d0202a020280201f020240202802028020280202602019010190101d0501d0501c0501b0001800015000120000f0000c0000b0000a000080000800007000090000f020180001800000040
00040000136301363015660136701867018660196501b650186501665017650196500055000570006700067000660006300067000630006400061000640006500066000630006600067000670006700067000670
0004000028140231401c6001b6401864017650196501b600186001660026140231401b600196501665013600156000060024150201501a6001765015650166001660000600006000060000600006000060000600
00040000136301363015630136301863018630196301b630186301663017630196300060000600007000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000400002675022750217001770000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000400000d7500a7500a7500a75009750097000570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000000000000000f00000000180501f00000000000000e0001205000000000000000000000170500e00000000000000000012050000000d0000000000000160500e000000000000000000120500000000000
000300001a1500f15025100221001d1001b1001610013100111000f1000d100081000b10009100081000710006100061000510005100041000410003100031000710006100081000610008100101000710007100
000300000d77011750107500d7101e700237002570025700267002670000700017002670026700267002670027700287003b700237002e7002e700297002a700347001a700197000070017700007001570000700
__music__
03 02424344
03 03424344
00 06054344

