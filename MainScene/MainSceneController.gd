extends Node

@onready var fuseki_caller = $ControlLayer/ControlPanel/FusekiCallerButton
@onready var fuseki_data = $ControlLayer/ControlPanel/FusekiCallerButton/SparqlFusekiQueries/FusekiData
@onready var dt_container = $DTContainer

func _ready():
	fuseki_caller.fuseki_data_updated.connect(_update_fuseki_data)

func _update_fuseki_data():
	dt_container.feed_fuseki_data(fuseki_data)
