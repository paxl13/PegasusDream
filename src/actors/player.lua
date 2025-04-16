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

player = actor:new {
	NAME = 'player',

	mask = rect2(0, 0, 7, 7),
	mv = vecNil(),
	cors = {},

	initial_state = 'normal',

	create = function(...)
		local tbl = actor.create(...)
		tbl.body = princess_body(tbl.pos)
		tbl.weapon = entityNil
		tbl.boost_arrow = entityNil
		return tbl
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

		boost_arrow = arrow(pos)
		local cnt = 0
		repeat
			cnt += 1
			yield()
		until not io.x or cnt > 30
		boost_arrow = entityNil

		return cnt > 30 and 'boost' or 'normal'
	end,

	attack = function(_ENV)
		local angle = io.vec:getAngle()

		weapon = sword(pos, angle)
		repeat
			mv += io.norm * 0.15
			mv = mv:cap_mag(0.5)

			yield()
		until weapon.done
		weapon = entityNil;

		return 'normal'
	end,

	boost = function(_ENV)
		body = princess_body_boosted(pos)

		weapon = boost_sword(pos)
		repeat
			mv = (mv + (io.norm * 0.15)):normalize(3)

			yield()
			debugPrint(atk)
		until colided or did_atk
		weapon = entityNil

		body = princess_body(pos)
		return 'normal'
	end,

	update = function(_ENV)
		if weapon != entityNil then
			weapon:update(mv)

			sw_mask = weapon:getMask():offset(pos())
			for act in all(actors) do
				atk = testRectIntersection(
					sw_mask,
					act.mask:offset(act.pos())
				)

				if atk == true then
					act:attacked(weapon:getAngle())
					did_atk = true
				end
			end
		else
			did_atk = false
			sw_mask = nil
		end

		boost_arrow:update(mv)
		actor.update(_ENV)
	end,

	touched = function(_ENV)
		mv = vec2:fromAngle(atk_angle, 0.75)
		local cnt = 0
		repeat
			yield()
			cnt += 1
		until colided or cnt > 60

		return 'normal'
	end,

	draw = function(_ENV)
		boost_arrow:draw()
		weapon:draw()

		if sw_mask then
			color(9)
			rect(sw_mask())
			color(7)
		end

		actor.draw(_ENV)

		if (colided) then
			sfx(0)
		end
	end,
}
