pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- text box code
--
textbox={ -- table containing all properties of a text box. i like to work with tables, but you could use global variables if you preffer.
  str={}, -- the strings. remember: this is the table of strings you passed to this function when you called on _update()
  voice=voice, -- the voice. again, this was passed to this function when you called it on _update()
  i=1, -- index used to tell what string from tb.str to read.
  cur=0, -- buffer used to progressively show characters on the text box.
  char=0, -- current character to be drawn on the text box.
  x=0, -- x coordinate
  y=64, -- y coordginate
  w=127, -- text box width
  h=60, -- text box height
  col1=0, -- background color
  col2=-1, -- border color (< 0 for no border)
  col3=7, -- text color
}

function textbox:new(o, voice, strings)
  o = o or {}
  o.str = strings
  o.voice = voice
  -- o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function mod1(x, b)
  return ((x - 1) % b ) + 1
end

function textbox:next_btnp()
  return btnp(0) or btnp(1) or btnp(2) or btnp(3) or btnp(4) or btnp(5)
end

function textbox:is_complete()
  return #self.str == self.i and self.char == #self.str[self.i]
end

function textbox:reset()
  self.i=1
  self.cur=0
  self.char=0
end

function textbox:update()  -- this function handles the text box on every frame update.
  if self.char<#self.str[self.i] then -- if the message has not been processed until it's last character:
    self.cur+=0.5 -- increase the buffer. 0.5 is already max speed for this setup. if you want messages to show slower, set this to a lower number. this should not be lower than 0.1 and also should not be higher than 0.9
    if self.cur>0.9 then -- if the buffer is larger than 0.9:
      self.char+=1 -- set next character to be drawn.
      self.cur=0	-- reset the buffer.
      if (ord(self.str[self.i],self.char)!=32) sfx(self.voice) -- play the voice sound effect.
      end
    if self:next_btnp() then
      self.char=#self.str[self.i] -- advance to the last character, to speed up the message.
      return true -- return true if you eat a button press
    end
  elseif self:next_btnp() then -- if already on the last message character and button ❎/x is pressed:
    if #self.str>self.i then -- if the number of strings to display is larger than the current index (this means that there's another message to display next):
      self.i+=1 -- increase the index, to display the next message on self.str
      self.cur=0 -- reset the buffer.
      self.char=0 -- reset the character position.
    else -- if there are no more messages to display:
      -- reading=false -- set reading to false. this makes sure the text box isn't drawn on screen and can be used to resume normal gameplay.
    end
  end
  return false
end

function textbox:draw() -- this function draws the text box.
  -- if reading then -- only draw the text box if reading is true, that is, if a text box has been called and tb_init() has already happened.
	rectfill(self.x,self.y,self.x+self.w,self.y+self.h,self.col1) -- draw the background.
	if self.col2 >= 0 then
	  rect(self.x,self.y,self.x+self.w,self.y+self.h,self.col2) -- draw the border.
	  print(sub(self.str[self.i],1,self.char),self.x+2,self.y+2,self.col3) -- draw the text.
	else
	  print(sub(self.str[self.i],1,self.char),self.x,self.y,self.col3) -- draw the text.
	end
  -- end
end
-->8
-- choice box
choicebox = textbox:new()
function choicebox:new(o, voice, strings, choices)
  o = o or textbox:new(o, voice, strings)
  o.choices = choices
  o.header = strings[#strings]
  o.choice = 1
  o.canceled = false
  o.last_choice = nil
  setmetatable(o, self)
  self.__index = self
  o:update_strings()
  return o
end

function choicebox:reset()
  self.last_choice = nil
  self.canceled = false
  self:update_strings()
end


function choicebox:update_strings()
  local str = self.header
  local sep
  for i = 1, #self.choices do
    if i == self.choice then
      if self.last_choice == nil then
        sep=">"
      elseif self.canceled then
        sep=" "
      else
        sep="."
      end
    else
      sep=" "
    end
    str = str .. "\n" .. sep .. " " .. self.choices[i]
  end
  self.str[#self.str] = str
  -- self.str = { str }
end

function choicebox:update()
  if not textbox.is_complete(self) then
    return textbox.update(self)
  else
    if self.last_choice ~= nil then
      return false
    elseif btnp(5) or btnp(4) or btnp(1) then
      printh("last choice set")
      self.last_choice = self.choice
      self:update_strings()
      return true
    elseif btnp(0) then
      self.canceled = true
      self:update_strings()
      return false
    elseif self.last_choice == nil then
      local result = false;
      if (btnp(3)) self.choice += 1; result = true
      if (btnp(2)) self.choice -= 1; result = true
      self.choice = mod1(self.choice, #self.choices)
      self:update_strings()
      return result
    else
      return false
    end
  end
end

function choicebox:is_complete()
  return textbox.is_complete(self) and (self.last_choice or self.canceled)
end


__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
