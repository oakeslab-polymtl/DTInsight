extends Button

func _on_pressed() -> void:
	#$SettingsPopup.popup()
	get_node('/root/MainScene/ControlLayer/SettingsBackground').show() 
	CameraSignals.disable_camera_movement.emit()
	CameraSignals.disable_camera_zoom.emit()

func _on_settings_settings_menu_closed() -> void:
	get_node('/root/MainScene/ControlLayer/SettingsBackground').hide()
	CameraSignals.enable_camera_movement.emit()
	CameraSignals.enable_camera_zoom.emit()
