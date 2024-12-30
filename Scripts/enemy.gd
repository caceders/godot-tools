extends Node

const MIN_STILL_TIME = .5
const MAX_STILL_TIME = 20
const MAX_STRAFE_RADIUS = 50
const ACCEPTABLE_DISTANCE_TO_STRAFE_POSITION = 1
const CHARGE_ATTACK_TIME = .5

enum State {IDLE,
			STRAFING,
			HUNTING,
			HURT,
			CHARGING,
			ATTACKING,
			DYING,
			DEAD,
}


enum Direction {
			LEFT,
			RIGHT,
}

@export var entity: TopDownEntity2D
@export var animation_player_controller : AnimationPlayerController
@export var detection_area: Area2D
@export var attack_area: Area2D
@export var target_groups: Array[String]
@export var health: ResourcePool
@export var damage_dealer: DamageDealer
var _target: Node2D

var _stand_still_timer : Timer
var _charge_attack_timer : Timer
var _active_state = State.IDLE
var _last_movement_direction = Direction.LEFT

var _strafe_position : Vector2

func _ready():
	_stand_still_timer = Timer.new()
	_stand_still_timer.one_shot = true
	add_child(_stand_still_timer)

	_charge_attack_timer = Timer.new()
	_charge_attack_timer.one_shot = true
	add_child(_charge_attack_timer)

	animation_player_controller.play_base_animation("enemyIdleLeft")


func _process(_delta):

	match _active_state:
		State.IDLE:
			if health.amount == 0:
				enter_state(State.DYING)
				return
			if _target_in_sight():
				enter_state(State.HUNTING)
				return
			if _stand_still_timer.time_left == 0:
				enter_state(State.STRAFING)
				return
			return
				
		State.STRAFING:

			if health.amount == 0:
				enter_state(State.DYING)
				return

			if _target_in_sight():
				enter_state(State.HUNTING)
				return

			var vector_to_strafe_position = _strafe_position - entity.global_position
			entity.direction = vector_to_strafe_position.normalized()

			if entity.direction.x < 0:
				animation_player_controller.play_base_animation("enemyWalkLeft")
				_last_movement_direction = Direction.LEFT
			else:
				animation_player_controller.play_base_animation("enemyWalkRight")
				_last_movement_direction = Direction.RIGHT

			if vector_to_strafe_position.length() < ACCEPTABLE_DISTANCE_TO_STRAFE_POSITION:
				enter_state(State.IDLE)
			return

		State.HUNTING:
			
			if health.amount == 0:
				enter_state(State.DYING)
				return

			if not _target_in_sight():
				enter_state(State.IDLE)
				return

			if _target_in_attack_range():
				enter_state(State.CHARGING)
				return

			entity.direction = (_target.global_position - entity.global_position)
			if entity.direction.x < 0:
				animation_player_controller.play_base_animation("enemyWalkLeft")
				_last_movement_direction = Direction.LEFT
			else:
				animation_player_controller.play_base_animation("enemyWalkRight")
				_last_movement_direction = Direction.RIGHT
			return
			
		State.CHARGING:

			if health.amount == 0:
				enter_state(State.DYING)
				return

			if not _target_in_attack_range():
				enter_state(State.HUNTING)
				return

			if _charge_attack_timer.time_left == 0:
				enter_state(State.ATTACKING)
			var vector_to_target = _get_vector_to_target()
			if vector_to_target.x < 0:
				animation_player_controller.play_base_animation("enemyChargeAttackLeft")
			else:
				animation_player_controller.play_base_animation("enemyChargeAttackRight")
			return
				
			
		State.ATTACKING:
			
			if health.amount == 0:
				enter_state(State.DYING)
				return

			enter_state(State.CHARGING)
			return
			
		State.DYING:
			enter_state(State.DEAD)
			return
			
		State.DEAD:
			animation_player_controller.play_base_animation("enemyDead")
			


func enter_state(state: State):

	exit_state(_active_state)
	_active_state = state

	match state:
		State.IDLE:

			entity.direction = Vector2.ZERO

			if _last_movement_direction == Direction.LEFT:
				animation_player_controller.play_base_animation("enemyIdleLeft")
			if _last_movement_direction == Direction.RIGHT:
				animation_player_controller.play_base_animation("enemyIdleRight")
			_stand_still_timer.start(randf_range(MIN_STILL_TIME, MAX_STILL_TIME))
			_stand_still_timer.paused = false
			return
			
		State.STRAFING:
			# Pick a random spot nearby and walk to
			var strafe_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			_strafe_position = strafe_direction * randf_range(0, MAX_STRAFE_RADIUS)
			return
			
		State.HUNTING:
			pass
			
		State.CHARGING:
			entity.direction = Vector2(0,0)
			_charge_attack_timer.start(CHARGE_ATTACK_TIME)
			return
			
		State.ATTACKING:

			# Deal damage
			var target_damage_receiver = _target.get_node("DamageReceiver")
			if target_damage_receiver != null:
				damage_dealer.deal_damage(10, target_damage_receiver)

			# Animate
			var vector_to_target = _get_vector_to_target()
			if vector_to_target.x < 0:
				animation_player_controller.play_overlay_animation("enemyAttackLeft", 1)
			else:
				animation_player_controller.play_overlay_animation("enemyAttackRight", 1)
			return
			
		State.DYING:
			animation_player_controller.play_overlay_animation("enemyDie", 1)
			
		State.DEAD:
			entity.direction = Vector2(0,0)
			return
			


func exit_state(state: State):
	match state:
		State.IDLE:
			pass
			
		State.STRAFING:
			pass
			
		State.HUNTING:
			_target = null
			return
			
		State.CHARGING:
			pass
			
		State.ATTACKING:
			pass
			
		State.DYING:
			pass
			
		State.DEAD:
			pass


func _body_is_target(body: Node2D):
	var groups = body.get_groups()
	for group in groups:
		if group in target_groups:
			return true
	return false

func _target_in_sight():
	var bodies_in_sight = detection_area.get_overlapping_bodies()
	for body in bodies_in_sight:
		if _body_is_target(body):
			_target = body
			return true
	return false


func _target_in_attack_range():
	var bodies_in_sight = attack_area.get_overlapping_bodies()
	for body in bodies_in_sight:
		if _body_is_target(body):
			_target = body
			return true
	return false

func _get_vector_to_target():
	return (_target.global_position - entity.global_position)
