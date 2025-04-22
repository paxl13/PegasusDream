--lint: func::_init
function game_init()
	framectr = 0
	actors = {}
	drawPipeline = {}
	running_game = true

	globals = _ENV

	hero = player(64, 64);

	if ENNY then
		for _ = 1, 9 do
			local kind = rnd({ knight, fool_knight })
			add(actors, kind(getRandomTile()))
		end
	end

	add(actors, knight(getRandomTile()))
end

function game_update()
	framectr += 1

	mapper:updateAnim()
	io:update()

	hero:input()

	if running_game then
		foreach(actors, invoke('input'))
	end

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
