class_name AttackArea extends Area2D

@export var damage_dealer: DamageDealer

func AttackAllDamagable(amount):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Damagable"):
			var target_damage_receiver = body.get_node("DamageReceiver")
			damage_dealer.deal_damage(amount, target_damage_receiver)