extends Button

func _on_pressed() -> void:
	#$SettingsPopup.popup()
	get_node('/root/MainScene/ControlLayer/SettingsBackground').show() 
	CameraSignals.disable_camera_mouvement.emit()

func _on_settings_settings_menu_closed() -> void:
	get_node('/root/MainScene/ControlLayer/SettingsBackground').hide()
	CameraSignals.enable_camera_mouvement.emit()
