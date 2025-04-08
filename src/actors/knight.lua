knight_birth_sprite = animated_sprite.pre_create_str([[
	 51, 15,
	 52, 7,
	 53, 7,
	 54, 15,
]]);

knight_dying_sprite = animated_sprite.pre_create_str([[
	 54, 15,
	 53, 7,
	 52, 7,
	 51, 15,
]]);

knight_idle = animated_sprite.pre_create_str([[
	48, 30,
	49, 30,
]], true);

knight = actor:new {
	NAME = 'knight',
	tileId = 48,

	initial_state = 'birth',

	birth = function(_ENV)
		body = knight_birth_sprite(pos)
		body:yeildUntilDone()

		body = knight_idle(pos)
		return 'wander'
	end,

	wander = function(_ENV)
		repeat
			onceEvery(2 * FPS, function()
				mv = vec2:random(0.2)
			end)

			yield()
		until (player.pos - pos):sq_len() < 20 * 20

		return 'follow'
	end,

	dash = function(_ENV)
		mv = vecNil()
		wait_internal(1 * FPS)

		mv = toward_player(_ENV, 3)
		wait_internal(0.5 * FPS)

		mv = vecNil()
		wait_internal(1 * FPS)

		return 'wander'
	end,

	follow = function(_ENV)
		repeat
			mv = toward_player(_ENV, 0.5)
			yield()
		until #(player.pos - pos) > 40

		return 'dash'
	end,

	dying = function(_ENV)
		mv = vecUp() * 0.25

		body = knight_dying_sprite(pos)
		body:yeildUntilDone()

		del(actors, _ENV)
	end
}
