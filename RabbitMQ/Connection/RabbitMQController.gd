extends Node

@onready var rabbit = $RabbitMQ

func _ready() -> void:
	set_rabbit_parameters()
	RabbitSignals.rabbit_connect.connect(_on_connect_order)

func set_rabbit_parameters() -> void:
	rabbit.SetParameters(
		RabbitConfig.USER,
		RabbitConfig.PASS,
		RabbitConfig.HOST,
		RabbitConfig.PORT,
		RabbitConfig.EXCHANGE_NAME,
		array_to_str(RabbitConfig.ROUTING_KEYS)
	)

static func array_to_str(array : Array) -> String:
	var result_string : String = ""
	for element in array:
		if(not result_string.is_empty()):
			result_string += "/"
		result_string += element
	return result_string

func _on_connect_order(order : bool) -> void:
	if (order):
		rabbit.ConnectToRabbitMQ()
	else :
		rabbit.DisconnectRabbitMQ()
