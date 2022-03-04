pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- winnie the pooh: sweet bouncin'
-- by shane celis for my five-year-old daughter ryland von hunter

extra_pages = {200, 201}
pages = { 
  [0] =
[[
winnie the pooh: 
sweet bouncin'

by shane celis (c) 2022/03/04

for $o07$r2ryland von hunter$rx$oxx's
6th birthday

hit ➡️ to go to next page.
]],
{
[[
pooh awoke and thought, what
should i do?
]],
[[
think, think, think. i know. i'll
ask$d08$ o14you$oxx,$dxx the reader.
]],
choices = {
  "visit eeyore", 3,
  "visit piglet", 2,
}
},
-- p2
{[[
"hi piglet, i just came by
because, well, i don't know why.
do you remember why, dear
reader?"
]],
choices = {
  "i need honey", 200,
  "listen to my poem", 201,
  "go home", 1,
},
},
[200] = {[[
"say piglet, you wouldn't happen
to have any honey, would you?"

"oh, d-d-dear me, no, pooh,"
piglet said.
]],
},
[201] = {[[
"a rum tum tiddle tiddle,
i seem to be in a bit of a
pickle but its rather safe to
say, it feels like a rather
pickely day"]],
[[
"oh, pooh bear, that is a very
nice poem."
]]},

-- p3
[[
"eeyore, have you got any honey
in there?"

"well, thank you for asking how
i've been. that means a lot.
i've been well," eeyore said.

"so no honey then?"

"no."
]],

-- p4
[[
"rabbit will surely have some
honey for his dear friend pooh."
]],

-- p5
[[
"rabbit, say, have you had 
any breakfast yet?"

"it's past noon, pooh."

"so it is. perhaps it's time
for lunch then? hmm?"

"not until these carrots are in
that wheelbarrow, no."
]],

-- p6
[[
"hey, pooh, want to play kings
and queens? or knights and
woozles?" roo asked.

"i would love to but my tummy
won't let me until it's had a
small smackerel of something."
]],

-- p7
[[
perhaps, i'll have to get some
honey the hard way, pooh 
thought to himself.
]],

-- p8
[[
"i seem to have stumbled upon
the very thing i was looking
for: honeeeey.

"but how to get it."
]],

-- p9
[[
"think, think, think."
]],

-- p10
[[
"hey there, pooh, buddy boy,
whatcha up to?" tigger asked.

"oh, just thinking very 
thinkingly about how to get that
honey," pooh answered.

"why you should bounce up there
of course!" tigger said.
]],

-- p11
[[
before pooh had a chance to 
explain that his bounces were
probably not going to dislodge
that hive, tigger had already
bounced that hive right out of
the tree.
]],

-- p12
[[
pooh tried to thank tigger 
between mouth fulls of honey.

"aw, don't sweat it, pooh boy.
if there's a job that needs a
lil' bouncin' this here's the
tigger to do it. t-t-f-n, ta
ta for now." and tigger left.
]],


-- p13
[[
pooh rubbed the honey off his
cheeks and said, "well, that
was everything my tumbly needed
and then some. perhaps i'll go
and play nights and wagons."
]],

-- p14
[[
and so pooh did.

the end.
]],


}

-->8
#include text-box.p8
#include plist.p8
#include page.p8
#include message.lua
-- book code

--_current_book = book:new({ page_class = cardinal_page }, pages)
_current_book = book:new({}, pages)
for i in all(extra_pages) do
  local p = _current_book:add_page(i, pages[i])
  if i > 100 then
    local default_page = flr(i/100)
    if (not p.scene or p.scene == i) p.scene = default_page
    if (not p.nextpage) p.nextpage = default_page
  end
end
--records = nil

function page_change(page)
--  if page ==8 then
--    music(00) -- starts music
--  elseif page >8 then
-- -- cep playing for ever
--  elseif page== 3 then 
--  --sfx(3)
--  music(1) 
--  else
--  music(-1)
--  -- stop music after
--  --rpoot all uv it on page(3)
--  -- whatever i want in my
--  -- comments
-- --stert  page--(8) music
--  end 
end
  
-- function sprite_change(number)
--   if number == 220 then
--     --sfx(6)
--     music(2)
--   elseif number == 154 then
--     sfx(9)
--   end
-- end

function _init()
--  scan_sprites()
  l = plist:new(nil, {1, 2, 3, 4})
  -- stop()
end

function _update()
  _current_book.current_page:update()
end


function _draw()
  _current_book.current_page:draw()
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
00000000000009900000000000000000000099000aaaa00000444400000aaaa00044440000005500000000000000000000000000000033333333333333330000
0000000000999990000000e0000000400999990000a5aa500004544505aa5a005445400005552500000000000000000000000000000003333333333333330000
0000000005995900000eee00000444005995900000aaaa000004444000aaaa000444400075752500000000000000000000000000000033333333333333300000
0000000000999900005e5e000054540009999000000aa00000004400000aa0000044000066550000000000000000000000000000000033333333333333330000
0000000000888800000eee0000044400099550000aaaaaa0004444440aaaaaa04444440066555555600000000000000000000000000333333333333333330000
000000000988889000e888e0004ccc409999900000aaaa004004444000aaaa000444400400055555060000000000000000000000000333333333333333300000
0000000000999900000eee00000444000995590900aaaa004444444000aaaa00044444440005555500e000000000000000000000000033333333333333330000
0000000000900900000e0e00000404000900909000a00a000004004000a00a000400400000050005000000000000000000000000000003333333333333300000
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
e01e331f3030303030303030303030e2e01e331f3030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e030e1303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e02e2e2f3030303030303030303030e2e02e2e2f3030303030303030303030e2e03030303030300d0e0f3030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03434303030303030303030303030e2e03434303030303030303030303030e2e03030303030301d1e1f3030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03434303030303030303030303030e2e03434303030303030303030303030e2e03030303030302d2e2f3030303030e2e03030303030003030303030303030e2e03030303030003030300030303030e2e03030303030303030300730303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03420013030303030303030303030e2e03420303030303001303030303030e2e03030303030011220303030303030e2e0303030090a551130303055305530e2e03030303030551930303055015530e2e03030303001525151511754523030e2e03030553030303001575613573058e2e03030303030035630573058300130e2
e03f3f3f3f3f3f3f3f3f3f3f3f3f3fe2e03f3f3f3f3f3f3f3f3f3f3f3f3f3fe2e03f3f3f3f3f3f3f3f3f3f3f3f3f3fe2e03333333333333333333333333333e2e03333333333333333333333333333e2e03333333333343434343433333333e2e03333333333343334343434343333e2e03333343334343434343333333333e2
f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2
d0c0c8d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c9d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1cad1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c2d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c3d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c4d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c5d1d1d1d1d1d1d1d1d1d1d1d2
e03030303030303030303030303434e2e03030303030303030303030303434e2e03030303030303030303030303434e2e03030303030303030303030303434e2e03030303030303030300c30303434e2e03030303030303030303030303434e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e030303030303030300c30494a3434e2e030303030303030303030494a3434e2e03030303030303030300c494a3434e2e030303030303030303030494a3434e2e030303030300c30303030494a3434e2e0300c3030303030303030494a3434e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03030303030303030303041303434e2e030303030303030303030410c3434e2e03030303030303030303041303434e2e03030303030303030300c30303434e2e03030303030303030303030303434e2e03030303030303030303030303434e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03030303030303030303030493434e2e03030303030303030300c30493434e2e03030303030303030303030493434e2e0303030303030303030300c493434e2e03030303030303030303030493434e2e03030303030303030303030493434e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03030300130305930303030303434e2e03030303030305901303030303434e2e03030303030045911303030303434e2e03030303030305911300442303434e2e03030303030305a11301430303434e2e03030303030015b30303030303434e2e03030553030303057035611573058e2e03030303030303030303030303030e2
e03333333333333333333333333333e2e03333333333333333333333333333e2e03333333333333333333333333333e2e03333333333333333333333333333e2e03333333333333333333333333333e2e03333333333333333333333333333e2e03333333333343334343434343333e2e03030303030303030303030303030e2
f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2
__sfx__
000100001b02000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001e05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
