sword_anim_data = splitN([[
17,10,8,0,f,f,0,
18,10,4,-4,f,f,0.125,
19,10,0,-8,f,f,0.250,
18,10,-4,-4,t,f,0.375,
17,10,-8,0,t,f,0.500,
18,10,-4,4,t,t,0.625,
19,10,0,8,f,t,0.750,
18,10,4,4,f,t,0.875,
]], 7)

sword_anim_speed = split([[
	8, 5, 4, 2, 1, 1, 1, 1
]])


sword_extension = {
	draw = function(_ENV)
		local id, _, ox, oy, fx, fy = unpack(data)

		spr(
			id,
			pos.x + ox,
			pos.y + oy,
			1, 1,
			fx == 't', fy == 't'
		)
	end,

	getMask = function(_ENV)
		local ox, oy = unpack(data, 3, 4)

		return rect2(
			pos.x + ox, pos.y + oy,
			8, 8
		)
	end,

	getAngle = function(_ENV)
		return data[7]
	end,

	getDmg = function(_ENV)
		return flr(rnd(rndDmg) + minDmg)
	end,

	getMvMag = function(_ENV)
		return rnd(rndMag) + minMag
	end
}

sword = animated_sprite:new {
	NAME = 'sword',

	minDmg = _SWORD_MIN_DMG,
	maxDmg = _SWORD_RND_DMG,
	minMag = 0.25,
	rndMag = 0.75,

	create = function(self, pos_vec, angle, speed)
		speed = speed or 1
		local anim = {}
		local afr = flr(angle * 8)

		for n = afr - 2, afr + 2 do
			local fr = clone(sword_anim_data[(n % 8) + 1])
			fr[2] = sword_anim_speed[n - afr + 3] * speed

			add(anim, fr)
			-- add(anim, sword_anim_data[(n % 8) + 1])
		end

		local tbl = animated_sprite.create(
			self,
			pos_vec,
			anim,
			false
		)

		tbl:include(sword_extension)

		return tbl
	end,

}

boost_sword = entity {
	NAME = 'boost_sword',

	minDmg = _BOOST_MIN_DMG,
	rndDmg = _BOOST_RND_DMG,
	minMag = 1,
	rndMag = 2,

	create = function(self, pos_vec)
		local tbl = entity.create(self, { pos = pos_vec });

		tbl:include(sword_extension)

		return tbl
	end,

	update = function(_ENV, mv)
		local angle = mv:getAngle() + 0.0625
		data = sword_anim_data[flr(angle * 8) % 8 + 1];
	end,
}
