if DEBUG then
	sysDisp = ''
	meDisp = ''

	function displayOverlay(a)
		if _OVERLAY then
			color(9)
			local r = a.mask:offset(a.pos())
			rect(r())
			color(7)

			-- display mv
			local pos = a.pos + vec2(3, 3);
			local zz = pos + (a.mv * 20);
			line(pos.x, pos.y, zz.x, zz.y)
		end
	end

	points = class({
		pt = {},

		add = function(_ENV, x, y, c, l, r)
			add(
				points.pt,
				{ x = x, y = y, c = c, l = l, r = r or 1 }
			)
		end,

		update = function(_ENV)
			for v in all(pt) do
				v.l -= 1
				if (v.l <= 0) then
					del(pt, v)
				end
			end
		end,

		draw = function(_ENV)
			foreach(pt, function(p)
				if (p.r > 1) then
					circfill(p.x, p.y, p.r, p.c)
				else
					pset(p.x, p.y, p.c)
				end
			end)
		end,
	})

	hud = class({
		baseY = 128 - 7,
		data = {},
		order = {},

		set = function(_ENV, key, val)
			if not val then
				del(data, key)
				del(order, key)
			else
				if not data[key] then
					add(order, key)
				end

				data[key] = tostr(val)
			end
		end,

		draw = function(_ENV, x, y)
			rectfill(x, y + baseY, x + 128, y + baseY + 6, 1)
			local str = ""
			for i in all(order) do
				local j = data[i]
				str = str ..
						i .. ': ' .. j .. ' '
			end
			line(x, y + baseY - 1, x + 128, y + baseY - 1, 0)
			print(str, x, y + baseY + 1, 6)
		end,
	})
end
