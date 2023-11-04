pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- copyright (c) 2023 shane celis[1]
-- licensed under the mit license[2]
--
-- this is the tinytest library
-- for pico-8; it was inspired
-- by the tinytest[3] javascript
-- library by joe walnes. it
-- provides a basic unit test
-- framework.
--
-- you can use it one of two
-- ways: as a no frills library
-- or as a singing, dancing cart.
--
-- library usage
-- -------------
--
-- you will enjoy colored text
-- reports but otherwise no
-- frills, but it's very
-- flexible this way.
--
-- ```
-- #include tinytest.p8:0
--
-- tinytest:new():run({
--   demo_pass = function(t)
--     t:ok(true, "hi")
--   end,
--
--   demo_fail = function(t)
--     t:ok(false, "bye")
--   end,
--
--   demo_error = function(t)
--     assert(false, "wtf")
--   end,
--
--   demo_misc  =
--   function(t)
--     t:ok(false, "bye2")
--     assert(false, "wtf2")
--   end,
-- })
-- ```
--
-- cart usage
-- ----------
--
-- the cart comes with some
-- images of bob from the
-- incredibles in meme format
-- and some audio sfx so you can
-- hear the sweet sound of tests
-- passing, failing, and
-- erroring to make unit testing
-- more fun.
--
-- in your cart, define
-- `my_tinytests`:
--
-- ```
-- -- yourcart.p8
-- my_tinytests = {
--   demo_pass = function(t)
--     t:ok(true, "yep")
--   end
-- }
-- ```
--
-- edit tinytest.p8's cart:
--
-- ```
-- -- tinytest.p8
-- #include yourcart.p8
-- ```
--
-- load tinytest.p8 and on every
-- run it will exercise your
-- tests. since it does an
-- include, you don't have to
-- reload either.
--
-- todo
-- ====
--
-- * add more bob meme images
--   (only two currently)
-- *
--
-- [1]: https://mastodon.gamedev.place/@shanecelis
-- [2]: https://opensource.org/licenses/MIT
-- [3]: https://github.com/joewalnes/jstinytest


-- define my_tintests in yourcart.
-- #include yourcart.p8
-- #include lib/matrix.p8
-- try runs the given function
-- t() first. on errors call
-- c(e). finally call f() when
-- complete.
--
-- try from https://github.com/sparr/pico8lib/blob/master/functions.p8
--
-- there is also a trace
-- function for coroutines gives
-- a stacktrace in the preceding
-- link.
local function try(t, c, f)
  local co = cocreate(t)
  local s, e = true
  while s and costatus(co) ~= "dead" do
    s, e = coresume(co)
    if not s then
      c(e)
    end
  end
  if f then
    f()
  end
end

-- tinytest class
--
-- it can be extended. see
-- bobtest below.
tinytest = {

  new = function(self, o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    -- o.verbose = o.verbose or false
    o.failures = {}
    o.fail_is_error = o.fail_is_error or false
    return o
  end,

  -- utility function. counts
  -- the number of entries in a
  -- table. sequences can do
  -- #list but tables have to be
  -- iterated it seems.
  table_count = function(table)
    local count = 0
    for key, value in pairs(table) do
      count += 1
    end
    return count
  end,

  -- run the tests and return
  -- the tables failures and
  -- errors.
  run = function(self, tests)
    local errors_map = {}
    local failures_map = {}
    local errors = {}
    cls()
    print("test results: \0")
    for testname, testaction in pairs(tests) do
      try(function ()
            testaction(self)
          end,
          function (e)
            add(errors, e)
          end,
          function ()

          end)

      if #errors == 0 and #self.failures == 0 then
        print("\fbp\0")
      end

      if #self.failures ~= 0 then
        print("\faf\0")
        failures_map[testname] = self.failures
        self.failures = {}
      end
      if #errors ~= 0 then
        print("\f8e\0")
        errors_map[testname] = errors
        errors = {}
      end
    end
    print("\f6")
    for testname, testaction in pairs(tests) do
      print(testname)
      if failures_map[testname] or errors_map[testname] then
        for _, failure in ipairs(failures_map[testname]) do
          print("  " .. failure)
        end

        for _, error in ipairs(errors_map[testname]) do
          print("  \f8error line\f6 " .. sub(error,32))
          print(error)
        end
      else
        print("  \fbpass\f6")
      end
    end
    return failures_map, errors_map
  end,

  -- report an unconditional failure.
  fail = function(self, msg, header)
    if not msg then
      msg = ''
      header = header or 'fail'
    end
    if self.false_is_error then
      assert(false,      header .. msg)
    else
      add(self.failures, header .. msg)
    end
  end,

  -- assert something is true.
  ok = function(self, value, msg)
    if (not value) self:fail(msg, '\fanot ok: \f6')
  end,

  -- assert something is equal.
  eq = function(self, expected, actual, msg)
    if (expected ~= actual) self:fail('"' .. expected .. '" ~= "' .. actual .. '" '..(msg or ''), 'not eq: ')
  end,

}

-->8

-- add image and sounds to unit
-- test report. must have
-- tinytest cart loaded and not
-- just included to work
-- properly.
bobtest = tinytest:new(
  { sprites =
      { good = {0, 64, 64, 32, 32},
        bad =  {8, 64, 64, 32, 32} },
    run = function(self, tests)
      local failures, errors = tinytest.run(self, tests)
      if self.table_count(failures) +
         self.table_count(errors) == 0 then
        spr(unpack(self.sprites.good))
      else
        spr(unpack(self.sprites.bad))
      end
      local soundstr = ""
      for testname, testaction in pairs(tests) do
        if errors[testname] then
          soundstr ..= "\a2 \^4"
        elseif failures[testname] then
          soundstr ..= "\a1 \^4"
        else
          soundstr ..= "\a0 \^4"
        end
      end
      print(soundstr)
    end
})

if my_tinytests then
  function _init()
    cls()
    bobtest:run(my_tinytests)
  end
  function _draw()
  end
  function _update()
  end
elseif not _init then

  demo_passtests = {
    demo_pass = function(t)
      t:ok(true, "hi")
    end,
  }

  demo_failtests = {
    demo_fail = function(t)
      t:ok(false, "bye")
    end,
  }

  demo_errortests = {
    demo_error = function(t)
      assert(false, "wtf")
    end,
  }

  demo_misctests = {
    demo_pass = function(t)
      t:ok(true, "hi")
    end,

    demo_fail = function(t)
      t:ok(false, "bye")
    end,

    demo_error = function(t)
      assert(false, "wtf")
    end,

    demo_misc = function(t)
      t:ok(false, "bye2")
      assert(false, "wtf2")
    end,
  }

  last = time()
  wait = 10
  slideshow = true
  function _init()
    cls()
    print("welcome to tiny test!")
    print("")
    print("press ❎ to run \fbpassing\f6 tests.")
    print("press 🅾️ to run \fafailing\f6 tests.")
    print("press ⬆️ to run \f8erroring\f6 tests.")
    print("press ➡️ to run \f7misc\f6 tests.")
    print("press ⬅️ to show this screen.")
    print("press ⬇️ to toggle random selection\n  (currently " .. (slideshow and "on" or "off") .. ").")
    print("")
    if slideshow then
      print("if no buttons are pressed, this \ncart will choose one randomly \nevery "..wait.." seconds.")
    end
  end

  function exec(n)
    if (btnp(5) or n == 1) bobtest:run(demo_passtests)
    if (btnp(4) or n == 2) bobtest:run(demo_failtests)
    if (btnp(2) or n == 3) bobtest:run(demo_errortests)
    if (btnp(1) or n == 4) bobtest:run(demo_misctests)
    if (btnp(0) or n == 5) _init()
    if (btnp(3) or n == 5) slideshow = not slideshow; _init()
  end

  function _update()
    if btnp() ~= 0 then
      exec(nil)
      last = time()
    elseif slideshow and (time() - last) > wait then
      exec(flr(rnd(5)) + 1)
      last = time()
    end
  end

end

__gfx__
ddddddddddddddddddd4444ddddddddddddddddddddddddddddddddddddddddd10000000000000000000000000000000000000001151155555555555555d55dd
ddddddddddddddddd44444aa444ddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000001155555555555555555ddd5d
ddddddddddddddd44445554ffa44455dd44ddddddddddddddddddddddddddddd0000000000000000000000000000000000000001115555555555555d5dd555d5
ddddddddd5ddddd445545554444455444d445dddd5dddddddddddddddddddddd00000000000000000000000000000000000000015555555555555555555dd5dd
5dddd4dddddd544545555500544455554a4554dddddddd4dddd4dddd4dddd4dd0000000000000000000000000000000000000001551555555555555dd555dd5d
dd4ddddddd4dd44455452244454444444455445ddddddddddddddddddddddddd0000000000000000000000000000000000000001551555555555555555d55d55
dddddddddddd44a45554444f4fa444a4d444444dddd4dddddd4ddddddddd4ddd00000000000000000000000155d5510000000000515555555555555555d55dd5
dddddddd4dd4ad5444444fff4ffefde44a444444dddddddddddddd4ddddddddd000000000000000000005dd6d6666ddd0000000005555555555555555555555d
5ddddd4dddd4445544afe4fef44ff4ffeed444444ddddddd4ddddddddd4ddddd0000000000000000015d6666666666666d10000000155555555555555555d55d
ddd4dddddd455444afe4ff44ffe4f9444444d44445dddddddddddddddddddddd0000000000000001dd666d666666666666dd500000015555d55555555d5555dd
d4dddddddd4544afd4ff4fff4ff4effffffa44d4444dd4dddddddddd4ddddddd000000000000005666666666666677666dddd5100000155555555555555d5555
dddddddddd544f4eff4ff4ff4eff4de44444ea444445dddddddd4ddddddddddd00000000110105666666666666676676666ddd55500005555555555555555d55
ddddddd4d454afd4afe4fe4ff44fa44ff4ee444444444ddddddddddddddddd4d0000000010501666666666666777777767666dd550000555d5555555555555d5
ddddddddd44d44ff44ff4ff4ff4effee4ff44fa444455dd4dddddddddd4ddddd0000001005006dd6d666666677667776666dd555110000555555555555555555
dddd4dddddaaef4fef4f44f44ff4ef4a4e44a444444444dddd4ddd4ddddddddd00000010010d6666d66d6666667766677666dd55100000055555555555555555
d5dddddd4dd4ef4fef4eff4ff4f4ff4ff44ff4444444445ddddddddddddddddd000000005006d66d6d66d66d6666666766dd5110000000015555555555555555
dddddd4d4ad4aee44ff44f4ae4f44ff4ef44455555544545dddddddddddd4ddd000000001056d66d6ddd6d66666666666666dd55000000005555155155555555
dddddd4d544fd4af44fa44f94f44f4e44fe5522004454445dddddddd4ddddddd00000000005ddd66d66d6dd66667666666dddd50000000000515511551555555
4ddddd444f44ff4ff44ff9ad4444feafe4450222444444554dddd4dddddddddd00000000005d6ddddddd6d66d6666d676666d510000000000155551515555555
ddd4dda54ad49f44aa44af444544fe4ef442250445444445dddddddddddddd4d00000000005ddd5d665d5100055d6d666d650000000000000051555115515555
ddddd44544fe44f44ff444552444fa44ff402225544444455ddddddddd4ddddd00000000005555d65000000000055d7665d00000000000000015551555515555
ddddd4444d44f44af444524244444ff44e405225225444454ddddddddddddddd0000000000511d50000000000000566665000000000000000015551551555555
ddd5da454f44f4444554424444444eef44520044455445445ddddd4ddddddddd00000000001151000000000000101666d5000000000000000005555555555555
ddddd4444f444a4544422424444e444ff4522444444544445ddd4ddddddd4ddd00000000000000000000000000155dd665000000000000000005555115155155
d4dd4d4444fa45445224444444444ff444500444e445444554ddddddd4dddddd000000000000000000000000110155dd50000000000000000005551551555555
dddd444544d4454244ef444444f444f4e42205555552544455dddddddddddddd000000000000000000000000555015dd50000000000000000001551151551555
ddddd444da4444444500054444e444f4f42500000d45544445dddddddddddddd000000000000000000000000055155dd50000000000000000000555115555555
ddd4445444444445465115f4444444f4445040505df4444445ddd4dddddddddd00000000000000000000005d015555dd50000000000000000000115115115555
4ddd444444444446fd00556d4e9444ef4452205556644445455ddddddd4ddddd00000000000000000000005501d555dd50000000000000000000555515551555
dddd4444df444d44ff555de44e44e44fe402244dd4445444454ddddddddddd4d000000001110000000000000005551ddd0000000000000000000051551555555
ddd4445444ff4ef4d44e4444f94444f444550244444444444555dd4ddddddddd00000000511000000000000001555556d0000000000000000000155551155155
44da544444e44444ee4444fe444e44e4f42224444e444444445545dddddd4ddd01dd10055155511000000005d55d55ddd0000000000000000000055155151555
da444444f44eff4e44fee4e44d4e444f44205444444444ed445255ddd4dddddd515d50055555dd5d55555dd6dddd55ddd0000000000000000000055155511555
444d444444444eff4fe44f44444f444f4452254ff4ef4d444550024ddddddddd50000005555dd66d66d6ddddd555555dd5000000000000000000055551555115
4444444d4ee4444444444e4444e4fe44e4520444ee44e4444522205ddddddddd1056000515d6d66ddddddd55505115d55d000000000000000000005555155155
44444544444fe444e44f444ee444f44ef424224444d44444454205ddddddd4dd0065001515dd66666666d55515d55ddd55000000000000000000015555155111
44454444d44444e4444444d4444444e944452244d44f4d444552024ddddddddd05d0055555d6666666dd55055dd55dd510000000000000000000005155511551
4444444d44f4444445554ef4ff44454452002544444d444d4452205ddd4ddddd5650561155d6d66dd655005d5100000000000000000000000000005551551115
444445444d44e44554444d4ef4ef442022222544454444444525254ddddddddd5d105d1555ddd6d6d55015d55100000000000000000000000000005551151000
94d4444d444e4445444444ff44fd444445422244455244d44545255ddddddddd5d50051555dddddd5501ddd55d55500000000000000000000000001555515051
44a44444f44d4e4444de4444dff4ff4e4445544544445444454255ddddddd4dd555d55551555dddd505555ddddd5551000000000000000000000000511511010
444444d444e44f44de44f64e4444eed44444444445444d44454554ddddd4dddd16ddd15555d555d551555dd5dddddd5100000000000000000000000551101000
dd55444d4ed4f4de44fd4e4ff4ef44ffd44444d444444ed4454554ddd4dddddd05d5d1555555d55d15dd55666666ddd555500000000000000000000555505010
ddd4444f444ed4f44de44fd4ed4ed4e4ffde44d44444544d444555dddddddddd0055105555d5dddd55d55d66dd66d55510000000000000000000000555510010
ddd4d444d44f44e4fe4fe4f44f44ff44e44ff44d44d4444d444554dddddddddd000005555dd55ddd1d5515001555510000000000000000000000000511551000
4dd44dd4e444f44d444fd4ff4ef44fdf44f44de444444444454455dddddddddd0000055555dd5dd6d5555ddd66666666d6d55000001010000000000555101000
dddd44f44fd4ee4fedf44f4ef4efd4ee4ff44e44d44d4544d44555dddddd4ddd000005555ddd5dd66ddd666666666666dd5551000055d5000000000051150051
dd44d44d444f44644fe4fe4de4dfe44df44ed44f44444444445425ddd5dddddd0000111555dd5ddd66d666666676666d555511000015d1000000000011151010
ddd44f44f44e44f44f44f4fe4fe44ff4e4df44f44d44d454445455dddddddddd0000015555dddd566dd66666666666dd55510000001550000000000005151001
54d44444edf4df4ef4df44fe4f4ef44eda44ed44d44d4454d445554ddddddd4d0000001555dddddd6d666666666666dddd555500001500000000000000510000
dd44644d44e44f4de44fde4dfe4fd4ff4ed4f44d444444445445255dddd4dddd00000011555d6d5d6666666666666666ddd55510000000000000000001551110
dd4444de44df44f44fe44fe4f4f44fe44df44ef44fd44455445545dddddddddd00000001555dddddd6666666666666d6d5dd5511100000000000000000155050
d4d44d44f44fd4e4df44f4df44fee44df44e44d4444dd4444554254ddddddddd00000001555ddddd66666666667666666ddd5555100000000000000000511010
da44d4444de44fd4f4dff44fee4df4fe4e4df44fd44444454445555ddddddddd00000000555dd5ddd666666666676666666d5555000000000000000000511555
d44444d44f44f44f44f44fe4df4ef4df4df44d444fd44d445542225ddd4ddddd000000000555dddddd66667677676766666dd555000000000000000000115101
44f444f4444fd44f4de44fd4f4f44f44f44e4f44444e444454552554dddddd4d0000000001555dddddd6666666766766666d5d51000000000000000000055555
ad44d444d4444fd4e44fd44fe4fd4fe4fe46446fd44dd44544552554dddddddd00000000115555d55dddd6666666666666ddd551000000000000000000055551
4f4444444ed44e44f4df4ef44f4fe4fd4fd4f444ed44444545545255dddd4ddd00000000000555d55d55d6666666d6666ddd5550000000000000000000005555
4aed44d44444d44d44f44df4df44fd4f44fedfe44de44d44552252555ddddddd0000000000005555555555dddd66dd6dd5d55500000000000000000000000555
44444444d44444f44d44f44444d44e44f444444d44444455445025555ddddddd0000000000001155555555d5d5dddd5555550000000000000000000000000015
ade944444d4d44d44444444d44e444d44d44d444444444552552552254dddddd0000110000000011110000555155550500000000000000000000000000000000
94e4d444444d4444d44d444d444d444d444d44d44445544552045025555dd4dd0000551000000000000000000000000000000000000000000000000000000000
44d4e4445444dd4444444d4444444d444444444444445552525522552554dddd1151101500000000000000000000000000000000000000000000000000000000
f44f44d44454444d44d4444444d444444444444455544552052052022555dddd6555115550000000000000000000000000000000000000000000000000000000
__sfx__
00020000170501c05020050250502b0502f0502200026000280002b0002f000300003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000033550305502b5502855025550215001e5001b500195001650013500115000f5000c5000a5000750006500005000050000500005000050000500005000050000500005000050000500005000050000500
00040000336102a610236101c61012610116001360000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
