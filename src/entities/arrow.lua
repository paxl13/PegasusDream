arrow = entity {
	create = function(self, pos_vec)
		local tbl = entity.create(self, { pos = pos_vec });
		tbl.boostFrames = 0
		return tbl
	end,

	update = function(_ENV, _mv)
		boostFrames += 1
	end,

	draw = function(_ENV)
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
}
