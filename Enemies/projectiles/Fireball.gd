extends Area2D

var sender = null

var direction = Vector2.RIGHT
var speed = 340

onready var stats = $Stats

func _ready():
	stats.atk = 1
	$Particles2D.process_material.direction = Vector3(direction.x, direction.y, 0) * -1

func _physics_process(delta):
	position += direction * speed * delta


func _on_Fireball_body_entered(body):
	if body.name == "Player":
		body.damage(self)
		queue_free()
