extends Node

@export var conductor: AudioStreamPlayer2D
@export var player: CharacterBody2D


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_down"):
		print(conductor.is_action_on_beat(conductor.song_position))
	
	if event.is_action_pressed("dash"):
		player.dash()
	
	if event.is_action_pressed("attack_heavy"):
		player.attack_heavy()
