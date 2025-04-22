actor = class {
	NAME = 'actor',

	-- defaults values
	mask = rect2(0, 0, 7, 7),
	mv = vecNil(),

	hp = nil,
	maxHp = nil,
	solid = true,
	spike = false,
	iframe = 0,

	create = function(self, x, y)
		local pos = vec2(x, y)

		local tbl = class.new(self, {
			pos = pos,
			body = entityNil
		})
		tbl:include(defaults_actor_mixin)

		tbl:change_state(tbl.initial_state)
		tbl.hpBar = hp_bar(tbl)

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
		self.state_co = cocreate(state_fn)
		self.current_state = name
	end,

	update = function(_ENV)
		mv, colided = process_map_colision(
			mask:offset(pos()),
			mv
		)

		if iframe ~= 0 then
			iframe -= 1
		end

		body:update(mv)
		pos:add(mv())
	end,

	attacked = function(_ENV, angle, dmg)
		if iframe == 0 then
			iframe = 20

			debugPrint(_ENV.name, ' ', hp, ' ', dmg)
			hp -= dmg
			if hp <= 0 then
				debugPrint(_ENV.NAME, hp);
				_ENV:change_state('dying')
			elseif knockback then
				atk_angle = angle
				_ENV:change_state('knockback')
			end
		end
	end,

	draw = function(_ENV)
		if draw_co then
			draw_co(_ENV)
		end

		hpBar:draw()
		body:draw()
	end
}

defaults_actor_mixin = {
	knockback = function(_ENV)
		draw_co = flash_dash_co()

		mv = vec2:fromAngle(atk_angle, 0.75)
		weapon = entityNil
		body.invert_mv = true

		local cnt = 0
		repeat
			yield()
			cnt += 1
		until colided or cnt > 60

		body.invert_mv = false
		draw_co = nil
		body:setPal(palette)

		return knockback_exit
	end,
}

white_draw_co = cofunc(forever(function(_ENV)
	body:setPal(split([[
		7, 7, 7, 7,
		7, 7, 7, 7,
		7, 7, 7, 7,
		7, 7, 7, 7
	]]))
	wait_internal(4)
	body:setPal(palette)
	wait_internal(4)
end))

dash_draw_co = cofunc(function(act)
	local part = {}

	repeat
		onceEvery(3, function()
			add(part, {
				pos = vec2(act.pos):add(4, 4),
				mv = vec2:random(1),
				life = 10
			})
		end)

		foreach(part, function(s)
			if inrng(s.life, 1, 9) then
				local c = pget(s.pos())

				circfill(
					s.pos.x,
					s.pos.y,
					s.life / 2,
					c > 8 and c - 8 or 0
				)
				s.pos:add(s.mv())
			elseif s.life <= 0 then
				del(part, s)
			end

			s.life -= 0.5
		end)

		yield()
	until false
end)

flash_dash_co = cofunc2(
	dash_draw_co,
	white_draw_co
)
