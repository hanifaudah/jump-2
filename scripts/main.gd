extends Node2D

@export var lead: float = 0.0

@onready var camera: Camera2D = $Camera2D
var player: Player
var finish_line: FinishLine
var viewport_size: Vector2
var offset: float

func _ready():
	viewport_size = get_viewport_rect().size
	
	_render_background()
	
	offset = -viewport_size.x * (1.0/3.0)
	var level_scene = load("res://scenes/level1.tscn")
	var level = level_scene.instantiate()
	add_child(level)

	player = level.get_node("Player") as Player
	player.died.connect(_on_player_died)
	player.level_completed.connect(_on_player_level_completed)
	player.position.x = player.get_width()
	
	finish_line = level.get_node("FinishLine") as FinishLine

func _on_player_died():
	get_tree().reload_current_scene()
	
func _on_player_level_completed():
	get_tree().reload_current_scene()

func _process(_delta):
	if player:
		# nearing finish line
		if camera.position.x + viewport_size.x >= finish_line.position.x:
			camera.position.x = finish_line.position.x - viewport_size.x
		else:
			camera.position.x = max(camera.position.x, player.global_position.x + offset)
			
		
func _render_background():
	# Parallax setup
	var bg = ParallaxBackground.new()
	add_child(bg)

	var layer = ParallaxLayer.new()
	layer.motion_scale = Vector2(0.5, 0.5)  # use Vector2.ZERO for a fixed backdrop
	bg.add_child(layer)

	# The image
	var sprite = Sprite2D.new()
	sprite.texture = load("res://assets/paper_bg.jpg")  # change to your image path
	sprite.centered = false
	# Scale to viewport height, keep aspect ratio so the tiles don't stretch
	var s = viewport_size.y / sprite.texture.get_size().y
	sprite.scale = Vector2(s, s)
	layer.add_child(sprite)
	
	# Repeat horizontally every one image width (in pixels, after scaling)
	layer.motion_mirroring = Vector2(sprite.texture.get_size().x * s, 0)
