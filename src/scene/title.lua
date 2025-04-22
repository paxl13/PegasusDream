title_scene = scene {
	update = function()
		if DEBUG then
			change_scene(game_scene)
		end

		if btn() ~= 0 then
			change_scene(game_scene)
		end
	end,

	draw = function()
		cls(0)

		print('boot of fury')
		print('Press any btn to begin')
	end
}
