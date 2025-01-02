extends CharacterBody2D

const ATTACK_DURATION = .2
const ATTACK_INTERVAL_TIME = .5
const FLSH_LERP_WEIGHT = 15
const PAUSE_REGENERATION_HURT_TIME = 5
const INVINSIBIBILY_TIME = 1

enum State {PASSIVE,
			INVINSIBLE,
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
@export var animation_player_controller: AnimationPlayerController
@export var attack_area_left: Area2D
@export var attack_area_right: Area2D
@export var health: ResourcePool
@export var hitbox: CollisionShape2D

var _attack_interval_timer : Timer
var _attack_duration_timer : Timer
var _active_state = State.PASSIVE
var _attack_target: Node2D

var _last_movement_direction: Direction = Direction.LEFT

var _damaged_flag: bool = false
var _damage_from_vector = Vector2.ZERO

func _ready():
	animation_player_controller.play_base_animation("playerIdleLeft")

	_attack_interval_timer = Timer.new()
	_attack_interval_timer.one_shot = true
	add_child(_attack_interval_timer)

	_attack_duration_timer = Timer.new()
	_attack_duration_timer.one_shot = true
	add_child(_attack_duration_timer)



func _process(_delta):

	match _active_state:
		State.PASSIVE:
			if health.amount == 0:
				enter_state(State.DYING)
				return
			if _damaged_flag:
				enter_state(State.HURT)
				return
			if Input.is_action_just_pressed("attack") and _attack_interval_timer.time_left == 0:
				enter_state(State.ATTACKING)
				return
			_move_around()
			return
		State.HURT:
			if health.amount == 0:
				enter_state(State.DYING)
				return
			enter_state(State.PASSIVE)
		State.INVINSIBLE:
			if health.amount == 0:
				enter_state(State.DYING)
				return
			return
		State.ATTACKING:
			if health.amount == 0:
				enter_state(State.DYING)
				return
			if _damaged_flag:
				enter_state(State.HURT)
				return
			if _attack_duration_timer.time_left == 0:
				enter_state(State.PASSIVE)
				return
			return
		State.DYING:
			enter_state(State.DEAD)
			return
		State.DEAD:
			return


func enter_state(state: State):
	exit_state(_active_state)
	_active_state = state
	match _active_state:
		State.PASSIVE:
			health.enable_growth = true
			player_entity.reacts_to_impulses = true
			hitbox.disabled = false
			return
		State.HURT:
			health.enable_growth = true
			player_entity.reacts_to_impulses = true
			if _last_movement_direction == Direction.LEFT:
				animation_player_controller.play_overlay_animation("playerHurtLeft", 1)
			if _last_movement_direction == Direction.RIGHT:
				animation_player_controller.play_overlay_animation("playerHurtRight", 1)
			player_entity.add_impulse(-_damage_from_vector)
			health.pause_growth_for(PAUSE_REGENERATION_HURT_TIME)
			_damaged_flag = false
			return
		State.INVINSIBLE:
			health.pause_for(INVINSIBIBILY_TIME)
			player_entity.reacts_to_impulses = true
			hitbox.disabled = false
			return
		State.ATTACKING:
			health.enable_growth = true
			player_entity.reacts_to_impulses = true
			hitbox.disabled = false
			player_entity.direction = Vector2.ZERO
			_attack_interval_timer.start(ATTACK_INTERVAL_TIME)
			_attack_duration_timer.start(ATTACK_DURATION)

			if _last_movement_direction == Direction.LEFT:
				animation_player_controller.play_overlay_animation("playerAttackLeft", 1)
			if _last_movement_direction == Direction.RIGHT:
				animation_player_controller.play_overlay_animation("playerAttackRight", 1)
			return 
		State.DYING:
			health.enable_growth = false
			player_entity.reacts_to_impulses = false
			hitbox.disabled = true
			player_entity.direction = Vector2.ZERO
			animation_player_controller.play_overlay_animation("playerDying", 1)
			return
		State.DEAD:
			health.enable_growth = false
			player_entity.reacts_to_impulses = false
			hitbox.disabled = true
			player_entity.direction = Vector2.ZERO
			animation_player_controller.play_base_animation("playerDead")
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
			animation_player_controller.play_base_animation("playerWalkLeft")
		else:
			animation_player_controller.play_base_animation("playerIdleLeft")

	if _last_movement_direction ==  Direction.RIGHT:
		if player_entity.is_moving:
			animation_player_controller.play_base_animation("playerWalkRight")
		else:
			animation_player_controller.play_base_animation("playerIdleRight")

func _flash(delta_time):
	animation_player_controller.modulate.a = lerp(animation_player_controller.modulate.a, 0, 1 - exp(delta_time * -FLSH_LERP_WEIGHT))

func _on_damage_received(_amount: float, damage_dealer : DamageDealer):
	_damaged_flag = true
	var _damage_from_entity = damage_dealer.get_parent() as Node2D
	_damage_from_vector = _damage_from_entity.position - position


func ressurect():
	health.amount = health.max_amount
	enter_state(State.PASSIVE)
