scene = class {
	init = function() end,
	update = function() end,
	draw = function() end,
	destroy = function() end,
}

current_scene = scene

change_scene = function(new_scene)
	current_scene.destroy()
	new_scene.init()
	current_scene = new_scene
end
