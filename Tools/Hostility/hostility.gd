class_name Hostility extends Node2D

enum HostiltiyState {
    IDLE,
    HUNTING,
    ATTACKING,
}

@export var entity : TopDownEntity2D
@export var vision : Vision
@export var strafer: Strafer
@export var chaser_evader: ChaserEvader
@export var attack_controller: AttackController
@export var attack_area: AttackArea
@export var damage_receiver: DamageReceiver

@export var enabled: bool = true
@export var hostile_groups: Array[String]= []
@export var specific_hostiles: Array[Node2D]
@export var strafe_on_non_hostile_mode: bool = true

@export var is_stunable: bool = true
@export var attack_amount: float = 20
@export var attack_knockback: bool = true

var _target: Node2D
var _hostility_state: HostiltiyState = HostiltiyState.IDLE

func _ready():
    if strafe_on_non_hostile_mode: strafer.enable()
    else: strafer.disable()

func _process(delta):
    if not enabled:
        return
    
    match _hostility_state:
        HostiltiyState.IDLE:
            _look_for_targets()
            return
        HostiltiyState.HUNTING:
            if not _target:
                _enter_state(HostiltiyState.IDLE)
                return
            if attack_area.is_body_in_attack_range(_target):
                _enter_state(HostiltiyState.ATTACKING)
                return
        HostiltiyState.ATTACKING:
            if not _target:
                attack_controller.cancel_attack()
                _enter_state(HostiltiyState.IDLE)
                return
            if not attack_area.is_body_in_attack_range(_target):
                attack_controller.cancel_attack()
                _enter_state(HostiltiyState.HUNTING)
                return
            if attack_controller.can_attack():
                attack_controller.charge_and_attack(attack_amount, attack_knockback, _target)
                return

func _enter_state(state: HostiltiyState):
    if not enabled:
        return
    _hostility_state = state
    match _hostility_state:
        HostiltiyState.IDLE:
            chaser_evader.disable()
            if strafe_on_non_hostile_mode:
                strafer.enable()
            return
        HostiltiyState.HUNTING:
            strafer.disable()
            chaser_evader.enable()
            return
        HostiltiyState.ATTACKING:
            strafer.disable()
            chaser_evader.disable()
            attack_controller.charge_and_attack(attack_amount, attack_knockback, _target)
            return

func _look_for_targets():
    var bodies = vision.get_bodies_in_sight()
    for body in bodies:
        if body in specific_hostiles:
            _target = body
            _enter_state(HostiltiyState.HUNTING)
            return
        for group in hostile_groups:
            if group in body.get_groups():
                _target = body
                _enter_state(HostiltiyState.HUNTING)
                return

func _on_damage_taken():
    if is_stunable:
        entity.stun()
        attack_controller.stun()
