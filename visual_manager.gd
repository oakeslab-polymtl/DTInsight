extends Node3D

# Function to parse JSON and spawn the shape
func spawn_shape_from_json(json_string: String):
	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		print("Failed to parse JSON: ", error)
		return

	var shape_data = json.data
	var shape_name = shape_data.get("shape", "").to_lower()
	var color = parse_color(shape_data.get("color", "white"))
	var description = shape_data.get("description", "No description")
	var shape_mesh = null
	
	match shape_name:
		"box", "cube":
			shape_mesh = BoxMesh.new()
		"cylinder":
			shape_mesh = CylinderMesh.new()
		"sphere":
			shape_mesh = SphereMesh.new()
		_:
			shape_mesh = null

	if shape_mesh:
		create_shape(shape_mesh, color)
		print(description)
	else:
		print("Unknown shape:", shape_name)

# Helper function to create and add the shape to the scene
func create_shape(mesh: Mesh, color: Color):
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.material_override = create_material(color)
	mesh_instance.transform.origin = self.position
	mesh_instance.name = "GeneratedShape"
	add_child(mesh_instance)

# Helper function to create a material with the specified color
func create_material(color: Color) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	return material

# Helper function to parse color from a string
func parse_color(color_name: String) -> Color:
	match color_name.to_lower():
		"red":
			return Color(1, 0, 0)
		"blue":
			return Color(0, 0, 1)
		"green":
			return Color(0, 1, 0)
		"yellow":
			return Color(1, 1, 0)
		"orange":
			return Color(1, 0.5, 0)
		"purple":
			return Color(0.5, 0, 0.5)
		"black":
			return Color(0, 0, 0)
		"white":
			return Color(1, 1, 1)
		"gray":
			return Color(0.5, 0.5, 0.5)
		"brown":
			return Color(0.6, 0.3, 0.1)
		"pink":
			return Color(1, 0.75, 0.8)
		"cyan":
			return Color(0, 1, 1)
		"teal":
			return Color(0, 0.5, 0.5)
		"lime":
			return Color(0.5, 1, 0)
		"gold":
			return Color(1, 0.84, 0)
		"silver":
			return Color(0.75, 0.75, 0.75)
		_:
			return Color(1, 1, 1)  # Default to white


func _ready():
	#var json_string = '{"color": "green", "description": "Cube in the center of the scene", "name": "Cube in the center", "position": "center" ,"shape": "cylinder"}'
	#spawn_shape_from_json(json_string)
	var nodes_in_group = get_tree().get_nodes_in_group("text_generators")
	for node in nodes_in_group:
		node.connect("shape_json_generated", self.spawn_shape_from_json)
