function is_wall(x, y)
	local colided =
			fget(mget(x / 8, y / 8), 0)

	if DEBUG then
		-- debugging code
		if colided then
			points:add(x, y,
				colided and 8 or 9,
				colided and 30 or 1,
				colided and 2 or 1
			)
		end
	end

	return colided
end

--
-- pos=position to check.
-- sprite corners:
-- c1 c2
-- c3 c4
function process_map_colision(pos, mv)
	local colided = false

	local m_x1, m_y1, m_x2, m_y2 = pos()

	local c1 = is_wall(m_x1, m_y1)
	local c2 = is_wall(m_x1, m_y2)
	local c3 = is_wall(m_x2, m_y1)
	local c4 = is_wall(m_x2, m_y2)

	if (c1 and c3 or c2 and c4) then
		-- horizonal
		mv.y *= -1
		colided = true
	end

	if (c1 and c2 or c3 and c4) then
		-- vertical
		mv.x *= -1
		colided = true
	end

	if (not colided and (
				c1 or c2 or c3 or c4
			)) then
		-- corners
		mv *= -1
		colided = true
	end

	return mv, colided
end

function getRandomTile()
	local is_valid = false
	local i, j
	repeat
		i = flr(rnd(30))
		j = flr(rnd(30))

		local t = mget(i, j)
		is_valid = not fget(t, 0)
	until is_valid
	return i * 8, j * 8
end

function addmask(v, mask)
	local l = v & mask
	l = (l + 1) & mask
	v = (v & ~mask) + l
	return v
end

function eachtile(campos, fn)
	local x = flr(campos.x / 8)
	local y = flr(campos.y / 8)

	for i = x, x + 15 do
		for j = y, y + 15 do
			local t = mget(i, j)
			local f = fget(t)
			fn(
				t, f,
				function(n)
					mset(i, j, n)
				end,
				i, j
			)
		end
	end
end

mapper = class {
	initialize = function(_ENV)
		-- setup dark blue as transparency
		palt(0, false)
		palt(11, true)

		speed = 12
		campos = vec2(0, 0)
	end,

	updateAnim = function(self)
		local animframe = framectr / self.speed

		if (animframe << 16 == 0) then
			eachtile(
				self.campos,
				function(t, f, set)
					local m = (f >> 4) & 0b11
					local s = (f >> 7) & 0b1
					if m != 0 and animframe & s == 0
					then
						set(addmask(t, m))
					end
				end
			)
		end
	end,

	updateCam = function(self)
		local x, y = hero.pos()

		self.campos.x = (x - 64) < 0 and 0 or x - 64
		self.campos.y = (y - 64) < 0 and 0 or y - 64
	end,

	draw = function(_ENV)
		camera(campos())
		map()
	end,

	draw2 = function(_ENV)
		camera(campos())
		map(0, 0, 0, 0, 128, 32, 0x2)
	end
}
