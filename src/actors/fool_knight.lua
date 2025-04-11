fool_birth_sprite = animated_sprite.pre_create_str([[
	 35, 15,
	 36, 7,
	 37, 7,
	 38, 15,
]], false);

fool_dying_sprite = animated_sprite.pre_create_str([[
	 38, 15,
	 37, 7,
	 36, 7,
	 35, 15,
]], false);

fool_body = animated_sprite.pre_create_str([[
	32, 30,
	33, 30,
]], true);

fool_knight = actor:new {
	NAME = 'Fool_Knight',
	tileId = 49,
	initial_state = 'birth',

	create = function(...)
		local tbl = actor.create(...)
		tbl.palette = {
			[9] = flr(rnd(16)),
		}
		return tbl
	end,

	-- palette_fun = forever(function(_ENV)
	-- 	onceEvery(30, function()
	-- 		body:setPal({
	-- 			[9] = flr(rnd(16)),
	-- 		})
	-- 	end)

	-- 	yield()
	-- end),

	blink_red = forever(function(_ENV)
		body:setPal({ [9] = 8 })
		wait_internal(30)
		body:setPal(palette)
		wait_internal(30)

		return {}
	end),

	birth = function(_ENV)
		body = fool_birth_sprite(pos)
		body:setPal(palette)
		body:yieldUntilDone()

		body = fool_body(pos, mv)
		body:setPal(palette)
		return { 'wander' }
	end,

	wander = forever(function(_ENV)
		onceEvery(flr(5 + rnd(5)), function()
			mv += vec2:random(0.25)
			mv = mv:normalize(0.5)
		end)

		yield()
	end),

	dying = forever(function(_ENV)
		mv = vecUp() * 0.25

		body = fool_dying_sprite(pos)
		body:setPal(palette)
		body:yieldUntilDone()

		del(actors, _ENV)
	end)
}
