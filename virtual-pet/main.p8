pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- virtual pet

#include ../lib/message.p8
#include ../lib/particles.p8
#include ../lib/timer.p8
#include ../lib/scene.p8
#include ../lib/actor.p8
#include ../lib/collision.p8
#include ../lib/mouse-and-keyboard.p8

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
 '<o1>you can draw sprites\n<i1>   like this, and you can\n\nadd a delay<d100>...<d->like this!',
 'looking for <d8><f1>spooky<f-><d-> effects?<d30>\n<d->hmm, how about some\n<o-><of><c1><ba>highlighting<b->',
 '<o-><u1>underlining?<u-><d30><o1> <d-> geeze, you\'re\na <f2>hard one to please!',
})
text_demo_scene.message.color.foreground = 15
text_demo_scene.message.color.outline = 1


particlefx = confetti()
-- particlefx.p_sprites = {1,1,1,3,1,1,1,1}
particlefx.p_sprites = variate:new(nil, {1,1,1,3,1,1,1,1})
-- particlefx = stars()
particlefx.pos = vec:new(65, 65)
bouncy_stage = scene:new {
  colliders = {},
  -- update = function(self)
  --   particlefx:update()
  -- end,
  -- draw = function(self)
  --   stage.draw(self)
  --   -- particlefx:draw()
  -- end
}

mouse:init(true, true, false)

add(bouncy_stage, particlefx)
-- add(bouncy_stage, {})
cursor = actor:new({
    update = function(self)
      mouse:update()
      self.x = mouse.x
      self.y = mouse.y
      particlefx.pos = vec:new(self.x, self.y)
      if mouse:btnp(0) then --and has_flag(self.x, self.y, 1) then
        sfx(1)
      end
    end
  }, 2)
add(bouncy_stage, cursor)

ball = bouncy_actor:new({ }, 1, 0, 0 )
ball:add(bouncy_stage.colliders)
add(bouncy_stage, ball)
ball.update = control_player
ball:draw()
local x = ball:is_solid(0,0)
print("solid" .. tostr(x))

ball = bouncy_actor:new({}, 1, 8, 8 )
ball:add(bouncy_stage.colliders)
add(bouncy_stage, ball)
ball.update = follow_actor(cursor)

-- curr_scene = scene:new()
-- curr_scene = text_demo_scene
-- curr_scene = idea
bouncy_stage:install()
-- curr_scene = bouncy_stage
-- credits:install()
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008808800000000000cc0cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070008888888007000000ccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700008888888000770000ccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000008888800007700000ccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000008880000000000000ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000008000000000000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0002000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0002000036050320401d0201d0001d0001d0001d0001d0002500028000000003c0003c00000000000003400000000000002d0002c0002b0002a00000000000000000000000000000000000000000000000000000
000100002f1502c1502a1500f110091000510001100291002b1002d10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
