entity = class {
	NAME = 'entity',
	create = function(...)
		return class.new(...)
	end,
	-- create = function(self, ...)
	-- 	debugPrint('create entity of ' .. self.NAME)
	-- 	local tbl = class.new(self, ...)
	-- 	add(drawPipeline, tbl)
	-- 	return tbl
	-- end,

	-- destroy = function(self)
	-- 	del(drawPipeline, self)
	-- end,

	update = function() end,
	draw = function() end,
	getMask = function() end,
	isNotNil = function(self) return self ~= entityNil end
}

entityNil = entity()
