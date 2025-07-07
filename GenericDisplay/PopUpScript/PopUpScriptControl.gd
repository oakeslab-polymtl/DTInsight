extends Control

@onready var script_label = $ScriptContainer/Script

func set_script_file(file_path : String) -> void:
	print(file_path)
	var file = FileAccess.open(file_path, FileAccess.READ)
	if (file == null):
		return
	var content : String = file.get_as_text()
	script_label.text = content
