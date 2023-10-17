pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--advanced micro platformer
--@matthughson

-- #include lib/vector.p8
dolly = {

  --target=target,--target to follow.
  --pos=vec:new(target.x,target.y),

  --how far from center of screen target must
  --be before camera starts following.
  --allows for movement in center without camera
  --constantly moving.
  pull_threshold=vec:new(16,32),

  --min and max positions of camera.
  --the edges of the level.
  pos_min=vec:new(64,64),
  pos_max=vec:new(320,128),

  shake_remaining=0,
  -- shake_force=0,
  new=function(self, o, t)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    t = t or o.target
    o.target = t
    o.pos=vec:new(t.x,t.y)
    return o
  end,

  update=function(self)
    local pos, thresh = self.pos, self.pull_threshold

    self.shake_remaining-=1

    --follow target outside of
    --pull range.
    local delta = self.target - pos
    pos += (delta - thresh):map(function(v) return mid(0, v, 4) end)
    pos += (delta + thresh):map(function(v) return mid(-4, v, 0) end)

    --lock to edge
    pos = pos:map(max, self.pos_min)
    pos = pos:map(min, self.pos_max)
    self.pos = pos
  end,

  cam_pos=function(self)
    --calculate camera shake.
    local shk=vec:new(0)
    if self.shake_remaining>0 then
      shk = vec:new(self.shake_force)
      shk = shk:map(rnd) - shk/2
    end
    local v = self.pos - vec:new(64, 64) + shk
    return v.x, v.y
  end,

  shake=function(self,ticks,force)
    self.shake_remaining=ticks
    self.shake_force=force
  end
}