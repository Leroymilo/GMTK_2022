extends KinematicBody2D

const MAX_SPEED = 100
const ACCELERATION = 1000
const FRICTION = 1000

var velocity = Vector2.ZERO
var AI = "wander"
var dir
var stop = 0
var time = 0

onready var animation_player = $AnimationPlayer
onready var stats = $Stats

func _ready() :
	stats.atk = 1
	stats.coins = 4
	stats.max_hp = 10
	stats.hp = 10
	var rng = RandomNumberGenerator.new()
	rng.randomize()
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
