extends BoxContainer

@onready var element_name = $GenericElementName.text

var mouse_over = false

func _on_mouse_entered():
	GenericDisplaySignals.generic_display_over.emit(element_name)

func _on_mouse_exited():
	GenericDisplaySignals.generic_display_over.emit("")
