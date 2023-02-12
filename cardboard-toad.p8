pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-- cardboard toad

#include _collision.p8

__gfx__
000000003bbbbbb7033333b0003b30000000000000ccc70000ccc70000ccc70000ccc7000aaaa0000aaaa0000aaaa0000aaaa000000000000000000000000000
000000003000000b33333b3b03333b30101110100cccccc00cccccc00cccccc00cccccc00a1f10000a1f10000a1f10000a1f1000000000000000000000000000
000000003000070b333333b303333330000000000cffffc00cffffc00cffffc00cffffc00affa0000affa0000affa0000affa000000000000000000000000000
000000003000000b33333333033333b3000000000c5ff5c00c5ff5c00c5ff5c00c5ff5c00eeee0000eeee0000eeeef00feeee000000000000000000000000000
000000003000000b3333333304333343000000000cffffc00cffffcc0cffffc0ccffffc0feecef00feecef00feece0000eecef00000000000000000000000000
000000003000000b333333330004444000101101ccccccccccccccc0cccccccc0ccccccc0eece0000eece0000eece0000eece000000000000000000000000000
000000003000000b3333333300040400000000000cccccc00cccccc00cccccc00cccccc00eeee0000eeee0000eeee0000eeee000000000000000000000000000
00000000111111110444444000040000000000000c0000c0c00000c00c0000c00c00000c0eeee0000eeee0000eeee0000eeee000000000000000000000000000
aaaaaaaa00ffff0000ffff000000000000000000077007707700077007700770077000770f00f0000f00f000f000f0000f000f00000000000000000000000000
a000000a00dffd0000dffd0000000000000000000e7007e0e77007e00e7007e00e70077e00000000000000000000000000000000000000000000000000000000
a000000a00ffff0000ffff0000000000000000000e7007e00e7007e00e7007e00e7007e000000000000000000000000000000000000000000000000000000000
a000000a0882288ff882288000000000000000000777777007777770077777700777777000000000000000000000000000000000000000000000000000000000
a000000af08228000082280f00000000000000000717717007177170071771700717717000000000000000000000000000000000000000000000000000000000
a000000a008558000085580000000000000000000077770000777700007777000077770000000000000000000000000000000000000000000000000000000000
a000000a005005000500005000000000000000000077770000777770007777000777770000000000000000000000000000000000000000000000000000000000
aaaaaaaa066006606600006600000000000000000700070000700000007000700000070000000000000000000000000000000000000000000000000000000000
0000000000aaaa000077770000000000000000000878800088878000088780000878880009900990990009900990099009900099000000003333333300000000
000000000a0000a0070000700000000000000000088870008788800007888000088878000e9009e0e99009e00e9009e00e90099e000000003333333300000000
00000000a000770a70007707000aa000000880000cffc0000cffc0000cffc0000cffc0000e9009e00e9009e00e9009e00e9009e0000000003333333300000000
00000000a000770a7000770700aa7a00008888000f0ff0000ff0f0000ff0f0000f0ff00009999990099999900999999009999990000000033333333300000000
00000000a000000a7000000700aaaa000087880000cc000000cc000000cc000000cc000009199190091991900919919009199190000000033333333300000000
00000000a000000a70000007000aa000000880000fccf0000fcc00000fccf00000ccf00000999900009999000099990000999900000000003333333300000000
000000000a0000a007000070000000000000000000cc000000ccf00000cc00000fcc000000999900009999900099990009999900000000003333333300000000
0000000000aaaa000077770000000000000000000f0f000000f0000000f0f000000f000009000900009000000090009000000900000000033333333300000000
00000000008888000088880000000000000000000000000000000000000000000000000008788000888780000887800008788800000000004444444400000000
00000000088888800888888000000000000000000000000000000000000000000000000008887000878880000788800008887800000000004444444400000000
00000000888887788888877800000000000ee000000000000000000000000000000000000cffc0000cffc0000cffc0000cffc000000000004444444400000000
0000000088888778888887780000000000ee7e00000000000000000000000000000000000f0ff0000ff0f0000ff0f0000f0ff000000000004444444400000000
000000008e8888888e8888880000000000eeee000000000000000000000000000000000000cc000000cc000000cc000000cc0000000000004444444400000000
000000008eee88888eee888800000000000ee000000000000000000000000000000000000fccf0000fcc00000fccf00000ccf000000000004444444400000000
0000000008ee888008ee888000000000000000000000000000000000000000000000000000cc000000ccf00000cc00000fcc0000000000004444444400000000
0000000000888800008888000000000000000000000000000000000000000000000000000f0f000000f0000000f0f000000f0000000000004444444400000000
0000000000000000000000000000000000000909090000000000000000000000000000000a0a0a00000000000000000000009000000900000000000000000000
000000000008000000000000000000000000099c99000000000000e000000000000000000aacaa00000000000000000000009000000900000000000000000000
00700700008880000000008888000000000aaaaaaaaa0000100000a9000000000000000009999900099999000000000000009000000900000000000000000000
00077000008880000000088788800000000aafcffcaa00000ea9b9ce000000000000000009000000090009000009900000009000000900000000000000000000
00077000000000000000888888780000000aafffffaa000009b0cb00000000000000000009000000090009000009000009999000000999900000000000000000
00700700000000000000878888880000000aafffffaa00000ea09e00000000000000000009000000090009000009000009009000000900900000000000000000
000000000000000000008888888800000000eeeceeee000000000000000000000000000009999900099999000009000009009000000900900000000000000000
000000000000000000000888788000000000eeeceeee000000000000000000000000000000000000000000900009000009999000000999900000000000000000
0000000000000000000008888880000000ffeeeeeee0000000000000000000000000000000887800000000000000000000000000000000000000000000000000
000000000000000000000ffffff00000000eeeeeeeeff0000000000000000000000000000078880009b9eb000000000000000000000000000000000000000000
000000000000000000000f1ff1f00000000eeeeeeee00000000000000000000000000000000880000e0009000000000000000000000000000000000000000000
000000000000000000000ffffff0000000eeeeeeee0000000000000000000000000000000007800009000e000000000000000000000000000000000000000000
000000000000000000000ccffcc0000000eeeeeeee000000000000000000000000000000000880000c000c000000000000000000000000000000000000000000
00000000000000000000fccffccf000000eeeeeeee000000000000000000000000000000000870000aebed000000000000000000000000000000000000000000
000000000000000000000ccffcc00000000f000f0000000000000000000000000000000000088000000000000000000000000000000000000000000000000000
000000000000000000000f0000f00000000f000f0000000000000000000000000000000000087000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001000009b00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000c9bebce00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000ea9b90000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000009b0cb0000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000ea09e0000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444bbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444bdbbbb9bbbbbbbbbbbbbbbbb000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444bbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444bbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444bbb1bbbbbbb8bbbbbbbbbbbb000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444bbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444bebbbb8bbbbbbbbbbebbbbbb000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444bbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
__label__
dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc7700000000
d0000077d0000077d0000077d0000077d0000077d0000077d0000077d0000077d0000077d0000077d0000077d0000077d0000077d0000077d000007700000000
d000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000c00000000
d000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000c00000000
d000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000c00000000
d000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000c00000000
d000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000c00000000
51111111511111115111111151111111511111115111111151111111511111115111111151111111511111115111111151111111511111115111111100000000
dccccc7700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dccccc7700000000
d000007700000000000000000000000000000000000000000000000000000000000000001011101000000000000000000000000000000000d000007700000000
d000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000000010110100000000000000000000000000000000d000000c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000
51111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005111111100000000
dccccc770000000000000000000000000000000000000000000000000cccccc0000000000000000000000000000000000000000000000000dccccc7700000000
d0000077000000000000000000000000000000000000000000000000d000007c000000000000000000000000000000000000000010111010d000007700000000
d000000c000000000000000000000000000000000000000000000000d000770c000000000000000000000000000000000000000000000000d000000c00000000
d000000c000000000000000000000000000000000000000000000000d000770c000000000000000000000000000000000000000000000000d000000c00000000
d000000c000000000000000000000000000000000000000000000000d000000c000000000000000000000000000000000000000000000000d000000c00000000
d000000c000000000000000000000000000000000000000000000000d000000c000000000000000000000000000000000000000000101101d000000c00000000
d000000c000000000000000000000000000000000000000000000000d000000c000000000000000000000000000000000000000000000000d000000c00000000
51111111000000000000000000000000000000000000000000000000011111100000000000000000000000000ffff00000000000000000005111111100000000
0cccccc0dccccc77dccccc77dccccc77000000000000000000000000000000000000000000000000000000000dffd00000000000000000000cccccc000000000
d000007cd0000077d0000077d0000077000000000000000000000000101110100000000000000000000000000ffff0000000000000000000d000007c00000000
d000770cd000000cd000000cd000000c00000000000000000000000000000000000000000000000000000000882288f00000000000000000d000770c00000000
d000770cd000000cd000000cd000000c0000000000000000000000000000000000000000000000000000000f082280000000000000000000d000770c00000000
d000000cd000000cd000000cd000000c00000000000000000000000000000000000000000000000000000000085580000000000000000000d000000c00000000
d000000cd000000cd000000cd000000c00000000000000000000000000101101000000000000000000000000050050000000000000000000d000000c00000000
d000000cd000000cd000000cd000000c00000000000000000000000000000000000000000000000000000000660066000000000000000000d000000c00000000
01111110511111115111111151111111000000000000000000000000000000000000000000000000000000000000000000000000000000000111111000000000
dccccc7700000000000000000000000000000000000000000000000000000000000000003bbbbbb700000000000000000000000000000000dccccc7700000000
d000007700000000101110100000000000000000000000000000000000000000000000003000000b00000000000000000000000000000000d000007700000000
d000000c00000000000000000000000000000000000000000000000000000000000000003000070b00000000000000000000000000000000d000000c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000003000000b00000000000000000000000000000000d000000c00000000
d000000c000000000000000000000000000000000000000000000000000000000ccc70003000000b00000000000000000000000000000000d000000c00000000
d000000c00000000001011010000000000000000000000000000000000000000cccccc003000000b00000000000000000000000000000000d000000c00000000
d000000c00000000000000000000000000000000000000000000000000000000cffffc003000000b00000000000000000000000000000000d000000c00000000
5111111100000000000000000000000000000000000000000000000000000000c5ff5c0011111111000000000000000000000000000000005111111100000000
dccccc7700000000dccccc770000000000000000008888000000000000000000cffffc000000000000000000000000000cccccc000000000dccccc7700000000
d000007700000000d0000077000000000000000018888880000000000000000cccccccc0000000000000000000000000d000007c00000000d000007700000000
d000000c00000000d000000c0000000000000000288888880000000000000000cccccc00000000000000000000000000d000770c00000000d000000c00000000
d000000c00000000d000000c00000000000000002e8e8e8e0000000000000000c0000c00000000000000000000000000d000770c00000000d000000c00000000
d000000c00000000d000000c00000000000000002e8e8e8e000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c00000000d000000c000000000000000022888888000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c00000000d000000c000000000000000002288880000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
51111111000000005111111100000000000000000022220000000000000000000000000000000000000000000000000001111110000000005111111100000000
dccccc770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dccccc7700000000dccccc7700000000
d00000770000000000000000000000000000000000000000101110100000000000000000000000000000000000000000d000007700000000d000007700000000
d000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c0000000000000000000000000000000000000000001011010000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c0000000000000000000000000000000000000000000000000000000000aaaa00000000000000000000000000d000000c00000000d000000c00000000
51111111000000000000000000000000000000000000000000000000000000000a0000a000000000000000000000000051111111000000005111111100000000
dccccc7700000000000000000000000000000000000000000000000000000000a000770a000000003bbbbbb700000000dccccc77000000000cccccc000000000
d000007700000000000000000000000000000000000000000000000000000000a000770a101110103000000b00000000d000007700000000d000007c00000000
d000000c00000000000000000000000000000000000000000000000000000000a000000a000000003000070b00000000d000000c00000000d000770c00000000
d000000c00000000000000000000000000000000000000000000000000000000a000000a000000003000000b00000000d000000c00000000d000770c00000000
d000000c000000000000000000000000000000000000000000000000000000000a0000a0000000003000000b00000000d000000c00000000d000000c00000000
d000000c0000000000000000000000000000000000000000000000000000000000aaaa00001011013000000b00000000d000000c00000000d000000c00000000
d000000c0000000000000000000000000000000000000000000000000000000000000000000000003000000b00000000d000000c00000000d000000c00000000
51111111000000000000000000000000000000000000000000000000000000000000000000000000111111110000000051111111000000000111111000000000
0cccccc00000000000000000dccccc77dccccc77dccccc770000000000000000000000003bbbbbb73bbbbbb7000000000000000000000000dccccc7700000000
d000007c1011101000000000d0000077d0000077d00000770000000000000000000000003000000b3000000b000000000000000000000000d000007700000000
d000770c0000000000000000d000000cd000000cd000000c0000000000000000000000003000070b3000070b000000000000000000000000d000000c00000000
d000770c0000000000000000d000000cd000000cd000000c0000000000000000000000003000000b3000000b000000000000000000000000d000000c00000000
d000000c0000000000000000d000000cd000000cd000000c0000000000000000000000003000000b3000000b000000000000000000000000d000000c00000000
d000000c0010110100000000d000000cd000000cd000000c0000000000000000000000003000000b3000000b000000000000000000000000d000000c00000000
d000000c0000000000000000d000000cd000000cd000000c0000000000000000000000003000000b3000000b000000000000000000000000d000000c00000000
01111110000000000000000051111111511111115111111100000000000000000000000011111111111111110000000000000000000000005111111100000000
dccccc770000000000000000dccccc77dccccc77dccccc77000000000000000000000000000000000000000000000000dccccc7700000000dccccc7700000000
d00000770000000000000000d0000077d0000077d0000077000000000000000000000000101110100000000000000000d000007700000000d000007700000000
d000000c0000000000000000d000000cd000000cd000000c000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c0000000000000000d000000cd000000cd000000c000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c0000000000000000d000000cd000000cd000000c000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c0000000000000000d000000cd000000cd000000c000000000000000000000000001011010000000000000000d000000c00000000d000000c00000000
d000000c0000000000000000d000000cd000000cd000000c000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
51111111000000000000000051111111511111115111111100000000000000000000000000000000000000000000000051111111000000005111111100000000
dccccc77000000000000000000000000000000000000000000000000dccccc77dccccc77dccccc77dccccc77dccccc77dccccc7700000000dccccc7700000000
d0000077000000000000000000000000000000000000000000000000d0000077d0000077d0000077d0000077d0000077d000007710111010d000007700000000
d000000c000000000000000000000000000000000000000000000000d000000cd000000cd000000cd000000cd000000cd000000c00000000d000000c00000000
d000000c000000000000000000000000000000000000000000000000d000000cd000000cd000000cd000000cd000000cd000000c00000000d000000c00000000
d000000c000000000000000000000000000000000000000000000000d000000cd000000cd000000cd000000cd000000cd000000c00000000d000000c00000000
d000000c000000000000000000000000000000000000000000000000d000000cd000000cd000000cd000000cd000000cd000000c00101101d000000c00000000
d000000c000000000000000000000000000000000000000000000000d000000cd000000cd000000cd000000cd000000cd000000c00000000d000000c00000000
51111111000000000000000000000000000000000000000000000000511111115111111151111111511111115111111151111111000000005111111100000000
dccccc77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc000000000
d000007700000000000000001011101000000000000000000000000000000000000000000000000000000000000000000000000000000000d000007c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000770c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000770c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000
d000000c00000000000000000010110100000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000
51111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111000000000
0cccccc0dccccc77dccccc77dccccc77dccccc770cccccc0dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc770cccccc0dccccc7700000000
d000007cd0000077d0000077d0000077d0000077d000007cd0000077d0000077d0000077d0000077d0000077d0000077d0000077d000007cd000007700000000
d000770cd000000cd000000cd000000cd000000cd000770cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000770cd000000c00000000
d000770cd000000cd000000cd000000cd000000cd000770cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000770cd000000c00000000
d000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000c00000000
d000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000c00000000
d000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000c00000000
01111110511111115111111151111111511111110111111051111111511111115111111151111111511111115111111151111111011111105111111100000000
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
70700000770077000000707077707770700000000000000000000000000000007070000077700000707070707770777000000000000000000000000000000000
70700000070007000000707070007070700000000000000000000000000000007070000000700000707070707070707000000000000000000000000000000000
07000000070007000000777077707070777000000000000000000000000000007770000007700000777077707770777000000000000000000000000000000000
70700000070007000000007000707070707000000000000000000000000000000070000000700000007000700070707000000000000000000000000000000000
70700000777077700700007077707770777000000000000000000000000000007770000077700700007000700070777000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0002020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000400000000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000002000000000000000004040000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000002000000040000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000002000000000002020202000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000400000000000000000000000002020202000000040002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304000000000000000000000000000000000000000002020202000400000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000400000000000202000000000002020202000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000202000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000400000000000000000000000202000404040000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000202000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000040000000000000202000000000004040000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000202000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020302020202030202020202020202020200000000020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002020202020200000000020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002000000000000000000000404000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002000000000000040400000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002000000000000000000000004000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002000004040000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002000000040000000000000004000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002000000000000000000040000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c55012540075100050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000100003073020750217201171000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000400002a3602e350313300030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
