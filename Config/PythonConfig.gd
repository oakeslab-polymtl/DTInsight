extends Node

#TODO Software path selection
var SOFTWARE_PATH : String = ""

#TODO relative file from software in ontology
const PYTHON_PATH : Dictionary = {
	"four_para_model" : "\\incubator\\models\\plant_models\\four_parameters_model\\four_parameter_model.py"
}

func _ready() -> void:
	ScriptSignals.scripts_folder_selected.connect(_on_software_path_selected)

func _on_software_path_selected(dir : String) -> void:
	SOFTWARE_PATH = dir
