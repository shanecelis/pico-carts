pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
book = {
  _page = nil,
  last_page_add = nil,
  page_class = page, -- this is nil currently bah!
  message_config = {
    color = { foreground = 7,
              outline = nil,
    },
    last_press = false,
    next_message = {
      button = 1,
      char = nil,
    },
    sound = {
      next_message = nil,
    },
  },
  pages = nil
}

function book:new(o, pages)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.pages = o.pages or {}
  for k, page in pairs(pages) do
    o:add_page(k, page)
  end
  if o.pages.title then
    o.pages.title.scene = 0
    o.pages.title.nextpage = 1
    o:set_page(o.pages.title)
  end
  return o
end

function book:set_page(p, set_prevpage)
  if self._page ~= p then
    if self._page then
      self._page:active(false)
      if (set_prevpage and not p.prevpage) p.prevpage = self._page
    end
    self._page = p
    p:active(true)
  end
end

function book:add_page(k, v)
  if (v == nil) v = k; k = #self + 1
  local o, p
  if type(v) == 'string' then
    o = { v }
  elseif type(v) == 'table' then
    if getmetatable(v) == page then
      p = v
    else
      o = v
    end
  else
    error("expect string or table but got type " .. type(v) .. " for value " .. v)

    -- assert(getmetatable(v) == page, "it should be a page but was " .. type(v) .. " key " .. k)
    -- p = v
  end
  o.index = k
  p = p or self.page_class:new(o)
  -- p = p or page:new(o)
  if self.last_page_add then
    -- p.prevpage = self.last_page_add
    if (not self.last_page_add.nextpage) self.last_page_add.nextpage = p
  end
  if (not p.scene) p.scene = k
  if (not self._page) self:set_page(p)
  self.last_page_add = p
  self.pages[k] = p
  -- rawset(self, k, p)
  assert(p.book == nil, "page in some other book already.")
  p.book = self
  return p
end

page = {
  scene = nil,
  choices = nil,
  bgcolor = nil,
  index = nil,
  nextpage = nil,
  prevpage = nil,
  book = nil,
  run_before = nil,
  run_after = nil,
  is_active = false
}

book.page_class = page

function page:new(o)
  o = o or {}
  if (o.choices ~= nil) o.choices = plist:new(nil, o.choices)
  setmetatable(o, self)
  self.__index = self
  return o
end

function page:active(yes)
  if self.is_active ~= yes then
    if yes then
      if (self.run_before) self:run_before()
    else
      if (self.run_after) self:run_after()
    end
  end
  -- if yes and self.choices and self.tb then
  if yes and self.choices and self.m then
    self.m:reset()
  end
  self.is_active = yes
end

function page:next()
  if self.choices then
    -- local result = self.tb:is_complete()
    local complete = self.m:is_complete()
    local i, k, result = self.m:result()
    if complete then
      if type(result) == 'function' then
        result = result(self)
      end
      return self.book.pages[result]
      -- else
      --   error("no choice reported.")
      -- end
    else
      return nil
    end
  else
    if type(self.nextpage) == 'number' then
      return self.book.pages[self.nextpage]
    elseif type(self.nextpage) == 'function' then
      return self.nextpage(self)
    else
      return self.nextpage
    end
  end
end

function page:prev()

  if type(self.prevpage) == 'number' then
    return self.book.pages[self.prevpage]
  elseif type(self.prevpage) == 'function' then
    return self.prevpage(self)
  else
    return self.prevpage
  end
end

function get_keys(t)
  local keys = {}
  for k,_ in pairs(t) do
    add(keys, k)
  end
  return keys
end

function page:draw_scene(i)
  map((i % 8) * 16, flr(i / 8) * 8,
      0,            0,
      16,           8)
  -- if records == nil then
  --   records = anim_scan_map(
  --     (i % 8) * 16,flr(i / 8) * 8,
  --     0,0,
  --     16, 8)
  -- end
end


function page:draw()
  cls(self.bgcolor)
  if (self.scene) self:draw_scene(self.scene)
  if #self > 0 then
    if not self.m then
      if self.choices then
        -- self.tb = choicebox:new(nil, 0, self, get_keys(self.choices))
        self.m = message_choice:new(self.book.message_config, self, get_keys(self.choices), self.choices)
      else
        self.m = message:new(self.book.message_config, self)
        -- self.tb = textbox:new(nil, 0, self)
      end
    end
    -- self.tb:draw()
    self.m:draw(4, 64)
  end
end

function page:update()
  -- if (self.tb and self.tb:update()) return
  if (self.m and self.m:update()) return

  local result = true
  -- if (self.tb) result = self.tb:is_complete()
  if (self.m) result = self.m:is_complete()
  local new_page = nil
  local set_prevpage = false
  if result and btnp(➡️) then
    new_page = self:next()
    set_prevpage = true
    if (not new_page) sfx(1)
  end
  if btnp(⬅️) then
    new_page = self:prev()
    if (not new_page) sfx(1)
  end
  if (new_page) self.book:set_page(new_page, set_prevpage)
end

cardinal_page = page:new {
  row = 1, -- [1, row_count]
  column = 1,
  column_count = 8,
  row_count = 4,
  directions = {"north", "south", "east", "west"; ["north"] = "n"}--, "south" = "s", "east" = "e", "west" = "w" },
}

function cardinal_page:new(o)
  o = page.new(self, o)
  -- if o.choices then
  --   self.choices
  -- end
  o.column, o.row = o:from_index(o.index)
  return o
end


function cardinal_page:draw()
  cls(self.bgcolor)
  if (self.scene) self:draw_scene(self.scene)
  if #self > 0 then
    if not self.m then
      if self.choices then
        self.m = message_choice:new(message_config, self, get_keys(self.choices), self.choices)
      else
        self.m = message_choice:new(message_config, self, self.directions)
      end
    end
    self.m:draw(5, 64)
  end
end

function cardinal_page:to_index(c, r)
  return (r - 1) * self.column_count + c - 1
end

function cardinal_page:from_index(i)
  local c = mod1(i + 1, self.column_count)
  local r = flr(i / self.column_count) + 1
  return c, r
end

function cardinal_page:update()

  if (self.m and self.m:update()) return

  local result = false
  -- if (self.tb) result = self.tb:is_complete()

  if (self.m) result = self.m:is_complete()
  if result then

    local r = self.row
    local c = self.column
    if result == 1 then
      r -= 1
    elseif result == 2 then
      r += 1
    elseif result == 3 then
      c += 1
    elseif result == 4 then
      c -= 1
    else
    end
    new_page = self.book.pages[self:to_index(c, r)]
    local set_prevpage = false
    if new_page then
      self.book:set_page(new_page, set_prevpage)
    else
      sfx(1)
    end
    self.m:reset()
 end
end




__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
