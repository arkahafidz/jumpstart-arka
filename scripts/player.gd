extends CharacterBody2D

@export var SPEED: float = 400.0
@export var JUMP_VELOCITY: float = -450.0
@export var ACCELERATION: float = 2000.0
@export var FRICTION: float = 1500.0

@export var CAMERA_LEAD_DISTANCE: float = 300.0
@export var CAMERA_SMOOTH_SPEED: float = 4.0

@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var jump_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D 
@onready var block_trail: CPUParticles2D = $CPUParticles2D

var target_camera_x: float = 0.0

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_movement(delta)
	handle_camera(delta) 
	handle_trail() 
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if jump_sound:
			jump_sound.play()

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

func handle_camera(delta: float) -> void:
	if camera_2d:
		camera_2d.position.x = lerp(camera_2d.position.x, target_camera_x, CAMERA_SMOOTH_SPEED * delta)

func handle_trail() -> void:
	if block_trail:
		block_trail.emitting = is_on_floor() and abs(velocity.x) > 20.0
