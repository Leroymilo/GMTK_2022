extends Node


var Player = null

func get_player():
	if is_instance_valid(Player):
		return Player
	return null
