-- inrng(value, min, max)
function inrng(...)
	return mid(...) == ...
end

function debugPrint(...)
	local tt, dt = flr(100 * time()) / 100, ''
	if tt % 1 == 0 then
		dt = tostr(tt) .. '.00'
	else
		dt = tostr(tt)
	end
	local str = '[' .. dt .. '] '
	for v in all(pack(...)) do
		str = str .. tostr(v)
	end
	printh(str)
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
	local v = hero.pos - pos
	return v:normalize(len)
end

-- CoRoutines Helpers

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

-- Table helpers

function splitN(s, n)
	local t = split(s)
	local len, rv, i = #t, {}, 1

	while i < len do
		add(rv, pack(unpack(t, i, i + (n - 1))))
		i += n
	end

	return rv
end

function split2(s)
	return splitN(s, 2)
end

-- function delIf(tbl, fn)
-- 	for i in all(tbl) do
-- 		if fn(i) then
-- 			del(tbl, i)
-- 		end
-- 	end
-- end
