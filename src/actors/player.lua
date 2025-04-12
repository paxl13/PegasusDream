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
		return tbl
	end,

	normal = forever(function(_ENV)
		mv += io.norm

		if (mv:sq_len() > 1) then
			mv = mv:normalize()
		end

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

		local cnt = 0
		repeat
			cnt += 1
			yield()
		until not io.x or cnt > 60

		return cnt > 60 and 'boost' or 'normal'
	end,

	attack = function(_ENV)
		local angle = atan2(io.vec())
		weapon = sword(pos, angle)

		repeat
			mv += io.norm * 0.15

			if (mv:sq_len() > 0.5 * 0.5) then
				mv = mv:normalize(0.5)
			end
			yield()
		until weapon.done

		weapon = entityNil;

		return 'normal'
	end,

	boost = function(_ENV)
		body = princess_body_boosted(pos)
		repeat
			mv = (mv + (io.norm * 0.15)):normalize(3)
			yield()
		until colided

		body = princess_body(pos)
		return 'normal'
	end,

	update = function(_ENV)
		if current_state == 'charging' then
			boostFrames += 1
		else
			boostFrames = 0
		end

		-- if current_state == 'attack' or current_state == 'boost' then
		-- 	sw_mask = _ENV:getSwordMask(atk_fr):offset(pos())
		-- 	for act in all(actors) do
		-- 		if not act.was_hit then
		-- 			local has_hit = testRectIntersection(sw_mask, act.mask:offset(act.pos()))
		-- 			if has_hit then
		-- 				act:attacked()
		-- 				-- act.health -= 1
		-- 				-- if act.health <= 0 then
		-- 				-- 	del(actors, act)
		-- 				-- else
		-- 				-- -- act.mv *= -1
		-- 				-- d('act mv:'..tostr(act.mv))
		-- 				-- act.mv:add((mv:normalize(3))())
		-- 				-- d('modified act mv:'..tostr(act.mv))
		-- 				-- act.was_hit=true;
		-- 				-- end
		-- 			end
		-- 		end
		-- 	end
		-- end

		weapon:update()
		actor.update(_ENV)
	end,

	drawArrow = function(_ENV)
		local x, y = pos()
		local mult = 1 + boostFrames / 20
		local sx = 8 * mult

		local acol = {
			10,
			9,
			8
		}
		local col = acol[flr(mult)]

		pal(9, col)
		if (io.vec.y ~= 0) then
			sspr(
				32, 8,
				7, 7,
				(x + 4) - (sx / 2), (y + 4) - (sx / 2),
				sx, sx,
				false, io.vec.y > 0
			)
		else
			sspr(
				40, 8,
				7, 7,
				(x + 4) - (sx / 2), (y + 4) - (sx / 2),
				sx, sx,
				io.vec.x > 0, false
			)
		end
		pal(9, 9)
	end,

	draw = function(_ENV)
		if current_state == 'charging' then
			_ENV:drawArrow()
		end

		weapon:draw()
		actor.draw(_ENV)

		if (colided) then
			sfx(0)
		end
	end,
}
