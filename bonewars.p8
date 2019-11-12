pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- bone wars

local tw=16
local th=16
local spawn_y=80

local army1={sign=1}
local army2={sign=-1}
local classes={
 {name="tower",
  hp=200,
  spr=32,
  sw=2,sh=2,noflip=true
 },
 {
  name="melee",
  spr=16,
  dmg=5,
  hp=50,
  tpa=5,
  tpm=0,
  range=8
 }
}

function _init()
	local tower1={x=8,y=spawn_y,c=1}
	local tower2={x=120,spr=34,y=spawn_y,c=1}
 for ty=0,th do
	 for tx=0,tw do
	 	local t=mget(tx,ty)
	 	if (t>=32 and t<=35) or
		    (t>=48 and t<=51)	then
	 	 mset(tx,ty,0)
	 	 if(t==32) tower1.x=tx*8	tower1.y=ty*8
	 	 if(t==34) tower2.x=tx*8	tower2.y=ty*8
	 	end
	 end
	end
	
	local sw={x=tower1.x,y=spawn_y,c=2,ttm=0}
	local sw2={x=tower2.x,y=spawn_y,c=2,ttm=0}
	army_add(army1,tower1)
	army_add(army2,tower2)
	army_add(army1,sw)
	army_add(army2,sw2)
end

function army_add(a,s)
 add(a,s)
 s.army=a
 s.sign=a.sign
 s.cls=classes[s.c]
 s.hp=s.cls.hp
 s.tta=0
 s.ttm=0
end

-->8
--update

function _update()
 upd_army(army1)
 upd_army(army2)
end

function upd_army(army)
	for s in all(army) do
	 upd_soldier(s)
	end
end

function upd_soldier(s)
 local c=classes[s.c]
 if(c.name=="tower") return
 local ce, ced=closest_enemy(s)
 if ced>c.range then
	 s.ttm-=1
	 if s.ttm<=0 then
	  s.ttm = c.tpm
		 s.x += s.sign
		end
	else
	 if (ce!=s.tgt) s.tgt=ce s.tta=s.cls.tpa
		s.tta-=1
		if s.tta<=0 then
		 s.dy=s.dy or 1
		 s.dy=-s.dy
		 s.y+=s.dy
		 s.tta = s.cls.tpa
		 dmg_soldier(s.tgt,s.cls.dmg)
		end
	end
end

function dmg_soldier(s, dmg)
 s.hp -= dmg
 if s.hp <= 0 then
  s.dead=true
  del(s.army, s)
 end
end

function closest_enemy(s)
 local a=army1
 if(s.army==a) a=army2
 local cdist=9999
 local ces=nil
 for es in all(a) do
  if not es.dead then
	  local d=abs(es.x-s.x)
	  if d<cdist then
	   cdist=d ces=es
	  end
	 end
 end
 return ces,cdist
end
-->8
--draw

function _draw()
	cls(12)
	map()
	
	draw_army(army1)
	draw_army(army2)
end

function draw_army(army)
	for s in all(army) do
	 draw_soldier(s)
	end
end

function draw_soldier(s)
 local c=s.cls
 if(c.spr) spr(s.spr or c.spr,s.x,s.y,c.sw or 1,c.sh or 1,s.sign==-1 and not c.noflip)
 draw_hp(s)
end

function draw_hp(s)
-- print(s.hp,s.x-1*s.sign,s.y-12,11)
 if (s.hp >= s.cls.hp) return
 local w=10
 local gw=w*s.hp/s.cls.hp
 local rw=w-gw
 local bary=s.y-6+s.sign
 line(s.x+w/2,bary,s.x+w/2-rw,bary,8)
 line(s.x-w/2,bary,s.x-w/2+gw,bary,11)
end
__gfx__
00000000444444443333333300000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbb00000000000000000000000
00000000444444443333333300000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbb00000000000000000000000
00700700444444444444444400000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbb00000000000000000000000
00077000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbb00000000000000000000000
00077000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbb00000000000000000000000
00700700444444444444444400000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbb00000000000000000000000
0000000044444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000bb00000000000000000000000
0000000044444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000bb00000000000000000000000
00600105006000000060050000600000006000050060000000600000000000000000000000000000000000000000fffffffffffffffffffffff0000000000000
06560155065600100656050006560000065600050656040006560400000000000000000000000000000000000000fffffffffffffffffffffff0000000000000
00600105006001050060050000600005006000500060004000600040000000000000000000000000000000000000fffffffffffffffffffffff0000000000000
06660100066610500666111006661050066601110666077706660040000000000000000000000000000000000000fffffffffffffffffffffff0000000000000
60606100606165006060610060606100606066106060664060606640000777000000000000000000000000000000fffffffffffffffffffffff0000000000000
006001000010000000600100006010100060010000600040006000400000000000000000000000000000000000fffffffffffffffffffffffffff00000000000
060600000606000006060000060600000606000006060040060600400000000000000000000000000000000000fffffffffffffffffffffffffff00000000000
060600000606000006060000060600000606000006060400060604000000000000000000000000000000000000fffffffffffffffffffffffffff00000000000
0000008880000000000000bbb00000000000000000000088800000000000055555000000000005555500666000fffffffffffffffffffffffffff00000000000
000008888000000000000bbbb00000000000000000000888800000000000056565000000000005656506666000fffffffffffffffffffffffffff00000000000
0000008880000000000000bbb00000000000000000000088800000000000055555000000000005555566600000fffffffffffffffffffffffffff00000000000
000000008000000000000000b00000000000000000000000800000000006655555666000000665555566000000fffffffffffffffffffffffffff00000000000
000000008000000000000000b00000000000000000000000800000000666666666666600066666666660000000fffffffffffffffffffffffffff00000000000
000000008000000000000000b00000000000000000000000800000000666666666666600066666666660000000fffffffffffffffffffffffffff00000000000
000000008000000000000000b00000000000000000000000800000006666006660066666666600666000000000fffffffffffffffffffffffffff00000000000
000000fffff00000000000fffff0000000000000000000fffff000006600006660000066660000666666600000fffffffffffffffffffffffffff00000000000
000000fffff00000000000fffff0000000000000000000fffff000000000006660000000000000666666660000fffffffffffffffffffffffffff00000000000
000000fffff00000000000fffff0000000000000000000fffff000000000006660000000000000666006666000fffffffffffffffffffffffffff00000000000
000000fffff00000000000fffff0000000000000000000fffff000000000666666600000000066666006666000fffffffffffffffffffffffffff00000000000
00fffffffffffff000fffffffffffff00000000000fffffffffffff00000666666660000000066666006666000fffffffffffffffffffffffffff00000000000
00fff5555555fff000fff5555555fff00000000000fff5555555fff00006666066660000000666600000000000fffffffffffffffffffffffffff00000000000
00ff5eeeeeee5ff000ff5eeeeeee5ff00000000000ff5eeee7775ff00006660006660000000666000000000000fffffffffffffffffffffffffff00000000000
00fff5555555fff000fff5555555fff00000000000fff5555555fff00006660006660000000666000000000000fffffffffffffffffffffffffff00000000000
00fffffffffffff000fffffffffffff00000000000fffffffffffff00006660006660000000666000000000000fffffffffffffffffffffffffff00000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000
__map__
000000000000000000000000000000000000000000000000000000000b0c0d0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000001b1c1d1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000027282b2c2d2e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000121637383b3c3d3e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000027280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000037380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000001600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021000000000000000000000022230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3031000000000000000000000032330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000272800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000373800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
