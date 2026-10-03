class_name Player
extends CharacterBody2D

@export var speed = 10.0
@export var jump_velocity = 450.0
@export var gravity_scale: float = 1.5
@export var fall_multiplier: float = 1.6

@onready var sprite: Sprite2D = $Sprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	velocity.x = speed

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		var g = gravity * gravity_scale
		if velocity.y > 0:  # falling
			g *= fall_multiplier
		velocity.y += g * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -1 * jump_velocity

	move_and_slide()
	
func get_width():
	return sprite.get_rect().size.x
