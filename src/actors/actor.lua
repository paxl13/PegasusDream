actor = class {
	NAME = 'actor',

	-- defaults values
	tileId = 0,
	mask = rect2(0, 0, 7, 7),
	mv = vecNil(),
	health = 1,
	was_hit = false,

	create = function(self, x, y)
		local pos = vec2(x, y)

		local tbl = class.new(self, {
			pos = pos,
			body = sprite(pos, self.tileId),
		})
		tbl:change_state(tbl.initial_state)

		return tbl
	end,

	input = function(_ENV)
		local new_state = resume(state_co, _ENV)

		if new_state then
			change_state(_ENV, new_state)
		end
	end,

	change_state = function(_ENV, state_name)
		local state_fn = _ENV[state_name];
		state_co = cocreate(state_fn)
		current_state = state_name
	end,

	update = function(_ENV)
		mv, colided = process_map_colision(
			mask:offset(pos()),
			mv
		)

		body:update(pos, mv)
		pos:add(mv())
	end,

	attacked = function(_ENV)
		change_state(_ENV, 'dying')
	end,

	draw = function(_ENV)
		body:draw()
	end
}
