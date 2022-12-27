pico-8 cartridge // http://www.pico-8.com
version 39
__lua__

local function try(t, c, f)
 local co = cocreate(t)
 local s, m = true
 while s and costatus(co) ~= "dead" do
  s, m = coresume(co)
  if not s then
   c(m)
  end
 end
 if f then
  f()
 end
end

tinytest = {

  new = function(self, o)
          o = o or {}
          setmetatable(o, self)
          self.__index = self
          o.failures = {}
          o.errors = {}
          o.verbose = o.verbose or false
          o.fail_is_error = o.fail_is_error or false
          return o
        end,

  run = function(self, tests)
          local errors_map = {}
          local failures_map = {}
          local output = ""
          for testname, testaction in pairs(tests) do

                  -- testaction(self)
            try(function ()
                  testaction(self)
                end,
                function (e)
                  -- print("error: line "..sub(e,32))
                  add(self.errors, e)
                end,
                function ()

                end)
            if #self.errors ~= 0 then
              output ..= "e"
              errors_map[testname] = self.errors
              self.errors = {}
            end
            if #self.failures ~= 0 then
              output ..= "f"
              failures_map[testname] = self.failures
              self.failures = {}
            else
              output ..= "p"
            end
          end
          print("test results: " .. output)
          for testname, testaction in pairs(tests) do
            if (failures_map[testname] or errors_map[testname]) print(testname)
            for _, failure in ipairs(failures_map[testname]) do
              print("  " .. failure)
            end

            for _, error in ipairs(errors_map[testname]) do
              print("  error line " .. sub(error,32))
            end
          end
        end,

  fail = function(self, msg, header)
           if self.false_is_error then
             assert(false,      (header or 'fail: ') .. msg)
           else
             add(self.failures, (header or 'fail: ') .. msg)
           end
         end,

  ok = function(self, value, msg)
         if (not value) self:fail(msg, 'not ok: ')
       end,

  eq = function(self, expected, actual)
         if (expected ~= actual) self:fail('"' .. expected .. '" ~= "' .. actual .. '"', 'not eq: ')
       end,

  -- eqq = function(expected, actual)
  --       if (expected !== actual) error('eqq() "' .. expected .. '" !== "' .. actual .. '"')
  --     end,

}

tinytest:new():run({
    test_passes = function(t)
               t:ok(true, "hi")
             end,

    test_fails = function(t)
              t:ok(false, "bye")
            end,
    test_errrors = function(t)
                assert(false, "wtf")
              end,

    test_fails_and_errors = function(t)
              t:ok(false, "bye")
              assert(false, "wtf")
            end,
})

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
