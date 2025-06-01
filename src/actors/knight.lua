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

	create = function(...)
		local _ENV = actor.create(...)

		palette = { [12] = flr(rnd(16)) }
		maxHp = flr(rnd(_KNIGHT_HP) + 1)
		hp = maxHp

		return _ENV
	end,

	update = function(_ENV)
		if weapon:isNotNil() then
			weapon:update(mv)

			local atk = weapon:getMask():intersect(
				hero.mask:offset(hero.pos())
			)

			if atk == true and hero.iframe == 0 then
				hero:attacked(weapon)
			end
		end

		actor.update(_ENV)
	end,

	birth = function(_ENV)
		yieldFor(flr(rnd(_DELAY_BIRTH)))

		body = knight_birth_sprite(pos)
		body:setPal(palette)
		body:yieldUntilDone()

		body = knight_body(pos)
		body:setPal(palette)
		return 'wander'
	end,

	wander = function(_ENV)
		repeat
			onceEvery(2 * _FPS, function()
				mv = vec2:random(0.2)
			end)

			yield()
		until #(hero.pos - pos) < 20

		return 'follow'
	end,

	dash = function(_ENV)
		mv = vecNil()
		yieldFor(1 * _FPS)

		mv = toward_player(_ENV, 3)
		yieldFor(0.5 * _FPS)

		mv = vecNil()
		yieldFor(1 * _FPS)

		return 'wander'
	end,

	follow = function(_ENV)
		repeat
			mv = toward_player(_ENV, 0.5)

			yield()
		until #(hero.pos - pos) > 12

		return 'attack'
	end,

	attack = function(_ENV)
		weapon = sword(pos, toward_player(_ENV):getAngle(), 3)

		weapon:yieldUntilDone()
		weapon = entityNil

		return 'wander'
	end,

	knockback_exit = 'wander',

	dying = function(_ENV)
		weapon = entityNil
		solid = false

		body = knight_dying_sprite(pos)
		body:setPal(palette)
		body:yieldUntilDone()

		del(actors, _ENV)
	end
}
