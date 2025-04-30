title_scene = scene {
	init = function(_ENV)
	end,

	update = function()
		if btn(5) or DEBUG then
			change_scene(game_scene)
		end
	end,

	draw = function(_ENV)
		cls()


		shadowPrint('bOOT oF fURY', 16, true)
		shadowPrint('BY PAXL13', 24, true)

		shadowPrint('press any btn to restart', 96)
	end
}
