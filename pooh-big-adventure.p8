pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- winnie the pooh: sweet bouncin'
-- by shane celis for my five-year-old daughter ryland von hunter

remember = {
  has_haycorn = false,

}
pages = {
  title =
[[
pooh's big adventure

by ryland von hunter (c) 2022

hit ➡️ to go to next page.
]],

---- px
--{[[ page description ]],
--choices = {
--"choice 1", 2,
--"choice 2", 3
--  }
--},

-- p1
{[[ ]],
choices = {
"go to rabbits", 2,
"go to piglets", 3
  }
},

-- p2
{[[helo says rabbit good
to see you i was just doing
some gardening]],
choices = {
"go to rabbits", 2,
"go to piglets", 3
  }
},


-- p3
{[[  ]],
choices = {
"stay here ",3 ,
"i want honney ", 4
  }
},


-- p4
{[[here you receveed
a haycornpie ]],
run_after = function() 
  remember.has_haycorn = true
  end
},

-- p5
{[[  ]],
choices = {
"go to tiggers ",8 ,
"go to kangas and roos ", 6
  }
},

-- p6
{[[  ]],
choices = {
[[give kanga 
the pie]], 7,
"go to begining", "title"
  }
},

-- p7
{[[why thank you pooh
go to tigger he
said he was going
to get you a present  ]],

},

-- p8
{[[just in time i
just finshed your  
present you receved
a honneypot   ]],
nextpage = 15
},

-- p15
[15] = {[[
the end

by ryland 
and shane "dada" celis
]],
choices = {
"restart", "title",
  }
},
--end
}
-->8
#include text-box.p8
#include plist.p8
#include page.p8
#include message.lua
#include util.p8
-- book code

--_book = book:new({ page_class = cardinal_page }, pages)
_book = book:new({}, pages)
for i, p in pairs(_book.pages) do
  if type(i) == "number" and i > 100 then
    local default_page = flr(i/100)
    if (not p.scene or p.scene == i) p.scene = default_page
    if (not p.nextpage) p.nextpage = default_page
  end
end
records = nil



function _init()
--  scan_sprites()
  l = plist:new(nil, {1, 2, 3, 4})
  printh(dump(l))
  printh(dump(l.keys))
  printh("count " ..#l)
  l['a'] = 5
  printh(dump(l))
  -- stop()
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
00000000099000000000000000000000009900000000000000000000000000000000000000000000005500000000000000000000000000000000000000000000
00000000099999000e00000004000000009999900000000000000000000000000000000000000000005255500000000000000000000000000000000000000000
007007000095995000eee00000444000000959950000000000000000000000000000000000000000005257570000000000000000000000000000000000000000
000770000099990000e5e50000454500000999900000000000000000000000000000000000000000000055660000000000070700000000000000000000000000
000770000088880000eee00000444000000559900aa0aa000000000000aa0aa00000000000000006555555660000000000009000000000330303300000000000
00700700098888900e888e0004ccc400000999990a20a20000000000002a02a00000000000000060555550000000000000000000000033333333330333000000
000000000099990000eee00000444000909559900a20a20000440440002a02a00440440000000e00555550000000000000000000000333333333333333300000
000000000090090000e0e00000404000090900900a20a20000420420002a02a00240240000000000500050000000000000000000000333333333333333330000
00000000000009900000000000000000000099000aaaa00000444400000aaaa0004444000000550000000000cccccccc00000000000033333333333333330000
0000000000999990000000e0000000400999990000a5aa500004544505aa5a00544540000555250000000000cccccccc00000000000003333333333333330000
0000000005995900000eee00000444005995900000aaaa000004444000aaaa00044440007575250000000000cccccccc00000000000033333333333333300000
0000000000999900005e5e000054540009999000000aa00000004400000aa000004400006655000000000000cccccccc00000000000033333333333333330000
0000000000888800000eee0000044400099550000aaaaaa0004444440aaaaaa0444444006655555560000000444ccccc00000000000333333333333333330000
000000000988889000e888e0004ccc409999900000aaaa004004444000aaaa00044440040005555506000000555ccccc00000000000333333333333333300000
0000000000999900000eee00000444000995590900aaaa004444444000aaaa00044444440005555500e00000cccccccc00000000000033333333333333330000
0000000000900900000e0e00000404000900909000a00a000004004000a00a00040040000005000500000000cccccccc00000000000003333333333333300000
44499944000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333333300000
44999994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333333000000
44999994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333333330000000
44999994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004333443400000000
44999094000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444444400000000
44999994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444444400000000
44999994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444444400000000
44999994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444444400000000
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000a99a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009aa9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0099900000099000000099a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
044444000000000000099a9900000000000000000000000000000000000000000000000000000400004400000000000000000000000000000000000000000000
004440000000000000099a9900000000000000000000000000000000000000000000000004000040000404040000000000000000000000000000000000000000
0044400000000000000099a000000000000000000000000000000000000000000000000000444444444444440000000000000000000000000000000000000000
000000000000000000000000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000bbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000bbb0000000004400000000000000000000000000000800000000000099a0000000000000000000000000000000000000000000
00000000000000000000000000999000040004400000000000000000000000000005555000000000099a99000000000000000000000000000000000000000000
00000000000000000000000000999000044444000033300000000000000000000005555000000000099a99000000000000000000000000000000000000000000
007cccc00b0b000b00000000009990000444455003333300004040400040000000000400000000000099a0000099a00000000000000000000000000000000000
0044444009090b090000990b00090000044455550333330000444440044400000000040000444000004440000944490000000000000000000000000000000000
0040004044444444009999bb0009000004000550003330000044f440044400000000040004444400044444000444449000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555500000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555500000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000055550000000000000000000000000000500000000000000000000000000000000000000000000000000000
00000000005550000000000000555550000500000050000000000000000000000000000000500000000500000055500000000000000000000000000000000000
00000000005050000055550000500050000500000050000000000000000000000000000000500000000000000050500000000000000000000000000000000000
00000000005550000050050000500050000500000055550000000000000000000000000000555500000500000055500000000000000000000000000000000000
00000000005000000050050000500050000555500000050000000000000000000000000000500500000500000000500000000000000000000000000000000000
00000000005000000050050000500050000500500055550000000000000000000000000000500500000500000000500000000000000000000000000000000000
00000000005000000055550000555550000500500000000000000000000000000000000000555500000500000055500000000000000000000000000000000000
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
00000000000000000000000000000000000000000009990000000000000000000000000000999000000000000000000000000000000000000000000000000000
00000000000000000000000000999900000000000009000000000000000900000000000000909000099990000000000000000000000000000000000000000000
00000000000000000000000000900900000900900009000000999090009990000009090000999000090000000000000000000000000000000000000000000000
00000000000000000000000000900900000900900009000000909090000900000009090000900000099990000000000000000000000000000000000000000000
00000000000000000000000000999900000900900009990000909090000900000009090000900000090000000000000000000000000000000000000000000000
00000000000000000000000000900900000900900009000000909090000900000009090000999000090000000000000000000000000000000000000000000000
00000000000000000000000000900900000999900009990000909990000900000009990000909000099999009000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700000770000077770000777700007007000077770000777700007777000077770000777700007777000000000000000000000000000000000000000000
00700700000070000000070000000700007007000070000000700000000007000070070000700700007007000000000000000000000000000000000000000000
00777700000070000077770000777700007777000077770000777700000007000077770000777700007007000000000000000000000000000000000000000000
00700000000070000070000000000700000007000000070000700700000007000070070000000700007007000000000000000000000000000000000000000000
00700000007777000077770000777700000007000077770000777700000007000077770000777700007777000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006677777777777766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006677777777777766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006677000000007766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006677000000007766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006677000000007766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006677000000007766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006677000000007766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006677000000007766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006677000000007766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006677000000007766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006677777777777766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006677777777777766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
d0d1d1d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c2d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c3d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c4d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c5d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c6d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c7d1d1d1d1d1d1d1d1d1d1d1d1d2
e00d0e0f7172737475000000000000e2e01e331f0000000000000000000000e2e00d0e0f0000000000000000000000e2e00d0e0f0000000000000000000000e2e00d0e0f3c3c3c3c3c3c3c3c3c3c3ce2e00000000000000000000000000000e2e00d0e0f0000000000000000000000e2e00d0e0f0000000000000000000000e2
e01d1e1f0000000000000000000000e2e02e2e2f0000000000000000000000e2e01d1e1f0000000000000000000000e2e01d1e1f0000000000000000000000e2e01d1e1f3c3c3c3c3c3c3c3c3c3c3ce2e00000000000000000000000000000e2e01d1e1f0000000000000000000000e2e01d1e1f0000000000000000000000e2
e02d2e2f797a7b0000000000000000e2e03434000000000000000000000000e2e02d2e2f0000000000000000000000e2e02d2e2f0000000000000000000000e2e02d2e2f3c3c3c3c3c3c3c3c3c3c3ce2e00000000000000000000000000000e2e02d2e2f0000000000000000000000e2e02d2e2f0000000000000000000000e2
e0003400b3b4b5b6b8b9babb000000e2e03434000000000000000000000000e2e00034000000000000000000000007e2e00034000000000000000000000000e2e03c343c3c3c3c3c3c3c3c3c3c3c3ce2e00000000000000000000000000000e2e00034000006000000000000000000e2e00034000600000000000000000000e2
e00020010000000000000000000000e2e03420000000000001000000000000e2e000206c0000015151515151515417e2e00020000200001100000000000000e2e03c203c021b113c3c3c3c3c3c3c3ce2e00000000000000200110000000000e2e000206c0016000300000000000000e2e00020001600030011000000000000e2
e03b3b3b3b3b3b3b3b3b3b3b3b3b3be2e03b3b3b3b3b3b3b3b3b3b3b3b3b3be2e03b3b3b3b3b3b3b3b3b3b3b3b3b3be2e03b3b3b3b3b3b3b3b3b3b3b3b3b3be2e03b3b3b3b3b3b3b3b3b3b3b3b3b3be2e03b3b3b3b3b3b3b3b3b3b3b3b3b3be2e03b3b3b3b3b3b3b3b3b3b3b3b3b3be2e03b3b3b3b3b3b3b3b3b3b3b3b3b3be2
f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2
d0c0c8d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c9d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1cad1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c2d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c3d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c4d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c5d1d1d1d1d1d1d1d1d1d1d1d2
e0000d0e0f00000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00002000000000000000000000000e2
e0001d1e1f00000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2
e0002d2e2f00000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00001000071727374000000000700e2
e00000200000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000001700e2
e00000340004000040110000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000030000000000000000000800e2
e03b3b3b3b3b3b3b3b3b3b3b3b3b3be2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000000000e2e00000000000000000000000001800e2
f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2
__sfx__
000100001b02000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001e05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
