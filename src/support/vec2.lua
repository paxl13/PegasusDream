vec2 = class {
	NAME = 'vec2',
	x = 0,
	y = 0,

	normalize = function(self, len)
		len = len or 1

		local l = #self;

		if (len < 0.1) then
			return vec2(0, 0)
		else
			return self / l * len
		end
	end,

	add = function(self, i, j)
		self.x += i
		self.y += j
		return self;
	end,

	sq_len = function(_ENV)
		return x * x + y * y
	end,

	fromAngle = function(self, angle, len)
		len = len or 1
		return self:create(
			len * cos(angle),
			len * sin(angle)
		)
	end,

	random = function(self, len)
		len = len or 1
		return self:fromAngle(rnd(1), len)
	end,

	create = function(self, x, y)
		local vv = { x = x, y = y }

		if (type(x) == 'table' and x.NAME == 'vec2') then
			vv = { x = x.x, y = x.y }
		end

		return class.new(
			self,
			vv,
			{
				__tostring = function(v)
					return
							'v<' .. format2(v.x) ..
							',' .. format2(v.y) .. '>'
				end,

				__add = function(v1, v2)
					return vec2(
						v1.x + v2.x,
						v1.y + v2.y
					)
				end,

				__sub = function(v1, v2)
					return vec2(
						v1.x - v2.x,
						v1.y - v2.y
					)
				end,

				__mul = function(a, b)
					if (type(b) == 'number') then
						return vec2(
							a.x * b,
							a.y * b
						)
					end

					return vec2(
						a.x * b.x,
						a.y * b.y
					)
				end,

				__div = function(v1, q)
					return vec2(
						v1.x / q,
						v1.y / q
					)
				end,

				__len = function(v)
					return sqrt(v.x ^ 2 + v.y ^ 2)
				end,

				__call = function(v)
					return v.x, v.y
				end,

				__eq = function(v1, v2)
					return v1.x == v2.x and v1.y == v2.y
				end,
			})
	end,
}

vecNil = vec2(0, 0)
vecLeft = vec2(-1, 0)
vecRight = vec2(1, 0)
vecUp = vec2(0, 1)
vecDown = vec2(0, -1)
