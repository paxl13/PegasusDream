sprite = class {
	NAME = 'sprite',

	create = function(self, pos_vec, tileId)
		local tbl = class.new(self, {
			pos = pos_vec,
			id = tileId,
		}, { __call = function(s) return s.pos(); end })
		return tbl;
	end,

	draw = function(_ENV)
		spr(id, pos())
	end,

	update = function()
	end,
}
