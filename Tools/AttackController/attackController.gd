class_name AttackController extends Node

var attack_cooldown: float = 1
var attack_duration: float = .2

var _attack_cooldown_timer : Timer
var _attack_duration_timer : Timer

func _ready():
	_attack_cooldown_timer = Timer.new()
	_attack_cooldown_timer.one_shot = true
	add_child(_attack_cooldown_timer)

	_attack_duration_timer = Timer.new()
	_attack_duration_timer.one_shot = true
	add_child(_attack_duration_timer)


func _process(delta):
	pass
