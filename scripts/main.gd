extends Node2D

@export var lead: float = 0.0

@onready var camera: Camera2D = $Camera2D
var player: Player
var finish_line: FinishLine
var viewport_size: Vector2
var visible_size: Vector2
var offset: float
var color_walls: Array[ColorWall] = []
var level_num: int = 1
var level: Node
const FINAL_LEVEL_NUM = 3

func _set_level(new_level_num):
	if level: level.queue_free()
	var level_scene = load("res://scenes/level%d.tscn" % new_level_num)
	level = level_scene.instantiate()
	add_child(level)
	
	player = level.get_node("Player") as Player
	player.died.connect(_on_player_died)
	player.level_completed.connect(_on_player_level_completed)
	player.color_changed.connect(_on_player_color_changed)
	player.position.x = player.get_width()
	camera.position.x = player.position.x
	
	color_walls.clear()
	for child in level.get_children():
		if child is ColorWall:
			color_walls.append(child)
	
	finish_line = level.get_node("FinishLine") as FinishLine
	
func _ready():
	viewport_size = get_viewport_rect().size
	
	_set_level(level_num)
	
	camera.zoom = Vector2(0.5, 0.5)   # shows 25% more of the world
	visible_size = viewport_size / camera.zoom
	camera.position.y = viewport_size.y - visible_size.y
	
	offset = -visible_size.x * (1.0/5.0)
	
	_render_background()

func _on_player_died():
	_set_level(level_num)
	
func _on_player_level_completed():
	if level_num == FINAL_LEVEL_NUM:
		get_tree().change_scene_to_file("res://scenes/the_end.tscn")
		return
		
	level_num += 1
	_set_level(level_num)
	
func _on_player_color_changed():
	for wall in color_walls:
		wall.set_player_collision(player.color_state)

func _process(_delta):
	if player:
		# nearing finish line
		if camera.position.x + visible_size.x >= finish_line.position.x:
			camera.position.x = finish_line.position.x - visible_size.x
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
	var s = visible_size.y / sprite.texture.get_size().y
	sprite.scale = Vector2(s, s)
	layer.add_child(sprite)
	
	# Repeat horizontally every one image width (in pixels, after scaling)
	layer.motion_mirroring = sprite.texture.get_size() * s
