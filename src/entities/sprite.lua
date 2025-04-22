sprite = entity:new {
	NAME = 'sprite',

	create = function(self, pos_vec, tileId)
		local tbl = entity.create(self, {
			pos = pos_vec,
			id = tileId,
		}, { __call = function(s) return s.pos(); end })
		return tbl;
	end,

	draw = function(_ENV)
		if (palette) then
			-- todo do better
			pal(palette)

			spr(id, pos())
			-- todo... do better
			pal()
			palt(0, false)
			palt(11, true)
		else
			spr(id, pos())
		end
	end,

	pal_draw = function(_ENV)
		pal(palette)
		spr(id, pos())

		pal()
		palt(0, false)
		palt(11, true)
	end,

	setPal = function(_ENV, p)
		-- todo: get taht working
		-- draw = pal_draw -- overwrite normal draw
		palette = p
	end,

	update = function()
	end,

	getMask = function()
	end,
}

animated_sprite = sprite:new {
	NAME = 'animated_sprite',
	anim = {},
	anim_data = {},

	fr_ctr = 0,
	current = 0,
	done = false,

	create = function(self, pos_vec, anim_table, loop)
		local tbl = sprite.create(self, pos_vec, nil)

		tbl.anim = anim_table;
		tbl.loop = loop or false
		self.next(tbl)

		return tbl
	end,

	update = function(_ENV)
		fr_ctr += 1;
		if fr_ctr > fr_n then
			next(_ENV)
			fr_ctr = 0
		end
	end,

	next = function(_ENV)
		current += 1
		if current > #anim then
			current = loop and 1 or #anim
			done = true
			-- _ENV:destroy()
		end
		data = anim[current]
		id, fr_n = unpack(data, 1, 2)
	end,

	yieldUntilDone = function(_ENV)
		repeat
			yield()
		until done
	end
}

directional_animated_sprite = animated_sprite:new {
	NAME = 'directional_animated_sprite',

	invert_mv = false,

	create = function(self, pos_vec, up_anim, down_anim, left_anim, right_anim)
		local tbl = animated_sprite.create(self, pos_vec, right_anim, true)

		tbl.up_anim = up_anim
		tbl.down_anim = down_anim
		tbl.right_anim = right_anim
		tbl.left_anim = left_anim

		tbl.current_dir = 'right'

		return tbl
	end,

	update = function(_ENV, mv)
		local angle = mv:getAngle()

		if invert_mv then
			angle = abs(angle - 0.5)
		end


		function changeIf(dir, tbl)
			if current_dir != dir then
				current_dir = dir
				anim = tbl

				current = 0
				_ENV:next()
			end
		end

		if mv:sq_len() > 0.01 then
			if inrng(angle, 0.125, 0.375) then
				changeIf('up', up_anim)
			elseif inrng(angle, 0.375, 0.625) then
				changeIf('left', left_anim)
			elseif inrng(angle, 0.625, 0.875) then
				changeIf('down', down_anim)
			else
				changeIf('right', right_anim)
			end

			-- only update the animation if the sprite is moving.
			animated_sprite.update(_ENV)
		end
	end,
}

animated_sprite.pre_create_str = function(anim_s, loop)
	local anim = split2(anim_s)
	return function(pos)
		return animated_sprite(pos, anim, loop)
	end
end

directional_animated_sprite.pre_create_str = function(
		up_anim_s, down_anim_s, left_anim_s, right_anim_s
)
	local up_anim = split2(up_anim_s)
	local down_anim = split2(down_anim_s)
	local left_anim = split2(left_anim_s)
	local right_anim = split2(right_anim_s)

	return function(pos)
		return directional_animated_sprite(pos, up_anim, down_anim, left_anim, right_anim)
	end
end
