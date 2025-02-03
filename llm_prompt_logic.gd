extends Node

@onready var llm = %LLM
@onready var rich_text_label = %RichTextLabel

@onready var fuseki_data : FusekiData = FusekiDataGlobal
@onready var fuseki_caller = %FusekiCallerButton

func _ready() -> void:
	if llm.api:
		rich_text_label.append_text("LLM initialized successfully\n")
	else:
		rich_text_label.append_text("LLM was not initialized successfully, check your config")
		return
	
	fuseki_caller.set_fuseki_data_manager(fuseki_data)
	FusekiSignals.fuseki_data_updated.connect(_update_fuseki_data)
	
	llm.add_tool(WeatherTool.new())
	rich_text_label.append_text("WeatherTool registered\n")
	llm.add_tool(UserNameTool.new())
	rich_text_label.append_text("UserName tool registered\n")
	llm.add_tool(SpawnObjectTool.new())
	rich_text_label.append_text("SpawnObject tool registered\n")
	llm.add_tool(DeleteObjectTool.new())
	rich_text_label.append_text("DeleteObject tool registered\n")
	llm.add_tool(ScaleObjectTool.new())
	rich_text_label.append_text("ScaleObject tool registered\n")
	llm.add_tool(RotateObjectTool.new())
	rich_text_label.append_text("RotateObject tool registered\n")
	llm.add_tool(ChangeMaterialTool.new())
	rich_text_label.append_text("ChangeMaterial tool registered\n")
	llm.add_tool(GetSceneInformationTool.new())
	rich_text_label.append_text("GetSceneObjects tool registered\n")
		
	llm.set_system_prompt("You are coder tasked with generating a complex 3D scene.")

func _on_button_pressed() -> void:
	var prompt_text = $MarginContainer/Control/TextEdit.text
	$MarginContainer/Control/TextEdit.clear()
	rich_text_label.append_text("\n\n")
	rich_text_label.append_text(prompt_text)
	rich_text_label.append_text("\n\n")
	var response = await llm.generate_response(prompt_text)
	rich_text_label.append_text("Response: " + JSON.stringify(response, "\t"))

func _update_fuseki_data():
	var prompt_context = "Your task is to generate 3D objects for the following components: "
	prompt_context += str(fuseki_data.sys_component.keys())
	var response = await llm.generate_response(prompt_context)
	rich_text_label.append_text("Response: " + JSON.stringify(response, "\t"))
