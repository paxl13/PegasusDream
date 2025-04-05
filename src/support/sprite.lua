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

animated_sprite = sprite:new {
	NAME = 'animated_sprite',
	anim = {},
	fr_ctr = 0,
	current = 0,
	done = false,

	create = function(self, pos_vec, anim_table, loop)
		local tbl = sprite.create(self, pos_vec, nil)

		tbl.anim = anim_table;
		tbl.loop = loop or false
		self.next(tbl)

		return tbl
	end,

	update = function(_ENV)
		fr_ctr += 1;
		if fr_ctr > fr_n then
			next(_ENV)
			fr_ctr = 0
		end
	end,

	next = function(_ENV)
		current += 1
		if current > #anim then
			current = loop and 1 or #anim
			done = true
		end
		id, fr_n = unpack(anim[current])
	end

}
