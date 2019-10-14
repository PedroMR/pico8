pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- ship
draw_bb=false
local scr={x0=0,x1=127,y0=0,y1=111}
local pl={x=60,y=60,w=8,h=6,tw=2,th=2,spr=16}
pl.w2=pl.w/2 pl.h2=pl.h/2
local cam={x=0,y=0}
local m_offs_x=127
local pl_bul={}
local pl_shot=0
local ene_shp={}

function _update()
 upd_cam()
 upd_ctrl()
 upd_obj()
 upd_spawn()
end

function upd_cam()
 local cam_spd=1
 cam.x += cam_spd
 if (cam_spd>0) upd_spawn()
 trymove(cam_spd,0) --drag pl
end

function upd_spawn()
 local ntx=flr((cam.x+128)/8)
 local nty0=flr(cam.y/8)
 for nty=nty0,nty0+16 do
	 local t=mgetoff(ntx,nty)
	 if band(fget(t),2)>0 then
		 sfx(3)
	 	spawn(t,ntx-12,nty)
	 	spawn(t,ntx-8,nty)
	 	msetoff(ntx,nty,0)
	 end
	end
end

function spawn(t,tx,ty)
 local ne={x=tx*8+m_offs_x,y=ty*8,w=8,h=6,tw=2,th=2,spr=18,spd=-1}
 ne.w2=ne.w/2 ne.h2=ne.h/2
 add(ene_shp,ne)
end

function upd_ctrl()
 pl_shot-=1
 local pl_spd=3 
 if (btn(0)) trymove(-pl_spd,0)
 if (btn(1)) trymove( pl_spd,0)
 if (btn(2)) trymove(0,-pl_spd)
 if (btn(3)) trymove(0, pl_spd)
 if (btn(4)) tryshoot()
end

function tryshoot()
 if (pl_shot>0) return
 pl_shot=16
 local nb={x=pl.x+8,y=pl.y,spd=4,
 	spr=2,tw=1,th=1,w=8,h=3
 } 
 nb.w2=nb.w/2 nb.h2=nb.h/2
 add(pl_bul,nb)
 sfx(1)
end

function trymove(dx,dy)
 local coll=false
 pl.x += dx pl.y += dy
 
 local x0,x1=pl.x-pl.w/2,pl.x+pl.w/2
 local y0,y1=pl.y-pl.h/2,pl.y+pl.h/2
 -- world bounds
 if x0<cam.x+scr.x0 or x1>cam.x+scr.x1 or y0<cam.y+scr.y0 or y1>cam.y+scr.y1 then
  coll=true
 else
		if coll_m(x0,y0) or coll_m(x1,y0) 
		 or coll_m(x0,y1) or coll_m(x1,y1)
		then
			coll=true
		end  
 end
 
 if (coll)	 pl.x-=dx pl.y-=dy
 --pl.x=flr(pl.x) pl.y=flr(pl.y)
end

function upd_obj()
 for b in all(pl_bul) do
		b.x += b.spd
 end
 for o in all(ene_shp) do
		o.x += o.spd
		if(obj_coll(o,pl)) then
	  del(ene_shp,o)
	  return
		end
	 for b in all(pl_bul) do
   if obj_coll(o,b) then
		  del(ene_shp,o)
		  del(pl_bul,b)
		  return
		 end
	 end
 end
end

function obj_coll(o1,o2)
 if (o1.x-o1.w2>o2.x+o2.w2) return false
 if (o1.x+o1.w2<o2.x-o2.w2) return false
 if (o1.y-o1.w2>o2.y+o2.h2) return false
 if (o1.y+o1.w2<o2.y-o2.h2) return false
 return true
end

function mgetoff(x,y)
 return mget(x-m_offs_x/8,y)
end

function msetoff(x,y,t)
 return mset(x-m_offs_x/8,y,t)
end

--collision check with tilemap
function coll_m(x,y)
 x,y=flr(x/8),flr(y/8)
 local t=mgetoff(x,y)
 local f=fget(t)
 if band(f,1)>0 then
  return true
 end
 
 return false
end

function _draw()
 camera(cam.x,cam.y)
 rectfill(cam.x+scr.x0,cam.y+scr.y0,cam.x+scr.x1,cam.y+scr.y1,1)
 map(0,0,m_offs_x,0)
 dspr(pl)
 for b in all(pl_bul) do
  dspr(b)
 end
 for o in all(ene_shp) do
  dspr(o)
 end
 camera()
 local t=mgetoff(flr(pl.x/8),flr(pl.y/8))
-- print(flr(pl.x/8)..","..flr(pl.y/8).." -> "..t.." f: "..fget(t))
end

function dspr(o)
 spr(o.spr,o.x-o.tw*4,o.y-o.th*4,o.tw,o.th)
 if draw_bb then
	 color(11)
	 rect(o.x-o.w/2,o.y-o.h/2,o.x+o.w/2,o.y+o.h/2)
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000000000000000000000ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700077700770000000000eeeedd0000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000007777770088ac0000ddddd0008880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000077000000000000eeeee00000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08a66666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
89aafffff666000000000ddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0066fffffff666000000555ddd1dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006fffffcff66600ddddddd11dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000006ffffccff700000ddd1111dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006fffffcff66600000ddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0066fffffff666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
89aafffff66600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08a66666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
66666666600000006666666666666666000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666660000000666666666666660000000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666000000066666666666600000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666600000006666666666000000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666660000000666666660000000666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666000000066666600000006666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666600000006666000000066666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666660000000660000000666666660002c80000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000202000000000000000000000000000002020000000000000000000000000000000000000000000000000000000001010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4240404040404040404040404040404040404040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0042404040404040404040404040404043000000000000004240404040404040430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000424040430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000001200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000444040404041000000000000444040404041000000000000000000000000000044404040404100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000044404040404040410000000044404040404040410000000000000000000000004440404040404041000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000800001b5501b5501d5501f5502255022550225501f5501d5501d55022550225502255022550005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000400001b1301d130000000000000000000000000000000000000000000000000000610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000e0500d050141000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001d5501a5501d5501855000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
