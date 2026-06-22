extends CharacterBody2D

# --- BOSS STATS ---
var current_speed: float = 150.0 
var current_spin_cooldown: float = 12.0
var damage_multiplier: float = 1.0

const STOP_DISTANCE: float = 400.0 
const KNOCKBACK_FORCE: int = 20    

@export var max_health: int = 5000
var health: int = 5000

# --- STATE VARIABLES ---
var target = null
var is_alive: bool = true
var is_attacking: bool = false
var hero_in_attack_range: bool = false 
var is_enraged: bool = false
var is_transitioning: bool = false 

var combo_step: int = 0 
var spin_timer: float = 0.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: Node2D = $HealthBar
@onready var attack_area: Area2D = $AttackArea

func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	spin_timer = 5.0 
	
	if health_bar.has_method("init_health"):
		health_bar.init_health(max_health)

func _process(delta: float) -> void:
	# Cooldown logic
	if not is_transitioning and spin_timer > 0:
		spin_timer -= delta

func _physics_process(_delta: float) -> void:
	if not is_alive or is_transitioning: 
		velocity = Vector2.ZERO
		return

	if is_attacking:
		velocity = Vector2.ZERO 
	elif target:
		var distance = global_position.distance_to(target.global_position)
		
		if distance > STOP_DISTANCE:
			var direction = (target.global_position - global_position).normalized()
			velocity = direction * current_speed 
			animated_sprite_2d.flip_h = (direction.x < 0)
			animated_sprite_2d.play("run_right")
		else:
			velocity = Vector2.ZERO
			if hero_in_attack_range:
				decide_boss_attack()
			else:
				animated_sprite_2d.play("idle_right")
	else:
		velocity = Vector2.ZERO
		animated_sprite_2d.play("idle_right")

	move_and_slide() 
	update_hitbox_direction()

# --- BOSS ATTACK SYSTEM ---

func decide_boss_attack() -> void:
	if is_attacking or is_transitioning: return

	if spin_timer <= 0:
		perform_attack("spin")
	elif combo_step < 2:
		perform_attack("thrust")
	else:
		perform_attack("slam")

func perform_attack(type: String) -> void:
	is_attacking = true
	match type:
		"thrust":
			animated_sprite_2d.play("attack_thrust_right")
			combo_step += 1
		"slam":
			animated_sprite_2d.play("attack_slam_right")
			combo_step = 0 
		"spin":
			animated_sprite_2d.play("attack_spin_right")
			spin_timer = current_spin_cooldown 

func _on_animated_sprite_2d_animation_finished() -> void:
	var anim_name = animated_sprite_2d.animation
	
	if anim_name.begins_with("attack"):
		check_damage_hit(anim_name)
		is_attacking = false # Unlock for next action
	
	if anim_name == "die_right":
		queue_free() 

func check_damage_hit(anim_name: String) -> void:
	var base_dmg = 10
	if anim_name.contains("slam"): base_dmg = 30
	elif anim_name.contains("spin"): base_dmg = 50

	var final_damage = int(base_dmg * damage_multiplier)
	var bodies = attack_area.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(final_damage, global_position)

# --- PHASE & ENRAGE SYSTEM ---

func take_damage(damage: int, attacker_position: Vector2) -> void:
	if not is_alive: return
	health -= damage
	if health_bar: health_bar.update_health(health)
	if health <= 0: _die()
	else:
		var knockback_direction = (position - attacker_position).normalized()
		var target_knockback_position = position + (knockback_direction * KNOCKBACK_FORCE)
		var tween = create_tween()
		tween.tween_property(self, "position", target_knockback_position, 0.3)
		
	# Trigger Enrage at 50% HP
	if not is_enraged and health <= max_health / 2:
		trigger_enrage()


func trigger_enrage() -> void:
	if is_enraged: return # Prevent duplicate trigger
	
	is_enraged = true
	is_transitioning = true 
	is_attacking = false # Force reset attack state
	velocity = Vector2.ZERO
	
	print("!!! BOSS IS ENRAGING (1.5s lock) !!!")
	animated_sprite_2d.play("enrage_right")
	modulate = Color(2.5, 0.5, 0.5) # Turn Boss red

	# WAIT FOR THE ENRAGE MOMENT (1.5 seconds)
	await get_tree().create_timer(1.5).timeout
	
	# --- APPLY BUFFS AFTER THE ROAR ---
	damage_multiplier = 2.0        # Double damage
	current_spin_cooldown = 5.0    # 5s instead of 12s
	current_speed = 280.0          # Fast rượt đuổi
	
	is_transitioning = false # UNLOCK BOSS
	print("!!! PHASE 2 ACTIVATED: BOSS IS BACK !!!")

func _die() -> void:
	is_alive = false
	animated_sprite_2d.play("die_right")
	set_collision_layer_value(3, false)
	$CollisionShape2D.set_deferred("disabled", true)

func update_hitbox_direction() -> void:
	attack_area.scale.x = -1 if animated_sprite_2d.flip_h else 1

# --- SIGNALS ---
func _on_detection_area_body_entered(body): if body.is_in_group("player"): target = body
func _on_detection_area_body_exited(body): if body.is_in_group("player"): target = null
func _on_attack_area_body_entered(body): if body.is_in_group("player"): hero_in_attack_range = true
func _on_attack_area_body_exited(body): if body.is_in_group("player"): hero_in_attack_range = false
