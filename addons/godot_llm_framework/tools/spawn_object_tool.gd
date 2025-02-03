extends BaseSceneModificationTool

class_name SpawnObjectTool

const ARROW_ASSET_PATH = "res://arrow.blend"
var i = 0

func _init():
	super._init(
		"spawn_object",
		"Spawn an object by specifying its name, and optionally shape and color. By default a white box is spawned in.",
		{
			"type": "object",
			"properties": {
				"object_name": {
					"type": "string",
					"description": "The unique name of the object. It must not be empty."
				},
				"shape": {
					"type": "string",
					"enum": ["box", "cube", "sphere", "cylinder", "torus"],
					"description": "This property determines the shape of the object."
				},
				"color":{
					"type": "string",
					 "enum": colors_list,
					"description": "The color of the object"
				  },
			},
			"required": ["object_name"]
		}
	)

func execute(_input: Dictionary) -> Dictionary:
	var result = {
		"output" = "",
		"is_error" = false
	}
	
	if not _input.has('object_name') or _input['object_name'] == "":
		result.is_error = true
		result.output = "Error: No object name has been provided."
		return result
	
	var object_name = _input.get_or_add('object_name', "default_object")
	var color_string = _input.get_or_add('color', 'white')
		
	var shape_mesh
	var shape_string = _input.get_or_add('shape', 'box')
	match shape_string:
		"box", "cube":
			shape_mesh = BoxMesh.new()
		"cylinder":
			shape_mesh = CylinderMesh.new()
		"sphere":
			shape_mesh = SphereMesh.new()
		"torus":
			shape_mesh = TorusMesh.new()
		_:
			shape_mesh = BoxMesh.new()
	
	# Create visual object
	var visual_object : Node3D = preload("res://visual_object.tscn").instantiate()
	# Prevent name conflict with pre existing scene objects
	var children_names = []
	var k = 1
	for child in scene_visuals.get_children():
		children_names.append(child.name)
	var original_name = object_name
	while object_name in children_names:
		object_name = original_name + '_' + str(k)
		k += 1
	# Create material
	var material_tool = ChangeMaterialTool.new()
	var mat = material_tool.create_material(color_string)
	# Add shape
	var new_shape = create_shape(shape_mesh, object_name, mat)
	visual_object.add_child(new_shape)
	# Add direcional arrow
	var arrow = preload(ARROW_ASSET_PATH).instantiate()
	visual_object.get_node("Shape").add_child(arrow)
	# Change the name of the label
	var label  : Label3D = visual_object.get_node("Label3D")
	label.text = object_name
	# Set the positiona and name
	visual_object.transform.origin = scene_visuals.position
	visual_object.transform.origin = Vector3(i, 0, 0)
	i += 2
	visual_object.name = object_name
	# Add the object to the scene visuals
	scene_visuals.add_child(visual_object)
	
	result.output = "Created a " + _input['shape'] + " named '" + object_name + "'"
	return result

func create_shape(mesh: Mesh, name: String, mat: Material) -> Node3D:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.material_override = mat
	mesh_instance.name = "Shape"
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	mesh_instance.transparency = 0.2
	return mesh_instance
