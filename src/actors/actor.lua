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
			cors = {}
		})
		add(tbl.cors, tbl:start_state(tbl.initial_state))

		return tbl
	end,

	input = function(_ENV)
		if DEBUG_PRINT then
			d('actor: ' .. NAME)
			foreach(cors, function(co)
				d('co: -- ' .. co.name)
			end)
			d('------------------')
		end

		foreach(cors, function(co)
			local new_states = resume(co.fn, _ENV)

			if (new_states) then
				del(cors, co);

				local states = type(new_states) == 'table' and new_states or { new_states }
				foreach(states, function(state)
					add(cors, _ENV:start_state(state))
				end)
			end
		end)
	end,

	start_state = function(_ENV, name)
		local state_fn = _ENV[name];
		return { name = name, fn = cocreate(state_fn) }
	end,

	update = function(_ENV)
		mv, colided = process_map_colision(
			mask:offset(pos()),
			mv
		)

		body:update(mv)
		pos:add(mv())
	end,

	attacked = function(_ENV)
		d('attacked')
		delIf(cors, function(t) return t.name == 'blink_red' end)
		add(cors, _ENV:start_state('blink_red'))
	end,

	draw = function(_ENV)
		body:draw()
	end
}
