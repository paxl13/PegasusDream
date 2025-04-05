knight = actor:new {
	NAME = 'knight',
	tileId = 48,

	initial_state = 'wander',

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
		repeat
			mv = vecDown() * 0.25
			wait_internal(.5 * FPS)
			del(actors, _ENV)
		until false
	end
}
