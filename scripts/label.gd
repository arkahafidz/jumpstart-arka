extends Label

func _ready() -> void:
	pivot_offset = size / 2
	visible = false
	if has_node("/root/gamemanager"):
		var global = get_node("/root/gamemanager")
		global.jelly_count_changed.connect(_on_jelly_count_changed)
		global.first_jelly_destroyed.connect(_on_first_jelly_destroyed)
		text = "Jelly Collected: " + str(global.jelly_count)
		if global.jelly_count > 0:
			visible = true

func _on_jelly_count_changed(new_count: int) -> void:
	text = "Jelly Collected: " + str(new_count)
	play_pop_effect()

func _on_first_jelly_destroyed() -> void:
	visible = true
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func play_pop_effect() -> void:
	pivot_offset = size / 2
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.08).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
