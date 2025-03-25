function round(v)
 local z=v&0x0.ffff
 if z<0.5 then
  return flr(v)
 else
  return ceil(v)
 end
end

-- 2 layer map display
-- idea... work by using the lower part of the map
--

mapper=class:new{
	speed=12,
	campos=vector:create(0,0),
	
	update=function(self)
	 local animframe=framectr/self.speed
	 
	 if (animframe<<16==0) then
			eachtile(
			 self.campos,
				function(t,f,set)
		   local m=(f>>4)&0b11
		   local s=(f>>7)&0b1
		   if m!=0 and animframe&s==0 
		   then
						set(addmask(t,m))
			  end
				end
			)
	 end

		local x,y=player.sprite()

		self.campos.x=(x-64)<0 and 0 or x-64
		self.campos.y=(y-64)<0 and 0 or y-64
 end,

	draw=function(_ENV, second_l)
		local x,y = campos()
		second_l = second_l or false
		local map_y = second_l and y+256 or y 
		camera(x,map_y)
		map()
		
		camera(x,y)
	end
}
