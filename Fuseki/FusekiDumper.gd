extends FusekiData

class_name FusekiDataDumper

#An extension to the class FusekiData could be calles in its place
#Permit the usage of dump_to_console function if needed for debug purpuses

func dump_to_console():
	print("Services :")
	display_dictionary(service)
	print("Services to enablers :")
	display_array_link(service_to_enabler)
	print("Enablers to services :")
	display_array_link(enabler_to_service)
	print("Enablers :")
	display_dictionary(enabler)
	print("Enablers to models :")
	display_array_link(enabler_to_model)
	print("Models to enablers :")
	display_array_link(model_to_enabler)
	print("Models :")
	display_dictionary(model)

func display_dictionary(dict : Dictionary):
	for key in dict.keys():
		print("	" + key)
		for attribute_key in dict[key].keys():
			print("		" + attribute_key + " : " + dict[key][attribute_key])

func display_array_link(list : Array[GenericLinkedNodes]):
	for link in list:
		print("	" + link.first_node_name + " -> " + link.second_node_name)
