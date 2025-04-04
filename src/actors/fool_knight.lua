fool_knight = actor:new {
	NAME = 'Fool_Knight',
	tileId = 49,

	behavior = function(_ENV)
		return _ENV:wander()
	end,

	wander = function(_ENV)
		repeat
			every(flr(5 + rnd(5)), function()
				mv += vec2:random(0.25)
				mv = mv:normalize(0.5)
			end)

			yield()
		until false
	end
}
