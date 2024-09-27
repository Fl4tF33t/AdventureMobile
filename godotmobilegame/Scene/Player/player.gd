extends CharacterBody2D

enum PLAYER_STATE {IDLE, WALK, ATTACK, INTERACT, DEAD}

var state: PLAYER_STATE = PLAYER_STATE.IDLE

const SPEED:= 100.0
const SPRINT_STAMINA:= 100.0
const SPRINT_REDUCTION:= 15.0
const SPRINT_REGENERATION:= 5.0

var speed: float = 100.0
var is_sprinting:= false
var direction: Vector2
var last_direction: Vector2:
	set(value):
		if value != last_direction:
			last_direction = value
			ray_cast.target_position = value * 10
			handle_animations()

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var ray_cast: RayCast2D = $RayCast2D

func _physics_process(delta: float) -> void:
	handle_inputs()
	
	if is_sprinting and Global.player_stamina > 0 and direction:
		Global.player_stamina -= (SPRINT_REDUCTION * delta)
	if not is_sprinting and Global.player_stamina < SPRINT_STAMINA:
		Global.player_stamina += (SPRINT_REGENERATION * delta)
		if Global.player_stamina > SPRINT_STAMINA:
			Global.player_stamina = SPRINT_STAMINA

func handle_inputs():
	#Sprint
	if Input.is_action_just_pressed("sprint"):
		is_sprinting = true
		speed = SPEED * 1.5
	if Input.is_action_just_released("sprint"):
		is_sprinting = false 
		speed = SPEED
	if Global.player_stamina <= 0:
		is_sprinting = false
		speed = SPEED
		change_state(PLAYER_STATE.DEAD)
	
	#Movement
	direction = Input.get_vector("left", "right", "up", "down")
	if direction and not in_action_state():
		change_state(PLAYER_STATE.WALK)
		last_direction = closest_direction()
		velocity = direction * speed
		move_and_slide()
	
	#Attack
	if Input.is_action_just_pressed("attack"):
		change_state(PLAYER_STATE.ATTACK)
	
	#Interact
	if Input.is_action_just_pressed("interact"):
		if ray_cast.is_colliding():
			change_state(PLAYER_STATE.INTERACT)
	
	#Idle
	if not direction and not in_action_state():
		change_state(PLAYER_STATE.IDLE)

func change_state(new_state):
	if state == new_state:
		return
	state = new_state
	handle_animations()

func in_action_state() -> bool:
	return true if state == PLAYER_STATE.ATTACK or state == PLAYER_STATE.INTERACT or state == PLAYER_STATE.DEAD else false

func closest_direction() -> Vector2:
	match direction:
		Vector2.UP:
			return Vector2.UP
		Vector2.DOWN:
			return Vector2.DOWN
		Vector2.LEFT:
			return Vector2.LEFT
		Vector2.RIGHT:
			return Vector2.RIGHT
		_:
			if abs(direction.x) > abs(direction.y):
				return Vector2.RIGHT if direction.x > 0 else Vector2.LEFT
			else:
				return Vector2.DOWN if direction.y > 0 else Vector2.UP

func handle_animations():
	if state == PLAYER_STATE.WALK:
		directional_animation()
	
	if state == PLAYER_STATE.ATTACK:
		directional_animation()
		await animated_sprite.animation_finished
		change_state(PLAYER_STATE.IDLE)
	
	if state == PLAYER_STATE.INTERACT:
		if ray_cast.get_collider() is Interactable:
			var interact = ray_cast.get_collider() as Interactable
			var tool_names = {
			Interactable.TOOL_TYPE.PICK_AXE: "pick_axe",
			Interactable.TOOL_TYPE.AXE: "axe",
			Interactable.TOOL_TYPE.WATER: "water"
			}
			var tool_variant = tool_names[interact.interaction]
			directional_animation(tool_variant)
			interact.interact()
		timer.start()
	
	if state == PLAYER_STATE.DEAD:
		animated_sprite.play("dead")
		await animated_sprite.animation_finished
		animated_sprite.play_backwards("dead")
		await animated_sprite.animation_finished
		change_state(PLAYER_STATE.IDLE)
	
	if state == PLAYER_STATE.IDLE:
		directional_animation()

func directional_animation(variant: String = ""):
	var output: String
	match state:
		PLAYER_STATE.IDLE:
			output = "idle"
		PLAYER_STATE.WALK:
			output = "walk"
		PLAYER_STATE.ATTACK:
			output = "attack"
		PLAYER_STATE.INTERACT:
			output = "interact_" + variant
	match last_direction:
			Vector2.UP:
				animated_sprite.play("back_%s" % output)
			Vector2.DOWN:
				animated_sprite.play("front_%s" % output)
			Vector2.LEFT:
				animated_sprite.flip_h = true
				animated_sprite.play("side_%s" % output)
			Vector2.RIGHT:
				animated_sprite.flip_h = false
				animated_sprite.play("side_%s" % output)

func _on_interact_timer_timeout() -> void:
	change_state(PLAYER_STATE.IDLE)
