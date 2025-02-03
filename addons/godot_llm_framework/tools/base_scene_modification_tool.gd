extends BaseTool

class_name BaseSceneModificationTool

var scene_visuals: Node3D

var colors_list = [
					"red",
					"blue",
					"green",
					"yellow",
					"orange",
					"purple",
					"black",
					"white",
					"gray",
					"brown",
					"pink",
					"cyan",
					"teal",
					"lime",
					"gold",
					"silver"
				 	]

func _init(_name: String, _description: String, _input_schema: Dictionary):
	super._init(
		_name,
		_description,
		_input_schema,
	)

func _ready() -> void:
	scene_visuals = get_tree().get_root().get_node("root/VisualsManager")
