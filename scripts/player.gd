extends CharacterBody2D

# Menggunakan @export agar nilai bisa diubah langsung dari Inspector Godot
@export var SPEED: float = 400.0
@export var JUMP_VELOCITY: float = -450.0
@export var ACCELERATION: float = 2000.0
@export var FRICTION: float = 1500.0

# Pengaturan Kamera Dinamis
@export var CAMERA_LEAD_DISTANCE: float = 300.0  # Jarak diperbesar agar pandangan ke depan lebih luas
@export var CAMERA_SMOOTH_SPEED: float = 4.0     # Sedikit diturunkan agar pergerakan terasa lebih cinematic

# Referensi node berdasarkan scene Anda
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D
# --- TAMBAHKAN REFERENSI NODE AUDIO DI SINI ---
@onready var jump_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D 

# Menyimpan target posisi horizontal kamera
var target_camera_x: float = 0.0

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_movement(delta)
	handle_camera(delta) # Memanggil fungsi kontrol kamera
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		# --- PANGGIL SUARA LOMPAT DI SINI ---
		if jump_sound:
			jump_sound.play()

func handle_movement(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		if sprite_2d:
			sprite_2d.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Kamera mengikuti arah hadap karakter, bukan hanya saat tombol ditekan
	if sprite_2d:
		if sprite_2d.flip_h:
			target_camera_x = -CAMERA_LEAD_DISTANCE # Menghadap kiri, kamera ke kiri
		else:
			target_camera_x = CAMERA_LEAD_DISTANCE  # Menghadap kanan, kamera ke kanan

func handle_camera(delta: float) -> void:
	if camera_2d:
		# Menggeser posisi X kamera secara halus (lerp) menuju target_camera_x
		camera_2d.position.x = lerp(camera_2d.position.x, target_camera_x, CAMERA_SMOOTH_SPEED * delta)
