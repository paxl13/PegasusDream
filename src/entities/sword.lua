sword_anim = splitN([[
17,10,8,0,f,f,
18,10,4,-4,f,f,
19,10,0,-8,f,f,
18,10,-4,-4,t,f,
17,10,-8,0,t,f,
18,10,-4,4,t,t,
19,10,0,8,f,t,
18,10,4,4,f,t,
]], 6)

sword = animated_sprite:new {
	NAME = 'sword',

	create = function(self, pos_vec, angle)
		local anim = {}
		local ifr = flr(angle * 8) - 2

		for n = ifr + 1, ifr + 3 do
			d(seq_tostr(sword_anim[(n % 8) + 1]))
			add(anim, sword_anim[(n % 8) + 1])
		end

		local tbl = animated_sprite.create(
			self,
			pos_vec,
			anim,
			false
		)

		return tbl
	end,

	draw = function(_ENV)
		local id, _, ox, oy, fx, fy = unpack(anim[current]);

		spr(
			id,
			pos.x + ox,
			pos.y + oy,
			1, 1,
			fx == 't', fy == 't'
		)
	end,

	getMask = function(_ENV)
		local _, ox, oy =
				unpack(sword_anim[current]);

		return rect2(
			ox, oy,
			ox + 8, oy + 8
		)
	end

	-- drawSword = function(_ENV, frame)
	-- 	local id, offset, flip_x, flip_y =
	-- 			unpack(sword_anim[flr(frame) % #sword_anim + 1]);
	-- 	local x, y = (pos + offset)()
	-- 	spr(id, x, y, 1, 1, flip_x, flip_y)
	-- end,

	-- getSwordMask = function(_ENV, frame)
	-- 	local _, offset =
	-- 			unpack(sword_anim[flr(frame) % #sword_anim + 1]);

	-- 	return rect2(
	-- 		offset.x, offset.y,
	-- 		offset.x + 8, offset.y + 8
	-- 	)
	-- end,

	-- drawBoostSword = function(_ENV)
	-- 	local angle = mv:getAngle()
	-- 	angle += 0.0625 -- 1/16
	-- 	_ENV:drawSword(flr(angle * 8))
	-- end,

	-- 	update = function(_ENV)
	-- 	end
}

boost_sword = sprite:new {
	create = function(self, pos_vec, angle)
		local anim = {}
		local ifr = flr(angle * 8) - 2

		for n = ifr + 1, ifr + 3 do
			d(seq_tostr(sword_anim[(n % 8) + 1]))
			add(anim, sword_anim[(n % 8) + 1])
		end

		local tbl = animated_sprite.create(
			self,
			pos_vec,
			anim,
			false
		)

		return tbl
	end,

	draw = function(_ENV)
		local id, _, ox, oy, fx, fy = unpack(anim[current]);

		spr(
			id,
			pos.x + ox,
			pos.y + oy,
			1, 1,
			fx == 't', fy == 't'
		)
	end,
}
