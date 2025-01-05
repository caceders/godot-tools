class_name AttackController extends Node2D

enum AttackType{
	NEAREST,
	ALL,
}

@export var attack_area: AttackArea
@export var damage_dealer: DamageDealer

@export var attack_cooldown: float = 1
@export var attack_duration: float = .2

var _attack_cooldown_timer : Timer
var _attack_duration_timer : Timer

func _ready():
	_attack_cooldown_timer = Timer.new()
	_attack_cooldown_timer.one_shot = true
	add_child(_attack_cooldown_timer)

	_attack_duration_timer = Timer.new()
	_attack_duration_timer.one_shot = true
	add_child(_attack_duration_timer)


func attack(amount: float, knockback: bool, attack_type: AttackType):
	if attack_type == AttackType.NEAREST:
		attack_area.attack_nearest_body_in_group(amount, knockback, damage_dealer)
	elif attack_type == AttackType.ALL:
		attack_area.attack_all_bodies_in_group(amount, knockback, damage_dealer)
	_attack_cooldown_timer.start(attack_cooldown)
	_attack_duration_timer.start(attack_duration)

func can_attack():
	return _attack_cooldown_timer.time_left == 0

func is_attacking():
	return _attack_duration_timer.time_left != 0