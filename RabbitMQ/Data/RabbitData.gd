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
		RabbitSignals.updated_data.emit(RabbitConfig.InfoContainers.T1_CONTAINER, t1_record.get_content())
		t2_record.add_element(data.fields.t2)
		RabbitSignals.updated_data.emit(RabbitConfig.InfoContainers.T2_CONTAINER, t2_record.get_content())
		t3_record.add_element(data.fields.t3)
		RabbitSignals.updated_data.emit(RabbitConfig.InfoContainers.T3_CONTAINER, t3_record.get_content())
		heater_record.add_element(data.fields.heater_on)
		RabbitSignals.updated_data.emit(RabbitConfig.InfoContainers.HEATER_CONTAINER, heater_record.get_content())		
		fan_record.add_element(data.fields.fan_on)
		RabbitSignals.updated_data.emit(RabbitConfig.InfoContainers.FAN_CONTAINER, fan_record.get_content())		
