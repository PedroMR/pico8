pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- freeze

😐={1,13,12,7}
🐱={0,33,66,100}
░={}

function _init()
 for y=0,127 do
		for x=0,127 do
		 local n1=get_val(x-1,y)
		 local n2=get_val(x,y-1)
		 local v=combine(n1,n2)
		 set_val(x,y,v)
   --set_val(x,y,flr(y*100/128))
  end
 end
 paint()
end

function combine(n1,n2)
 local degrade=rnd()*0.01;
	return (1-degrade)*(n1+n2)/2
end

function get_val(x,y)
	if (x<=0 and y<=0) return 100
	if (x<0) return get_val(0,y-1)
	if (y<0) return get_val(x-1,0)

 local v=░[x..":"..y]
 if (v==nil) v=0
 return v
end

function set_val(x,y,v)
 ░[x..":"..y]=v
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
 if (tband==0) then tband=#🐱 end
 
 --interpolate with prev
 if (tband==1) then return 😐[tband] end
 local tv=🐱[tband]
 local bv=🐱[tband-1]
 local da=tv-bv
 local db=v-bv
 local r=db/da
 if rnd() < r then
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
