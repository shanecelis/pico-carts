pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
plist = {
  keys = nil
}
function plist:new(o, list)
  o = o or {}
  local keys = {}
  o.ordered_keys = keys
  local hash = {}
  setmetatable(o, {
                 -- __index = hash,

                 __index = function(t, k)
                   local v = rawget(t, k)
                   if type(k) == 'number' then
                     return v or keys[k]
                   else
                     return v or hash[k]
                   end
                 end,
                 __pairs =
                   function(t)
                     local i = 0
                     return function()
                       i += 1
                       local key = keys[i]
                       if (key ~= nil) then
                         return key, hash[key]
                       end
                     end
                   end,
                 __newindex =
                   function(t, k, v)
                     add(keys, k)
                     hash[k] = v
                   end,
                 __len = function(t) return #hash end,

  })

  for i = 1, #list, 2 do

    o[list[i]] = list[i + 1]
    -- add(keys, list[i])
    -- hash[list[i]] = list[i + 1]
  end
  return o
end
-- function plist.__index(t,k)
--   if type(k) == 'number' then
--     return rawget(t, 'keys')[k] or rawget(t, k)
--   else
--     return rawget(t, 'hash')[k] or rawget(t, k)
--   end
-- end
-- -- len is for ipairs not pairs
-- function plist.__len(t)
--   return #t.keys
-- end
-- function plist.__pairs(t)
--   local i = 0
--   return function()
--     i += 1
--     local key = t.keys[i]
--     if (key ~= nil) return key, t.hash[key]
--   end
-- end
