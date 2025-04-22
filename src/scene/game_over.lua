gameover_scene = scene {
	update = function()
		if btn(5) then
			change_scene(game_scene)
		end
	end,

	draw = function()
		cls(0)

		camera(0, 0)
		cursor(0, 0)
		print('boot of fury')
		print('you are dead!')
	end
}
