extends BaseSceneModificationTool

class_name DeleteObjectTool

func _init():
	super._init(
		"delete_object",
		"Delete an object based on its scene's name",
		{
			"type": "object",
			"properties": {
				"object_name": {
					"type": "string",
					"description": "The unique name of the object",
				}
			},
			"required": ["object_name"]
		}
	)

func execute(_input: Dictionary) -> Dictionary:
	var result = {
		"output" = "",
		"is_error" = false
	}
		
	if not _input.has('object_name'):
		result.is_error = true
		result.output = "There was an error in deleting the object: no name provided."
		return result
	elif not scene_visuals.has_node(_input['object_name']):
		result.is_error = true
		result.output = "Error: could not find an object named '" + _input['object_name'] + "' in the scene."
		return result

	
	for child in scene_visuals.get_children():
		if child.name == _input['object_name']:
			remove_child(child)
			child.queue_free()

	result.output = "Deleted an object named" + _input['object_name']
	return result

func get_scene_objects():
	var scene_object_names = []
	for child in scene_visuals.get_children():
		scene_object_names.append(child.name)
	return scene_object_names
