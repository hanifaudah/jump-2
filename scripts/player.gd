class_name Player
extends CharacterBody2D

@export var speed = 10.0
@export var jump_velocity = 450.0
@export var gravity_scale: float = 1.5
@export var fall_multiplier: float = 1.6
@export var spin_speed: float = 6.0   # radians per second (about 1 turn/sec)
var color_state: ColorService.ColorState = ColorService.ColorState.BLACK

@onready var sprite: Sprite2D = $Sprite2D

var mat: ShaderMaterial

signal died
signal level_completed
signal color_changed

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	mat = ShaderMaterial.new()
	mat.shader = load("res://scripts/player.gdshader")
	sprite.material = mat
	
	_update_color(ColorService.ColorState.BLACK)
	velocity.x = speed
	
func _update_color(new_color_state: ColorService.ColorState):
	mat.set_shader_parameter("tint", ColorService.get_color(new_color_state))
	color_state = new_color_state
	color_change()

func _handle_color_change():
	if Input.is_action_pressed("cyan"):
		_update_color(ColorService.ColorState.CYAN)
		return
		
	if Input.is_action_pressed("magenta"):
		_update_color(ColorService.ColorState.MAGENTA)
		return
		
	if Input.is_action_pressed("yellow"):
		_update_color(ColorService.ColorState.YELLOW)
		return
	
	_update_color(ColorService.ColorState.BLACK)
	
func _physics_process(delta):
	move_and_slide()
	
	# Gravity
	if not is_on_floor():
		var g = gravity * gravity_scale
		if velocity.y > 0:  # falling
			g *= fall_multiplier
		velocity.y += g * delta
		
	if is_on_floor():
		sprite.rotation = 0.0
	else:
		sprite.rotation += spin_speed * delta
		
	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -1 * jump_velocity
	
	_handle_color_change()
		
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is Rock:
			die()
			break
		
		if collider is FinishLine:
			level_complete()
			break
			
		if collider is ColorWall:
			var color_wall = collider as ColorWall
			if color_wall.color_state != color_state:
				die()
				break

func get_width():
	return sprite.get_rect().size.x
	
func die():
	died.emit()

func level_complete():
	level_completed.emit()
	
func color_change():
	color_changed.emit()
