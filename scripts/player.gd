extends CharacterBody2D

# handling player state:
enum PlayerState {
	IDLING,
	MOVING,
	DASHING,
	ATTACKING,
}
var current_state: PlayerState = PlayerState.IDLING

@export var player_sprite: AnimatedSprite2D

@export var movement_speed = 400



func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * movement_speed
	move_and_slide()
	play_run_animation(direction)
	flip_sprite(direction)


func play_run_animation(direction):
	
	if current_state != PlayerState.DASHING and current_state != PlayerState.ATTACKING:
		if direction.x != 0 or direction.y != 0:
			current_state = PlayerState.MOVING
		elif direction.x == 0 and direction.y == 0:
			current_state = PlayerState.IDLING
	
	match current_state:
		PlayerState.IDLING:
			player_sprite.play("idle")
		PlayerState.MOVING:
			player_sprite.play("run")
		PlayerState.DASHING:
			player_sprite.play("dash")


func flip_sprite(direction):
	if direction.x > 0:
		player_sprite.flip_h = false
	elif direction.x < 0:
		player_sprite.flip_h = true


func dash():
	current_state = PlayerState.DASHING
	await player_sprite.animation_finished
	current_state = PlayerState.IDLING

func attack_light():
	pass

func attack_heavy():
	current_state = PlayerState.ATTACKING
	player_sprite.play("attack_4")
	await player_sprite.animation_finished
	current_state = PlayerState.IDLING
