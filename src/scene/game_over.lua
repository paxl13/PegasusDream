gameover_scene = scene {
	scollY = 0,
	update = function(_ENV)
		if btn(5) then
			change_scene(game_scene)
		end

		-- scollY += 0.1
		-- if scollY > 100 then
		-- 	scollY = -32
		-- end
	end,

	draw = function(_ENV)
		cls(0)
		camera(0, scollY)

		shadowPrint('bOOT oF fURY', 16, true)
		shadowPrint('BY PAXL13', 24, true)

		shadowPrint('press any btn to restart', 64)
		shadowPrint('game stats: ', 96)
		shadowPrint('- death: ' .. '123', 100)
		shadowPrint('- time: ' .. '10 m 45', 104)
	end
}
