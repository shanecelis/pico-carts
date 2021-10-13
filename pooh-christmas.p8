pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- winnie the pooh: sweet bouncin'
-- by shane celis for my five-year-old daughter ryland von hunter

pages = { 

[[
pooh's christmas 

by ryland von hunter
(c) 2021/10/12

hit ➡️ or ❎ to go to next
page.
]],

-- p1
[[
at last it was chistmas
pooh got up pooh
god awt sid 
]],

-- p2
[[
do you wont to play
sno hefulups   
]],

-- p3
[[

]],

-- p4
[[

]],

-- p5
[[

]],

-- p6
[[


]],

-- p7
[[

]],

-- p8
[[

]],

-- p9
[[

]],

-- p10
[[

]],

-- p11
[[

]],

-- p12
[[

]],

-- p13
[[

]],

-- p14
[[

]],

-- p15
[[

]],

-- p16
[[

]],

-- p17
[[

]],

-- p18
[[

]],

-- p19
[[

]],

-- p20
[[

]],

-- p21
[[

]],
}

-->8
-- text box code

function tb_init(voice,string) -- this function starts and defines a text box.
	reading=true -- sets reading to true when a text box has been called.
	tb={ -- table containing all properties of a text box. i like to work with tables, but you could use global variables if you preffer.
	str=string, -- the strings. remember: this is the table of strings you passed to this function when you called on _update()
	voice=voice, -- the voice. again, this was passed to this function when you called it on _update()
	i=1, -- index used to tell what string from tb.str to read.
	cur=0, -- buffer used to progressively show characters on the text box.
	char=0, -- current character to be drawn on the text box.
	x=0, -- x coordinate
	y=64, -- y coordginate
	w=127, -- text box width
	h=60, -- text box height
	col1=0, -- background color
	col2=-1, -- border color (< 0 for no border)
	col3=7, -- text color
	}
end

function tb_next_btnp()
  return btnp(5) or btnp(1) or btnp(0) or btnp(4)
end

function te_is_complete()
  if (te == nil) return true
  return #te.str == te.i and te.char == #te.str[te.i]
end

function tb_update()  -- this function handles the text box on every frame update.
	if tb.char<#tb.str[tb.i] then -- if the message has not been processed until it's last character:
		tb.cur+=0.5 -- increase the buffer. 0.5 is already max speed for this setup. if you want messages to show slower, set this to a lower number. this should not be lower than 0.1 and also should not be higher than 0.9
		if tb.cur>0.9 then -- if the buffer is larger than 0.9:
			tb.char+=1 -- set next character to be drawn.
			tb.cur=0	-- reset the buffer.
			if (ord(tb.str[tb.i],tb.char)!=32) sfx(tb.voice) -- play the voice sound effect.
		end
		if tb_next_btnp() then 
		  tb.char=#tb.str[tb.i] -- advance to the last character, to speed up the message.
		  return true -- return true if you eat a button press
		end
	elseif tb_next_btnp() then -- if already on the last message character and button ❎/x is pressed:
		if #tb.str>tb.i then -- if the number of strings to disay is larger than the current index (this means that there's another message to display next):
			tb.i+=1 -- increase the index, to display the next message on tb.str
			tb.cur=0 -- reset the buffer.
			tb.char=0 -- reset the character position.
		else -- if there are no more messages to display:
			reading=false -- set reading to false. this makes sure the text box isn't drawn on screen and can be used to resume normal gameplay.
		end
		return false
	end
	return false
end

function tb_draw() -- this function draws the text box.
	if reading then -- only draw the text box if reading is true, that is, if a text box has been called and tb_init() has already happened.
		rectfill(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,tb.col1) -- draw the background.
		if tb.col2 >= 0 then
		rect(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,tb.col2) -- draw the border.
		print(sub(tb.str[tb.i],1,tb.char),tb.x+2,tb.y+2,tb.col3) -- draw the text.
  else
		print(sub(tb.str[tb.i],1,tb.char),tb.x,tb.y,tb.col3) -- draw the text.  
  end
	end
end
-->8
-- book code




last_page = 0
current_page = 1

function _init()
  reading=false
--  tb_init(0, { pages[current_page] })
end
  

function _update()
  if reading then
    if (tb_update()) return
  end
  if last_page != current_page then
    last_page = current_page
    tb_init(0, { pages[current_page] })
    return 
  else
  if reading or te_is_complete() then
    if btnp(➡️) or btnp(❎) then
      current_page += 1
    end
    if btnp(⬅️) or btnp(4) then
      current_page -= 1
    end
    if current_page > #pages 
    or current_page < 1 then
      sfx(1)
    end
    current_page = clamp(current_page, 1, #pages)
  end
  end
  
  
end

function draw_page(page)
  local i = page - 1
		map((i % 8) * 16,flr(i / 8) * 8, 
		0,0, 
		16, 8)
		--print(pages[page], 0, 64)
end

function _draw()
  cls()
  draw_page(current_page)
  tb_draw()
end

function clamp(x, a, b)
  return max(a, min(b,x))
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
00000000000009900000000000000000000099000aaaa00000444400000aaaa00044440000005500000000000008788700000000000033333333333333330000
0000000000999990000000e0000000400999990000a5aa500004544505aa5a005445400005552500000000000007878800000000000003333333333333330000
0000000005995900000eee00000444005995900000aaaa000004444000aaaa000444400075752500000000000007878700000000000033333333333333300000
0000000000999900005e5e000054540009999000000aa00000004400000aa0000044000066550000000000000008787800900500000033333333333333330000
0000000000888800000eee0000044400099550000aaaaaa0004444440aaaaaa04444440066555555600000000007878799889990000333333333333333330000
000000000988889000e888e0004ccc409999900000aaaa004004444000aaaa000444400400055555060000000000040009889990000333333333333333300000
0000000000999900000eee00000444000995590900aaaa004444444000aaaa00044444440005555500e000000000040009889590000033333333333333330000
0000000000900900000e0e00000404000900909000a00a000004004000a00a000400400000050005000000000000040099889999000003333333333333300000
44499944ccc999cc00000000000000000000990000000000000000000000cc000000000000000000000000000000000009900000000003333333333333300000
44999994cc99999c00000000000000000999990000000000000000000000c0c00000000000000000000000000000000009999900000003333333333333000000
44999994cc99999c00000000000000005995900000000000000000000000cc000000000000000000000000000000000000959950000000333333333330000000
44999994cc99999c0000000000000000e99990000000000000000000000ccccc0000000000000000000707000000000000999900000000004333443400000000
44999094cc99909c00000000000000000995500000000000000000000000ccc00000000000000000000050000000000000888800000000004444444400000000
44999994cc99999c00000000000000009999900000000000000000000000ccc0007070700000000000000000000000000988889a000000004444444400000000
44999994cc99999c00000000000000000995590900000000000000000000ccc00077777000000000000000000000000000999900000000004444444400000000
44999994cc99999c00000000000000000900909000000000000000000000c0c00077077000000000000000000000000000900900000000004444444400000000
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
0000000000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000
0000000000a99a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000
00000000009aa900000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000
00000000009999000000000000000000000000000000000000000000000000000000000000000000000000000000000000444440000000000000000000000000
0099900000099000000099a000000000000000000000000000004000044400000000000000000000000000000000000000400040000000000000000000000000
044444000000000000099a9900000000000000000000000000040400044400000000000000000400004400000000000000400040000000000000000000000000
004440000000000000099a99000000000000000000000000000eee00004000000000000004000040000404040000000000444440000000000000000000000000
0044400000000000000099a0000000000000000000000000000eee00004000000000000000444444444444440000000000000000000000000000000000000000
000000000000000000000000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000bbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000bbb0000000004400000000000000000000000000000800000000000099a0000000000000000000000000000000000000000000
00000000000000000000000000999000040004400000000000000000000000000005555000000000099a99000000000000000000000000000000000000000000
00000000000000000000000000999000044444000033300000000000000000000005555000000000099a99000000000000000000000000000000000000000000
007cccc00b0b000b00000000009990000444455003333300004040400040000000000400000000000099a0000099a00000000000000000000000000000000000
0044444009090b090000990b00090000044455550333330000444440044400000000040000444000004440000944490000000000000000000000000000000000
0040004044444444009999bb0009000004000550003330000044f440044400000000040004444400044444000444449000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04444400004444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
044fff0000fff4400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04f5ff5005ff5f400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ffff0000ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ffff0000ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f00000000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ccc000000ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ccc000000ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ccc000000ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0fcccf0000fcccf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000000888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000000888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00f0f000000f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00f0f000000f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00404000000404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099888000000000000000000009900000000000000000000009900000000000000000000005500000000000000000000000000000000000000000000
00000000099999000e0000000400000000999990000000000000000000999990000000e000000000005255500444440000444440000000000000000000000000
000000000095995000eee0000044400000095995000000000000000000095995000eee000000000000525757044fff0000fff440000000000000000000000000
000000000099990000e5e500004545000009999000000000000000000009999e005e5e00000000000000556604f5ff5005ff5f40009005000000000000000000
000000000088880000eee00000444000000bbbb00000000000aa0aa0000bbbb0000eee0000000006ccccc56600ffff0000ffff00998899980000000000000000
00000000098888900ebbbe0004888400000bbbb900000000002a02a0000bbbb900ebbbe000000060ccccc00000ffff0000ffff00098899980000000000000000
000000000099990000b2b000004440009095599004404400002a02a090955990000b2b0000000e00ccccc000000f00000000f000098895980000000000000000
000000000090090000e0e000004040000909009002402400002a02a009090090000e0e00000000005000500000ccc000000ccc00998899990000000000000000
000000000088899000000000000000000000000000444400000ccca00000000000000000000055000000000000ccc000000ccc00000000000000000000000000
00000000009999900000000000000000000000005445400005aa5a000000000000000000055525000000000000ccc000000ccc00000000000000000000000000
00000000059959000000000000000000000000000444400000aaaa00000000000000000075752500000000000fcccf0000fcccf0070007000000000000000000
000000000099990000000000000000000000000000440000000ccccc000000000000000066550000000000000088800000088800000000000000000000000000
00000000008888000000000000000000000000004ecce4000aaaaaa00000000000000000665ccccc000000000088800000088800000000000000000000000000
00000000098888900000000000000000000000000ecce00400aaaa000000000000000000000ccccc0000000000f0f000000f0f00007000000000000000000000
00000000009999000000000000000000000000000444444400aaaa000000000000000000000ccccc0000000000f0f000000f0f00000000000000000000000000
00000000009009000000000000000000000000000400400000a00a00000000000000000000050005000000000040400000040400000000070000000000000000
00000000000000000000000000000000000099000000000000000000000000000000000000000000000000000000000009900000000000000000000000000000
00000000000000000444440000444440099999000000000000000000000000000000000000000000000000000000000009999900000000000000000000000000
0000000000000000044fff0000fff440599590000000000000000000000000000000000000000000000000000000000000959950000000000000000000000000
000000000000000004f5ff5005ff5f40e99990000000000000000000000000000000000000000000000707000000000000999900000000000000000000000000
000000000000000000ffff0000ffff000bbbb0000000000000000000000000000aa0aa0000000000000050000000000000888800000000000000000000000000
000000000000000000ffff0000ffff009bbbb0000000000000000000000000000a20a2000000000000000000000000000988889a000000000000000000000000
0000000000000000000f00000000f000099559090000000000000000000000000a20a20000440440000000000000000000999900000000000000000000000000
000000000000000000ddd000000ddd00090090900000000000000000000000000a20a20000420420000000000000000000900900000000000000000000000000
000000000000000000bbb000000bbb00000000000000000000009900000000000accc00000444400000000000000000000000000000000000000000000000000
00000000000000000029e00000029e000000000000000000099999000000000000a5aa5000045445000000000000004000000040000000000000000000000000
00000000000000000f29ef0000f29ef00000000000000000599590000000000000aaaa0000044440000000000004440000044400000000000000000000000000
000000000000aaa000aaa000000aaa0000000000000000000999900000000000ccccc00000004400000000000054540000545400000000000000000000000000
000000000000a5a500aaa000000aaa0000000000000000000bbbb000000000000aaaaaa0004ecce4000000000004440000044400000000000000000000000000
0000000000007c7000f0f000000f0f0000000000000000009bbbb0000000000000aaaa00400ecce0000000000048884000488840000000000000000000000000
000000000000080000f0f000000f0f000000000000000000099559090000000000aaaa0044444440000000000004440000044400000000000000000000000000
000000000000707000404000000404000000000000000000090090900000000000a00a0000040040000000000004040000040400000000000000000000000000
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
e03730303030303030303030303030e2e03730303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e0373030309d3030309d3030303030e2e0373030309d3030309d3030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e037309d3030309d3030309d303030e2e037309d3030309d3030309d303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e034303030303030309d3030309d30e2e034303030303030309d3030309d30e2e03030303030308530303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e02030813030303030303058303030e2e02030813030303030303058303030e2e03030303030309530303083282727e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03737373737373737373737373737e2e03737373737373737373737373737e2e03737373737373737373737373737e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2
d0c0c8d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c9d1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1cad1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c2d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c3d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c4d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c5d1d1d1d1d1d1d1d1d1d1d1d2
e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2
d0c0c1c6d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c7d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c8d1d1d1d1d1d1d1d1d1d1d1d2d0c0c1c9d1d1d1d1d1d1d1d1d1d1d1d2d0c0c2cad1d1d1d1d1d1d1d1d1d1d1d2d0c0c2c1d1d1d1d1d1d1d1d1d1d1d1d2d0c0c2c2d1d1d1d1d1d1d1d1d1d1d1d2d0c0c2c3d1d1d1d1d1d1d1d1d1d1d1d2
e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2e03030303030303030303030303030e2
f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2
__sfx__
000100001b02000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001e05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
