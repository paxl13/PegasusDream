fool_knight = actor:new {
	NAME = 'Fool_Knight',
	tileId = 49,
	initial_state = 'birth',

	birth = function(_ENV)
		body = animated_sprite(pos, {
			{ 38, 15 },
			{ 39, 7 },
			{ 40, 7 },
			{ 41, 15 },
		})

		yieldUntil(function() return body.done end)

		body = sprite(pos, tileId)
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
