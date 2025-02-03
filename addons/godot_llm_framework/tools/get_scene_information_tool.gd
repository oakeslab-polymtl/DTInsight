extends BaseSceneModificationTool

class_name GetSceneInformationTool

func _init():
	super._init(
		"get_scene_information",
		"Gets the current scene information such as the names of the objects in the scene, their color.",
		{
			"type": "object",
			"properties": {}
		}
	)

func execute(_input: Dictionary) -> Dictionary:
	var result = {
		"output" = "",
		"is_error" = false
	}
	
	var scene_object_names = []
	for child in scene_visuals.get_children():
		scene_object_names.append(child.name)
	
	# Empty scene
	if scene_object_names == []:
		result.output = "The scene is empty."
		return result
	
	result.output = str(scene_object_names)
	return result
