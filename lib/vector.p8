pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-- a riff on this lib
-- https://github.com/automattf/vector.lua/blob/master/vector.lua
vec = {
  new = function (self, x, y)
    local v = {x = x, y = y}
    setmetatable(v, self)
    self.__index = self
    return v
  end,

  __add = function(a,b)
    return vec:new(a.x + b.x, a.y + b.y)
  end,

  __sub = function(a,b)
    return vec:new(a.x - b.x, a.y - b.y)
  end,

  __mul = function(a,b)
    if type(a) == 'number' then
      return vec:new(a * b.x, a * b.y)
    elseif type(b) == 'number' then
      return vec:new(a.x * b, a.y * b)
    else
      return vec:new(a.x * b.x, a.y * b.y)
    end
  end,

  __div = function(a,b)
    assert(type(b) == 'number' and type(a) ~= 'number')
    return vec:new(a.x / b, a.y / b)
  end,

  --get the length of the vector
  length=function(self)
    return sqrt(self.x^2+self.y^2)
  end,

  --get the normal of the vector
  normalize=function(self)
    return self / l:length()
  end,

  map = function(a, f)
    return vec:new(f(a.x), f(a.y))
  end
}
