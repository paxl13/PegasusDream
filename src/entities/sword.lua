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


sprite_extension = {
	draw = function(_ENV)
		local id, _, ox, oy, fx, fy = unpack(data)

		spr(
			id,
			pos.x + ox,
			pos.y + oy,
			1, 1,
			fx == 't', fy == 't'
		)
	end
}

sword_mask = {
	getMask = function(_ENV)
		local ox, oy = unpack(data, 3, 4)

		return rect2(
			ox, oy,
			ox + 8, oy + 8
		)
	end,
	getAngle = function(_ENV)
		return data[7]
	end
}

sword = animated_sprite:new {
	NAME = 'sword',

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

		tbl:include(sprite_extension)
		tbl:include(sword_mask)

		return tbl
	end,

}

boost_sword = entity {
	NAME = 'boost_sword',

	create = function(self, pos_vec)
		local tbl = entity.create(self, { pos = pos_vec });
		tbl:include(sprite_extension)
		tbl:include(sword_mask)
		return tbl
	end,

	update = function(_ENV, mv)
		local angle = mv:getAngle() + 0.0625
		data = sword_anim_data[flr(angle * 8) % 8 + 1];
	end,
}
