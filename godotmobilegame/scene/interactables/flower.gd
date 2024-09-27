extends Interactable

var sprite_index

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite_index = randi_range(0, 1)
	sprite_2d.frame = sprite_index

func interact():
	sprite_2d.frame += 2
