pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- scene.p8

scene = {
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
end

function scene:draw()
end

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
	self.f += 1
	self.t += self.speed * delta_time
	self.emitter:update(delta_time)
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
