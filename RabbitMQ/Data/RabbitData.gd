extends Node

class_name RabbitMQ

@onready var rabbit_mq_controller = $RabbitMQController
@onready var rabbit_mq = $RabbitMQController/RabbitMQ

var fuseki_data : FusekiData = null

class MessageListner:
	var viz_container : String
	var data : Fifo

var exchange_name : String = ""
var routing_key : String = ""
var source : String = ""
var message_listeners : Dictionary = {}

var connected : bool

func _ready():
	rabbit_mq.connect("UpdatedRabbit", _on_updated_rabbit)
	FusekiSignals.fuseki_data_updated.connect(update_rabbit_data)

func set_fuseki_data_manager(fuseki : FusekiData) -> void:
	fuseki_data = fuseki

func update_rabbit_data() -> void:
	exchange_name = fuseki_data.rabbit_exchange["incubator_exchange"]["exchange_name_str"][0]
	routing_key = fuseki_data.rabbit_route["incubator_routing_key"]["routing_key_str"][0]
	source = fuseki_data.rabbit_source["incubator_source"]["source_str"][0]
	for ml in fuseki_data.rabbit_message_listener.keys():
		var new_ml = MessageListner.new()
		new_ml.viz_container = fuseki_data.rabbit_message_listener[ml]["MLTarget"][0]
		new_ml.data = Fifo.new()
		message_listeners[fuseki_data.rabbit_message_listener[ml]["MLSource"][0]] = new_ml
	rabbit_mq_controller.get_rabbit_parameters(exchange_name, [routing_key] as Array[String])

func _on_updated_rabbit(rabbit_data : String) -> void:
	var data = JSON.parse_string(rabbit_data)

	if data.tags.source != null && data.tags.source == source:
		for src in message_listeners.keys():
			message_listeners[src].data.add_element(data.fields[src])
			RabbitSignals.updated_data.emit(message_listeners[src].viz_container, message_listeners[src].data.get_content())
