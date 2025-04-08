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

fool_idle = animated_sprite.pre_create_str([[
	 32, 30,
	 33, 30,
]], true);

fool_knight = actor:new {
	NAME = 'Fool_Knight',
	tileId = 49,
	initial_state = 'birth',

	birth = function(_ENV)
		body = fool_birth_sprite(pos)
		body:yeildUntilDone()

		body = fool_idle(pos)
		return 'wander'
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
		body:yeildUntilDone()

		del(actors, _ENV)
	end)
}
