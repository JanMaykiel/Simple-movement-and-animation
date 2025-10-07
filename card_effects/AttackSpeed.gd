extends Node

func trigger_effect(player, caller) -> void:
	player.attack_speed = 5
	var timer = caller.get_tree().create_timer(5.0)
	timer.timeout.connect(func():
		player.attack_speed = 1
	)
