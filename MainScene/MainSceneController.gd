extends Node
#scene ressources
@onready var fuseki_caller = $ControlLayer/ControlPanel/MarginContainer/ControlContainer/FusekiCallerButton
@onready var fuseki_dumper = $ControlLayer/ControlPanel/MarginContainer/ControlContainer/FusekiDumperController
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
	if OS.has_feature("web"):
		print("Detected running on the web")
		$ControlLayer.hide()
		load_yaml_from_dump()

func _update_fuseki_data():
	audio_player.stream = drop_sound
	audio_player.play()
	dt_container.feed_fuseki_data(fuseki_data)

func load_yaml_from_dump():
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(self._on_HTTPRequest_yaml_completed)
	# TODO: Fix this hardcoded URL
	var error = http.request("https://oakeslab-polymtl.github.io/DTDF/data_dump.yaml")
	#var error = http.request("http://localhost:1313/DTDF/data_dump.yaml")
	if error != OK:
		push_error("An error occurred in the HTTP request for YAML data.")

func _on_HTTPRequest_yaml_completed(result, response_code, headers, body):
	if response_code == 200:
		var yaml_content = body.get_string_from_utf8()
		fuseki_dumper.load_from_dump(fuseki_data, yaml_content)
		print("YAML data loaded successfully from HTTP request")
	else:
		push_error("Failed to load YAML data. Response code: " + str(response_code))
