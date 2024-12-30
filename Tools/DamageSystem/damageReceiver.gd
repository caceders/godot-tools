class_name DamageReceiver extends ResourcePool

signal damage_received(amount: float)

@export var ignore_all_damage: bool = false

func damage(p_amount):
	if not ignore_all_damage:
		damage_received.emit(p_amount)
		super.remove_from_pool(p_amount)