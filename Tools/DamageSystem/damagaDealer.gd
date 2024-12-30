class_name DamageDealer extends Node

func deal_damage(amount: float, damage_receiver: DamageReceiver):
	damage_receiver.damage(amount)