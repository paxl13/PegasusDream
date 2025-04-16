knight_birth_sprite = animated_sprite.pre_create_str([[
	 51, 15,
	 52, 7,
	 53, 7,
	 54, 15,
]]);

knight_dying_sprite = animated_sprite.pre_create_str([[
	 54, 15,
	 53, 7,
	 52, 7,
	 51, 15,
]]);

knight_body = directional_animated_sprite.pre_create_str(
	[[ 217, 10, 218, 10, 219, 10 ]], -- up
	[[ 201, 10, 202, 10, 203, 10 ]], -- down
	[[ 249, 10, 250, 10, 251, 10 ]], -- left
	[[ 233, 10, 234, 10, 235, 10 ]] -- right
);

knight = actor:new {
	NAME = 'knight',
	tileId = 48,

	initial_state = 'birth',

	create = function(...)
		local _ENV = actor.create(...)
		palette = { [12] = flr(rnd(16)) }
		weapon = entityNil
		return _ENV
	end,

	update = function(_ENV)
		if weapon:isNotNil() then
			weapon:update(mv)

			local atk = testRectIntersection(
				weapon:getMask():offset(pos()),
				hero.mask:offset(hero.pos())
			)

			if atk == true then
				hero:attacked(weapon:getAngle())
			end
		end

		actor.update(_ENV)
	end,

	draw = function(_ENV)
		weapon:draw()
		actor.draw(_ENV)
	end,

	birth = function(_ENV)
		body = knight_birth_sprite(pos)
		body:setPal(palette)

		body:yieldUntilDone()

		body = knight_body(pos)
		body:setPal(palette)
		return 'wander'
	end,

	wander = function(_ENV)
		repeat
			onceEvery(2 * FPS, function()
				mv = vec2:random(0.2)
			end)

			yield()
		until (hero.pos - pos):sq_len() < 20 * 20

		return 'follow'
	end,

	dash = function(_ENV)
		mv = vecNil()
		wait_internal(1 * FPS)

		mv = toward_player(_ENV, 3)
		wait_internal(0.5 * FPS)

		mv = vecNil()
		wait_internal(1 * FPS)

		return 'wander'
	end,

	follow = function(_ENV)
		repeat
			mv = toward_player(_ENV, 0.5)

			yield()
		until #(hero.pos - pos) < 16

		return 'attack'
	end,

	attack = function(_ENV)
		weapon = sword(pos, toward_player(_ENV):getAngle())

		weapon:yieldUntilDone()
		weapon = entityNil

		return 'wander'
	end,

	touched = function(_ENV)
		mv = vec2:fromAngle(atk_angle, 0.75)
		local cnt = 0
		repeat
			yield()
			cnt += 1
		until colided or cnt > 60

		return 'wander'
	end,

	dying = function(_ENV)
		mv = vecUp() * 0.25

		body = knight_dying_sprite(pos)
		body:setPal(palette)
		body:yieldUntilDone()

		del(actors, _ENV)
	end
}
