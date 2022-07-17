extends Node2D

enum {PLAY, PAUSE}
var state = PAUSE

var min_enem = 1
var max_enem = 3
var nb_enemies

var min_diff = 1
var max_diff = 1
var difficulty

var coins = 0
var round_nb = 1

var dice_roll_scene = load("res://Dices/Roll_dices.tscn")
var upgrade_scene = load("res://Upgrade/Upgrade.tscn")
var dice_roll

var upgrade

var enemy_easy = load("res://Enemies/Enemy_easy.tscn")
var enemy_medium = load("res://Enemies/Enemy_medium.tscn")

var music_loop = load("res://Music/normal loop.wav")

var arena_low_easy = load("res://Arenas/Arena_low_easy.tscn")
var arena_medium_easy = load("res://Arenas/Arena_medium_easy.tscn")

var arena
onready var coin_UI = $Coin_UI/Label

onready var loop_player = $Music/Audio_loop

func _ready():
	dice_roll = dice_roll_scene.instance()
	add_child(dice_roll)
	PlayerStats.connect("no_hp", self, "game_over")

func roll_dices() :
	round_nb += 1
	$Round_UI.text = "Round " + str(round_nb) + " / 12"
	upgrade.queue_free()
	dice_roll = dice_roll_scene.instance()
	add_child(dice_roll)

func start_round() :
	dice_roll.queue_free()
	var enemy_type
	if difficulty == 1 :
		enemy_type = enemy_easy
		if nb_enemies <= 4 :
			arena = arena_low_easy.instance()
		elif nb_enemies <= 8 :
			arena = arena_medium_easy.instance()
	elif difficulty == 2 :
		enemy_type = enemy_medium
	add_child(arena)
	arena.connect("enemy_killed", self, "change_coins")
	arena.generate_enemies(enemy_type, nb_enemies)
	$Player.position = Vector2(2544, 2336)
	$Player.velocity = Vector2(0, 0)
	state = PLAY

func end_round() :
	print("end round")
	state = PAUSE
	arena.queue_free()
	var text = "Next round : "
	if round_nb%2 == 1 :
		max_enem += 1
		text += "max number of enemies up"
	elif round_nb%4 != 0 :
		min_enem += 1
		text += "min number of enemies up"
	elif round_nb == 4 :
		max_diff += 1
		text += "new enemy !"
	else :
		max_diff += 1
		text += "no easy enemies !"
	upgrade = upgrade_scene.instance()
	add_child(upgrade)
	upgrade.set_text(text)

func change_coins(value: int) :
	coins += value
	coin_UI.text = str(coins) + " X"

func _on_AudioStreamPlayer_finished() :
	print("audio intro end")
	loop_player.play()
func _on_Audio_loop_finished() :
	print("audio looping")
	loop_player.play()

func game_over() :
	print("player is dead")
	state = PAUSE
	round_nb = 0
	coins = 0
	PlayerStats.atk = 2
	PlayerStats.max_hp = 5
	PlayerStats.hp = 5
	min_enem = 1
	max_enem = 3
	min_diff = 1
	max_diff = 1
	dice_roll = dice_roll_scene.instance()
	add_child(dice_roll)
