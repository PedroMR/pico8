pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- bone wars

local turbo_mult=1

local tw=16
local th=16
local spawn_y=80
local buy_cooldown=10

local army1={sign=1}
local army2={sign=-1}
local proj={}
local classes={
 {name="tower",
  hp=200,
  spr=32,
  sw=2,sh=2,noflip=true
 },
 {
  name="melee",
  spr=18,
  cost=10,
  attspr=19,
  dmg=5,
  hp=50,
  tpa=9,
  tpm=3,
  range=16
 },
 {
  name="bow",
  spr=22,
  cost=20,
  attspr=6,
  hp=35,
  tpa=19,
  tpm=3,
  range=62,
  proj={
	  vy=-0.6,
	  vx=2,
	  dmg=10
	 }  
 }
}

function init_game()
 army1={sign= 1, gp=0, selected=1, ttbuy=0}
 army2={sign=-1, gp=0, selected=1, ttbuy=0}
 proj={}
 spots={}
	local tower1={x=8,y=spawn_y-8,c=1}
	local tower2={x=120,spr=34,y=spawn_y-8,c=1}
	army1.tower=tower1
	army2.tower=tower2
 for ty=0,th do
	 for tx=0,tw do
	 	local t=mget(tx,ty)
	 	if (t>=32 and t<=35) or
		    (t>=48 and t<=51)	then
	 	 mset(tx,ty,0)
--	 	 if(t==32) tower1.x=tx*8	tower1.y=ty*8
--	 	 if(t==34) tower2.x=tx*8	tower2.y=ty*8
	 	end
	 end
	end
	
	army_add(army1,tower1)
	army_add(army2,tower2)
	local sw={x=tower1.x,y=spawn_y,c=2,ttm=0}
	army_add(army1,sw)
	local sw2={x=tower2.x,y=spawn_y,c=2,ttm=0}
	army_add(army2,sw2)
	for i=1,2 do
		sw2={x=tower2.x+4*i,y=spawn_y,c=3,ttm=0}
		army_add(army2,sw2)
	end
	for i=1,2 do
		sw={x=tower1.x-4*i,y=spawn_y,c=3,ttm=0}
		army_add(army1,sw)
	end
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

local spots={} --taken by troops
local time_until_end

function update_game()
 for i=1,turbo_mult do
  if time_until_end ~= nil then
   time_until_end -= 1
   if time_until_end <= 0 then
    game_over()
    time_until_end=nil
   end
  end
  
		upd_input()
	
	 upd_army(army1)
 	upd_army(army2)
 	upd_proj()
 end
end

function upd_army(army)
	for s in all(army) do
	 upd_soldier(s)
	end
	army.gp+=0.1
end

function upd_soldier(s)
 local c=classes[s.c]
 if(c.name=="tower") return
 local ce, ced=closest_enemy(s)
 if ced>c.range/2 then
	 s.ttm-=1
	 if s.ttm<=0 then
	  s.ttm = c.tpm
		 local nx = s.x + s.sign
		 if spots[nx]==nil then
--		  spots[nx]=true
		  spots[s.x]=nil
		  s.x=nx
		 end
		end
	end	
	if ced<=c.range then
	 if (ce!=s.tgt) s.tgt=ce s.tta=s.cls.tpa 
		s.tta-=1
		if s.tta<=4 then
		 s.spr = s.cls.attspr
		else
		 s.spr = nil
		end
		if s.tta<=0 then
--[[
		 if s.spr == s.cls.attspr then
		  s.spr=nil
		 else
			 s.spr=s.cls.attspr
			end
		]]
		 s.dy=s.dy or 1
		 s.dy=-s.dy
--		 s.y+=s.dy
		 s.tta = s.cls.tpa
		 if(s.cls.dmg) dmg_soldier(s.tgt,s.cls.dmg)
		 if(s.cls.proj) soldier_shoot(s)
		end
	end
end

function soldier_shoot(s)
 local np={}
 for k,v in pairs(s.cls.proj) do
  np[k] = v
 end
 np.army=s.army
 np.x = s.x
 np.y = s.y
 np.vx = np.vx * s.sign
 add(proj, np)
end

function dmg_soldier(s, dmg)
 s.hp -= dmg
 if s.hp <= 0 then
  s.dead=true
  spots[s.x]=nil
  del(s.army, s)
  
  if(s.cls.name=="tower") time_until_end = 10
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

function upd_input()
 if btnp(5) then
--  fire_arrow()
 end
 upd_army_btn(army1,1)
 upd_army_btn(army2,0)
end

function upd_army_btn(a,p)
 if (btnp(2,p)) a.selected-=1
 if (btnp(3,p)) a.selected+=1 
 
 a.selected=(a.selected+2-1)%2+1
 a.ttbuy -= 1
 
 if (btnp(5,p)) then
	 buy_soldier(a)
 end
end

function buy_soldier(a)
 if (a.ttbuy>0) return
 local cidx=a.selected+1
 local c=classes[cidx]
 if (c.cost == nil or c.cost>a.gp) return
 a.gp -= c.cost
	local s={x=a.tower.x,y=spawn_y,c=cidx,ttm=0}
	army_add(a,s)
	a.ttbuy=buy_cooldown
end

function fire_arrow()
 local arrow={
  x=8,
  y=80,
  vy=-1,
  vx=1.5,
  army=army1
 }
 add(proj, arrow)
end

function upd_proj()
	for p in all(proj) do
	 p.x += p.vx
	 p.y += p.vy
	 p.vy += 0.07
  local ce, ced=closest_enemy(p)
  local hit=false
  if(ced < 2) then
   if abs(ce.y-p.y)<8 then
				dmg_soldier(ce,5)
				hit=true
			end
  end
	 if(p.y > spawn_y+3 or hit) del(proj,p)
	end
end
-->8
--draw

function draw_game()
	cls(12)
	map()
	
	draw_army(army1)
	draw_army(army2)
	foreach(proj, draw_proj)
end

function draw_army(army)
 foreach(army, draw_soldier)
	draw_hud(army)
end

function draw_hud(a)
 local gx=a.tower.x-5
 local gy=spawn_y+10
 print(flr(a.gp).."◆",gx,gy,10)
 
 for i=1,2 do
	 draw_opt(a, i)
	end
end

function draw_opt(a,i)
 local c=classes[i+1]
 if (c.cost == nil) return
 local y=i*12
 local w=24
 local x=64-a.sign*(64-w*0.6)-w/2 
 rectfill(x,y-2,x+w,y+8,2)
 spr(c.spr,x+1,y)
 local col=5
 if (a.selected==i) col=7
 print(c.cost.."◆",x+9,y,10)
 rect(x,y-2,x+w,y+8,col)
end

function draw_soldier(s)
 local c=s.cls
 local sx=s.x
 if (c.name=="tower") sx-=8
 if(c.spr) spr(s.spr or c.spr,sx,s.y,c.sw or 1,c.sh or 1,s.sign==-1 and not c.noflip)
 draw_hp(s)
end

function draw_hp(s)
-- print(s.hp,s.x-1*s.sign,s.y-12,11)
 if (s.hp >= s.cls.hp) return
 local w=10
 local gw=w*s.hp/s.cls.hp
 local rw=w-gw
 local bary=s.y-6+s.sign
 local x0=s.x+(s.sw or 1)*8
 if (s.cls.name=="tower") x0-=8
 line(x0+w/2,bary,x0+w/2-rw,bary,8)
 line(x0-w/2,bary,x0-w/2+gw,bary,11)
end

function draw_proj(p)
 local r=p.vy/p.vx
 local s=23
 if (r<-0.35) s=7
 if (r> 0.5) s=25
 spr(s,p.x,p.y)
end
-->8
--menus

local scr_start=1
local scr_game=2
local scr_gameover=3
local screen=scr_start

function _init()
-- init_game()
end

function _draw()
 if screen==scr_start then
  cls()
  print("press ❎ to start",30,80)
 elseif screen==scr_game then 
  draw_game()
 elseif screen==scr_gameover then 
--  draw_game()
  draw_game()
  print("◆ game over ◆",24,30)   
 end
end

function _update()
 if screen==scr_start then
  if btnp(5) then
   screen=scr_game
   init_game()
  end
 elseif screen==scr_game then
	 update_game()
 elseif screen==scr_gameover then
	 update_game()
  if btnp(5) then
   screen=scr_start
  end
	end
end

function game_over()
 screen=scr_gameover
end
__gfx__
00000000444444443333333300000000000000000000000000600007000000000000000000000000000000000000000bbbbbbbbbb00000000000000000000000
00000000444444443333333300000000000000000000000006564470000000000000000000000000000000000000000bbbbbbbbbb00000000000000000000000
00700700444444444444444400000000000000000000000000600740000000000000000000000000000000000000000bbbbbbbbbb00000000000000000000000
00077000444444444444444400000000000000000000000006666604000007000000000000000000000000000000000bbbbbbbbbb00000000000000000000000
00077000444444444444444400000000000000000000000060600004000070000000770000070000000070000000000bbbbbbbbbb00000000000000000000000
00700700444444444444444400000000000000000000000000600000000700000007000000007000000070000000000bbbbbbbbbb00000000000000000000000
0000000044444444444444440000000000000000000000000606000000000000000000000000700000007000000000000000000bb00000000000000000000000
0000000044444444444444440000000000000000000000000606000000000000000000000000000000000000000000000000000bb00000000000000000000000
00600105006000000060050000600000006000050060000000600000000000000000000000000000000000000000fffffffffffffffffffffff0000000000000
06560155065600100656050006560000065600050656040006560400000000000000000000000000000000000000fffffffffffffffffffffff0000000000000
00600105006001050060050000600005006000500060004000600040000000000000000000000000000000000000fffffffffffffffffffffff0000000000000
06660100066610500666111006661050066601110666077706660040000000000000000000070000000000000000fffffffffffffffffffffff0000000000000
60606100606165006060610060606100606066106060664060606640000777000007700000007000000000000000fffffffffffffffffffffff0000000000000
006001000010000000600100006010100060010000600040006000400000000000000700000007000000000000fffffffffffffffffffffffffff00000000000
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
00fffff454fffff000fffff454fffff00000000000fff5555555fff00006666066660000000666600000000000fffffffffffffffffffffffffff00000000000
00ffff44544ffff000ffff44544ffff00000000000ff5eeee7775ff00006660006660000000666000000000000fffffffffffffffffffffffffff00000000000
00ffff44544ffff000ffff44544ffff00000000000fff5555555fff00006660006660000000666000000000000fffffffffffffffffffffffffff00000000000
00ffff44544ffff000ffff44544ffff00000000000fffffffffffff00006660006660000000666000000000000fffffffffffffffffffffffffff00000000000
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
0000000000000000000000000000000000000000000000000000000000000037380000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000001700170000000000090000000000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021000000000000000000000022230000000000160017000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
