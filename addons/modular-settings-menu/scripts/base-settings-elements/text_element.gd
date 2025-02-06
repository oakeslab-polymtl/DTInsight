extends SettingsElement
class_name TextElement
## A settings element specifically for elements that have option buttons.

## Default value for the element.
@export var DEFAULT_VALUE: String = "Default Text"

## Element node references
@export var TextRef: LineEdit


func _ready() -> void:
	super._ready()
	TextRef.connect("text_changed", text_selected)

func init_element() -> void:
	TextRef.text = currentValue

func get_valid_values() -> Dictionary:
	return {
		"defaultValue": DEFAULT_VALUE,
		"validOptions": ["__ACCEPT_ALL__"]
	}

func text_selected(new_text: String) -> void:
	# Check if the settings menu is open
	if ParentRef.settingsCache_.size() > 0:
		# Update the settings cache with the selected option
		ParentRef.settingsCache_[IDENTIFIER] = new_text
		# Check if the selected value is different than the saved value
		ParentRef.settings_changed(IDENTIFIER)
		currentValue = new_text
