extends Node

#scene ressources
@onready var fuseki_caller = $ControlLayer/ControlPanel/ControlContainer/FusekiCallerButton
@onready var fuseki_dumper = $ControlLayer/ControlPanel/ControlContainer/FusekiDumperController
@onready var fuseki_data : FusekiData = $FusekiData
@onready var rabbit_data : RabbitMQ = $RabbitMq
@onready var dt_container : BoxContainer = $DTContainer

#audio ressources
@onready var audio_player = $AudioStreamPlayer
@onready var drop_sound = preload("res://Audio/drop_001.ogg")

func _ready():
	fuseki_caller.set_fuseki_data_manager(fuseki_data)
	fuseki_dumper.set_fuseki_data_manager(fuseki_data)
	rabbit_data.set_fuseki_data_manager(fuseki_data)
	FusekiSignals.fuseki_data_updated.connect(_update_fuseki_data)

func _update_fuseki_data():
	audio_player.stream = drop_sound
	audio_player.play()
	dt_container.feed_fuseki_data(fuseki_data)
