extends StaticBody2D

@export var max_hits: int = 3
@export var squash_step: float = 0.3 
@export var jump_bounce_force: float = -550.0

@export var can_respawn: bool = false      
@export var respawn_time: float = 5.0      

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var splash_particles: CPUParticles2D = $CPUParticles2D

var current_hits: int = 0
var is_collected: bool = false
var can_take_damage: bool = true
var original_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	if sprite:
		original_scale = sprite.scale

func take_damage(player: CharacterBody2D) -> void:
	if is_collected or not can_take_damage:
		return
		
	can_take_damage = false
	current_hits += 1
	player.velocity.y = jump_bounce_force
	
	if splash_particles:
		splash_particles.amount = 24 * current_hits
		splash_particles.initial_velocity_min = 300.0 + (80.0 * current_hits)
		splash_particles.initial_velocity_max = 500.0 + (150.0 * current_hits)
		splash_particles.restart()
		splash_particles.emitting = true
	
	if current_hits < max_hits:
		var target_scale_y = 1.0 - (squash_step * current_hits)
		var target_scale_x = 1.0 + (squash_step * 0.8 * current_hits)
		
		var tween = create_tween()
		tween.tween_property(sprite, "scale", original_scale * Vector2(target_scale_x * 1.6, target_scale_y * 0.3), 0.05).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "scale", original_scale * Vector2(target_scale_x * 0.7, target_scale_y * 1.4), 0.07).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(sprite, "scale", original_scale * Vector2(target_scale_x * 1.1, target_scale_y * 0.9), 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(sprite, "scale", original_scale * Vector2(target_scale_x, target_scale_y), 0.35).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		
		var cooldown_timer = get_tree().create_timer(0.12)
		cooldown_timer.timeout.connect(func(): can_take_damage = true)
	else:
		collect()

func collect() -> void:
	is_collected = true
	
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	
	if has_node("/root/gamemanager"):
		get_node("/root/gamemanager").add_jelly()
		
	var tween = create_tween()
	tween.tween_property(sprite, "scale", original_scale * Vector2(2.5, 0.02), 0.04).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", original_scale * Vector2(0.02, 3.0), 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): sprite.visible = false)
	
	var lifetime_duration = 1.0
	if splash_particles:
		lifetime_duration = splash_particles.lifetime
		
	if can_respawn:
		var respawn_timer = get_tree().create_timer(lifetime_duration + respawn_time)
		respawn_timer.timeout.connect(respawn_jelly)
	else:
		var destroy_timer = get_tree().create_timer(lifetime_duration + 0.2)
		destroy_timer.timeout.connect(queue_free)

func respawn_jelly() -> void:
	current_hits = 0
	is_collected = false
	can_take_damage = true

	if collision_shape:
		collision_shape.set_deferred("disabled", false)
	
	if sprite:
		var buah_tween = create_tween() 
		
		sprite.visible = true
		sprite.scale = Vector2.ZERO
		
		buah_tween.tween_property(sprite, "scale", original_scale, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func get_current_hits() -> int:
	return current_hits

func get_max_hits() -> int:
	return max_hits
