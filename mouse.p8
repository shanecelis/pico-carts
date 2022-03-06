pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- mouse wrapper class
-- by slainte
--------------------------------
-- this snippet provices an oop
-- wrapper for the mouse
--
-- implements:
-- + enable()
-- + disable() 
-- + pressed(<num>) : true/false
--   if button number <num> is
--   pressed in current frame
-- + clicked(<num>) : true/false
--   if button number <num> is
--   pressed but was not in the
--   previous frame  
-- + released(<num>) : true/false
--   if button number is not 
--   pressed but was in the 
--   previous frame
-- + inside(minx,miny,maxx,maxy) : true/false
--   if mouse inside the given
--   rect area

-- mouse
--------------------------------
mouse={  
  enabled  = false,
  btnstate = {
    { false, false },
    { false, false }
  },
  sp = 1
}

function mouse:enable()
  poke(0x5f2d, 1)  
  self.enabled = true
end

function mouse:disable()
  poke(0x5f2d, 0)
  self.enabled = false
end

function mouse:inside(minx,miny,maxx,maxy)
  if self.x < minx or
    self.x > maxx or
    self.y < miny or
    self.y > maxy then
    return false
  end
  return true
end

function mouse:draw()
  if (self.enabled) then
    palt(0,false)
    palt(10,true)
    spr(self.sp,self.x,self.y)
    palt()
  end
end

function mouse:update()

  local mbtn

  if (self.enabled) then
    self.btn1waspressed=self.btn1
    self.btn2waspressed=self.btn2
    self.x    = stat(32)
    self.y    = stat(33)
    for idx,mbtn in pairs(self.btnstate) do
      mbtn[2] = mbtn[1]
      mbtn[1] = (band(stat(34),idx)==idx)      
    end
  end    
end

function mouse:pressed(idx)
  if (self.enabled) return self.btnstate[idx][1]
  return false
  end

function mouse:clicked(idx)
  if (self.enabled) return self.btnstate[idx][1] and not self.btnstate[idx][2]
  return false
  end

function mouse:released(idx)
  if (self.enabled) return self.btnstate[idx][2] and not self.btnstate[idx][1]
  return false
  end


__gfx__
00000000000000aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077770aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700070000aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700007070aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000070070aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000a070a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aaaaa00a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06660066060600660666000006060000000000000666066000000000000000000000000000000000000000000000000000000000000000000000000000000000
06660606060606000600000006060060000000000006006000000000000000000000000000000000000000000000000000000000000000000000000000000000
06060606060606660660000000600000000000000666006000000000000000000000000000000000000000000000000000000000000000000000000000000000
06060606060600060600000006060060000000000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000
06060660006606600666006006060000000000000666066600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06660066060600660666000006060000000000000660066606660000000000000000000000000000000000000000000000000000000000000000000000000000
06660606060606000600000006060060000000000060060600060000000000000000000000000000000000000000000000000000000000000000000000000000
06060606060606660660000006660000000000000060060606660000000000000000000000000000000000000000000000000000000000000000000000000000
06060606060600060600000000060060000000000060060606000000000000000000000000000000000000000000000000000000000000000000000000000000
06060660006606600666006006660000000000000666066606660000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000b0000000000000000000000000000000008888888888888888888888888888888888888888888888888000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
000000000000000000000000000000000000000080000000000000000000000000000000000000000000000080000000000000000000000000000000000c0000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000c0c000
000000000000000000000000000000000000000080000000000000000000000000000000000000000000000080000000000000000000000000000000000c0000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000030000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000303000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000030000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000001000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000010100000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000001000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000008888888888888888888888888888888888888888888888888000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000007070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
