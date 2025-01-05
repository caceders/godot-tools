class_name Player extends CharacterBody2D

const PAUSE_REGENERATION_HURT_TIME = 5
const BASE_ATTACK_AMOUNT = 10
const INVINSIBILITY_TIME = 3

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


@onready var player_entity: TopDownEntity2D = $TopDownEntity2D
@onready var animation_player_controller: AnimationPlayerController = $AnimationPlayerController
@onready var attack_area_left: AttackArea = $AttackAreaLeft
@onready var attack_area_right: AttackArea = $AttackAreaRight
@onready var health: DamageReceiver = $DamageReceiver
@onready var hitbox: CollisionShape2D = $HitBox
@onready var invincibility_manager: InvincibilityManager = $InvincibilityManager
@onready var knockback: Knockback = $Knockback
@onready var attack_controller: AttackController = $AttackController
@onready var sprite: Sprite2D = $Sprite2D

var _active_state = State.PASSIVE
var _last_movement_direction = Direction.LEFT
var _damaged_flag = false

func _ready():
	animation_player_controller.play_base_animation("playerIdleLeft")
	_enter_state(State.PASSIVE)


func _process(_delta):
	_set_active_attack_area()
	_state_process()
	

func _state_process():
	match _active_state:
		State.PASSIVE:
			if health.amount == 0:
				_enter_state(State.DYING)
				return
			elif _damaged_flag:
				_enter_state(State.HURT)
				return
			elif Input.is_action_just_pressed("attack") and attack_controller.can_attack():
				_enter_state(State.ATTACKING)
				return
			_movement()
			return
		State.HURT:
			_enter_state(State.PASSIVE)
			return
		State.ATTACKING:
			if health.amount == 0:
				_enter_state(State.DYING)
				return
			elif _damaged_flag:
				_enter_state(State.HURT)
				return
			elif not attack_controller.is_attacking():
				_enter_state(State.PASSIVE)
			return
		State.DYING:
			_enter_state(State.DEAD)
		State.DEAD:
			return


func _enter_state(state: State):
	_exit_state(_active_state)
	_active_state = state

	#For every state
	_reset_movement()

	match _active_state:
		State.PASSIVE:
			return
		State.HURT:
			_damaged_flag = false
			invincibility_manager.activate_invincibility_for_time(INVINSIBILITY_TIME)
			return
		State.ATTACKING:
			attack_controller.attack(BASE_ATTACK_AMOUNT, true, AttackController.AttackType.ALL)
			_animate_attack()
			return
		State.DYING:
			return
		State.DEAD:
			sprite.visible = false
			return


func _exit_state(state: State):
	match state:
		State.PASSIVE:
			return
		State.ATTACKING:
			return
		State.DYING:
			return
		State.DEAD:
			sprite.visible = true
			return

func ressurect():
	health.amount = health.max_amount
	_enter_state(State.PASSIVE)

func _movement():
	# Set direction
	var movement_direction = Input.get_vector("left", "right", "up", "down")
	player_entity.direction = movement_direction

	# Get direction for animation
	if Input.is_action_pressed("left"):
		_last_movement_direction = Direction.LEFT
	elif Input.is_action_pressed("right"):
		_last_movement_direction = Direction.RIGHT

	# Animate
	if _last_movement_direction == Direction.LEFT:
		if player_entity.is_moving:
			animation_player_controller.play_base_animation("playerWalkLeft")
		else:
			animation_player_controller.play_base_animation("playerIdleLeft")

	if _last_movement_direction == Direction.RIGHT:
		if player_entity.is_moving:
			animation_player_controller.play_base_animation("playerWalkRight")
		else:
			animation_player_controller.play_base_animation("playerIdleRight")


func _on_damage_received(_amount: float, p_knockback: bool, damage_dealer: DamageDealer):
	_damaged_flag = true


func _reset_movement():
	player_entity.direction = Vector2.ZERO


func _animate_attack():
	if _last_movement_direction == Direction.LEFT:
		animation_player_controller.play_overlay_animation("playerAttackLeft", 1)
	else:
		animation_player_controller.play_overlay_animation("playerAttackRight", 1)

func _set_active_attack_area():
	if _last_movement_direction == Direction.LEFT:
		attack_controller.attack_area = attack_area_left
	else:
		attack_controller.attack_area = attack_area_right
