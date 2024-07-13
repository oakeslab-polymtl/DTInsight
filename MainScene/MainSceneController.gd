extends Node

#scene ressources
@onready var fuseki_caller = $ControlLayer/ControlPanel/FusekiCallerButton
@onready var fuseki_data = $ControlLayer/ControlPanel/FusekiCallerButton/SparqlFusekiQueries/FusekiData
@onready var dt_container = $DTContainer

#audio ressources
@onready var audio_player = $AudioStreamPlayer
@onready var drop_sound = preload("res://Audio/drop_001.ogg")

func _ready():
	fuseki_caller.fuseki_data_updated.connect(_update_fuseki_data)

func _update_fuseki_data():
	audio_player.stream = drop_sound
	audio_player.play()
	dt_container.feed_fuseki_data(fuseki_data)
