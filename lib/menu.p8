pico-8 cartridge -- http://www.pico-8.com
version 41
__lua__

menu = scene:new {
  items={"item 1","item 2","item 3"},
  selection=1,
  foreground=7,
  line_height=12,
  x=12,
  y=20,

  draw = function(s)
    cls()
    for i=1,#s.items do
      local ii=i-1
      if s.selection == i then
        print("> \f"..s.background.."\#"..s.foreground..s.items[i],s.x,s.y+(s.line_height*ii),s.foreground)
      else
        print("  "..s.items[i],s.x,s.y+(s.line_height*ii),s.foreground)
      end
    end
  end,

  update = function(s)
    if btnp(2) then
      s.selection-=1
    elseif btnp(3) then
      s.selection+=1
    end
    s.selection=max(1, min(#s.items, s.selection))
    if btnp(❎) or btnp(🅾️) then
      return s:selected(s.selection)
    end
  end,

  selected = function(s, i)
  end
}
