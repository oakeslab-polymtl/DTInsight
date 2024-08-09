extends Node

@onready var rabbit_mq = $RabbitMq

func _ready():
	rabbit_mq.connect("UpdatedRabbit", _on_updated_rabbit)

func _on_updated_rabbit(data : String) -> void:
	print(data)
