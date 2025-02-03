extends TextEdit

signal submitted

# Handle input behaviour if shift+enter or just enter is pressed
func _gui_input(event):
	if self.has_focus() and event is InputEventKey and event.is_pressed():
		if event.key_label == KEY_ENTER:
			if event.shift_pressed:
				insert_text_at_caret("\n")
				LogDuck.d("Shift+Enter pressed in TextEdit")
			else:
				if self.text != "":
					submitted.emit()
					self.clear()
					LogDuck.d("Enter pressed in TextEdit")
			get_viewport().set_input_as_handled()
