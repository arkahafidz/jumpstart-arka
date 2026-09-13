extends CharacterBody2D

@export var SPEED: float = 400.0
@export var JUMP_VELOCITY: float = -450.0
@export var ACCELERATION: float = 2000.0
@export var FRICTION: float = 1500.0
@export var ROTATION_SPEED: float = 9.0
@export var SNAP_SPEED: float = 20.0

@export var CAMERA_LEAD_DISTANCE: float = 300.0
@export var CAMERA_SMOOTH_SPEED: float = 4.0

@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var jump_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D 
@onready var block_trail: CPUParticles2D = $CPUParticles2D

var target_camera_x: float = 0.0
var original_sprite_scale: Vector2 = Vector2.ONE

var shake_tween: Tween
var shake_vector: Vector2 = Vector2.ZERO
var was_in_air: bool = false

func _ready() -> void:
	if sprite_2d:
		original_sprite_scale = sprite_2d.scale

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_land_effect()
	handle_jump()
	handle_movement(delta)
	handle_rotation(delta)
	handle_falling_stretch()
	handle_camera(delta) 
	handle_trail() 
	move_and_slide()
	handle_jelly_collisions()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_land_effect() -> void:
	if is_on_floor() and was_in_air:
		trigger_juice_stretch(Vector2(1.4, 0.6))
		was_in_air = false
	elif not is_on_floor():
		was_in_air = true

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		trigger_juice_stretch(Vector2(0.6, 1.5))
		if jump_sound:
			jump_sound.pitch_scale = randf_range(0.95, 1.05)
			jump_sound.play()
	
	if is_on_floor() and Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

func handle_movement(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		if sprite_2d:
			sprite_2d.flip_h = (direction < 0)
		if block_trail:
			block_trail.direction.x = -direction
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	if sprite_2d:
		target_camera_x = -CAMERA_LEAD_DISTANCE if sprite_2d.flip_h else CAMERA_LEAD_DISTANCE

func handle_rotation(delta: float) -> void:
	if not sprite_2d:
		return
		
	if not is_on_floor():
		if velocity.x > 20.0:
			sprite_2d.rotation += ROTATION_SPEED * delta
		elif velocity.x < -20.0:
			sprite_2d.rotation -= ROTATION_SPEED * delta
	else:
		var kelipatan_90_derajat = PI / 2
		var target_rotasi = round(sprite_2d.rotation / kelipatan_90_derajat) * kelipatan_90_derajat
		sprite_2d.rotation = rotate_toward(sprite_2d.rotation, target_rotasi, SNAP_SPEED * delta)

func handle_falling_stretch() -> void:
	if not is_on_floor() and velocity.y > 50.0 and sprite_2d:
		var fall_stretch = clamp(velocity.y / 1200.0, 0.0, 0.3)
		var current_tween = create_tween()
		current_tween.tween_property(sprite_2d, "scale", original_sprite_scale * Vector2(1.0 - fall_stretch, 1.0 + fall_stretch), 0.1)
		if jump_sound:
			jump_sound.pitch_scale = randf_range(0.95, 1.05)
			jump_sound.play()

func handle_camera(delta: float) -> void:
	if camera_2d:
		camera_2d.position.x = lerp(camera_2d.position.x, target_camera_x, CAMERA_SMOOTH_SPEED * delta)
		camera_2d.offset = shake_vector

func handle_trail() -> void:
	if block_trail:
		block_trail.emitting = is_on_floor() and abs(velocity.x) > 20.0

func handle_jelly_collisions() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.has_method("take_damage"):
			if collision.get_normal().y < -0.6:
				if collider.has_method("get_current_hits") and collider.has_method("get_max_hits"):
					var next_hit = collider.get_current_hits() + 1
					var max_hits = collider.get_max_hits()
					if next_hit >= max_hits:
						apply_juicy_shake(20.0, 0.4)
						trigger_juice_stretch(Vector2(1.6, 0.4))
					else:
						apply_juicy_shake(6.0 * next_hit, 0.25)
						trigger_juice_stretch(Vector2(1.4, 0.6))
				else:
					apply_juicy_shake(10.0, 0.3)
					trigger_juice_stretch(Vector2(1.4, 0.6))
					
				collider.take_damage(self)
				if jump_sound:
					jump_sound.pitch_scale = randf_range(0.95, 1.05)
					jump_sound.play()

func apply_juicy_shake(intensity: float, duration: float) -> void:
	if shake_tween:
		shake_tween.kill()
	
	shake_tween = create_tween()
	var loops = int(duration / 0.05)
	
	for i in range(loops):
		var current_intensity = intensity * (1.0 - (float(i) / loops))
		var random_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * current_intensity
		shake_tween.tween_property(self, "shake_vector", random_direction, 0.025).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		shake_tween.tween_property(self, "shake_vector", -random_direction * 0.5, 0.025).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
	shake_tween.tween_property(self, "shake_vector", Vector2.ZERO, 0.05).set_trans(Tween.TRANS_SINE)

func trigger_juice_stretch(target_scale: Vector2) -> void:
	if not sprite_2d:
		return
	var tween = create_tween()
	tween.tween_property(sprite_2d, "scale", original_sprite_scale * Vector2(target_scale.x * 1.3, target_scale.y * 0.6), 0.05).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite_2d, "scale", original_sprite_scale * Vector2(target_scale.x * 0.8, target_scale.y * 1.2), 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite_2d, "scale", original_sprite_scale, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
