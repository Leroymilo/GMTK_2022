extends Node

export(int) var max_hp = 5
onready var hp = max_hp setget set_hp
var atk
var coins

signal no_hp
signal hp_changed(value)
signal max_hp_changed(value)

func set_hp(value) :
	hp = clamp(value, 0, max_hp)
	emit_signal("hp_changed", value)
	if hp == 0 :
		emit_signal("no_hp")

func increase_max_hp() :
	max_hp += 1
	hp = clamp(hp + 1, 0, max_hp)
	emit_signal("hp_changed", hp)
	emit_signal("max_hp_changed", max_hp)
