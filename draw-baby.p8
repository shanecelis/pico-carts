pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- mouse interface
-- by dracus17
#include lib/mouse-and-keyboard.p8
#include lib/actor.p8

function _init()
  widgets = {}
  cursor = actor:new {
    sprite = 5,
    frames = 3,
    update = function(self)
      self.frame = 0
      self.x, self.y = mouse.x, mouse.y
      for w in all(widgets) do
        if (w:in_bounds(mouse.x, mouse.y) and w.can_click) self.frame = 1
      end
      if (mouse:btn()) self.frame = 2
    end
  }
  init_widgets(widgets)
  mouse:init(false, false)
end

function _update()
  mouse:update()
  cursor:update()
  foreach(widgets, function (w) w:update() end)
end

function _draw()
  cls()
  print("for testing purposes")
  foreach(widgets, function (w) w:draw() end)
  print("⬆️ click to reset",60,68,7)
  cursor:draw()
end

-- widgets

--	 an example of a few widgets
-- which utilise the different
-- features of the interface

function init_widgets(list)
  -- red button
  add(list,
      widget:new {
        x = 40, y = 50,
        can_click = true,
        on_down = 
          function (self)
            sfx(0)
            self.frame=1
          end,
        on_up = function (self)
            self.frame=0
          end,
        sprite = 1,
        frames = 2,
  })

  -- green button
  -- lights up on hover
  add(list,
      widget:new {
        x = 50, y = 50,
        can_click = true,
        on_down = 
          function (self)
            sfx(1)
            self.frame=1
          end,
        on_up = 
          function (self)
            self.frame=0
          end,
        on_hover = 
          function (self, inside)
            self.frame = inside and 2 or 0
          end,
        sprite = 17,
        frames = 3,
  })

  -- screen which draws using
  -- randomly coloured pixels
  -- and clears after click
  add(list,
      widget:new {
        x = 60, y = 50, 
        width = 2, height = 2, 
        pixels = {},
        on_up = 
          function (self)
            self.pixels = {}
          end,
        on_hover = 
          function (self, inside)
            if mouse:btn() then
              add(self.pixels,
               {mouse.x,
                mouse.y,
                flr(rnd(17))})
            end
          end,
        draw = function(self)
          widget.draw(self)
          foreach(self.pixels, 
          function (p) 
            pset(unpack(p)) 
          end)
        end,
        sprite = 33,
  })
end


__gfx__
0000000000888800000000000000000000000000010000000a000000080000000000000000000000000000000000000000000000000000000000000000000000
000000008888888800888800000000000000000016100000a6a00000868000000000000000000000000000000000000000000000000000000000000000000000
000000008888888888888888000000000000000016610000a66a0000866800000000000000000000000000000000000000000000000000000000000000000000
000000008888888888888888000000000000000016661000a666a000866680000000000000000000000000000000000000000000000000000000000000000000
000000002288882288888888000000000000000016666100a6666a00866668000000000000000000000000000000000000000000000000000000000000000000
000000001122221111888811000000000000000016611000a6611000866110000000000000000000000000000000000000000000000000000000000000000000
00000000001111000011110000000000000000000116100001161000011610000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000dddd000000000000bbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd00bbbb00bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ddddddddbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ddddddddbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055dddd55bbbbbbbb33bbbb33000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001155551111bbbb1111333311000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001111000011110000111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddddddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d11111111116161d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d11111111111616d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d11111111111161d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d11111111111116d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d11111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d11111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d11111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d11111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d11111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d11111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d11111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d11111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d11111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d11111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddddddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
77700770777000007770777007707770777077000770000077707070777077700770077077700770000000000000000000000000000000000000000000000000
70007070707000000700700070000700070070707000000070707070707070707070700070007000000000000000000000000000000000000000000000000000
77007070770000000700770077700700070070707000000077707070770077707070777077007770000000000000000000000000000000000000000000000000
70007070707000000700700000700700070070707070000070007070707070007070007070000070000000000000000000000000000000000000000000000000
70007700707000000700777077000700777070707770000070000770707070007700770077707700000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000008888000000dddd00000dddddddddddddd00000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000008888888800dddddddd00d11111111116161d0000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000008888888800dddddddd00d11111111111616d0000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000008888888800dddddddd00d11111111111161d0000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000228888220055dddd5500d11111111111116d0000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000011222211001155551100d11111111111111d0000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000111100000011110000d11111111111111d0000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000d11111111111111d0000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000d11111111111111d0000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000d11111111111111d0000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000d11111111111111d0000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000d11111111111111d0000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000d11111111111111d0000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000d11111111111111d0000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000d11111111111111d0000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000dddddddddddddd00000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000007777700000007707000777007707070000077700770000077707770077077707770
00000000000000000000000000000000000000000000000000000000000077707770000070007000070070007070000007007070000070707000700070000700
00000000000000000000000000000000000000000000000000000000000077000770000070007000070070007700000007007070000077007700777077000700
00000000000000000000000000000000000000000001000000000000000077000770000070007000070070007070000007007070000070707000007070000700
00000000000000000000000000000000000000000016100000000000000007777700000007707770777007707070000007007700000070707770770077700700
00000000000000000000000000000000000000000016610000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000016661000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000016666100000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000016611000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000001161000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

__sfx__
000100001105011050110501105011050100500f0500f0500d0500c0500a050060500405002050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000240502505025050250502505024050220501e0501a050130500d0500b0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
