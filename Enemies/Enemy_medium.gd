extends KinematicBody2D

const MAX_SPEED = 100
const ACCELERATION = 1000
const FRICTION = 1000

var velocity = Vector2.ZERO
var AI = "wander"
var dir
var stop = 0
var time = 0

var fireball = preload("res://Enemies/projectiles/Fireball.tscn")

onready var animation_player = $AnimationPlayer
onready var stats = $Stats

func attack():
	AI = "attack"
	if Globals.get_player().global_position.x > global_position.x:
		animation_player.play("AttackRight")
	else:
		animation_player.play("AttackLeft")

func _shoot_fireball():
	var fb = fireball.instance()
	fb.direction = (Globals.get_player().global_position - global_position).normalized()
	fb.global_position = self.global_position
	fb.sender = self
	get_tree().get_root().add_child(fb)

func _ready() :
	stats.atk = 1
	stats.coins = 2
	stats.max_hp = 3
	stats.hp = 3
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	Timer
	$AttackTimer.wait_time = rng.randi_range(6,12)
	if rng.randi_range(0,1) == 0 :
		dir = "right"
	else :
		dir = "left"

func _physics_process(delta) :
	
	if AI == "wander" :
		if stop < 0 :
			if dir == "right" :
				velocity.x = move_toward(velocity.x, MAX_SPEED, delta * ACCELERATION)
				animation_player.play("IdleRight")
			elif dir == "left" :
				velocity.x = move_toward(velocity.x, -MAX_SPEED, delta * ACCELERATION)
				animation_player.play("IdleLeft")
		else :
			velocity.x = move_toward(velocity.x, 0, delta * FRICTION)
			stop -= delta
				
			if dir == "left" :
				animation_player.play("IdleRight")
			elif dir == "right" :
				animation_player.play("IdleLeft")
	
		time += delta
		velocity.y = 10*sin(5*time)
		velocity = move_and_slide(velocity)


func _on_PlayerDetector_body_entered(body):
	if body.has_method("damage") :
		body.dangers.append(self)
		body.nb_dangers += 1

func _on_PlayerDetector_body_exited(body):
	if body.has_method("damage") :
		for i in range(body.nb_dangers) :
			if body.dangers[i] == self :
				body.dangers.remove(i)
				break
		body.nb_dangers -= 1

func _on_Hurtbox_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	stats.hp -= area.get_parent().get_parent().stats.atk
	velocity.x = 5*(self.position.x - area.get_parent().get_parent().position.x)
	velocity.y = -100
	print("hit")


func _on_Timer_timeout():
	stop = 1
	if dir == "right" :
		dir = "left"
	elif dir == "left" :
		dir = "right"


func _on_AttackTimer_timeout():
	attack()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name in ["AttackRight", "AttackLeft"]:
		AI = "wander"
