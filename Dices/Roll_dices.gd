extends Node2D

var rng = RandomNumberGenerator.new()
var parent
onready var timer = $Timer
onready var dice_nb = $Dice_nb
onready var dice_df = $Dice_df
onready var nb_low = $nb_low
onready var nb_high = $nb_high
var dice_nb_val
var dice_df_val
var rolling = true

func _ready() :
	parent = get_parent()
	rng.randomize()
	dice_nb_val = parent.min_enem
	dice_df_val = parent.min_diff
	nb_low.set_frame(parent.min_enem - 1)
	nb_high.set_frame(parent.max_enem - 1)

func _on_Button_pressed():
	var nb = rng.randi_range(parent.min_enem, parent.max_enem)
	var df = rng.randi_range(parent.min_diff, parent.max_diff)
	parent.nb_enemies = nb
	parent.difficulty = df
	
	$Button.disabled = true
	
	rolling = false
	dice_nb.set_frame(nb - 1)
	dice_df.set_frame(df - 1)
	
	var t = Timer.new()
	t.set_wait_time(0.8)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	parent.start_round()

func _on_Timer_timeout() :
	if rolling :
		dice_nb_val += 1
		dice_df_val += 1
		if dice_nb_val == parent.max_enem + 1 :
			dice_nb_val = parent.min_enem
		if dice_df_val == parent.max_diff + 1 :
			dice_df_val = parent.min_diff
		dice_nb.set_frame(dice_nb_val - 1)
		dice_df.set_frame(dice_df_val - 1)
