pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-- timer

-- timer = {
-- }

-- function timer:new(o, func, wait)
--   o = o or {}
--   setmetatable(o, self)
--   self.__index = self
--   o.start = time()
--   o.stop = o.start + wait
--   return o
-- end

function wait_frames(f)
  for _=1,f do
    yield()
  end
end

function wait(t)
  local start = time()
  while time() - start < t do
    yield()
  end
end

coroutines = {}

function coroutines:start(f, ...)
  add(self, { co = cocreate(f), args = {...} })
end

-- https://wiki.zlg.space/programming/pico8/recipes/coroutine
function coroutines:update()
  local s
  local t
  if #self > 0 then
    for c in all(self) do
      t = c.co
      s = costatus(t)
      if s != 'dead' then
        active, exception = coresume(t, unpack(c.args))
        if exception then
          printh(trace(t, exception))
          stop(trace(t, exception))
        end
      else
        del(coroutines, c)
      end
    end
  end
end

