--lint: func::_init
function game_init()
	framectr = 0
	actors = {}
	drawPipeline = {}
	running_game = true

	globals = _ENV

	hero = player(64, 64);

	if ENNY then
		for _ = 1, 20 do
			local kind = rnd({ knight, fool_knight })
			add(actors, kind(getRandomTile()))
		end
	end
end

-- if (vec2.sq_len(a.pos - b.pos) < 8 * 8) then
-- local colided = a:test_collision(b)
-- for b in all(pack(unpack(acts, i + 1, #actors))) do
-- onceEvery(10, function()
-- 	debugPrint('#act ', #acts, ' test# ', nbr, ' n# ', n, ' cpu# ', stat(1) - ta)
-- local ta = stat(1)
-- local n, nbr = 0, 0
-- nbr += 1
-- n += 1
--
--
-- do
--   local _f, _s, _var = explist
--   while true do
--     local var_1, ... , var_n = _f(_s, _var)
--     _var = var_1
--     if _var == nil then break end
--     block
--   end
-- end
--

-- function non_solid_next(tbl, i)
-- 	i += 1

-- 	local v
-- 	while i < #tbl do
-- 		v = tbl[i]
-- 		if (v.solid) then
-- 			return i, v
-- 		end
-- 		i += 1
-- 	end
-- end

function deal_with_colision()
	local acts = pack(hero, unpack(actors))

	for i, a in inext, acts, 0 do
		for _, b in inext, acts, i do
			if (
						a.pos.x - b.pos.x < 12 and
						a.pos.y - b.pos.y < 12
					) then
				if a.solid and b.solid then
					local colided = testIntersection(
						b.mask.x1 + b.pos.x, b.mask.y1 + b.pos.y,
						b.mask.x2 + b.pos.x, b.mask.y2 + b.pos.y,
						a.mask.x1 + a.pos.x, a.mask.y1 + a.pos.y,
						a.mask.x2 + a.pos.x, a.mask.y2 + a.pos.y
					)

					if colided then
						local mv = vec2:fromAngle((b.pos - a.pos):getAngle())
						a.mv = mv * -1
						b.mv = mv
					end
				end
			end
		end
	end
end

function game_update()
	framectr += 1

	mapper:updateAnim()

	io:update()
	hero:input()

	if running_game then
		foreach(actors, invoke('input'))
	end

	deal_with_colision()

	hero:update()

	if running_game then
		foreach(actors, invoke('update'))
	end

	mapper:updateCam()

	if DEBUG then
		points:update()

		onceEvery(10, function()
			hud:set('hp', hero.hp)
			hud:set('c%', sysDisp)
			hud:set('m%', meDisp)
			hud:set('#a', #actors)
			hud:set('c', mapper.campos)
		end)
	end
end

function darken(x1, y1, x2, y2)
	for x = x1, x2 do
		for y = y1, y2 do
			local col = pget(x, y)
			col = col < 7 and 0 or col - 8
			pset(x, y, col)
		end
	end
end

function game_draw()
	cls(11)
	mapper:draw()

	-- todo: draw in order (y ascending)
	foreach(actors, invoke('draw'))
	hero:draw()
	mapper:draw2()


	if DEBUG then
		points:draw()
		hud:draw(mapper.campos())
		foreach(actors, displayOverlay)
		displayOverlay(hero)

		onceEvery(10, function()
			-- pad string
			meDisp = tostr(flr((stat(1) - stat(2)) * 100))
			if (#meDisp == 1) then
				meDisp = ' ' .. meDisp
			end
			sysDisp = tostr(flr(stat(1) * 100))
			if (#sysDisp == 1) then
				sysDisp = ' ' .. sysDisp
			end
		end)
	end
end

function game_destroy()
	actors = {}
	cls(0)
end

game_scene = {
	init = game_init,
	update = game_update,
	draw = game_draw,
	destroy = game_destroy
}
