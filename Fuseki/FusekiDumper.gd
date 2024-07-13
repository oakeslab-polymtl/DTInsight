extends Node

class_name FusekiDataDumper

const DUMP_PATH = "D:/Polytechnique/DTdump"

static func dump(data : FusekiData, to_console = false):
	var dump_string = ""
	dump_string += "Services :\n"
	dump_string += dump_dictionary(data.service)
	dump_string += "Services to enablers :\n"
	dump_string += dump_array_link(data.service_to_enabler)
	dump_string += "Enablers to services :\n"
	dump_string += dump_array_link(data.enabler_to_service)
	dump_string += "Enablers :\n"
	dump_string += dump_dictionary(data.enabler)
	dump_string += "Enablers to models :\n"
	dump_string += dump_array_link(data.enabler_to_model)
	dump_string += "Models to enablers :\n"
	dump_string += dump_array_link(data.model_to_enabler)
	dump_string += "Models :\n"
	dump_string += dump_dictionary(data.model)
	if(to_console):
		print(dump_string)
	else:
		var file = FileAccess.open(DUMP_PATH, FileAccess.WRITE)
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
