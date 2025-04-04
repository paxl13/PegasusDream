knight = actor:new {
	NAME = 'knight',
	tileId = 48,

	behavior = function(_ENV)
		return _ENV:wander()
	end,

	wander = function(_ENV)
		repeat
			every(2 * FPS, function()
				mv = vec2:random(0.2)
			end)

			yield()
		until (player.pos - pos):sq_len() < 20 * 20

		return follow
	end,

	dash = function(_ENV)
		mv = vecNil
		wait_internal(1 * FPS)

		mv = toward_player(_ENV, 3)
		wait_internal(0.5 * FPS)

		mv = vecNil
		wait_internal(1 * FPS)

		return wander
	end,

	follow = function(_ENV)
		repeat
			mv = toward_player(_ENV, 0.5)
			yield()
		until #(player.pos - pos) > 40

		return dash
	end
}
