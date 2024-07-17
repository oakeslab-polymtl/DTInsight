extends BoxContainer

@onready var element_name = $GenericElementName.text

var mouse_over = false

func _on_mouse_entered():
	mouse_over = true

func _on_mouse_exited():
	mouse_over = false

func _process(delta):
	if(mouse_over):
		print(element_name)
