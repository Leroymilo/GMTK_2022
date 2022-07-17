extends Control

var max_hp = 5
var hp = max_hp

const HEART_WIDTH = 216
onready var heartFull = $HeartFull
onready var heartEmpty = $HeartEmpty

func set_hp(value) :
	hp = clamp(value, 0, max_hp)
	if heartFull != null :
		heartFull.rect_size.x = hp * HEART_WIDTH

func set_max_hp(value) :
	max_hp = max(value, 1)
	if heartEmpty != null :
		heartEmpty.rect_size.x = max_hp * HEART_WIDTH

func _ready() :
	self.max_hp = PlayerStats.max_hp
	self.hp = PlayerStats.hp
	PlayerStats.connect("hp_changed", self, "set_hp")
	PlayerStats.connect("max_hp_changed", self, "set_max_hp")
