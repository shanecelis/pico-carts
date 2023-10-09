pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- scene.p8

scene = {
  background = 0,
  music = -1,
  fade = 600
}

function scene:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function scene:enter()
	music(self.music, self.fade)
end

function scene:exit()
	music(-1, self.fade)
end

function scene:update()
  for e in all(self) do
    e:update()
  end
end

function scene:draw()
  cls(self.background)
  for e in all(self) do
    e:draw()
  end
end

-- install the scene with a
-- skeleton of the _init,
-- _update, and _draw functions.
-- warning: do not use if those
-- functions are already
-- defined.
function scene.install(scene)
  function _init()
    prev_time = time()
    scene:enter()
  end

  function _update()
    -- if scene.text == nil then
      particle.update_time()
      coroutines:update()
    -- end
    local next = scene:update()
    if next ~= nil then
      scene:exit()
      scene = next
      scene:enter()
    end
  end

  function _draw()
    scene:draw()
  end
end

-- a stage has actors
stage = scene:new { actors = {},
                    update = function(self)
                      for actor in all(self.actors) do
                        actor:update()
                      end
                    end,

                    draw = function(self)
                      cls()
                      for actor in all(self.actors) do
                        actor:draw()
                      end
                    end
                  }


text_scene = scene:new({ texts = { "default text" }, next_scene = nil, x = 2, y = 2 })

function text_scene:new(o, texts)
    o = scene.new(self, o)
    o.message = message:new({}, texts)
    o.message.color = clone(message.color)
    return o
end

function text_scene:draw()
	cls()
    self.message:draw(self.x, self.y)
end


function text_scene:update()
	self.message:update()
	-- if (m:is_complete() and btnp(5)) curr_scene = collision
	if (self.message:is_complete() and btnp(5)) return self.next_scene
end

envelope = text_scene:new({ border = 10 })

function envelope:new(o, texts)
    o = text_scene.new(self, o, texts)
    o.x = self.border * 1.5
    o.y = 64 + 1.5 * self.border
    return o
end
function envelope:draw()
	cls()
	camera(0, 0)
	local border = self.border
    rectfill(border, 64 + border, 127 - border, 127 - border, 7)
    rect(border, 64 + border, 127 - border, 127 - border, 6)
    line(border, 64 + border,
        63, 64 + 3 * border, 6)

    line(63, 64 + 3 * border,
        127 - border, 64 + border, 6)

    self.message:draw(border * 1.5, 64 + 1.5 * border)
end


credits = scene:new {
	emitter = stars(),
	x = 35,
	y = 145,
	t = 0,
	f = 0,
	speed = -4,
    text = "credits text",
    music = 4,
}

function credits:enter()
	music(4, 600)
end

function credits:update()
  particle.update_time()
	self.f += 1
	self.t += self.speed * particle.delta_time
	self.emitter:update()
end

function credits:draw()
	cls(0)
	self.emitter:draw()
	if (self.f < 100) then
		rectfill(0,0, 128 - self.f, 128, 0)
		print("the end", 50, 64, 7)
	end
	print(self.text, self.x, self.t + self.y)
end


__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
