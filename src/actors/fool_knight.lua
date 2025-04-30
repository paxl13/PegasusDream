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

	create = function(...)
		local _ENV = actor.create(...)

		palette = { [9] = flr(rnd(16)) }
		maxHp = flr(rnd(5) + 1)
		hp = maxHp
		spike = true

		return _ENV
	end,

	birth = function(_ENV)
		body = fool_birth_sprite(pos)
		body:setPal(palette)
		body:yieldUntilDone()

		body = fool_body(pos, mv)
		body:setPal(palette)
		return 'wander'
	end,

	wander = forever(function(_ENV)
		onceEvery(flr(5 + rnd(5)), function()
			mv += vec2:random(0.25)
			mv = mv:normalize(0.5)
		end)

		yield()
	end),

	knockback_exit = 'wander',

	dying = forever(function(_ENV)
		spike = false
		solid = false

		body = fool_dying_sprite(pos)
		body:setPal(palette)
		body:yieldUntilDone()

		del(actors, _ENV)
	end)
}
