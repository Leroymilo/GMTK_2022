extends Node2D

enum {MAX_HP, HP, ATK, SPD, NB_U, NB_D}

var descs = {MAX_HP : "Max health up", HP : "Heal",
ATK : "Strength up", SPD : "Speed up",
NB_U : "Number of enemies range up",
NB_D : "Number of enemies range down"
}

var costs = {MAX_HP : 5, HP : 2, ATK : 3, SPD : 2, NB_U : 2, NB_D : 1}

var frames = {MAX_HP : 0, HP : 1, ATK : 2, SPD : 3, NB_U : 4, NB_D : 5}

onready var choices = $Choices.get_children()
onready var game = get_parent()
var rng = RandomNumberGenerator.new()

func _ready() :
	var pos = []
	if PlayerStats.max_hp - PlayerStats.hp != 0 :
		pos.append(HP)
	if PlayerStats.max_hp < 10 :
		pos.append(MAX_HP)
	if PlayerStats.atk < 6 :
		pos.append(ATK)
	if game.min_enem > 1 :
		pos.append(NB_D)
	if game.max_enem < 12 :
		pos.append(NB_U)

	rng.randomize()
	for i in range(3) :
		if len(pos) > 0 :
			var j = rng.randi_range(0, len(pos)-1)
			choices[i].Desc.text = descs[pos[j]]
			choices[i].Logo.set_frame(frames[pos[j]])
			choices[i].Cost.text = "X " + str(costs[pos[j]])
			choices[i].type = pos[j]
			choices[i].id = i
			choices[i].game = game
			pos.remove(j)
			choices[i].connect("buy", self, "buy")
		else :
			choices[i].queue_free()

func set_text(text) :
	$Info.text = text

func buy(type, id) :
	if game.coins < costs[type] :
		return
	choices[id].queue_free()
	game.change_coins(-costs[type])
	match type :
		MAX_HP :
			PlayerStats.increase_max_hp()
		HP :
			PlayerStats.set_hp(PlayerStats.hp + 2)
		ATK :
			PlayerStats.atk += 1
		NB_U :
			game.max_enem += 1
			game.min_enem += 1
		NB_D :
			game.max_enem -= 1
			game.min_enem -= 1

func end_shop():
	print("end shop phase")
	get_parent().roll_dices()
