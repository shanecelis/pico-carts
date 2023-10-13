pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- mouse interface
-- by dracus17
#include lib/mouse-and-keyboard.p8
#include lib/actor.p8

function _init()
	_init_all()
  mouse:init(false, false)
	init_mouse(widgets)
end

function _update()
	_updt()
  update_mouse()

	foreach(widgets, function (w) w:update() end)
end

function _draw()
	_drw()
	draw_mouse()
end

-->8
-- mouse handling

function init_mouse(list)
	-- poke(0x5f2d, 1) -- enable mouse
	--mouse.x,mouse.y,
  mouse_click = mouse:btn()
	mouse_can_click 		= false
	mouse_is_clicking = false
	mouse_is_down 				= false
	mouse_w_down_f 			= nil
	mouse_w_up_f 					= nil
	mouse_w_id 							= nil
	mouse_w_list 					= list
end

-- updates mouse position
-- and state, and triggers
-- mouse events
function update_mouse()
  mouse:update()
  mouse_click = stat(34) --mouse:btn()

	-- test if over widget
	-- also triggers on_hover event
	-- mouse_hover()
		
	-- event trigger detection
	-- mouse_event()
	
	-- if not (mouse_can_click or mouse_is_clicking) then
	-- 	mouse_w_id = nil
	-- 	mouse_w_down_f = nil
	-- 	mouse_w_up_f = nil
	-- end
end

function draw_mouse()
	local s = 0 
	if mouse_can_click then
	 s = 16
	 if (mouse_is_clicking) s = 32
	end
	spr(s, mouse.x-1, mouse.y-1)
end

-- tests if mouse is hovering
-- over a widget
function mouse_hover()
	mouse_can_click = false
	for i=1,#mouse_w_list do
		local o = mouse_w_list[i]
		if in_bounds_of(o) then
			if not mouse_is_clicking then
				mouse_w_down_f = o.on_down
				mouse_w_up_f = o.on_up
				mouse_w_id = i
			end
			if (o.on_hover) o.on_hover(i)
			if (o.clickable)	mouse_can_click = true
			break
		end
	end
end

function in_bounds_of(o)
	return mouse.x >= o.x and
				mouse.x < 	o.x+8*o.w and
				mouse.y >= o.y and
				mouse.y <  o.y+8*o.h;
end

function mouse_event()
	if(mouse_click == 1) then
		if (not mouse_is_down) mouse_down()
		mouse_is_down = true
	elseif mouse_is_down then
		mouse_is_down = false
		mouse_up()
	end
end

-- triggered on click
function mouse_down()
	if not mouse_is_clicking then
		mouse_is_clicking = true
		if (mouse_w_down_f) mouse_w_down_f(mouse_w_id)
	end
end

-- triggered on release
function mouse_up()
	mouse_is_clicking = false
	if(mouse_w_up_f) mouse_w_up_f(mouse_w_id)
end

-->8
-- widgets

--	 an example of a few widgets
-- which utilise the different
-- features of the interface

function init_widgets(list)
	-- red button
	add(widgets,
	widget:new {
    x = 40, y = 50,
		on_down = 
			function (self)
					sfx(0)
          self.frame=1
				end,
		on_up =
			function (self)
          self.frame=0
				end,
    sprite = 1,
    frames = 2,
	})

	-- green button
	-- lights up on hover
	add(widgets,
	widget:new {
    x = 50, y = 50,
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
	add(widgets,
	widget:new {
    x = 60, y = 50, width = 2, height = 2, pixels = {},
		on_up =
			function (self)
        self.pixels = {}
      end,
		on_hover =
			function (self, inside)
        if (inside) add(self.pixels,{mouse.x,mouse.y,flr(rnd(17))})
      end,
    draw = function(self)
      widget.draw(self)
      foreach(self.pixels, function (p) pset(unpack(p)) end)
    end,
    sprite = 33,
	})
end

-- function draw_widget(widget)
-- 	local s = widget.s_up
-- 	if (widget.is_down) s = widget.s_down
-- 	spr(s,widget.x,widget.y,widget.w,widget.h)
-- end
-->8
-- updates, draws, inits, etc

--  separated to make first tab
-- as simple as possible

function _init_all()
	widgets = {}
	pixels = {}
	init_widgets(widgets)
end

function _updt()
	-- widgets[2].s_up = 17
end

function _drw()
	cls()
	print("for testing purposes")
	foreach(widgets, function (w) w:draw() end)
	print("⬆️ click to reset",60,68,7)
end

__gfx__
01000000008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16100000888888880088880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16610000888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16661000888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16666100228888228888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16611000112222111188881100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01161000001111000011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000dddd000000000000bbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a6a00000dddddddd00bbbb00bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a66a0000ddddddddbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a666a000ddddddddbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a6666a0055dddd55bbbbbbbb33bbbb33000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a66110001155551111bbbb1111333311000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01161000001111000011110000111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
080000000dddddddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
86800000d11111111116161d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
86680000d11111111111616d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
86668000d11111111111161d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
86666800d11111111111116d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
86611000d11111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01161000d11111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
