function tbl_tostr(t)
	local rv = (t.NAME or 'unamed') .. ': {\n'
	for k, v in pairs(t) do
		v = ifn(v)
		rv = rv .. ' ' .. k .. '=' .. v .. ',\n'
	end
	return rv .. '}'
end

class = setmetatable({
	NAME = 'class',
	new = function(self, t, mt)
		t = t or {}

		mt = mt or {}
		mt.__index = mt.__index or self
		mt.__tostring = mt.__tostring or tbl_tostr
		mt.__call = mt.__call or function(tbl, ...)
			return tbl.create and
					tbl:create(...) or
					tbl:new(...)
		end

		t = setmetatable(t, mt)

		-- For any class, call initialize when the instance is newed.
		-- This will be most useful for singleton
		if t.initialize then
			t:initialize()
		end

		return t
	end,

	include = function(tbl, mixin)
		for k, v in pairs(mixin) do
			tbl[k] = v
		end
	end
}, {
	__index = _ENV,
	__call = function(tbl, ...) return tbl:new(...) end
})
