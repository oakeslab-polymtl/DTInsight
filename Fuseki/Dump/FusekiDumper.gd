extends Node

class_name FusekiDataDumper

@onready var file_path_input : TextEdit = $DumpPathEdit
@onready var file_dialog : FileDialog = $FileDialog

#Dump file indicators
const SERVICES_INDICATOR = "Services :"
const ENABLERS_TO_SERVICES_INDICATOR = "Enablers to services :"
const ENABLERS_INDICATOR = "Enablers :"
const MODELS_TO_ENABLERS_INDICATOR = "Models to enablers :"
const MODELS_INDICATOR = "Models :"
const PROVIDED_THING_INDICATOR = "ProvidedThings :"
const SERVICES_TO_PROVIDED_THING_INDICATOR = "Services to provided thing :"
const DATA_TRANSMITTED_INDICATOR = "Data transmitted :"
const SENSORS_INDICATOR = "Sensors :"
const SYS_INDICATOR = "System :"
const ENV_INDICATOR = "System environnement :"
const DATA_INDICATOR = "Data :"
const RABBIT_EXCHANGE_INDICATOR = "Rabbit exchange :"
const RABBIT_ROUTE_INDICATOR = "Rabbit route :"
const RABBIT_SOURCE_INDICATOR = "Rabbit source :"
const RABBIT_ML_INDICATOR = "Rabbit message listener :"
const EOF_INDICATOR = ""

#FusekiDataManager
var FusekiDataManager : FusekiData
func set_fuseki_data_manager(fuseki_data_manager : FusekiData):
	FusekiDataManager = fuseki_data_manager

func _on_load_button_pressed():
	var file = FileAccess.open(file_path_input.text, FileAccess.READ)
	if (file == null):
		return
	var content : String = file.get_as_text()
	load_from_dump(FusekiDataManager, content)

func _on_dump_button_pressed():
	
	dump(FusekiDataManager, file_path_input.text)

static func dump(data : FusekiData, dump_path : String, to_console = false):
	var dump_string = ""
	dump_string += SERVICES_INDICATOR + "\n"
	dump_string += dump_dictionary(data.service)
	dump_string += ENABLERS_INDICATOR + "\n"
	dump_string += dump_dictionary(data.enabler)
	dump_string += MODELS_INDICATOR + "\n"
	dump_string += dump_dictionary(data.model)
	dump_string += PROVIDED_THING_INDICATOR + "\n"
	dump_string += dump_dictionary(data.provided_thing)
	dump_string += DATA_TRANSMITTED_INDICATOR + "\n"
	dump_string += dump_dictionary(data.data_transmitted)
	dump_string += SENSORS_INDICATOR + "\n"
	dump_string += dump_dictionary(data.sensing_component)
	dump_string += SYS_INDICATOR + "\n"
	dump_string += dump_dictionary(data.sys_component)
	dump_string += ENV_INDICATOR + "\n"
	dump_string += dump_dictionary(data.env)
	dump_string += DATA_INDICATOR + "\n"
	dump_string += dump_dictionary(data.data)
	dump_string += RABBIT_EXCHANGE_INDICATOR + "\n"
	dump_string += dump_dictionary(data.rabbit_exchange)
	dump_string += RABBIT_ROUTE_INDICATOR + "\n"
	dump_string += dump_dictionary(data.rabbit_route)
	dump_string += RABBIT_SOURCE_INDICATOR + "\n"
	dump_string += dump_dictionary(data.rabbit_source)
	dump_string += RABBIT_ML_INDICATOR + "\n"
	dump_string += dump_dictionary(data.rabbit_message_listener)
	if(to_console):
		print(dump_string)
	else:
		var file = FileAccess.open(dump_path, FileAccess.WRITE)
		file.store_string(dump_string)
		print("Data dumped at: ", dump_path)

static func dump_dictionary(dict : Dictionary) -> String:
	var dict_string = ""
	for key in dict.keys():
		dict_string += "	" + key + "\n"
		for attribute_key in dict[key].keys():
			dict_string += "		" + attribute_key + " : " + array_to_str(dict[key][attribute_key]) + "\n"
	return dict_string

static func array_to_str(array : Array) -> String:
	var result_string : String = ""
	for element in array:
		if(not result_string.is_empty()):
			result_string += "/"
		result_string += element
	return result_string

static func str_to_array(str : String) -> Array:
	return str.split("/")

static func load_from_dump(fuseki_data : FusekiData, yaml_content: String):
	var content = yaml_content.split("\n")
	fuseki_data.service = load_between(content, SERVICES_INDICATOR, ENABLERS_INDICATOR)
	fuseki_data.enabler = load_between(content, ENABLERS_INDICATOR, MODELS_INDICATOR)
	fuseki_data.model = load_between(content, MODELS_INDICATOR, PROVIDED_THING_INDICATOR)
	fuseki_data.provided_thing = load_between(content, PROVIDED_THING_INDICATOR, DATA_TRANSMITTED_INDICATOR)
	fuseki_data.data_transmitted = load_between(content, DATA_TRANSMITTED_INDICATOR, SENSORS_INDICATOR)
	fuseki_data.sensing_component = load_between(content, SENSORS_INDICATOR, SYS_INDICATOR)
	fuseki_data.sys_component = load_between(content, SYS_INDICATOR, ENV_INDICATOR)
	fuseki_data.env = load_between(content, ENV_INDICATOR, DATA_INDICATOR)
	fuseki_data.data = load_between(content, DATA_INDICATOR, RABBIT_EXCHANGE_INDICATOR)
	fuseki_data.rabbit_exchange = load_between(content, RABBIT_EXCHANGE_INDICATOR, RABBIT_ROUTE_INDICATOR)
	fuseki_data.rabbit_route = load_between(content, RABBIT_ROUTE_INDICATOR, RABBIT_SOURCE_INDICATOR)
	fuseki_data.rabbit_source = load_between(content, RABBIT_SOURCE_INDICATOR, RABBIT_ML_INDICATOR)
	fuseki_data.rabbit_message_listener = load_between(content, RABBIT_ML_INDICATOR, EOF_INDICATOR)
	
	FusekiSignals.fuseki_data_updated.emit()

static func load_between(content : PackedStringArray, start_indicator : String, end_indicator : String) -> Dictionary:
	return load_dictionary(content.slice(content.find(start_indicator), content.find(end_indicator)))

static func load_dictionary(lines : Array[String]) -> Dictionary:
	lines.pop_front() #remove indicaor
	var elements : Dictionary = {}
	var last_appended_element : String
	for line in lines:
		if line.begins_with("\t\t"): #is an attribute
			var clean_attribute = clean_line(line)
			var split_attribure = clean_attribute.split(" : ")
			var attribute_name = split_attribure[0]
			var attribute_value = split_attribure[1]
			elements[last_appended_element][attribute_name] = str_to_array(attribute_value)
		else : #is a new element
			var clean_element = clean_line(line)
			last_appended_element = clean_element
			elements[clean_element] = {}
	return elements

static func clean_line(str : String) -> String :
	return str.replace("\t","")

#file picker functions ---------------------------------------------------------
func _on_pick_button_pressed() -> void:
	file_dialog.visible = true

func _on_file_dialog_file_selected(path: String) -> void:
	file_path_input.text = path

func _on_dump_path_edit_focus_entered() -> void:
	CameraSignals.disable_camera_movement.emit()

func _on_dump_path_edit_focus_exited() -> void:
	CameraSignals.enable_camera_movement.emit()
