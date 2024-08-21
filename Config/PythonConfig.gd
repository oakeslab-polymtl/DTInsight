extends Node

const LOCATION_KEY : String = "file_loc_str"

var SOFTWARE_PATH : String = ""

func _ready() -> void:
	ScriptSignals.scripts_folder_selected.connect(_on_software_path_selected)

func _on_software_path_selected(dir : String) -> void:
	SOFTWARE_PATH = dir
