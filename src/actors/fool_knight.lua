birth_sprite = animated_sprite.pre_create({
	{ 38, 15 },
	{ 39, 7 },
	{ 40, 7 },
	{ 41, 15 },
}, false);

fool_idle = animated_sprite.pre_create({
	{ 49, 30 },
	{ 35, 30 },
}, true);

fool_knight = actor:new {
	NAME = 'Fool_Knight',
	tileId = 49,
	initial_state = 'birth',

	birth = function(_ENV)
		body = birth_sprite(pos)
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

		body = animated_sprite(pos, {
			{ 41, 15 },
			{ 40, 7 },
			{ 39, 7 },
			{ 38, 60 },
		})

		yieldUntil(function() return body.done end)
		del(actors, _ENV)
	end)
}
