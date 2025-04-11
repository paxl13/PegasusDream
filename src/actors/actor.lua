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
		if DEBUG_PRINT then
			d('actor: ' .. NAME .. 'in state: ' .. current_state)
		end

		local ns = resume(state_co, _ENV)
		if ns then
			_ENV:change_state(ns)
		end
	end,

	change_state = function(self, name)
		local state_fn = self[name];
		d(self)
		self.state_co = cocreate(state_fn)
		self.current_state = name
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
		-- delIf(cors, function(t) return t.name == 'blink_red' end)
		-- add(cors, _ENV:start_state('blink_red'))
	end,

	draw = function(_ENV)
		body:draw()
	end
}
