function inrng(...)
	return mid(...) == ...
end

function d(...)
	for v in all(pack(...)) do
		printh(v)
	end
end

function invoke(name)
	return function(o)
		o[name](o)
	end
end

function format2(n)
	local s =
			flr(n) .. "." ..
			flr(n % 1 * 10 ^ 2)

	if #s ~= 4 then
		s = s .. '0'
	end
	return s
end

function indent2(s)
	local l = split(s, '\n')
	local rv = ''
	for i = 1, #l - 1 do
		rv = rv .. l[i] .. '\n  '
	end
	return rv .. l[#l]
end

function ifn(v)
	if type(v) == 'table' then
		return indent2(tostr(v))
	end

	return tostr(v)
end

function seq_tostr(s, n)
	local rv = (n or 'seq') .. ': [\n'
	for v in all(s) do
		v = ifn(v)

		rv = rv .. ' ' .. v .. ', \n'
	end
	return rv .. ']'
end

function resume(thr, ...)
	local error, rv = coresume(thr, ...)
	assert(error, rv)
	return rv
end

function wait_internal(v)
	for _ = 1, v do
		yield()
	end
end

function toward_player(_ENV, len)
	local v = player.pos - pos
	return v:normalize(len)
end

-- function moveToward(x, y, t)
-- 	return function(_ENV)
-- 		mv = vec2(x, y)
-- 		wait_internal(t)
-- 	end
-- end

-- function set_(key, fnOrV)
-- 	if type(fnOrV) == 'function' then
-- 		return function(self)
-- 			self[key] = fnOrV(self)
-- 		end
-- 	end

-- 	return function(self)
-- 		self[key] = fnOrV
-- 	end
-- end

-- function add_mv(fn)
-- 	return function(_ENV)
-- 		mv += fn(_ENV)
-- 	end
-- end

-- function untilMapCollision_(_ENV)
-- 	repeat
-- 		yield()
-- 	until colided
-- end

-- function pipe_(f_list)
-- 	local outArgs = {}

-- 	return function(self)
-- 		for fn in all(f_list)
-- 		do
-- 			outArgs = pack(fn(self, unpack(outArgs)))
-- 		end
-- 	end
-- end

function onceEvery(cnt, fn)
	if (framectr % cnt == 1) then
		fn()
	end
end

function forever(fn)
	return function(_ENV)
		repeat
			local rv = fn(_ENV)
			if rv then
				return rv
			end
		until false
	end
end

function split2(s)
	local t = split(s)
	local len, rv, i = #t, {}, 1

	while i < len do
		add(rv, pack(unpack(t, i, i + 1)))
		i += 2
	end

	return rv
end

-- function yieldUntil(fn)
-- 	repeat
-- 		yield()
-- 	until fn()
-- end
