pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- a riff on this lib
-- https://github.com/automattf/vector.lua/blob/master/vector.lua
matrix = {
  __add = function(a,b,r)
    r = r or mat()
    for i=1, #a do
      r[i] = a[i] + b[i]
    end
    return r
  end,

  __sub = function(a,b,r)
    r = r or mat()
    for i=1, #a do
      r[i] = a[i] - b[i]
    end
    return r
  end,

  __mul = function(a,b,r)
    -- assert(type(b) ~= 'number')
    if type(a) == 'number' then
      return b:map(function(x) return a * x end, r)
    elseif type(b) == 'number' then
      return a:map(function(x) return b * x end, r)
    else
      local m,n,o = a:rows(), a:cols(), b:cols()
      -- a.col = a:cols()
      -- b.col = b:cols()
      -- assert(b:rows() == n)
      r = r or mat{col = o}

      -- https://rosettacode.org/wiki/Matrix_multiplication#Lua
      for i=0,m-1 do
        for j=0,o-1 do

          r[i*o + j + 1] = 0
          for k=0,n-1 do
            -- print("i,j,k"..tostr(i)..tostr(j)..tostr(k))
            r[i*o + j + 1] += a[i*n + k + 1] * b[k*o + j + 1]
          end
        end
      end
      return r

      -- this should be generic actually.
      -- r[1] = a[1]*b[1] + a[2]*b[4] + a[3]*b[7]
      -- r[2] = a[1]*b[2] + a[2]*b[5] + a[3]*b[8]
      -- r[3] = a[1]*b[3] + a[2]*b[6] + a[3]*b[9]

      -- r[4] = a[4]*b[1] + a[5]*b[4] + a[6]*b[7]
      -- r[5] = a[4]*b[2] + a[5]*b[5] + a[6]*b[8]
      -- r[6] = a[4]*b[3] + a[5]*b[6] + a[6]*b[9]

      -- r[7] = a[7]*b[1] + a[8]*b[4] + a[9]*b[7]
      -- r[8] = a[7]*b[2] + a[8]*b[5] + a[9]*b[8]
      -- r[9] = a[7]*b[3] + a[8]*b[6] + a[9]*b[9]
    end
  end,

  __div = function(a,b,r)
    assert(type(b) == 'number' and type(a) ~= 'number')
    r = r or mat()
    for i=1, #a do
      r[i] = a[i] / b
    end
    return r
  end,

  -- negate the vector
  __unm=function(self)
    return -1 * self
  end,

  map = function(a, f, r)
    r = r or mat()
    for i=1, #a do
      r[i] = f(a[i])
    end
    return r
  end,

  zip = function(a, b, f, r)
    r = r or mat()
    for i=1, #a do
      r[i] = f(a[i], b[i])
    end
    return r
  end,

  rows = function(a)
    if (a.col) return #a / a.col
    return #a
  end,

  cols = function(a)
    return a.col or 1
  end,

  transpose = function(a)
    if a:cols() == 1 then
      a.col = #a
    elseif (a:cols() == #a) then
      a.col = 1
    else
      assert(false)
    end
  end,

  clone = function(a)
    local b = mat {col = a:cols()}
    for i,v in ipairs(a) do
      b[i] = v
    end
    return b
  end

}
matrix.__index = matrix

function mat(m)
  local m = m or {}
  setmetatable(m, matrix)
  return m
end

my_tinytests = {
  test_add = function(t)
    a = mat{1, 2}
    b = mat{3, 4}
    c = a + b
    t:ok(c[1] == 4)
    t:ok(c[2] == 6)
  end,
  test_sub = function(t)
    a = mat{1, 2}
    b = mat{3, 4}
    c = a - b
    t:ok(c[1] == -2)
    t:ok(c[2] == -2)
  end,

  test_neg = function(t)
    a = mat{1, 2}
    c = -a
    t:ok(c[1] == -1)
    t:ok(c[2] == -2)
  end,

  test_mul = function(t)
    a = mat{1, 2}
    c = -a
    t:ok(c[1] == -1)
    t:ok(c[2] == -2)
  end,

  test_shape = function(t)
    a = mat{1, 2}
    t:ok(a:rows() == 2)
    t:ok(a:cols() == 1)

    a:transpose()
    t:ok(a:rows() == 1)
    t:ok(a:cols() == 2)

    a = mat{col=2, 1, 2}
    t:ok(a:rows() == 1)
    t:ok(a:cols() == 2)
  end,

  test_map = function(t)
    a = mat{1, 2}
    b = a:map(function(x) return x * 3 end)
    t:ok(b[1] == 3)
    t:ok(b[2] == 6)
  end,

  test_mul = function(t)
    a = mat{1, 2}
    b = a:map(function(x) return x * 3 end)
    t:ok(b[1] == 3)
    t:ok(b[2] == 6)
  end,

  test_mulm = function(t)
    a = mat{1, 2}
    b = mat{col=2, 1, 2}
    -- b = a:clone()
    -- b:transpose()
    t:eq(2, a:rows(), "rows")
    t:eq(1, a:cols(), "cols")
    t:eq(2, b:cols())
    -- interior product
    c = b * a
    t:eq(1, #c)
    t:eq(5, c[1])
    -- exterior product
    d = a * b
    t:eq(4, #d)
  end,
}
