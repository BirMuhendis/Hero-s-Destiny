extends CharacterBody2D

@onready var animations = $AnimationPlayer
@onready var isTakeDMG : bool = true
@onready var health : int = 1000
signal BossheatlhChanged
@onready var player
@onready var readyToFight:bool =false
@onready var maxHealth:int = 1000

func get_DMG(area):
	if isTakeDMG:
		readyToFight=false
		health-=area.dmgValue
		BossheatlhChanged.emit()
		animations.play("Hurt")
		await animations.animation_finished
		isTakeDMG=false
		readyToFight=true
	else:return
	

func _on_hurt_box_area_entered(area):
	if area.has_method("playerWeaponary") :
		if isTakeDMG:get_DMG(area)
		else:return


@warning_ignore("unused_parameter")
func _on_detectand_attack_zone_body_entered(body):
	if body.has_method("player"):
		player = body
		readyToFight=true


@warning_ignore("unused_parameter")
func _on_detectand_attack_zone_body_exited(body):
	if body.has_method("player"):
		player = null
		readyToFight=false


@warning_ignore("unused_parameter")
func _on_hurt_box_area_exited(area):
	isTakeDMG=true

func Attack():
	animations.play("Throwing")
	
func Summon():
	animations.play("Summoning")

func _process(delta):
	if !health <= 0:
		if !readyToFight:
			animations.play("Hurt")
		else : 
			animations.play("Idle")
			await animations.animation_finished
			Attack()
	else:
		animations.play("Death")
		await animations.animation_finished
		animations.play("StayDeath")
