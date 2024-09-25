extends CharacterBody2D

const SPEED:= 100

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	handle_inputs()
	handle_animation()

func handle_inputs():
	var direction_x
	direction_x = Input.get_axis("left", "right")
	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func handle_animation():
	if velocity.x != 0:
		animated_sprite.flip_h = true if velocity.x < 0 else false
		animated_sprite.play("side_walk")
	if velocity.x == 0:
		animated_sprite.play("side_idle")
