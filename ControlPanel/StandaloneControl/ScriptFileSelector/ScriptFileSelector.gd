extends HBoxContainer

@onready var file_dialog : FileDialog = $FileDialog
@onready var path_edit : TextEdit = $SoftwarePathEdit

func _on_pick_button_pressed() -> void:
	file_dialog.visible = true

func _on_file_dialog_dir_selected(dir: String) -> void:
	path_edit.text = dir
	ScriptSignals.scripts_folder_selected.emit(dir)

func _on_path_edit_focus_entered() -> void:
	CameraSignals.disable_camera_mouvement.emit()

func _on_path_edit_focus_exited() -> void:
	CameraSignals.enable_camera_mouvement.emit()
