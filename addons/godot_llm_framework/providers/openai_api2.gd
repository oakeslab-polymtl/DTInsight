extends LLMProviderAPI
## LocalAPI: A class for interacting with a local LMStudio API to generate responses using your language models.
##
## This class implements the LLMProviderAPI interface for the Local API,
## allowing generation of responses and handling of tool calls using local models.
## It provides methods for generating responses, getting available models, and preparing tool data for requests.
##
## @tutorial: https://lmstudio.ai/docs/api/server

class_name OpenAIAPI2

## The base URL for the Local API.
const API_URL = "https://api.openai.com/v1/chat/completions"

var system_prompt: String

func generate_response(params: Dictionary) -> Dictionary:
	var headers = {
		"Authorization": "Bearer " + api_key,
		"Content-Type": "application/json"
	}
	
	LogDuck.d("LLM Message Parameters are: " + JSON.stringify(params))

	var body = {
		"model": params.get("model", "qwen2.5-3b-instruct"),
		"max_tokens": params.get("max_tokens", 1024),
		"messages": params.get("messages"),
		"temperature": params.get("temperature", 1.0),
		"top_p": params.get("top_p", 1.0),
		"top_k": params.get("top_k", -1),
		"stream": false
	}

	## Adds tools to the body if they are provided
	if params.has("tools"):
		body["tools"] = params.get("tools")
		LogDuck.d("Tools request is: " + str(params.get("tools")))
	
	# Adds system prompt if it has been provided
	if params.has("system") && params.get("system") != "":
		body["messages"].append({
			"role": "system",
			"content": params.get("system")
		})
	elif system_prompt:
				body["messages"].append({
			"role": "system",
			"content": system_prompt
		})

	var response = await _make_request(API_URL, headers, body)
	LogDuck.d("LLM Response: " + str(response))
	
	var error_message

	if response.has("error"):
		error_message = "Local API error: " + response.error.message
		push_error(error_message)
		return {"Error": error_message}
	
	#if response.has("content"):
		#return response
	
	# Check if the nested key exists
	if response.has("choices") and response["choices"].size() > 0:
		return response["choices"][0]
	else:
		print("Key 'choices' is missing or empty.")
	
	# If we reach this point, there was an unexpected response format
	error_message = "Unexpected response format from Local API"
	push_error(error_message)
	return {"Error": error_message}

func get_available_models() -> Array:
	return [
		"TODO: List local API models"
	]

func extract_response_message(response: Dictionary) -> Dictionary:
	return response.Error if response.has("Error") else response.message

func supports_tool_use() -> bool:
	return true

func prepare_tools_for_request(tools: Array) -> Array:
	var prepared_tools = []
	for tool in tools:
		prepared_tools.append(tool.to_dict())
	return prepared_tools

func has_tool_calls(response: Dictionary) -> bool:
	return response.has("finish_reason") && response.finish_reason == "tool_calls"

func extract_tool_calls(response: Dictionary) -> Array:
	LogDuck.d("Response from extract_tool_calls looks like: " + str(response))
	var tool_calls = []
	for calls in response.message.get("tool_calls", []):
		tool_calls.append({
			"id": calls.get("id"),
			"name": calls.function.get("name"),
			"input": JSON.parse_string(calls.function.get("arguments"))
		})
	LogDuck.d("Response from tool_calls looks like: " + str(tool_calls))
	return tool_calls

func format_tool_result(tool_result: Dictionary) -> Dictionary:
	LogDuck.d("format_tool_results param of tool_result: " + str(tool_result))
	var is_error = false
	if tool_result.output.has("is_error"):
		is_error = tool_result.output.is_error
		tool_result.output.erase("is_error")
	return {
		"role": "tool",
		"content": tool_result.output.output,
		"name": tool_result.name
		}

func supports_system_prompt() -> bool:
	return true

func set_system_prompt(prompt: String) -> void:
	system_prompt = prompt

func get_system_prompt() -> String:
	return system_prompt
