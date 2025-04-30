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

charge_draw_co = cofunc(function(_ENV)
	local cnt = 0
	while true do
		cnt += 1

		if cnt > 5 then
			local center = pos + vec2(4, 4)
			local angle = 0.25 - cnt / 30

			circ(center.x, center.y, 8, 0)

			for a = 0.25, angle, -0.01 do
				local endOfLine = vec2:fromAngle(a, 9) + center
				line(center.x, center.y, endOfLine.x, endOfLine.y, 9)
			end
		end

		yield()
	end
end)
