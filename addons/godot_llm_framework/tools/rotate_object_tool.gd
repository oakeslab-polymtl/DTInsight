extends BaseSceneModificationTool

class_name RotateObjectTool

func _init():
	super._init(
		"rotate_object",
		"Rotate an object along its up axis by degrees. Positive angles turn it counterclockwise/left, negative angles turn it clockwise/right.",
		{
			"type": "object",
			"properties": {
				"object_name": {
					"type": "string",
					"description": "The unique name of the object",
				},
				"angle":{
					"type": "integer",
					"description": "The rotation in degrees, for example 90 for a left rotation of 90 degrees, -45 for a right rotation of 45 degrees."
				  },
			},
			"required": ["object_name", "angle"]
		}
	)

func execute(_input: Dictionary) -> Dictionary:
	var result = {
		"output" = "",
		"is_error" = false
	}
		
	if not _input.has('object_name') || not _input.has('angle'):
		result.is_error = true
		result.output = "There was an error in rotating the object"
		return result
	elif not scene_visuals.has_node(_input['object_name']):
		result.is_error = true
		result.output = "Error: could not find an object named '" + _input['object_name'] + "' in the scene."
		return result
	
	var mesh_instance : MeshInstance3D
	mesh_instance = scene_visuals.get_node(_input['object_name']).get_node("Shape")
	mesh_instance.rotation_degrees.y += float(_input['angle'])
	
	result.output = "The object named " + _input['object_name'] + " has been rotated by " + str(_input['angle']) + " degrees."
	return result

func get_scene_objects():
	var scene_object_names = []
	for child in scene_visuals.get_children():
		scene_object_names.append(child.name)
	return scene_object_names
