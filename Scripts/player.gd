extends Node

const ATTACK_DURATION = .2
const ATTACK_INTERVAL_TIME = .5

enum State {PASSIVE,
			ATTACKING,
			HURT,
			DYING,
			DEAD,
}

enum Direction {
	LEFT,
	RIGHT,
}


@export var player_entity: TopDownEntity2D
@export var animated_sprite_controller: AnimatedSprite2DController
@export var attack_area_left: Area2D
@export var attack_area_right: Area2D
@export var health: ResourcePool

var _attack_interval_timer : Timer
var _attack_duration_timer : Timer
var _active_state = State.PASSIVE
var _attack_target  : Node2D

var _last_movement_direction: Direction = Direction.LEFT

func _ready():
	animated_sprite_controller.play_base_animation("playerIdleLeft")

	_attack_interval_timer = Timer.new()
	_attack_interval_timer.one_shot = true
	add_child(_attack_interval_timer)

	_attack_duration_timer = Timer.new()
	_attack_duration_timer.one_shot = true
	add_child(_attack_duration_timer)



func _process(_delta):

	match _active_state:
		State.PASSIVE:
			_move_around()
			if Input.is_action_just_pressed("attack") and _attack_interval_timer.time_left == 0:
				enter_state(State.ATTACKING)
			return
		State.ATTACKING:
			if _attack_duration_timer.time_left == 0:
				enter_state(State.PASSIVE)
			return
		State.DYING:
			return
		State.DEAD:
			return


func enter_state(state: State):
	exit_state(_active_state)
	_active_state = state
	match _active_state:
		State.PASSIVE:
			return
		State.ATTACKING:
			player_entity.direction = Vector2.ZERO
			_attack_interval_timer.start(ATTACK_INTERVAL_TIME)
			_attack_duration_timer.start(ATTACK_DURATION)

			if _last_movement_direction == Direction.LEFT:
				animated_sprite_controller.play_overlay_animation("playerAttackLeft", 1)
				return
			if _last_movement_direction == Direction.RIGHT:
				animated_sprite_controller.play_overlay_animation("playerAttackRight", 1)
				return
			return
		State.DYING:
			return
		State.DEAD:
			return

func exit_state(state: State):
	match _active_state:
		State.PASSIVE:
			return
		State.ATTACKING:
			return
		State.DYING:
			return
		State.DEAD:
			return


func _move_around():
	var movement_direction = Input.get_vector("left", "right", "up", "down")
	player_entity.direction = movement_direction

	if Input.is_action_pressed("left"):
		_last_movement_direction = Direction.LEFT

	elif Input.is_action_pressed("right"):
		_last_movement_direction = Direction.RIGHT
	

	if _last_movement_direction ==  Direction.LEFT:
		if player_entity.is_moving:
			animated_sprite_controller.play_base_animation("playerWalkLeft")
		else:
			animated_sprite_controller.play_base_animation("playerIdleLeft")

	if _last_movement_direction ==  Direction.RIGHT:
		if player_entity.is_moving:
			animated_sprite_controller.play_base_animation("playerWalkRight")
		else:
			animated_sprite_controller.play_base_animation("playerIdleRight")