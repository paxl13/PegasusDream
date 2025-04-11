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

	sword_anim = {
		{ 17, vec2(8, 0),   false, false },
		{ 18, vec2(4, -4),  false, false },
		{ 19, vec2(0, -8),  false, false },
		{ 18, vec2(-4, -4), true,  false },
		{ 17, vec2(-8, 0),  true,  false },
		{ 18, vec2(-4, 4),  true,  true },
		{ 19, vec2(0, 8),   false, true },
		{ 18, vec2(4, 4),   false, true },
	},

	initialize = function(_ENV)
		pos = vec2(64, 64)
		body = princess_body(pos)

		sword = entityNil

		_ENV:change_state('normal')
		status = 'normal'
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
		status = 'charging'
		mv = vecNil()

		local cnt = 0
		repeat
			cnt += 1
			yield()
		until not io.x or cnt > 60

		status = 'normal'
		return cnt > 60 and 'boost' or 'normal'
	end,

	attack = function(_ENV)
		status = 'attack'

		local angle = atan2(io.vec())
		local initial_fr = flr(angle * 8) - 2

		atk_fr = initial_fr;
		repeat
			mv += io.norm * 0.15

			if (mv:sq_len() > 0.5 * 0.5) then
				mv = mv:normalize(0.5)
			end

			atk_fr += 0.3
			yield()
		until atk_fr >= initial_fr + 4 + 0.3

		status = 'normal'
		return 'normal'
	end,

	boost = function(_ENV)
		status = 'boost'
		body = princess_body_boosted(pos)
		repeat
			mv = (mv + (io.norm * 0.15)):normalize(3)
			yield()
		until colided

		body = princess_body(pos)
		status = 'normal'
		return 'normal'
	end,

	update = function(_ENV)
		if status == 'charging' then
			boostFrames += 1
		else
			boostFrames = 0
		end
		if status == 'attack' or status == 'boost' then
			sw_mask = _ENV:getSwordMask(atk_fr):offset(pos())
			for act in all(actors) do
				if not act.was_hit then
					local has_hit = testRectIntersection(sw_mask, act.mask:offset(act.pos()))
					if has_hit then
						act:attacked()
						-- act.health -= 1
						-- if act.health <= 0 then
						-- 	del(actors, act)
						-- else
						-- -- act.mv *= -1
						-- d('act mv:'..tostr(act.mv))
						-- act.mv:add((mv:normalize(3))())
						-- d('modified act mv:'..tostr(act.mv))
						-- act.was_hit=true;
						-- end
					end
				end
			end
		end

		sword:update()
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

	-- sword helpers.
	drawBoostSword = function(_ENV)
		local angle = mv:getAngle()
		angle += 0.0625 -- 1/16
		_ENV:drawSword(flr(angle * 8))
	end,

	drawSword = function(_ENV, frame)
		local id, offset, flip_x, flip_y =
				unpack(sword_anim[flr(frame) % #sword_anim + 1]);
		local x, y = (pos + offset)()
		spr(id, x, y, 1, 1, flip_x, flip_y)
	end,

	getSwordMask = function(_ENV, frame)
		local _, offset =
				unpack(sword_anim[flr(frame) % #sword_anim + 1]);

		return rect2(
			offset.x, offset.y,
			offset.x + 8, offset.y + 8
		)
	end,

	draw = function(_ENV)
		-- handle pegasus arrow
		if status == 'charging' then
			_ENV:drawArrow()
		end

		if status == 'attack' then
			_ENV:drawSword(atk_fr)
		end

		if status == 'boost' then
			_ENV:drawBoostSword()
		end

		sword:draw()
		actor.draw(_ENV)


		if (colided) then
			sfx(0)
		end
	end,
}
