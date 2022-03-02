pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
book = {
  current_page = nil,
  last_page_add = nil,
}

function book:new(o, pages)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  if (pages[0]) o:add_page(0, pages[0])
  for k, page in ipairs(pages) do
    o:add_page(k, page)
  end
  return o
end

function book:set_page(p, set_prevpage)
  if self.current_page ~= p then
    if self.current_page then
      self.current_page:active(false)
      if (set_prevpage and not p.prevpage) p.prevpage = self.current_page
    end
    self.current_page = p
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
  p = p or page:new(o)
  if self.last_page_add then
    -- p.prevpage = self.last_page_add
    if (not self.last_page_add.nextpage) self.last_page_add.nextpage = p
  end
  if (not p.scene) p.scene = k
  if (not self.current_page) self:set_page(p)
  self.last_page_add = p
  self[k] = p
  -- rawset(self, k, p)
  assert(p.book == nil, "page in some other book already.")
  p.book = self
end

_pages = {}

page = {
  scene = nil,
  choices = nil,
  bgcolor = nil,
  index = nil,
  nextpage = nil,
  prevpage = nil,
  book = nil,
}

function page:new(o)
  o = o or {}
  if (o.choices ~= nil) o.choices = plist:new(nil, o.choices)
  setmetatable(o, self)
  self.__index = self
  return o
end

function page:active(yes)
  -- printh("active " .. yes)
  if yes and self.choices and self.tb then
  printh("reset ")
    self.tb:reset()
  end
end

function page:next()
  if self.choices then
    -- local result = self.tb:is_complete()
    local result = self.tb:is_complete()
    if result then
      if type(result) == 'number' then
        local action = self.choices[self.tb.choices[result]]
        if type(action) == 'number' then
          return self.book[action]
        end
        -- elseif type(action) == 'function' then
        --   result()
      else
        assert(false, "no choice reported.")
      end
    else
      return nil
    end
  else
    if type(self.nextpage) == 'number' then
      return self.book[self.nextpage]
    elseif type(self.nextpage) == 'function' then
      return self.nextpage(self)
    else
      return self.nextpage
    end
  end
end

function page:prev()

  if type(self.prevpage) == 'number' then
    return self.book[self.prevpage]
  elseif type(self.prevpage) == 'function' then
    return self.prevpage(self)
  else
    return self.prevpage
  end
end

function page:draw()
  cls(self.bgcolor)
  if (self.scene) draw_page(self.scene)
  if #self > 0 then
    if not self.tb then
      if self.choices then
        self.tb = choicebox:new(nil, 0, self, get_keys(self.choices))
        self.m = message_choice:new(nil, self, get_keys(self.choices))
      else
        self.m = message:new(nil, self)
        self.tb = textbox:new(nil, 0, self)
      end
    end
    -- self.tb:draw()
    self.m:draw(0, 64)
  end
end

function page:update()
  -- if (self.tb and self.tb:update()) return
  if (self.m and self.m:update()) return

  local result = true
  -- if (self.tb) result = self.tb:is_complete()
  if (self.m) result = self.m:is_complete()
  local new_page = nil
  if result then
    local set_prevpage = false
    if btnp(➡️) then
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
end

-- _pages = {
-- page:new(nil, "test page"),
-- page:new({ text = [[are you a good merekat?]];
--  choices = { ["yes"] = 3;
--               ["no"] = 4 }
-- }),
-- page:new(nil, "next page"),
-- page:new(nil, "last page"),
-- }

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
