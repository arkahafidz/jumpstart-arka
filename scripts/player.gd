extends CharacterBody2D

# Menggunakan @export agar nilai bisa diubah langsung dari Inspector Godot
@export var SPEED: float = 400.0
@export var JUMP_VELOCITY: float = -450.0
@export var ACCELERATION: float = 2000.0
@export var FRICTION: float = 1500.0

# Referensi node Sprite (sesuaikan nama "Sprite2D" dengan yang ada di scene Anda)
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_movement(delta)
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_jump() -> void:
	# Menggunakan "ui_accept" atau buat custom action "jump" di Project Settings
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func handle_movement(delta: float) -> void:
	# Menggunakan ui_left dan ui_right bawaan jika Anda belum membuat custom action
	var direction := Input.get_axis("left", "right")
	
	if direction != 0:
		# Bergerak halus menuju kecepatan maksimal menggunakan akselerasi
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		# Mengubah arah hadap sprite berdasarkan input arah
		if sprite_2d:
			sprite_2d.flip_h = (direction < 0)
	else:
		# Berhenti secara halus menggunakan friksi/gesekan saat tidak ada input
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
