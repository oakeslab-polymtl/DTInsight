extends Control

@onready var script_label = $ScriptContainer/Script

func _ready() -> void:
	ScriptSignals.hide.connect(reset)

func reset():
	script_label.text = ""

func _on_hide_button_pressed() -> void:
	ScriptSignals.hide.emit()

func set_script_file(file_path : String) -> void:
	print(file_path)
	var file = FileAccess.open(file_path, FileAccess.READ)
	if (file == null):
		return
	var content : String = file.get_as_text()
	script_label.text = content
