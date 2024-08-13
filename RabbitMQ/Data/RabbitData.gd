extends Node

@onready var rabbit_mq = $RabbitMQController/RabbitMQ

var connected : bool

var t1_record : Fifo = Fifo.new()
var t2_record : Fifo = Fifo.new()
var t3_record : Fifo = Fifo.new()
var heater_record : Fifo = Fifo.new()
var fan_record : Fifo = Fifo.new()

func _ready():
	rabbit_mq.connect("UpdatedRabbit", _on_updated_rabbit)

func _on_updated_rabbit(rabbit_data : String) -> void:
	var data = JSON.parse_string(rabbit_data)
	
	if data.measurement != null && data.measurement == "low_level_driver":
		t1_record.add_element(data.fields.t1)
		t2_record.add_element(data.fields.t2)
		t3_record.add_element(data.fields.t3)
		heater_record.add_element(data.fields.heater_on)
		fan_record.add_element(data.fields.fan_on)
	print(t1_record.get_content())
