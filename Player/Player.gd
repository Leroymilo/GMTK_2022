extends KinematicBody2D

enum {MOVE, ATTACK, STUN}
var state = MOVE

const ACCELERATION = 1500
const UP_GRAV = 900
const DOWN_GRAV = 1500
const FRICTION = 1500
var MAX_SPEED = 250
const JUMP = 500

var velocity = Vector2.ZERO
var jumping = false
var running = false
var direction = "right"
var time_since_last_jPress = 1
var time_since_last_onFloor = 1

onready var stats = PlayerStats
onready var sword = $Position2D/Hitbox/CollisionShape2D
onready var animation_player = $AnimationPlayer

var nb_dangers = 0
var dangers = []
var stuned = 0
var invincible = 0

func _ready() :
	stats.atk = 2

func start_attack() :
	state = ATTACK
	sword.disabled = false

func end_attack() :
	state = MOVE
	sword.disabled = true

func start_stun() :
	state = STUN

func end_stun() :
	state = MOVE

func damage(danger) :
	if invincible < 0 :
		stats.hp -= danger.stats.atk
		invincible = 1
		velocity.x = 10*(self.position.x - danger.position.x)
		velocity.y = -100

func _input(event) :
	if Input.is_action_just_pressed("ui_select") :
		time_since_last_jPress = 0

func move_process(delta) :
	var input_dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if input_dir != 0 :
		velocity.x += input_dir * ACCELERATION * delta
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
		if input_dir > 0 :
			direction = "right"
		else :
			direction = "left"
		running = true
	
	else :
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		running = false
	
	if self.is_on_floor() :
		time_since_last_onFloor = 0
	
	if time_since_last_onFloor < 0.1 and not jumping :
		if time_since_last_jPress < 0.1 :
			jumping = true
			velocity.y = -JUMP
	
	else :
		var jumps = Input.get_action_strength("ui_select")
		if not jumps :
			jumping = false
		
		var grav
		if jumping and velocity.y < 0 :
			grav = UP_GRAV
		else :
			grav = DOWN_GRAV
	
		velocity.y += grav * delta
	
	if Input.is_action_just_pressed("ui_attack") :
		if direction == "left" :
			animation_player.play("AttackLeft")
		if direction == "right" :
			animation_player.play("AttackRight")
	
	elif is_on_floor() :
		if running :
			if direction == "right" :
				animation_player.play("RunRight")
			elif direction == "left" :
				animation_player.play("RunLeft")
		
		else :
			if direction == "right" :
				animation_player.play("IdleRight")
			elif direction == "left" :
				animation_player.play("IdleLeft")
	
	else :
		if velocity.y < 0 :
			if direction == "right" :
				animation_player.play("JumpRight")
			elif direction == "left" :
				animation_player.play("JumpLeft")
		
		else :
			if direction == "right" :
				$Sprite.set_frame(6)
			elif direction == "left" :
				$Sprite.set_frame(7)
	
func attack_process(delta) :
	if self.is_on_floor() :
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else :
		velocity.y += DOWN_GRAV * delta

func stun_process(delta) :
	if self.is_on_floor() :
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else :
		velocity.y += DOWN_GRAV * delta

func _physics_process(delta) :
	if get_parent().state == get_parent().PAUSE :
		return
	if nb_dangers > 0 :
		damage(dangers[0])

	match state :
		MOVE :
			move_process(delta)
		STUN :
			stun_process(delta)
		ATTACK :
			attack_process(delta)

	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	time_since_last_jPress += delta
	time_since_last_onFloor += delta
	invincible -= delta
