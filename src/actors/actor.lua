actor = class {
	NAME = 'actor',

	-- defaults values
	mask = rect2(0, 0, 7, 7),
	mv = vecNil(),

	hp = nil,
	maxHp = nil,
	solid = true,
	spike = false,
	initial_state = 'birth',
	iframe = 0,

	create = function(self, x, y)
		local pos = vec2(x, y)

		local tbl = class.new(self, {
			pos = pos,
			body = entityNil,
			weapon = entityNil
		})

		tbl:change_state(tbl.initial_state)
		tbl.hpBar = hp_bar(tbl)

		return tbl
	end,

	input = function(_ENV)
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

	attacked = function(_ENV, atk_weapon)
		if iframe ~= 0 then return end

		iframe = 20
		hp -= atk_weapon:getDmg()
		if hp <= 0 and current_state ~= 'dying' then
			_ENV:change_state('dying')
			return
		end

		mv = vec2:fromAngle(
			atk_weapon:getAngle(),
			atk_weapon:getMvMag()
		)

		_ENV:change_state('knockback')
	end,

	knockback = function(_ENV)
		draw_co = flash_dash_co()

		weapon = entityNil
		body.invert_mv = true

		local cnt = 0
		repeat
			yield()
			cnt += 1
		until colided or cnt > 30

		body.invert_mv = false
		draw_co = nil
		body:setPal(palette)

		return knockback_exit
	end,

	draw = function(_ENV)
		if draw_co then
			draw_co(_ENV)
		end

		hpBar:draw(iframe)
		weapon:draw()
		body:draw()
	end
}
