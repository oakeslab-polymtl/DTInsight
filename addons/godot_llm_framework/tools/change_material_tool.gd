extends BaseSceneModificationTool

class_name ChangeMaterialTool

func _init():
	super._init(
		"change_material",
		"Change the material (color, transparency, shininess) of an object with his name",
		{
			"type": "object",
			"properties": {
				"object_name": {
					"type": "string",
					"description": "The unique name of the object",
				},
				"color":{
					"type": "string",
					 "enum": colors_list,
					"description": "The color of the object"
				  },
			},
			"required": ["object_name", "color", "transparency"]
		}
	)

func execute(_input: Dictionary) -> Dictionary:
	var result = {
		"output" = "",
		"is_error" = false
	}
		
	if not _input.has('color') || not _input.has('object_name'):
		result.is_error = true
		result.output = "There was an error in changing the material"
		return result
	elif not scene_visuals.has_node(_input['object_name']):
		result.is_error = true
		result.output = "Error: could not find an object named '" + _input['object_name'] + "' in the scene."
		return result
		
	var mesh_instance : MeshInstance3D
	mesh_instance = scene_visuals.get_node(_input['object_name']).get_node("Shape")
	mesh_instance.material_override = create_material(_input['color'])
	
	result.output = "Set the material of " + _input['object_name'] + " to a " + _input['color'] + " color"
	return result

func create_material(color_string: String) -> StandardMaterial3D:
	var chosen_color: Color
	match color_string.to_lower():
		"red":
			chosen_color = Color(1, 0, 0)
		"blue":
			chosen_color =  Color(0, 0, 1)
		"green":
			chosen_color =  Color(0, 1, 0)
		"yellow":
			chosen_color =  Color(1, 1, 0)
		"orange":
			chosen_color =  Color(1, 0.5, 0)
		"purple":
			chosen_color =  Color(0.5, 0, 0.5)
		"black":
			chosen_color =  Color(0, 0, 0)
		"white":
			chosen_color =  Color(1, 1, 1)
		"gray":
			chosen_color =  Color(0.5, 0.5, 0.5)
		"brown":
			chosen_color =  Color(0.6, 0.3, 0.1)
		"pink":
			chosen_color =  Color(1, 0.75, 0.8)
		"cyan":
			chosen_color =  Color(0, 1, 1)
		"teal":
			chosen_color =  Color(0, 0.5, 0.5)
		"lime":
			chosen_color =  Color(0.5, 1, 0)
		"gold":
			chosen_color =  Color(1, 0.84, 0)
		"silver":
			chosen_color =  Color(0.75, 0.75, 0.75)
		_:
			chosen_color =  Color(1, 1, 1)  # Default to white
	
	var material = StandardMaterial3D.new()
	#chosen_color.a = 0.8
	#material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = chosen_color
	return material

func get_scene_objects():
	var scene_object_names = []
	for child in scene_visuals.get_children():
		scene_object_names.append(child.name)
	return scene_object_names
