
function clear_page(i)
  if i == "all" then
    for n = 0, 31, 1 do
      clear_page(n)
    end
  else
  map_set((i % 8) * 16 + 1,
  flr(i / 8) * 8 + 1,
        13, 5, 0)
  end
end

function clear_page(i)
  local s = i * 64
  local c = 64
  if i == 0 then
    s = 1
    c = 47
  elseif i == 3 then
    clear_sprite(203, 5)
    for j = 0, 3, 1 do
      clear_sprite(211 + 16 * j, 13)
    end
    return
  end
  clear_sprite(s, c)
end

function clear_sprite(n, c)
  for k = 1, c or 1, 1 do
  local m = n + k - 1
  local x = (m % 16) * 8
  local y = flr(m / 16) * 8
  for i = x, x + 8, 1 do
    for j = y, y + 8, 1 do
      sset(i, j, 0)
      fset(m, 0)
    end
  end
  end
end

function map_set(cx, cy, cw, ch, v)
  for i = cx, cx + cw, 1 do
    for j = cy, cy + ch, 1 do
      mset(i, j, v)
    end
  end
end
