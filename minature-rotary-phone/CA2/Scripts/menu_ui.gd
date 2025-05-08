extends Control

func _ready():
	# Connect the buttons
	$CanvasLayer/ColorRect/MarginContainer4/AddBirdBtn.connect("pressed", _on_add_bird_pressed)
	$CanvasLayer/ColorRect/MarginContainer5/RemoveBirdBtn.connect("pressed", _on_remove_bird_pressed)
	$CanvasLayer/ColorRect/MarginContainer3/SoundOffBtn.connect("pressed", _on_sound_button_pressed)
	
	# Connect to BirdManagers birds_changed signal
	BirdManager.connect("birds_changed", _on_birds_changed)
	BirdManager.connect("toggle_sound_requested", _on_sound_toggled)
	
	update_sound_button_text(BirdManager.is_sound_enabled())

func _on_add_bird_pressed():
	BirdManager.request_add_bird()

func _on_remove_bird_pressed():
	BirdManager.request_remove_bird()
	
func _on_birds_changed(count):
	print("Bird count updated: ", count)
	
func _on_sound_button_pressed():
	# Toggle sound
	BirdManager.request_toggle_sound()

func _on_sound_toggled(enabled):
	# Update the sound button text
	update_sound_button_text(enabled)

func update_sound_button_text(enabled):
	var sound_button = $CanvasLayer/ColorRect/MarginContainer3/SoundOffBtn
	if sound_button:
		sound_button.text = "Sound: " + ("ON" if enabled else "OFF")
