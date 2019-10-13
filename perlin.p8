pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- perlin noise attempt
-- flafla2 perlinnoise
perm={ 151,160,137,91,90,15, 
    131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
    190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
    88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
    77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
    102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
    135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
    5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
    223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
    129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
    251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
    49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
    138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180}
p={}
for i=0,510 do
 p[i] = perm[i%256+2]
end

local rep=0
function perlin(x,y)
	if(rep>0) x=x%rep y=y%rep 
	local xi=band(x,0xff)
	local yi=band(y,0xff)
	local xf=x-flr(x)
	local yf=y-flr(y)
 local u=fade(xf)
 local v=fade(yf) 
 local aa=p[p[xi  ]+yi  ]
 local ab=p[p[xi  ]+yi+1] 
 local ba=p[p[xi+1]+yi  ]
 local bb=p[p[xi+1]+yi+1] 
 local x1,x2
 x1=lerp(grad(aa,xf,yf),grad(ba,xf-1,yf),u)
 x2=lerp(grad(ab,xf,yf-1),grad(bb,xf-1,yf-1),v)
 local y1 = lerp(x1,x2,v)

	return (y1+1)/2
--foreach({x, xi, xf},print)
end

function lerp(a,b,t)
	return a+t*(b-a)
end

function grad(h,x,y)
 local fx,fy
	if band(h,4) then fx=x else fx=-x end
	if band(h,1) then fy=y else fy=-y end
--print(x..","..y.." h "..h.." fx "..fx.." fy "..fy)
	return fx+fy
end

function fade(t)
 return t*t*t*(t*(t*6-15)+10)
end

function octavep(x,y,octs,pers)
	local total=0
	local freq,amp=1,1
	local maxval=0
	for i=1,octs do
		total += perlin(x*freq,y*freq)*amp
		maxval += amp
		amp *= pers
		freq*= 2
	end
	return total/maxval
end

--print(perlin(53.2,22.2))
--stop()

😐={1,12} 🐱={0,100}
--😐={1,13,12,7} 🐱={0,33,66,100}
░={}

function _init()
 for y=0,127 do
		for x=0,127 do
			local px=x/128
			local py=y/128
		--	print (px..","..py)
		 local v=octavep(px,py,1,0.5)*100
--		 local v=perlin(px,py)*100
		 set_val(x,y,v)
  end
 end
--[[ for x=0,127,10 do
  print(get_val(x,x))
 end
 ]]
 paint()
end

function set_val(x,y,v)
 ░[x..":"..y]=v
end

function get_val(x,y)
	if (x<=0 and y<=0) return 100
	if (x<0) return get_val(0,y-1)
	if (y<0) return get_val(x-1,0)

 local v=░[x..":"..y]
 if (v==nil) v=0
 return v
end

function get_col_sq(v)
  local maxd_sq=100*100
  local ⧗={}
  local tot⧗=0
  
  for i=1,#🐱 do
   local d=(v-🐱[i])
   local ⧗s=maxd_sq-d
  	⧗[i]=⧗s
  	tot⧗ += ⧗s
  end
  local win⧗=rnd()*tot⧗
  for i=1,#⧗ do
  	win⧗ -= ⧗[i]
  	if (win⧗ <= 0) return 😐[i]
  end
  return 😐[#🐱]
end

function get_col(x,y)
 local v=get_val(x,y)
 local tband = 0
 for i=1,#🐱 do
  if 🐱[i] > v then   
   tband=i
   break
  end
 end 
 if (tband==0) tband=#🐱 
 
 --interpolate with prev
 if (tband==1) return 😐[1]
 
 local tv=🐱[tband]
 local bv=🐱[tband-1]
 local da=tv-bv
 local db=v-bv
 local r=db/da
 
 local w=rnd() < r
 if w then
 	return 😐[tband]
 else
 	return 😐[tband-1]
 end
end



function _update()
	if btnp(4) then
		paint()
	end
end

function paint()
	for x=0,127 do
	 for y=0,127 do
	  pset(x,y,get_col(x,y))
	 end
	end
end
	
	
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
