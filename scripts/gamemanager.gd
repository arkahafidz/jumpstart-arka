extends Node

var player: CharacterBody2D = null
var last_checkpoint_position: Vector2 = Vector2.ZERO

signal jelly_count_changed(new_count: int)
signal first_jelly_destroyed

var jelly_count: int = 0

func add_jelly() -> void:
	jelly_count += 1
	jelly_count_changed.emit(jelly_count)
	if jelly_count == 1:
		first_jelly_destroyed.emit()

func register_player(player_node: CharacterBody2D) -> void:
	player = player_node
	last_checkpoint_position = player.global_position
	
func update_checkpoint(checkpoint_pos: Vector2) -> void:
	last_checkpoint_position = checkpoint_pos
	print("Checkpoint diperbarui ke: ", last_checkpoint_position)

func respawn_player() -> void:
	if player != null:
		player.global_position = last_checkpoint_position
		player.velocity = Vector2.ZERO
