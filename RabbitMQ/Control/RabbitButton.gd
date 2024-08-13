extends CheckButton

func _on_toggled(toggled_on: bool) -> void:
	RabbitSignals.rabbit_connect.emit(toggled_on)
