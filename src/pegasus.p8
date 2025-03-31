pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- pegasus dream

-- CONSTANTS
--[[const]] DEBUG=true
--[[const]] MASK=false
--[[const]] FPS=60
--[[const]] t_zone=false

if DEBUG then
	norm_per_frame=0
	norm_arr={}
end

if not t_zone then
	function _init()
		d('---INIT----')

		framectr=0

		actors=seq({},'actors')

		-- for _=1,20 do
		-- 	local kind = rnd({slime, knight, fool_knight, p_knight})
		-- 	add(actors, kind(getRandomTile()))
		-- end
		
		-- add(actors, slime(48,48))
		-- add(actors, p_knight(48,48))
	
		sfx(0)
	end
	
	function _update60()
		framectr+=1
	
		points:update()
		io:update()
		player:update()
		mapper:update()
	
		foreach(actors, invoke('update'))
	
		if DEBUG then
			hud:set('#mv', format2(#player.mv))

			-- pad string
			local cpuDisp = tostr(flr(stat(1)*100))
			if (#cpuDisp == 1) cpuDisp=' '..cpuDisp

			hud:set('norm', norm_per_frame) 
			hud:set('cpu', cpuDisp)

			-- clean debug states
			norm_per_frame=0
		end
	end
	
	function _draw()
		cls(11)
	
		mapper:draw()
		player:draw()
	
		foreach(actors, invoke('draw'))
		
		
		if DEBUG then
			local displayOverlay = function (a)
				if MASK then
					color(9)
					local r = a.mask:offset(a.pos())
					rect(r())
					color(7)
				end
				local pos=a.pos+vec2(3,3);
				local zz=pos+(a.mv*20);
				line(pos.x, pos.y, zz.x, zz.y)
			end
	
			points:draw()
			hud:draw(mapper.campos())
			foreach(actors, displayOverlay)
			displayOverlay(player)
		end
	end
end
-->8
-- support class/functions
-- 

function d(...)
	for v in all(pack(...)) do
		printh(v)
	end
end

function invoke(name)
	return function (o)
		o[name](o)
	end
end

function get(name)
	return function(o)
		return o[name]
	end
end

function id(val)
	return function()
		return val;
	end
end



function format2(n)
	local s =
		flr(n) .. "." ..
		flr(n%1 * 10^2)
	
	if #s != 4 then
		s=s..'0'
	end
	return s
end

function i2(s)
	local l=split(s, '\n')
	local rv=''
	for i=1,#l-1 do
		rv..=l[i]..'\n  '
	end
	return rv..l[#l]
end

function ifn(v)
	if type(v)=='table' then
		return i2(tostr(v))
	end
	
	return tostr(v)
end

function tbl_tostr(t)
	local rv=(t.NAME or 'unamed')..': {\n'
	for k, v in pairs(t) do
		v=ifn(v)
		rv..=' '..k..'='..v..',\n'
	end
	return rv..'}'
end

function seq_tostr(s, n)
	local rv = (n or 'seq')..': [\n'
	for v in all(s) do
		v=ifn(v)

		rv..=' '..v..', \n'
	end
	return rv..']'
end

class=setmetatable({
	NAME='class',
	new=function(self, t, mt)
		t = t or {}

		mt = mt or {}
		mt.__index=mt.__index or self
		mt.__tostring=mt.__tostring or tbl_tostr
		mt.__call=mt.__call or function (tbl, ...) 
			if tbl.create then
				return tbl:create(...)
			end
		end

		t=setmetatable(t, mt)
		
		-- For any class, call initialize when the instance is newed.
		-- This will be most useful for singleton
		if t.initialize then
			t:initialize()
		end

		return t
	end,

	include=function(tbl, mixin)
		for k,v in pairs(mixin) do
			tbl[k]=v
		end
	end
}, {__index = _ENV})

seq=class:new{
	NAME='seq',
	create=function(self,s,name)
		return class.new(
			self,
			s, 
			{__tostring=function (own) 
				return seq_tostr(own, name or self.NAME) 
			end}
		)
	end
}

vec2=class:new{
	NAME='vec2',
	x=0,
	y=0,

	normalize=function(self)
		if DEBUG then norm_per_frame+=1 end

		local len=#self;

		if (len<0.1) then
			return vec2(0, 0)
		else
			return self/len;
		end
	end,

	add=function(self, i, j)
		self.x+=i
		self.y+=j
		return self;
	end,

	sq_len=function(_ENV)
		return x*x+y*y
	end,
	
	create=function(self, x, y)
		local vv = {x=x, y=y}

		if (type(x)=='table' and x.NAME=='vec2') then
			vv={x=x.x, y=x.y}
		end

		return class.new(
			self, 
			vv,
			{
				__tostring=function(v)
					return 
						'v<'..format2(v.x)..
						','..format2(v.y)..'>'
					end,

				__add=function(v1, v2)
					return vec2(
						v1.x+v2.x,
						v1.y+v2.y
					)
				end,

				__sub=function(v1, v2)
					return vec2(
						v1.x-v2.x,
						v1.y-v2.y
					)
				end,

				__mul=function(a, b)
					if (type(b)=='number') then
						return vec2(
							a.x*b,
							a.y*b
						)
					end

					return vec2(
						a.x*b.x,
						a.y*b.y
					)
				end,

				__div=function(v1, q)
					return vec2(
						v1.x/q,
						v1.y/q
					)
				end,

				__len=function(v)
					return sqrt(v.x^2+v.y^2)
				end,
						
				__call=function(v)
					return v.x,v.y
				end,
				
				__eq=function(v1,v2) 
					return v1.x == v2.x and v1.y == v2.y
				end,
			})
	end,
}

rect2=class.new{
	NAME='rect2',

	offset=function(self,i,j)
		return rect2(
			self.x1+i, self.y1+j,
			self.x2+i, self.y2+j
		)
	end,

	create=function(self,x1,y1,x2,y2)
		local tbl=class.new(
			self,
			{ x1=x1,y1=y1,x2=x2,y2=y2 },
			{
				__tostring=function(_ENV)
					return 'r<'..tostr(x1)..','..tostr(y1)..'\n'
						 ..tostr(x2)..','..tostr(y2)..'>'
				end,

				__call=function(_ENV)
						return x1,y1,x2,y2
				end,
			}
		)

		return tbl
	end
}

io=class:new{
	NAME='io',
	vec=nil,
	norm=nil,
	x=false,
	o=false,

	xcnt=0,
	ocnt=0,
	
	nodir=false,

	initialize=function(_ENV)
		vec=vec2(0, 0)
		norm=vec2(0, 0)
	end,

	update=function(_ENV)
		local i=0
		local j=0
		nodir=true

		if (btn(⬅️)) i=-1 nodir=false
		if (btn(➡️)) i=1 nodir=false
		if (btn(⬆️)) j=-1 nodir=false
		if (btn(⬇️)) j=1 nodir=false

		if (btn(❎)) then 
			x=true 
			xcnt+=1
		else 
			x=false
			xcnt=0
		end
		
		if (btn(🅾️)) then 
			o=true 
			ocnt+=1
		else 
			o=false
			ocnt=0
		end

		vec.x=i vec.y=j

		local factor=1 
		if (abs(i)==1 and abs(j)==1) then
				factor=0.707
		end

		norm=vec*factor
	end,
}

sprite=class:new{
	NAME='sprite',

	create = function(self, pos_vec, tileId)
		local tbl = class.new(self, {
			pos=pos_vec,
			id=tileId,
		}, {__call=function(s) return s.pos(); end})
		return tbl;
	end,

	draw = function(_ENV)
		spr(id, pos())
	end,

	update=function()
	end,
}

-->8
-- game classes
--

actor=class:new{
	NAME='actor',

	-- defaults values
	tileId=0,
	speed=0,
	mask=rect2(0,0,7,7),
	mv=vec2(0,0),

	create=function(self,x,y)
		local pos=vec2(x,y)

		local tbl=class.new(self, {
			pos=pos,
			body=sprite(pos, self.tileId),
			update_cor=self.behavior and cocreate(self.behavior) or nil
		})

		return tbl
	end,

	update=function(_ENV)
		if process_mv then
			_ENV:process_mv()
		else
			if costatus(update_cor) == 'dead' then
				update_cor=cocreate(behavior)
			end
			assert(coresume(update_cor, _ENV))
		end

		-- optimization to debug!
		-- if mv:sq_len() > (speed*speed) then
		-- end

		if(mv != old_mv or speed != old_speed) then
			mv=mv:normalize()*speed
		end


		mv,colided=process_map_colision(
			mask:offset(pos()),
			mv
		)

		pos:add(mv())

		old_mv=vec2(mv)
		old_speed=speed
	end,

	draw=function(_ENV)
		body:draw()
	end

	-- process_mv=virtual function = 0
}

-- Behaviors coroutines

function wait_internal(v)
	for _=1,v do
		yield()
	end
end

function wait_(fnOrV)
	return function(self)
		local v=type(fnOrV)=='function' and fnOrV(self) or fnOrV
		wait_internal(v)
	end
end

function random_vec()
	return vec2(rnd(2)-1, rnd(2)-1);
end


function toward_player(_ENV)
	local v=player.pos-pos
	return v:normalize()
end

function set_(key, fnOrV)
	if type(fnOrV) == 'function' then
		return function(self)
			self[key]=fnOrV(self)
		end
	end

	return function(self)
		self[key]=fnOrV
	end
end

function set_mv(fn)
	return function(_ENV)
		mv=fn(_ENV)
	end
end

function add_mv(fn)
	return function(_ENV)
		mv+=fn(_ENV)
	end
end

function untilMapCollision_(_ENV)
	repeat
		yield()
	until colided
end

function pipe_(f_list)
	local outArgs={}

	return function(self)
		for fn in all(f_list)
		do
			outArgs=pack(fn(self, unpack(outArgs)))
		end
	end
end
	


knight=actor:new{
	NAME='knight',
	tileId=48,
	speed=0.5,

	create=function(...)
		local tbl=actor.create(...)
		tbl.speed=0.25+rnd(0.5)
		return tbl
	end,

	behavior=pipe_{
		set_('speed', function () return 0.25+rnd(0.5) end),
		wait_(function() return rnd(90) end),
		add_mv(toward_player),
	}
}

fool_knight=actor:new{
	NAME='Fool_Knight',
	tileId=49,
	speed=1,

	behavior=pipe_{
		add_mv(random_vec),
		wait_(5+rnd(5)),
	},
}

function moveToward(x,y,t)
	return function(_ENV)
		mv=vec2(x,y)
		wait_internal(t)
	end
end

slime=actor:new{
	NAME='slime',
	tileId=50,

	behavior=pipe_({
		set_('speed', function() return 0.2+rnd(0.8) end),
		moveToward(1,0,0.5*FPS),
		moveToward(0,-1,0.5*FPS),
		moveToward(-1,0,0.5*FPS),
		moveToward(0,1,0.5*FPS),

		set_('mv', toward_player),
		untilMapCollision_,
		wait_(1 * FPS),
	}),
}

function trackPlayer(n)
	return function(self)
		local nbr_f=n
		repeat
			self.mv=toward_player(self)
			nbr_f-=1
			yield()
		until (nbr_f==0)
	end
end

p_knight=actor:new{
	NAME='Pegasus_Knight',
	tileId=51,

	behavior=pipe_({
		set_('speed', 0.2),
		trackPlayer(5*FPS, 0.2),

		set_('mv', vec2(0,0)),
		wait_(3*FPS),
		set_('speed', 3),
		set_('mv', toward_player),
		untilMapCollision_,
		set_('speed', 1),
		wait_(1*FPS)
	}),
}

player=class:new{
	NAME='player',

	initialize=function(_ENV)
		pos=vec2(64,64)
		mv=vec2(0,0)
		mask=rect2(2,2,5,5)
		direction=vec2(0,0)

		colided=false

		body=sprite(pos, 16)

		update_cor=cocreate(behavior)
		status='normal'
	end,

	sword_anim={
		{54, vec2(8,0),false,false},
		{56, vec2(4,-4),false,false},
		{57, vec2(0,-8),false,false},
		{56, vec2(-4,-4),true,false},
		{54, vec2(-8,0),true,false},
		{56, vec2(-4,4),true,true},
		{57, vec2(0,8),false,true},
		{56, vec2(4,4),false,true},
	},

	behavior=function (_ENV)
		boostFrames=0
		if io.x then
			status='charging'

			repeat
				boostFrames+=1
				yield()
				if (boostFrames >= 16) then
					mv=vec2(0,0)
				end
			until (not io.x or boostFrames > 60)
			if boostFrames < 16 then
				status = 'attack'
				atk_fr = 0
			elseif boostFrames > 60 then
				status = 'boost'
			else
				status = 'normal'
			end

			boostFrames=0
		end
		
		-- state machine based on 'status'
		if status == 'normal' then
			mv+=io.norm

			if(mv:sq_len()>1) then 
				mv=mv:normalize()*1
			end

			if io.nodir then mv=mv*0.95 end
		end

		if status == 'boost' then
			repeat
				mv=(mv+(io.norm*0.15)):normalize()*3
				yield()
			until colided

			status = 'normal'
		end

		if status == 'attack' then

			local angle = atan2(mv.x, mv.y)
			local initial_fr = flr(angle*#sword_anim)-(#sword_anim\4)

			atk_fr = initial_fr;
			repeat
				mv+=io.norm*0.15

				if(mv:sq_len()>0.5*0.5) then 
					mv=mv:normalize()*0.5
				end

				atk_fr+=0.3
				yield()
			until atk_fr >= initial_fr+(#sword_anim\2)+0.3
			status = 'normal'
		end

	end,
	
	update=function (_ENV)
		if costatus(update_cor) == 'dead' then
			update_cor=cocreate(behavior)
		end
		assert(coresume(update_cor, _ENV))

		mv,colided=process_map_colision(
			mask:offset(pos()),
			mv
		)

		pos:add(mv())
	end,

	drawArrow=function(_ENV)
		if (boostFrames>16) then
			local x,y=pos()
			local mult=1+boostFrames/20
			local sx=8*mult
			d(mult)

			local acol={
				[1]=10,
				[2]=9,
				[3]=8,
			}
			local col=acol[flr(mult)]
			
			pal(9, col)
			if (io.vec.y!=0) then
				sspr(
					64,8,
					7,7,
					(x+4)-(sx/2),(y+4)-(sx/2),
					sx,sx,
					false,io.vec.y>0		
				)
			else
				sspr(
					71,8,
					7,7,
					(x+4)-(sx/2),(y+4)-(sx/2),
					sx,sx,
					io.vec.x>0,false		
				)
			end
			pal(9,9)		
		end
	end,


	drawBoostSword=function(_ENV)
		local angle = atan2(mv.x, mv.y)
		_ENV:drawSword(flr(angle*#sword_anim))
	end,

	drawSword=function(_ENV, frame)
		local s_id,offset,flip_x,flip_y=
			unpack(sword_anim[flr(frame)%#sword_anim+1]);
		s_pos=pos+offset
		sspr(
			(s_id % 16) * 8, (s_id \ 16) * 8, 
			8,8,
			s_pos.x, s_pos.y,
			8,8,
			flip_x,
			flip_y
		)
	end,

	draw=function (_ENV)
		-- handle pegasus arrow
		if status == 'charging' then
			_ENV:drawArrow()
		end

		if status == 'attack' then
			_ENV:drawSword(atk_fr)
		end

		if status == 'boost' then
			_ENV:drawBoostSword()
		end
		
		body:draw();

		if (colided) then
			sfx(0)
		end
	end,
}

points=class:new({
	pt={},

	add=function(_ENV,x,y,c,l,r)
		add(
			points.pt,
			{x=x,y=y,c=c,l=l,r=r or 1}
		)
	end,

	update=function(_ENV)
		for v in all(pt) do
			v.l-=1
			if(v.l<=0) then
				del(pt, v)
			end
		end
	end,
	
	draw=function(_ENV) 
		foreach(pt, function(p)
			if(p.r>1) then
				circfill(p.x,p.y,p.r,p.c)
			else
				pset(p.x, p.y, p.c)
			end
		end)
	end,
	
})

if DEBUG then
	hud=class:new({
		baseY=0,
		col=7,
		data={},
		order={},
		
		set=function(_ENV, key, val)
			if not val then
				del(data, key)
				del(order, key)
			else
				if not data[key] then
					add(order, key)
				end

				data[key]=tostr(val)
			end
		end,

		draw=function(_ENV, x, y)
			rectfill(x,y+baseY,x+128,y+baseY+6,1)
			local str=""
			for i in all(order) do
				local j=data[i]
				str=str..
					i..': '..j..' '
			end
			print(str,x,y,col)
		end,
	})
end

-->8
-- map stuff
-- flags on tiles
-- fl0: colision mask
-- fl4,5: anmiation mask
-- fl7: anmiation speed / 2

function is_wall(x, y)
	local colided = 
		fget(mget(x\8, y\8), 0)

	if DEBUG then
		-- debugging code
		if colided then
			points:add(x, y, 
				colided and 8 or 9,
				colided and 30 or 1,
				colided and 2 or 1
			)
		end
	end
	
	return colided
end

-- pos=position to check.
-- TODO:
-- return 'H' / 'V' / 'C'
function process_map_colision(pos,mv)
	-- sprite corners:
	-- c1 c2
	-- c3 c4

	local colided=false

	local m_x1, m_y1, m_x2, m_y2=pos()

	local c1 = is_wall(m_x1, m_y1)
	local c2 = is_wall(m_x1, m_y2)
	local c3 = is_wall(m_x2, m_y1)
	local c4 = is_wall(m_x2, m_y2)

	if (c1 and c3 or c2 and c4) then
		-- horizonal
		mv.y*=-1
		colided=true
	end

	if (c1 and c2 or c3 and c4) then
		-- vertical
		mv.x*=-1
		colided=true
	end

	if (not colided and (
		c1 or c2 or c3 or c4
	)) then
		-- corners
		mv*=-1
		colided=true
	end

	return mv,colided
end

function addmask(v, mask)
	local l=v&mask
	l=(l+1)&mask
	v=(v&~mask)+l
	return v
end

function eachtile(campos, fn)
	local x,y=campos.x\8,campos.y\8

	for i=x,x+15 do
		for j=y,y+15 do
			local t=mget(i, j)
			local f=fget(t)
			fn(
				t, f,
				function(n)
					mset(i, j, n)
				end,
				i, j
			)
		end
	end
end

function getRandomTile()
	local is_valid=false
	local i,j
	repeat
		i = flr(rnd(16))
		j = flr(rnd(16))

		local t=mget(i,j)
		is_valid = not fget(t,0)
	until is_valid
	return i*8,j*8
end

mapper=class:new{
	initialize=function(_ENV)
		-- setup dark blue as transparency
		palt(0, false)
		palt(1, true)

		speed=12
		campos=vec2(0,0)
	end,
	
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

		local x,y=player.pos()

		self.campos.x=(x-64)<0 and 0 or x-64
		self.campos.y=(y-64)<0 and 0 or y-64
	end,

	draw=function(_ENV)
		camera(campos())
		map()
	end
}

-->8
-- testing zone

if t_zone then
	cor=cocreate(function(a)
		local b=''
		for j=1,5 do
			print(a..' '..b..' '..tostr(j))
			a,b=yield(j, 10+j)
			b=b or 'undefined'
		end
		return 99,1
	end)

	cls()
	
	function resume(thr, ...)
		local error,rv= coresume(thr, ...)
		assert(error, rv)
		return rv
	end
	
	d(cor, costatus(cor))
	print(resume(cor, '1st', 'hello'))
	print(resume(cor, '2nd', 'world'))
	print(resume(cor, '3rd'))
	print(resume(cor, '4th'))
	print(resume(cor, '5th'))
	print(resume(cor, '5th'))
	d(cor, costatus(cor))

  data=split('54, 8,0,false,false,54, 8,-2,false,false, 55, 4,-4,false,false, 56, 4,-4,false,false, 57, 0,-8,false,false, 57, 0,-8,false,false, 56, -4,-4,true,false, 55, -4,-4,true,false, 54, -8,-2,true,false,54, -8,0,true,false')
  -- data=split('54, 8,0,false,false,|,54, 8,-2,false,false, 55, 4,-4,false,false, 56, 4,-4,false,false, 57, 0,-8,false,false, 57, 0,-8,false,false, 56, -4,-4,true,false, 55, -4,-4,true,false, 54, -8,-2,true,false,54, -8,0,true,false')

	function subsplit(s, n)
		local rv=seq{}
		for i=1,(#s\n)-1 do
			local subs=seq{}
			for j=1,n do
				add(subs, s[i*n+j])
			end
			add(rv, subs)
		end
		return rv
	end

	-- function subsplit(s)
	-- 	local rv=seq{}
	-- 	local i = 1
	-- 	repeat
	-- 		local subs=seq{}
	-- 		repeat
	-- 			local item = s[i]
	-- 			add(subs, item)
	-- 			i+=1
	-- 		until item != '|'
	-- 		add(rv, subs)
	-- 	until i == #s
	-- 	return rv
	-- end

	animtable=subsplit(data, 5)

	d(animtable)
	 
	stop('eh')
end
__gfx__
00000000119999111199991111999911119999111199991111999911000000000000000000000000000000000000000011110000001111100000011100000000
66666666198888211988882119888821198888211988882119888821000000000000000000000000000000000000000011100777700111007777001100000000
65555556982882829882288298822882988228829888288298828882000000000000000000000000000000000000000011107aaaa7011107aaaa701100000000
66656666988228829828828298822882982222829822228298222282000000000000000000000000000000000000000011107aa7a7011107a7aa701100000000
00656000988228829828828298222282988228829822228298222282000000000000000000000000000000000000000011107aaaa7011107aaaa701100000000
00656000982882829882288298822882988228829888288298828882000000000000000000000000000000000000000011109777790111097777901100000000
00656000198888211988882119888821198888211988882119888821000000000000000000000000000000000000000011109999990111099999901100000000
00656000112222111122221111222211112222111122221111222211000000000000000000000000000000000000000000009999990000099999900000000000
11000011110000111100001111000011110000111100001111000011110000111110111111001111100000011000000199909999990999099999909900000000
10cccc0110cccc0110c22c0110ccc20110cccc0110cccc011022cc0110ccc2011109011110901111007777000077770044409999990444099999904400000000
0cccccc0022cccc00cc22cc00cc222c00ccccc2002222cc00cc2ccc00cc222c0109990110990001107aaaa7007aaaa7000004999940000049999400000000000
0cc222200c2222c00cc22cc00cc222c0022222200c2222c00cc22cc00c222cc0099999009999901107aa7a7007aa7a7011104444440111044444401100000000
022222200c2222c00cc22cc00cc222c002222cc00c2222c00cc22cc00c222cc0000900010990001107aaaa7007aaaa7011104444440111044444401100000000
02ccccc00cc222200ccc2cc00c222cc00cccccc00cccc2200cc22cc00c222cc01109011110901111097777900977779011104444440111044444401100000000
10cccc0110cccc0110cc2201102ccc0110cccc0110cccc0110c22c01102ccc011100011111001111099999900999999011155444455111554444501100000000
11000011110000011100001111000011110000111100001111000011110000111111111111111111099999900999999011115555551111155555511100000000
10010011100100111001001100000000b333bb33b33b337b00000000000000001111111100000000090000900900009011110000000001110000000000000000
08808801088077010770770100000000bb3bb333b3bb37b300000000000000001111000100000000007777000077770011100777777700110000000000000000
0888e80108e8770107777701000000003bb3337333b3b7b300000000000000001110aa010000000007aaaa7007aaaa7011107aaaaaaa70110000000000000000
0888880108887701077777010000000073b337b333b3bb330000000000000000110a99010000000007aa7a7007aa7a7011107aa7a7aa70110000000000000000
10888011108870111077701100000000b733bb3b7333bb33000000000000000010a990110000000007aaaa7007aaaa7011107aaaaaaa70110000000000000000
11080111110801111107011100000000b7b3bb33b733bb3300000000000000000099011100000000097777900977779011109777777790110000000000000000
111011111110111111101111000000003bb3b33b3bb3b33700000000000000005500111100000000099999900999999011109999999990110000000000000000
1111111111111111111111110000000033b3b3b333b3b37b00000000000000005501111100000000099999900999999011109999999990110000000000000000
111111111111111111111111111111117b333bb37b333bb31111111111111111111100001110a011090000900999999011109999999990110000000000000000
1888888119999991155555511eeeeee137b33bb337b33bb301111111111100011110aaa0110a9901090940900999999011109999999990110000000000000000
888888889999999955555555eeeeeeee3b7b3b333bbb3b330000000110009990110a9990110a9901040940400499994011104999999940110000000000000000
888ffff8999ffff9555ffff5eeeffffe33bb333733bb333750aaaaa00999999910a99990110a9901040940400444444011104444444440110000000000000000
88f0ff0899f2ff2955f2ff25eef2ff2eb3bb337b3b3b33735099999a999999900a999901110a9901040940400444444011104444444440110000000000000000
18fffff119fffff115fffff11efffff1bb3b3bb33bb33bb3509999909999000100999011110a9901040940400444444011104444444440110000000000000000
11333311113333111133331111333311bb3b3b3b3bb33bb300000001900011115509011111000001550940555544445511155444444450110000000000000000
117117111171171111711711117117113b33333bb3b33b3301111111011111115500111110055500150940511555555111115555555551110000000000000000
11111111cccccccc000000000000044477777777777777777a99999995a9990077777777777777777a99999995a9900011111111111111111111111111111111
11111111c6cc6ccc0aa9999999999aa4aaaaaaaaaaaaaaaa7a99999995a99900aaaaaaaaaaaaaaa77a99999995a9000011133111111331111113311111111111
11111111616616cc0a999999999999a09aa9999999aa99997a999999959a99009aa99999a99990a77a99999995a0009911133111113a73111113311111133111
111111111111116c099999999999999099999999999999997a999999959a990099999999999900a77a99999995000999133a7331133aa331133a733113133131
11111111111116cc099999999999999099999999999999997aa9909995a9990099900999999000a77aa99099900099aa133aa33113133131133aa331133a7331
1111111111116ccc099999999999999099999999990099997aa9909995a9990099999999990009a77aa99099000aaa99111331111113311111133111113aa311
1111111111116ccc0aaaaaaaaaaaaaa099999999999999997a99999995a9090099999999900099a77a9999900055555511133111111111111113311111133111
11111111111116cc044444444444444099900999999999997a99999995a9090090099999000999a77a9999000999999911111111111111111111111111111111
1111111611111116044444222244444099999999999999997a999999959a990099999990009999a77a9990009999900911111111111111111110001100000000
1111116c1111166c044444444444444055555555555555557a999999959a990055555500099999a77a9900099999999911111111111111111106660100000000
111116cc111166cc0999999999999990aaaaaa99aaaa99aa7a99999995a9990099aaa00099099aa77a9000999999999911111111111111111066766000000000
111166cc111666cc0444444444444440999999aa9999aa997a99999095a99900aa99000999099aa77a0009999990099931111311131113110666776000000000
1111166c1111666c004444222244440090099999009999997a99999095a9990099900059999999a77a0099999999999913113111131113110666666000000000
111116cc111166cc004444444444440099999999999999997aa9999995a9090099000a59999999a77a09999a99999aa913113113131131130566665000000000
111166cc111166cc109999999999990100000000000000007aa9999995a9090000009a59999999a77aaaaaaaaaaaaaaa11111131111111311555555100000000
111116661111666610aaaaaaaaaaaa0100000000000000007a99999995a9990000099a59999999a7777777777777777711111131111111311111111100000000
11111111111111110000000000000000000000000000000000999a59999999a777777777777777770099a959999999a7cccccccccccccccccccccccc00000000
11111111111111110000000000000000000000000000000000909a5999999aa77aaaaaaaaaaaaaaa0099a95909999aa7ccccccccccccccccccc6cccc00000000
11111111111111110000000000000000999999999999999900909a5999999aa77a00099999aa999900099a5909999aa7cccccccccccccccccc616cc600000000
11111111111111110000000000000000999999009999900900999a59099999a77a9000999999999990009a59999099a7ccbcccccccbcccccc611166100000000
1611611611111111000000000000000099aa9999aa99999900999a59099999a77a9900099999999999000a59999099a7cbcccccccbcccccccc61111100000000
66666616611111110000000000000000aa99aaaa99aaaaaa00999a59999999a77a99900099009999aaa00059999999a7cbccccbccbcccbcccc61111100000000
6cc6cc6cc6111111000000000000000055555555555555550099a959999999a77a9999000999999955550009999999a7cccccbcccccccbccc611111100000000
cccccccccc611111000000000000000099999999999999990099a959999999a77aa999900099999999999000999999a7cccccbcccccccbcccc61111100000000
cccccccccc611111cccccccc11111116999999999990099900909a59999999a77a999999000999999999990009999aa7c6111111cc611111ccc11111cc666111
ccccccccccc61111c6cc6cc61111116c999999999999999900909a59999999a77a9999999000555599999990009999a7c6111111cc611111ccc11111cc666111
ccccccccccc6111161666666111116cc999900999999999900999a5999099aa77a99999995000aaa99990099000999a7cc611111ccc61111cccc1111ccc66611
cccccccccc61111161161161111166cc999999999999999900999a5999099aa77a99099995a0009999999999900099a7ccc61111cccc6111ccccc111cccc6661
ccccccccc6111111111111111111166c99999999999999990099a959999999a77a99099995a9000999999999990009a7ccc61111cccc6111ccccc111cccc6661
cccccccccc61661611111111111116cc9999aa9999999aa90099a959999999a77aa9999095a990009999aa99999000a7cc611111ccc61111cccc1111ccc66611
ccccccccccc6cc6c11111111111166ccaaaaaaaaaaaaaaaa00999a59999999a77aa99990959a9900aaaaaaaaaaaaaaa7c6111111cc611111ccc11111cc666111
cccccccccccccccc1111111111111666777777777777777700999a59999999a77a999999959a99007777777777777777cc611111ccc61111cccc1111ccc66611
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000002434a10000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000a1c2d0e0a100000000000000000000000000002535a20000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000a2c3d1e1a2000000000000000000000000e5000000a30000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000a3000000a300000000000000000000000000000000b10000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000a1000000a100000000e50000000000000000000000b20000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000a2c0d0d2a200000000000000000000000000000000b30000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000b3c1d1d3b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000e50000000000000000e5000000a10000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000a20000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000a30000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000a10000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000c2d0e0c0d0e0c0d0e0c0d0e0c0d0e0b20000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000c3d1e1c1d1e1c1d1e1c1d1e1c1d1e1b30000000000000000000000000000000000000000000000000000000000000000
__label__
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
60000006600000066000000660000006600000066000000660000006600000066000000660000006600000066000000660000006600000066000000660000006
60000006600000066000000660000006600000066000000660000006600000066000000660000006600000066000000660000006600000066000000660000006
60000006600000066000000660000006600000066000000660000006600000066000000660000006600000066000000660000006600000066000000660000006
60000006600000066000000660000006600000066000000660000006600000066000000660000006600000066000000660000006600000066000000660000006
60000006600000066000000660000006600000066000000660000006600000066000000660000006600000066000000660000006600000066000000660000006
60000006600000066000000660000006600000066000000660000006600000066000000660000006600000066000000660000006600000066000000660000006
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666bbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
60000006bbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbb3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbb66666666
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3bb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbb60000006
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
66666666bb33bbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
60000006bb3bbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bb33bbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bb3bb3bbbbbbbbbbbbbbbbbbbb3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbb33bbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbb3bbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3bbbbbbbbbbbbbbbbbbbb3bb3bbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
66666666bbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
60000006bbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbb3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3bbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb999bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb999bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb999b9b99bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9999bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
60000006bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb60000006
66666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
60000006600000066000000660000006600000066000000660000006600000066000000660000006600000066000000660000006600000066000000660000006
77717171111111117771111177717171111111117771111177717171111111117771111177717171111111117771111111111111111111111111111111111111
77717171171111117171111177717171171111117171111171717171171111117171111171717171171111117171111111111111111111111111111111111111
71717771111111117171111171711711111111117171111177111711111111117171111177117771111111117171111111111111111111111111111111111111
71711171171111117171111171717171171111117171111171717171171111117171111171711171171111117171111111111111111111111111111111111111
71717771111111117771111171717171111111117771111177717171111111117771111177717771111111117771111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

__gff__
00000000000000000000000000000000000000000000000000000101010101000000000000000000000001010000000000000000000000000000010101010000000001010101010101010101303030309090010101010101010101019090010100000000010101010101010190900001000000000101010101010101b0b0b0b0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
6869444544454445444544454545444544454445444544454445444544454445686944454445444544454445444548490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7879545554555455545554555455545554555455545554555455545554555455787954555455545554555455545558590000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4647242525252524242425000000000024252425242524252425242524252425464700000000000000000000000066670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
565734242535355e3434350000000000343534353435343534353435343534355657005c00005c00004c0000000076770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4647613435252524252425004c00000024252425242524252425242524252425464761000000000000000000000066670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56577161343535343534354c4c4c00003435343534353435343534353435343556577161004c000000000000005c76770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
464770715c0000005c0000000000000024252425242524252425245e24252425464770715c0000005c004c00000066670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
565770707c000000000000000000000034353435343534353435343534353435000070707c00000000000000000076770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4647706c716061000000000000000000242524252425242524252425242524250000706c71606100000000005c0066670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5657707070707c00004c000000000000343534353435343534353435343534350000707070707c00004c0000000076770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4647706c707071606100000000000000242524252425242524252425242524254647706c7070716061000000000066670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56577070707070707c000000000000003435343534353435343534353435343556577070707070707c005c00000076770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
46477070706c707071606060606100002425242524252425242524252425242546477070706c7070716100004c0066670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56577070707070707070706c707c000034353435343534353435345e34353435565770707070707070716100000076770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
464770707070706c70707070707c000024252425245e242524252425252424254a4b6565656565656565656565656a6b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
565770707070707070706c70707c00005e3534353435343534353435353434355a5b7474747474747474747474747a7b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
464770706c70707070707070707c00005e5e0000000000454445444544454849686944454445444544454445444548490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
565770707070707070707070707c00005e000000000000555455545554555859787954555455545554555455545558590000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
46477070706e727272727272720000005e000000000000000000000000006667464700000000000000000000000066670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56577070707c5c0000000000000000000000005c00005c00004c0000000076775657005c00005c00004c0000000076770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4647706c707c0000000000000000000000006100000000000000000000006667464761000000000000000000000066670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56577070707c000000000000005c767756577161004c000000000000005c767756577161004c000000000000005c76770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
46477070707c00005c004c0000006667464770715c0000005c004c0000006667464770715c0000005c004c00000066670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56577070707c00000000000000007677565770707c0000000000000000007677565770707c00000000000000000076770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4647706c70716100005e00005c0066674647706c71606100000000005c0066674647706c71606100000000005c0066670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5657707070707c00004c0000000076775657707070707c00004c0000000076775657707070707c00004c0000000076770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4647706c7070716061000000000066674647706c7070716061000000000066674647706c7070716061000000000066670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56577070707070707c005c000000767756577070707070707c005c000000767756577070707070707c005c00000076770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
46477070706c7070716100004c00666746477070706c7070716100004c00666746477070706c7070716100004c0066670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5657707070707070707161000000767756577070707070707071610000007677565770707070707070716100000076770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4b6565656565656565656565656a6b4a4b6565656565656565656565656a6b4a4b6565656565656565656565656a6b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5a5b7474747474747474747474747a7b5a5b7474747474747474747474747a7b5a5b7474747474747474747474747a7b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000c0700c0700c0700b0700a07009070070600506000050070500600005000030300203002020010200001000010160001b0001a0001a0001a000100001000010000100001000010000100001100000000
011000101c55500005000051b5551c555000051e555000051f555000051e055000051b05500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
011000101c0172001723017280171f0172001723017280171c0172001723017280171c01720017230172801700007000070000700007000070000700007000070000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002000001885000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
02 01024344

