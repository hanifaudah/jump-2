class_name Player
extends CharacterBody2D

@export var speed = 10.0
@export var jump_velocity = 450.0
@export var gravity_scale: float = 1.5
@export var fall_multiplier: float = 1.6
@export var spin_speed: float = 6.0   # radians per second (about 1 turn/sec)

@onready var sprite: Sprite2D = $Sprite2D

signal died
signal level_completed

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	velocity.x = speed

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
		
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is Rock:
			die()
			break
		
		if collider is FinishLine:
			level_complete()
			break

func get_width():
	return sprite.get_rect().size.x
	
func die():
	died.emit()

func level_complete():
	level_completed.emit()
