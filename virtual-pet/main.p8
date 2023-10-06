pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- virtual pet

#include message.p8
#include particles.p8
#include timer.p8
#include scene.p8
#include skeleton.p8

idea = text_scene:new({}, {
  "<ac>paw village game",
  "<ac>by ryland and shane",
})
idea.y = 64

our_credits = credits:new({
  text = [[
artwork by ryland

music by ryland

code by ryland
    and shane
]]
})

idea.next_scene = our_credits


text_demo_scene = text_scene:new(nil, {
 '<r9><o1><c9>welcome<c-> to the text demo!',
 '<o1>you can draw sprites\n<i1>   like this, and you can\n\nadd a delay<d10>...<d->like this!',
 'looking for <d8><f1>spooky<f-><d-> effects?<d30>\n<d->hmm, how about some\n<o-><of><c1><ba>highlighting<b->',
 '<o-><u1>underlining?<u-><d30><o1> <d-> geeze, you\'re\na <f2>hard one to please!',
})
text_demo_scene.message.color.foreground = 15
text_demo_scene.message.color.outline = 1

--curr_scene = text_demo_scene
curr_scene = idea
-- curr_scene = credits
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008808800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700088888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000088888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000008888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0002000036050320401d0201d0001d0001d0001d0001d0002500028000000003c0003c00000000000003400000000000002d0002c0002b0002a00000000000000000000000000000000000000000000000000000
000100002f1502c1502a1500f110091000510001100291002b1002d10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
