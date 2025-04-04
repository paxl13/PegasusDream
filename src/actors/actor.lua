actor = class {
	NAME = 'actor',

	-- defaults values
	tileId = 0,
	speed = 0,
	mask = rect2(0, 0, 7, 7),
	mv = vec2(0, 0),
	health = 1,
	was_hit = false,

	create = function(self, x, y)
		local pos = vec2(x, y)

		local tbl = class.new(self, {
			pos = pos,
			body = sprite(pos, self.tileId),
			co_behavior = self.behavior and cocreate(self.behavior) or nil
		})

		return tbl
	end,

	input = function(_ENV)
		-- if costatus(co_behavior) == 'dead' then
		-- 	co_behavior=cocreate(behavior)
		-- end
		local new_state = resume(co_behavior, _ENV)
		if new_state then
			co_behavior = cocreate(new_state)
		end

		-- if(mv != old_mv or speed != old_speed) then
		-- 	mv=mv:normalize()*speed
		-- end

		-- old_mv=vec2(mv)
		-- old_speed=speed
	end,

	update = function(_ENV)
		mv, colided = process_map_colision(
			mask:offset(pos()),
			mv
		)

		pos:add(mv())
	end,

	draw = function(_ENV)
		body:draw()
	end
}
