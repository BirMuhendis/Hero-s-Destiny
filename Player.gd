class_name Player extends CharacterBody2D

var isCanAttack : bool = true
@onready var effects = $Effects
@onready var animations = $AnimationPlayer
@export var knockbackPower : int = 500
@export var inv: Inv
@export var characterLVL : int
@onready var inventory = preload("res://Resources/Inventory/PlayerInventory.tres")
@onready var meleeWeapon = $Weaponary/Weapon_Sword
@onready var rangedWeapon = $Weaponary/Bows
@onready var magicWeapon = $Weaponary/Magics
@onready var Magics = $Weaponary/Magics
@onready var arrow = preload("res://ScenePacks/weapones/arrow.tscn")
@onready var magic = preload("res://ScenePacks/Magics/Destructive/magics_destructive.tscn")
var bow_cooldown=true
var magic_cooldown=true
var weaponaryAccess : int = 1
signal heatlhChanged
signal manaChanged
signal staminaChanged
signal armorValueChanged
var isAttacking = false
var isDeath = false
signal playerDeath
var lastAnimDirection: String = "South"
var regen_wait  : bool = false
var regen_rate
#									PlayerStats									#
#################################################################################
@onready var speed: int 
var Name="Max"
var currentHealth=100
var currentStamina=100
var currentMana=100
var currentArmor=100
var maxHealth=100 
var maxStamina=100
var maxMana=100
var maxArmor=100
var direction="South"
################################################################################
# I am getting Madddddd!!!!!!!!!!
func Death()-> void : 
	if currentHealth <= 0:
		isDeath=true
		playerDeath.emit()
		animations.play("Death" + direction)
		await animations.animation_finished
		queue_free()
		
func Sacrifice()-> void:
	effects.play("Sacrifice") ############################## Draw the Fucking Sacrifice Anim 
	await effects.animation_finished
	currentHealth-=25
	print_debug(currentHealth)
	heatlhChanged.emit()

func ChangeAim():
	match direction:
		"East":
			$RangedAim.position = Vector2(17,-3)
			$RangedAim.rotation = 0 
		"North":
			$RangedAim.position = Vector2(0,-16)
			$RangedAim.rotation = -1.570
		"South":
			$RangedAim.position = Vector2(1,7)
			$RangedAim.rotation = 1.570
		"West":
			$RangedAim.position = Vector2(-17,-3)
			$RangedAim.rotation = 3.141

func gravity():
	pass

func player():
	pass
	
func WeaponChange():
	if Input.is_action_just_pressed("weapon_melee"):
		weaponaryAccess=1
	if Input.is_action_just_pressed(("weapon_ranged")):
		weaponaryAccess=2
	if Input.is_action_just_pressed("weapon_magical_destructive"):
		weaponaryAccess=3
	if Input.is_action_just_pressed("weapon_magical_conjuractive"):
		weaponaryAccess=4
	if Input.is_action_just_pressed("weapon_magical_constructive"):
		weaponaryAccess=5
	pass
		

func collect(item):
	inv.Insert(item)
###############################################################################3
#  ENOUGHHHHHHHHHHHH FUCKING SCRIPTS
func Knockback(enemyVelocity):
	var knockbackdirection = (enemyVelocity - velocity).normalized() * knockbackPower
	velocity=knockbackdirection
	move_and_slide()

func RegenStamina():
	match characterLVL:
		1:
			regen_rate=1
		2:
			regen_rate=3
		_:
			regen_rate=5
	if regen_wait == false :
		if currentStamina < maxStamina:
			currentStamina += regen_rate
			regen_wait=true
			staminaChanged.emit()
			
func CurrentStabilizer():
	if currentStamina < maxStamina : return
	else: currentStamina = maxStamina
	if currentHealth < maxHealth : return
	else: currentHealth = maxHealth
	if currentMana < maxMana : return
	else: currentMana = maxMana

func handleInput():
	if !Input.is_action_pressed("shiftKey"):
		speed = 50
		var moveDirection = Input.get_vector("move_west","move_east","move_north","move_south")
		velocity = moveDirection * speed
		move_and_slide()
	else:return

func RunHandleInput():
	if Input.is_action_pressed("shiftKey"):
		if currentStamina > 0 : speed = 75
		else: speed = 50
		var moveDirection = Input.get_vector("move_west","move_east","move_north","move_south")
		velocity = moveDirection * speed
		move_and_slide()
	else:return
	
func Attack_1():
	if !inventory.slots[18].item == null and inventory.slots[18].item.type=="OneHanded" and isCanAttack==true:
		if weaponaryAccess==1:
			if Input.is_action_just_pressed("attack1") and bow_cooldown and currentStamina >= inventory.slots[18].item.requiredStamina:
				bow_cooldown=false
				meleeWeapon.enable()
				animations.play("Attack1_"+lastAnimDirection)
				currentStamina-=inventory.slots[18].item.requiredStamina
				staminaChanged.emit()
				isAttacking=true
				await animations.animation_finished
				bow_cooldown=true
				isAttacking=false
				meleeWeapon.disable()
		else:return
	elif inventory.slots[18].item == null:return
	
func BowAttack():
	if !inventory.slots[19].item == null and  inventory.slots[19].item.type=="Ranged" and isCanAttack==true:
		ChangeAim()
		if weaponaryAccess==2:
			if Input.is_action_just_pressed("attack1") and bow_cooldown and currentStamina >= inventory.slots[19].item.requiredStamina:
				bow_cooldown=false
				var arrow_instance = arrow.instantiate()
				arrow_instance.rotation = $RangedAim.rotation
				arrow_instance.global_position = $RangedAim.global_position
				rangedWeapon.visible=true
				animations.play("Bow"+lastAnimDirection)
				add_child(arrow_instance)
				currentStamina-=inventory.slots[19].item.requiredStamina
				staminaChanged.emit()
				isAttacking=true
				await  animations.animation_finished
				bow_cooldown=true
				isAttacking=false
				rangedWeapon.visible=false
		else:return	
	elif inventory.slots[19].item == null:return
	
func MagicThrowAttack():
	if !inventory.slots[20].item == null and  inventory.slots[20].item.type=="Destructive" and isCanAttack==true:
		ChangeAim()
		if weaponaryAccess==3:
			if Input.is_action_just_pressed("attack1") and magic_cooldown and currentMana >= inventory.slots[20].item.requiredMana:
				magic_cooldown=false
				var magic_instance = magic.instantiate()
				magic_instance.rotation = $RangedAim.rotation
				magic_instance.global_position = $RangedAim.global_position
				magicWeapon.visible=true
				animations.play("ThrowMagic"+lastAnimDirection)
				currentMana-= inventory.slots[20].item.requiredMana
				manaChanged.emit()
				isAttacking=true
				await  animations.animation_finished
				add_child(magic_instance)
				isAttacking=false
				magicWeapon.visible=false
				await get_tree().create_timer(0.5).timeout
				magic_cooldown=true
		else:return	
	elif inventory.slots[20].item == null:return
	
func UpdateAnimation():
	var movementName : String = ""
	if isAttacking: return
	if  velocity.length() == 0 and isDeath==false and global.picked==false:
		movementName = "Idle"
		isCanAttack=true
	elif  velocity.length() == 0 and isDeath==false and global.picked==true:
		isCanAttack=false
		movementName = "CarryIdle"
	elif Input.is_action_pressed("shiftKey") and global.picked==false:
		isCanAttack=true
		if currentStamina > 0:movementName = "Run"
		else : movementName = "Walk"
		if velocity.x < 0 :		direction = "West"
		elif velocity.x > 0:	direction = "East"
		elif velocity.y < 0:	direction = "North"
		elif velocity.y > 0: 	direction = "South"
		
	elif !Input.is_action_pressed("shiftKey") and !global.picked==true:
		isCanAttack=true
		movementName = "Walk"
		if velocity.x < 0 : 	direction = "West"
		elif velocity.x > 0: 	direction = "East"
		elif velocity.y < 0: 	direction = "North"
		elif velocity.y > 0 :	direction = "South"
	
	elif global.picked==true:
		isCanAttack=false
		movementName = "CarryWalk"
		if velocity.x < 0 :	 	direction = "West"
		elif velocity.x > 0: 	direction = "East"
		elif velocity.y < 0: 	direction = "North"
		elif velocity.y > 0 :	direction = "South"
	lastAnimDirection = direction
	animations.play(movementName + lastAnimDirection)
	if movementName == "Run": 
		await animations.animation_finished
		currentStamina-=0.1
		staminaChanged.emit()
@warning_ignore("unused_parameter")
func _physics_process(delta):
	#print("stamina: " , currentStamina)
	RunHandleInput()
	handleInput()
	UpdateAnimation()
	BowAttack()
	MagicThrowAttack()
	Attack_1()
	Death()
	
func _ready():
	$UICanvas.visible = true
	$FX_Light.enabled = false
	magicWeapon.visible=false
	rangedWeapon.visible=false
	meleeWeapon.disable()
	animations.play("RESET")
	inventory.UseItemAtIndex(get_node("UICanvas").get_node("HotbarGUI").currentlySelected)
	
@warning_ignore("unused_parameter")
func _process(delta):
	WeaponChange()
	RegenStamina()
	CurrentStabilizer()


func _on_hurt_box_area_entered(area):
	if area.name == "HitBox":
		print_debug(area.get_parent().name)
		Knockback(area.get_parent().velocity)
		effects.play("Hurt" + direction)
		await effects.animation_finished
		animations.play("Idle" + direction)


func _on_regen_cooldown_timeout():
	regen_wait=false
