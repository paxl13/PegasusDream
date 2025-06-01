scene = class {
	init = function() end,
	update = function() end,
	draw = function() end
}

current_scene = scene

change_scene = function(new_scene)
	new_scene:init()
	current_scene = new_scene
end
