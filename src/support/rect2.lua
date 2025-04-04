rect2 = class {
	NAME = 'rect2',

	offset = function(self, i, j)
		return rect2(
			self.x1 + i, self.y1 + j,
			self.x2 + i, self.y2 + j
		)
	end,

	create = function(self, x1, y1, x2, y2)
		local tbl = class.new(
			self,
			{ x1 = x1, y1 = y1, x2 = x2, y2 = y2 },
			{
				__tostring = function(_ENV)
					return 'r<'
							.. tostr(x1) .. ',' .. tostr(y1) .. ',' .. tostr(x2) .. ',' .. tostr(y2) .. '>'
				end,

				__call = function(_ENV)
					return x1, y1, x2, y2
				end,
			}
		)

		return tbl
	end
}

function testRectIntersection(ra, rb)
	local xa1, ya1, xa2, ya2 = ra()
	local xb1, yb1, xb2, yb2 = rb()

	local insideY =
			(ya1 > yb1 and ya1 < yb2) or
			(ya2 > yb1 and ya2 < yb2)

	local insideX =
			(xa1 > xb1 and xa1 < xb2) or
			(xa2 > xb1 and xa2 < xb2)

	return insideX and insideY
end
