extends Node

enum Direction {
	DIRECTION_LEFT,
	DIRECTION_RIGHT,
}

@export var player_entity: TopDownEntity2D
@export var animated_sprite_controller: AnimatedSprite2DController

var _last_movement_direction: Direction = Direction.DIRECTION_LEFT

func _ready():
	animated_sprite_controller.play_base_animation("playerIdleLeft")


func _process(_delta):
	var movement_direction = Input.get_vector("left", "right", "up", "down")
	player_entity.direction = movement_direction

	if Input.is_action_pressed("left"):
		_last_movement_direction = Direction.DIRECTION_LEFT

	elif Input.is_action_pressed("right"):
		_last_movement_direction = Direction.DIRECTION_RIGHT
	

	if _last_movement_direction ==  Direction.DIRECTION_LEFT:
		if player_entity.is_moving:
			animated_sprite_controller.play_base_animation("playerWalkLeft")
		else:
			animated_sprite_controller.play_base_animation("playerIdleLeft")

	if _last_movement_direction ==  Direction.DIRECTION_RIGHT:
		if player_entity.is_moving:
			animated_sprite_controller.play_base_animation("playerWalkRight")
		else:
			animated_sprite_controller.play_base_animation("playerIdleRight")
	
	if Input.is_action_just_pressed("attack"):
		if _last_movement_direction == Direction.DIRECTION_LEFT:
			animated_sprite_controller.play_overlay_animation("playerSpellLeft", 1)
		if _last_movement_direction == Direction.DIRECTION_RIGHT:
			animated_sprite_controller.play_overlay_animation("playerSpellRight", 1)
