extends Node

# Signals
signal birds_changed(count)
signal add_bird_requested
signal remove_bird_requested
signal set_bird_count_requested(count)

signal toggle_sound_requested(enabled)

# Current state information
var current_bird_count: int = 0
var sound_enabled: bool = true

# Request functions
func request_add_bird():
	emit_signal("add_bird_requested")
	
func request_remove_bird():
	emit_signal("remove_bird_requested")
	
func request_set_bird_count(count: int):
	emit_signal("set_bird_count_requested", count)
	
# Update functions
func update_bird_count(count: int):
	current_bird_count = count
	emit_signal("birds_changed", count)

# Getter
func get_current_bird_count() -> int:
	return current_bird_count


	
func request_toggle_sound(enabled: bool = !sound_enabled):
	sound_enabled = enabled
	emit_signal("toggle_sound_requested", sound_enabled)
	
	# mute/unmute the master bus
	var master_bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus_index, !sound_enabled)
	
func is_sound_enabled() -> bool:
	return sound_enabled
	
