pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- tbship

pl={i=2,j=0}
local gy1=96
local xd,yd=16,8

function dr_grid()
 cls(0)
 color(6)
 for y=0,gy1,yd do
  for x=0,128,2 do
   pset(x,y,6)
  end
	end
 for x=0,128,xd do
  for y=0,gy1,2 do
   pset(x,y,6)
  end
	end
--	 line(0,y,128,y,6)
end

function dr_ships()
 spr(1,pl.j*xd+4,pl.i*yd+2)
end

function dr_stats()
 print("blahahaha",0,gy1+2)
end

function _draw()
 dr_grid()
 dr_stats()
 dr_ships()
end

function _update()
 if btnp(3) then
 	pl.i+=1
 end
 if btnp(2) then
  pl.i-=1
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000970000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700877cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000977cc7700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000