extends Interactable

@onready var sprite_2d: Sprite2D = $Sprite2D

func _on_area_2d_body_entered(_body: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property(sprite_2d, "modulate:a", 0.5, 0.2)
	z_index = 0


func _on_area_2d_body_exited(_body: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property(sprite_2d, "modulate:a", 1, 0.2)
	z_index = -1
