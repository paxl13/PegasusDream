slime = actor:new {
	NAME = 'slime',
	tileId = 50,

	behavior = pipe_({
		set_('speed', function() return 0.2 + rnd(0.8) end),
		moveToward(1, 0, 0.5 * FPS),
		moveToward(0, -1, 0.5 * FPS),
		moveToward(-1, 0, 0.5 * FPS),
		moveToward(0, 1, 0.5 * FPS),

		set_('mv', toward_player),
		untilMapCollision_,
		wait_(1 * FPS),
	}),
}

function trackPlayer(n)
	return function(self)
		local nbr_f = n
		repeat
			self.mv = toward_player(self)
			nbr_f -= 1
			yield()
		until (nbr_f == 0)
	end
end

p_knight = actor:new {
	NAME = 'Pegasus_Knight',
	tileId = 51,

	behavior = pipe_({
		set_('speed', 0.2),
		trackPlayer(5 * FPS, 0.2),

		set_('mv', vec2(0, 0)),
		wait_(3 * FPS),
		set_('speed', 3),
		set_('mv', toward_player),
		untilMapCollision_,
		set_('speed', 1),
		wait_(1 * FPS)
	}),
}
