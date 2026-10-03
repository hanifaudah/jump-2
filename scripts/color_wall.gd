class_name ColorWall
extends StaticBody2D

@onready var sprite = $Sprite2D
@export var color_state: ColorService.ColorState

@onready var collision_shape = $CollisionShape2D

func _ready():
	var mat = ShaderMaterial.new()
	mat.shader = load("res://scripts/player.gdshader")
	mat.set_shader_parameter("tint", ColorService.get_color(color_state))
	sprite.material = mat
	
func set_player_collision(player_color_state: ColorService.ColorState):
	var is_collision_disabled = player_color_state == color_state
	print(is_collision_disabled)
	collision_shape.set_deferred("disabled", is_collision_disabled)
