extends Node

var server := TCPServer.new()
var port = 9090
var save_path = OS.get_user_data_dir() + "/latest_screenshot.png"

func _ready():
	start_server()

func start_server():
	if server.listen(port) == OK:
		print("ScreenshotServer started on port ", port)
	else:
		print("Failed to start ScreenshotServer")

func _process(_delta):
	if server.is_connection_available():
		var client = server.take_connection()
		handle_request(client)

func handle_request(client: StreamPeerTCP):
	client.put_data("HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nScreenshot taken!".to_utf8_buffer())
	
	# Capture the screenshot
	var img = get_viewport().get_texture().get_image()
	img.save_png(save_path)
	print("Screenshot saved at: ", save_path)

	client.disconnect_from_host()
