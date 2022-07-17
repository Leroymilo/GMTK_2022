extends Node2D

onready var Desc = $Description
onready var Logo = $Sprite
onready var Cost = $Price
var type
var id
var game

signal buy(type)

func _on_Button_pressed():
	$Button.disabled = true
	emit_signal("buy", type, id)
