princess_body = directional_animated_sprite.pre_create_str(
	[[ 214, 10, 215, 10, 216, 10 ]], -- up
	[[ 198, 10, 199, 10, 200, 10 ]], -- down
	[[ 246, 10, 247, 10, 248, 10 ]], -- left
	[[ 230, 10, 231, 10, 232, 10 ]] -- right
);

princess_body_boosted = directional_animated_sprite.pre_create_str(
	[[ 214, 2, 215, 2, 216, 2 ]], -- up
	[[ 198, 2, 199, 2, 200, 2 ]], -- down
	[[ 246, 2, 247, 2, 248, 2 ]], -- left
	[[ 230, 2, 231, 2, 232, 2 ]] -- right
);

princess_body_dying = animated_sprite.pre_create_str([[
	 54, 15,
	 53, 7,
	 52, 7,
	 51, 15,
]]);

player = actor:new {
	NAME = 'player',

	mask = rect2(0, 0, 7, 7),
	mv = vecNil(),
	cors = {},

	initial_state = 'normal',

	create = function(...)
		local _ENV = actor.create(...)

		body = princess_body(pos)
		-- sha = shadow(pos)
		weapon = entityNil

		maxHp = 20
		hp = 20

		return _ENV
	end,

	normal = forever(function(_ENV)
		mv += io.norm
		mv = mv:cap_mag(1)

		if io.nodir then
			mv = mv * 0.95
		end

		yield()

		-- state change on io
		if io.x then yield('charging') end
		if io.o then yield('attack') end
	end),


	charging = function(_ENV)
		mv = vecNil()

		draw_co = charge_draw_co()
		local cnt = 0
		repeat
			cnt += 1
			yield()
		until not io.x or cnt > 30
		draw_co = nil


		return cnt > 30 and 'boost' or 'dash'
	end,

	attack = function(_ENV)
		local angle = io.nodir and
				mv:getAngle() or
				io.vec:getAngle()

		angle -= 0.5
		repeat
			angle += 0.5
			weapon = sword(pos, angle)
			repeat
				mv += io.norm * 0.15
				mv = mv:cap_mag(0.5)

				yield()
			until weapon.done
			weapon = entityNil;
		until not io.o

		return 'normal'
	end,

	dash = function(_ENV)
		body = princess_body_boosted(pos)
		draw_co = dash_draw_co()
		mv = io.norm * 3
		solid = false

		local cnt = 0
		repeat
			iframe = 2
			yield()
			cnt += 1
		until colided or cnt > 15 or io.o

		solid = true
		weapon = entityNil
		draw_co = nil
		body = princess_body(pos)

		return io.x and 'attack' or 'normal'
	end,

	boost = function(_ENV)
		body = princess_body_boosted(pos)

		draw_co = flash_dash_co()
		weapon = boost_sword(pos)
		repeat
			iframe = 2
			mv = (mv + (io.norm * 0.15)):normalize(3)

			yield()
		until colided or did_atk
		weapon = entityNil

		draw_co = nil
		body = princess_body(pos)
		return 'normal'
	end,

	update = function(_ENV)
		if weapon ~= entityNil then
			weapon:update(mv)

			local sw_mask = weapon:getMask()
			for _, act in inext, actors do
				atk = sw_mask:intersect(
					act.mask:offset(act.pos())
				)

				if atk == true and act.iframe == 0 then
					act:attacked(weapon)
					did_atk = true
				end
			end
		else
			did_atk = false
		end

		for _, act in inext, actors do
			if act.spike then
				dmg = testRectIntersection(
					mask:offset(pos()),
					act.mask:offset(act.pos())
				)

				if dmg then
					_ENV:attacked(
						{
							getAngle = function()
								return (act.pos - pos):getAngle() + 0.5
							end,
							getDmg = function(_ENV)
								return 1
							end,
							getMvMag = function(_ENV)
								return 1
							end
						},
						1
					)
				end
			end
		end

		actor.update(_ENV)
	end,

	knockback_exit = 'normal',

	dying = function(_ENV)
		globals.running_game = false
		body = princess_body_dying(pos)
		body:setPal(palette)
		body:yieldUntilDone()

		change_scene(gameover_scene)
	end,

	draw = function(_ENV)
		weapon:draw()
		actor.draw(_ENV)

		-- if (colided) then
		-- 	sfx(0)
		-- end
	end,
}
