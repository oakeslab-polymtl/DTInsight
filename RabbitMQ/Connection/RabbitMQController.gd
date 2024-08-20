extends Node

@onready var rabbit = $RabbitMQ

var exchange_name : String = ""
var routing_keys : Array[String] = []

func _ready() -> void:
	RabbitSignals.rabbit_connect.connect(_on_connect_order)

func get_rabbit_parameters(exchange : String, routing : Array[String]) -> void:
	exchange_name = exchange
	routing_keys = routing

func set_rabbit_parameters() -> void:
	rabbit.SetParameters(
		RabbitConfig.USER,
		RabbitConfig.PASS,
		RabbitConfig.HOST,
		RabbitConfig.PORT,
		exchange_name,
		array_to_str(routing_keys)
	)

static func array_to_str(array : Array) -> String:
	var result_string : String = ""
	for element in array:
		if(not result_string.is_empty()):
			result_string += "/"
		result_string += element
	return result_string

func _on_connect_order(order : bool) -> void:
	set_rabbit_parameters()
	if (order):
		rabbit.ConnectToRabbitMQ()
	else :
		rabbit.DisconnectRabbitMQ()
