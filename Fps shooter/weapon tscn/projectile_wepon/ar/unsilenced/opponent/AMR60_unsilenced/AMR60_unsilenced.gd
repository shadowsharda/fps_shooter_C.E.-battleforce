extends basic_opponent_weapons_script







func _on_Spatial_shoooting_bullets():
	firerate_timer.set_paused(false)
	print_debug("shooting")
