extends Node

@onready var Conductor: AudioStreamPlayer2D = $"../Conductor"


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		print(Conductor.is_action_on_beat(Conductor.song_position))
