extends Node

class_name FusekiDataDumper

@onready var file_path_input = $DumpPathEdit

#Dump file indicators
const services_indicator = "Services :"
const services_to_enablers_indicator = "Services to enablers :"
const enablers_to_services_indicator = "Enablers to services :"
const enablers_indicator = "Enablers :"
const enablers_to_models_indicator = "Enablers to models :"
const models_to_enablers_indicator = "Models to enablers :"
const models_indicator = "Models :"
const EOF_indicator = ""

#FusekiDataManager
var FusekiDataManager : FusekiData
func set_fuseki_data_manager(fuseki_data_manager : FusekiData):
	FusekiDataManager = fuseki_data_manager

func _on_load_button_pressed():
	load_from_dump(FusekiDataManager, file_path_input.text)

func _on_dump_button_pressed():
	dump(FusekiDataManager, file_path_input.text)

static func dump(data : FusekiData, dump_path : String, to_console = false):
	var dump_string = ""
	dump_string += services_indicator + "\n"
	dump_string += dump_dictionary(data.service)
	dump_string += services_to_enablers_indicator + "\n"
	dump_string += dump_array_link(data.service_to_enabler)
	dump_string += enablers_to_services_indicator + "\n"
	dump_string += dump_array_link(data.enabler_to_service)
	dump_string += enablers_indicator + "\n"
	dump_string += dump_dictionary(data.enabler)
	dump_string += enablers_to_models_indicator + "\n"
	dump_string += dump_array_link(data.enabler_to_model)
	dump_string += models_to_enablers_indicator + "\n"
	dump_string += dump_array_link(data.model_to_enabler)
	dump_string += models_indicator + "\n"
	dump_string += dump_dictionary(data.model)
	if(to_console):
		print(dump_string)
	else:
		var file = FileAccess.open(dump_path, FileAccess.WRITE)
		file.store_string(dump_string)

static func dump_dictionary(dict : Dictionary) -> String:
	var dict_string = ""
	for key in dict.keys():
		dict_string += "	" + key + "\n"
		for attribute_key in dict[key].keys():
			dict_string += "		" + attribute_key + " : " + dict[key][attribute_key] + "\n"
	return dict_string

static func dump_array_link(list : Array[FusekiData.GenericLinkedNodes]) -> String:
	var array_string = ""
	for link in list:
		array_string += "	" + link.first_node_name + " -> " + link.second_node_name + "\n"
	return array_string

static func load_from_dump(fuseki_data : FusekiData, file_path : String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if (file == null):
		return
	fuseki_data.empty()
	var content = file.get_as_text().split("\n")
	fuseki_data.service = load_dictionary(content.slice(content.find(services_indicator), content.find(services_to_enablers_indicator)))
	fuseki_data.service_to_enabler = load_array_link(content.slice(content.find(services_to_enablers_indicator), content.find(enablers_to_services_indicator)))
	fuseki_data.enabler_to_service = load_array_link(content.slice(content.find(enablers_to_services_indicator), content.find(enablers_indicator)))
	fuseki_data.enabler = load_dictionary(content.slice(content.find(enablers_indicator), content.find(enablers_to_models_indicator)))
	fuseki_data.enabler_to_model = load_array_link(content.slice(content.find(enablers_to_models_indicator), content.find(models_to_enablers_indicator)))
	fuseki_data.model_to_enabler = load_array_link(content.slice(content.find(models_to_enablers_indicator), content.find(models_indicator)))
	fuseki_data.model = load_dictionary(content.slice(content.find(models_indicator), content.find(EOF_indicator)))
	FusekiSignals.fuseki_data_updated.emit()

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
			elements[last_appended_element][attribute_name] = attribute_value
		else : #is a new element
			var clean_element = clean_line(line)
			last_appended_element = clean_element
			elements[clean_element] = {}
	return elements

static func load_array_link(lines : Array[String]) -> Array[FusekiData.GenericLinkedNodes]:
	lines.pop_front() #remove indicator
	var links : Array[FusekiData.GenericLinkedNodes] = []
	for line in lines:
		var clean_line = clean_line(line)
		var split_line = clean_line.split(" -> ")
		var first_element = split_line[0]
		var second_element = split_line[1]
		var link = FusekiData.GenericLinkedNodes.new()
		link.first_node_name = first_element
		link.second_node_name = second_element
		links.append(link)
	return links

static func clean_line(str : String) -> String :
	return str.replace("\t","")
