cloud = actor:new {
	NAME = 'Cloud',
	initial_state = 'normal',

	create = function(...)
		local _ENV = actor.create(...)
		palette = { [9] = flr(rnd(16)) }
		maxHp = 10
		hp = 10
		body = cloud_body(pos)
		return _ENV
	end,

	normal = forever(function(_ENV)
		onceEvery(flr(5 + rnd(5)), function()
			mv += vec2:random(0.25)
			mv = mv:normalize(0.5)
		end)

		yield()
	end),
}
