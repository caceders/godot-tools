class_name DamageReceiver extends ResourcePool

signal damage_received(amount: float, damage_dealer: DamageDealer)

@export var ignore_all_damage: bool = false

func damage(p_amount, damage_dealer: DamageDealer):
	if not ignore_all_damage:
		damage_received.emit(p_amount, damage_dealer)
		super.remove_from_pool(p_amount)
