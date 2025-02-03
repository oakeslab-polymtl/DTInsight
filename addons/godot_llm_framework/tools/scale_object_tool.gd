extends BaseSceneModificationTool

class_name ScaleObjectTool

func _init():
	super._init(
		"scale_object_by_factor",
		"Scale an object in the scene by a certain factor",
		{
			"type": "object",
			"properties": {
				"object_name": {
					"type": "string",
					"description": "The unique name of the object",
				},
				"scaling_factor":{
					"type": "number",
					"description": "The scaling factor, for example 1.2 for scaling up by 20%"
				  },
			},
			"required": ["object_name", "scaling_factor"]
		}
	)

func execute(_input: Dictionary) -> Dictionary:
	var result = {
		"output" = "",
		"is_error" = false
	}
		
	if not _input.has('object_name') || not _input.has('scaling_factor'):
		result.is_error = true
		result.output = "There was an error in scaling the object"
		return result
	elif not scene_visuals.has_node(_input['object_name']):
		result.is_error = true
		result.output = "Error: could not find an object named '" + _input['object_name'] + "' in the scene."
		return result
	
	var mesh_instance : MeshInstance3D
	mesh_instance = scene_visuals.get_node(_input['object_name']).get_node("Shape")
	mesh_instance.scale = mesh_instance.scale * float(_input['scaling_factor'])
	
	result.output = "The object named " + _input['object_name'] + " has been scaled by " + str(_input['scaling_factor']) + "."
	return result

func get_scene_objects():
	var scene_object_names = []
	for child in scene_visuals.get_children():
		scene_object_names.append(child.name)
	return scene_object_names
