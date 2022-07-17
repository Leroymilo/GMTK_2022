extends Node2D

onready var enemies = $Enemies
onready var enemies_pos = $Enemies_pos.get_children()
onready var pos_count = $Enemies_pos.get_child_count()
var rng = RandomNumberGenerator.new()

signal enemy_killed(value)

func generate_enemies(enemy_scene, nb: int) :
	rng.randomize()
	var used_pos = []
	for i in range(nb) :
		var pos = rng.randi_range(0, pos_count - 1)
		while pos in used_pos :
			pos = rng.randi_range(0, pos_count - 1)
		used_pos.append(pos)
		var enemy = enemy_scene.instance()
		enemy.position = enemies_pos[pos].position
		enemies.add_child(enemy)

func _process(delta) :
	for enemy in enemies.get_children() :
		if enemy.stats.hp <= 0 :
			emit_signal("enemy_killed", enemy.stats.coins)
			enemy.queue_free()
	if enemies.get_child_count() == 0 and get_parent().state == get_parent().PLAY :
		get_parent().end_round()
