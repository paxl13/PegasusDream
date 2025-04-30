hp_bar = entity:new {
	NAME = 'hp_bar',

	create = function(self, act)
		return entity.create(self, { act = act })
	end,

	draw = function(_ENV, iframe)
		if act.hp > 0 then
			local x, y = act.pos()
			local ratio = act.hp / act.maxHp
			local greenX = x + flr(ratio * 8)

			local borderCol = iframe ~= 0 and 13 or 0

			if ratio ~= 1 then
				rectfill(x - 1, y - 4, x + 9, y - 2, borderCol)
				line(x, y - 3, greenX, y - 3, 11) -- green
				line(greenX, y - 3, x + 8, y - 3, 8) -- red
			end
		end
	end

}
