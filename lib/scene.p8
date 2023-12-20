pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- scene.p8

scene = {
  background = 0,
  music = -1,
  fade = 600,
  new = function (self, o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
  end,

  enter = function (self)
    music(self.music, self.fade)
  end,

  exit = function (self)
    music(-1, self.fade)
  end,

  update = function (self)
    for e in all(self) do
      e:update()
    end
  end,

  draw = function (self)
    if (self.background) cls(self.background)
    for e in all(self) do
      e:draw()
    end
  end,

  -- install the scene with a
  -- skeleton of the _init,
  -- _update, and _draw functions.
  -- warning: do not use if those
  -- functions are already
  -- defined.
  install = function (ascene)
    function _init()
      prev_time = time()
      ascene:enter()
    end

    function _update60()
      -- these are for global updates.
      for e in all(ascene) do
        e:update()
      end
      local next = ascene:update()
      if next ~= nil then
        ascene:exit()
        ascene = next
        ascene:enter()
      end
    end

    function _draw()
      ascene:draw()
    end
  end,
}

-- text_scene = scene:new {
--   texts = { "default text" },
--   next_scene = nil,
--   x = 2,
--   y = 2,

--   new = function (self, o, texts)
--     o = scene.new(self, o)
--     o.message = message:new({}, texts)
--     o.message.color = clone(message.color)
--     return o
--   end,

--   draw = function (self)
--     cls()
--     self.message:draw(self.x, self.y)
--   end,

--   update = function (self)
--     self.message:update()
--     -- if (m:is_complete() and btnp(5)) curr_scene = collision
--     if (self.message:is_complete() and btnp(5)) return self.next_scene
--   end,
-- }


-- envelope = text_scene:new {
--   border = 10,
--   new = function (self, o, texts)
--     o = text_scene.new(self, o, texts)
--     o.x = self.border * 1.5
--     o.y = 64 + 1.5 * self.border
--     return o
--   end,
--   draw = function (self)
--     cls()
--     camera(0, 0)
--     local border = self.border
--     rectfill(border, 64 + border, 127 - border, 127 - border, 7)
--     rect(border, 64 + border, 127 - border, 127 - border, 6)
--     line(border, 64 + border,
--         63, 64 + 3 * border, 6)

--     line(63, 64 + 3 * border,
--         127 - border, 64 + border, 6)

--     self.message:draw(border * 1.5, 64 + 1.5 * border)
--   end,
-- }


-- credits = scene:new {
--   emitter = stars(),
--   x = 35,
--   y = 145,
--   t = 0,
--   f = 0,
--   speed = -4,
--   text = "credits text",
--   music = 4,

--   update = function (self)
--     particle.update_time()
--     self.f += 1
--     self.t += self.speed * particle.delta_time
--     self.emitter:update()
--   end,

--   draw = function (self)
--     cls(0)
--     self.emitter:draw()
--     if (self.f < 100) then
--       rectfill(0,0, 128 - self.f, 128, 0)
--       print("the end", 50, 64, 7)
--     end
--     print(self.text, self.x, self.t + self.y)
--   end,
-- }



__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
