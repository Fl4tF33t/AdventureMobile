extends CanvasLayer

@onready var stamina_bar: TextureProgressBar = $StaminaBar

func _ready() -> void:
	Global.stamina_change.connect(display_stamina)

func display_stamina():
	stamina_bar.value = Global.player_stamina 
