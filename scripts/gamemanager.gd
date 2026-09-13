extends Node

signal jelly_count_changed(new_count:int)
signal first_jelly_destroyed

var jelly_count: int = 0

func add_jelly() -> void:
	jelly_count += 1
	jelly_count_changed.emit(jelly_count)
	if jelly_count ==1:
		first_jelly_destroyed.emit()
