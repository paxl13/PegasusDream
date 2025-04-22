shadow = sprite:new {
	create = function(self, pos_vec)
		local _ENV = sprite.create(self, vecNil(), 1)
		posv = pos_vec
		return _ENV
	end,

	draw = function(_ENV)
		pos = posv + vec2(0, 2)
		for x = 0, 7 do
			for y = 0, 7 do
				local pix = sget(x, y + 8)
				-- debugPrint(pix)
				local pix_pos = pos + vec2(x, y)
				-- if pix != 0 then
				color(0)
				pset(pix_pos())
				-- end
			end
		end
	end

}
