extends Node

class_name Fifo

var SIZE_LIMIT : int = RabbitConfig.MESSAGES_LIMIT
var content : Array[String] = []

func add_element(element) -> void:
	var string_element : String = str(element)
	trim_elements_to_fit()
	content.append(string_element)

func trim_elements_to_fit() -> bool:
	if (content.size() < SIZE_LIMIT):
		return false
	else:
		content.remove_at(0)
		return true

func get_content() -> Array[String]:
	return content
