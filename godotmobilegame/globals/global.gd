extends Node

signal stamina_change()

var player_stamina: float = 100.0:
	get:
		return player_stamina
	set(value):
		player_stamina = value
		stamina_change.emit()
