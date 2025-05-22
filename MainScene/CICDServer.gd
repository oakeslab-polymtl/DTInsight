extends Node

@export var margins : Vector2 = Vector2(50, 300)
@export var container : DT_PT
@export var to_hide : Array[Node] = []

var server := TCPServer.new()
@export var port = 9090
var screenshot_save_path = OS.get_user_data_dir() + "/latest_screenshot.png"
var dump_save_path = OS.get_user_data_dir() + "/data_dump.yaml"

func _ready():
	if not OS.has_feature("web"):
		start_server()

func start_server():
	if server.listen(port) == OK:
		print("CICDServer started on port ", port)
	else:
		print("Failed to start CICDServer")

func _process(_delta):
	if server.is_connection_available():
		var client = server.take_connection()
		handle_request(client)

func handle_request(client: StreamPeerTCP):
	# Call the Fuseki server
	var fuseki_button = get_tree().root.get_node("MainScene/%FusekiCallerButton")
	fuseki_button._on_pressed()
	
	# Wait for the visualization to load
	await get_tree().create_timer(1).timeout
	
	# Dump the yaml
	dump_yaml()
	
	# Capture a screenshot
	capture_image()
	
	# Return a success string
	client.put_data("HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 33\r\n\r\nScreenshot taken and data dumped!".to_utf8_buffer())
	
	# Wait until the image is saved
	await get_tree().create_timer(0.2).timeout

	# Disconnect the client
	client.disconnect_from_host()


func capture_image():
	print("[Start Capture...]")
	
	# Hide nodes (UI)
	for node_to_hide: Node in to_hide:
		node_to_hide.visible = false
	
	var camera=Camera2D.new()
	self.add_child(camera)
	camera.anchor_mode=Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	camera.enabled = true
	camera.make_current()
	var full_rect = container.get_rect()
	
	# Apply margins around the screenshot container
	full_rect.position.x -= margins.x / 2
	full_rect.position.y -= margins.y / 2
	full_rect.size.x += margins.x
	full_rect.size.y += margins.y
	
	var starting_position = full_rect.position
	camera.position = starting_position

	var tree=get_tree()
	tree.paused = true
	await tree.process_frame

	var viewport_size = get_viewport().size / camera.zoom.x
	var image = Image.create_empty(full_rect.size.x, full_rect.size.y, false, Image.FORMAT_RGBA8)
	# Take multiple screenshots and merge them into one image
	while camera.position.y < full_rect.size.y:
		while camera.position.x < full_rect.size.x:
			await tree.process_frame
			var segment = camera.get_viewport().get_texture().get_image()
			
			# Ensure segment uses the same format as the main image
			if segment.get_format() != Image.FORMAT_RGBA8:
				segment.convert(Image.FORMAT_RGBA8)
						
			var target_position = Vector2i(int(camera.position.x - full_rect.position.x), int(camera.position.y - full_rect.position.y))
			var src_rect = Rect2i(Vector2i(0, 0), Vector2i(segment.get_width(), segment.get_height()))
			image.blit_rect(segment, src_rect, target_position)
			
			camera.position.x += viewport_size.x

		camera.position.x = full_rect.position.x
		camera.position.y += viewport_size.y
	
	# Save the screenshot on the disk
	image.save_png(screenshot_save_path)
	print("Screenshot saved at: ", screenshot_save_path)
	get_tree().paused = false
	camera.queue_free()
	
	# Show nodes
	for node_to_hide: Node in to_hide:
		node_to_hide.visible = true
	
	print("[END Capture...]")

func dump_yaml():
	var dumper_controller = get_tree().root.get_node("MainScene/%FusekiDumperController")
	var fuseki_data : FusekiData = get_tree().root.get_node("MainScene/FusekiData")
	dumper_controller.dump(fuseki_data, dump_save_path)
