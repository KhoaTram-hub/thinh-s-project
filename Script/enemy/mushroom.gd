extends CharacterBody2D

const SPEED: int = 150 
const STOP_DISTANCE: float = 100.0
const KNOCKBACK_FORCE: int = 80 

var health: int = 100
var target = null
var is_alive = true
var is_attacking = false          
var hero_in_attack_range = false  

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: Node2D = $HealthBar
@onready var attack_area: Area2D = $AttackArea
@onready var attack_area_collision_shape_2d: CollisionShape2D = $AttackArea/CollisionShape2D

var last_direction = Vector2.RIGHT

func _physics_process(_delta: float) -> void:
	if not is_alive:
		velocity = Vector2.ZERO
		return

	if is_attacking:
		velocity = Vector2.ZERO 
	elif target:
		var distance = position.distance_to(target.position)
		if distance > STOP_DISTANCE:
			var direction = (target.position - position).normalized()
			velocity = direction * SPEED
			if direction.x != 0:
				last_direction = direction
		else:
			velocity = Vector2.ZERO 
	else:
		velocity = Vector2.ZERO

	move_and_slide() 
	process_animation() 


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		hero_in_attack_range = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		hero_in_attack_range = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"): 
		target = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and is_alive:
		target = null

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation.begins_with("attack"):
		is_attacking = false
		check_damage_hit()
	if animated_sprite_2d.animation == "die":
		queue_free() 


func check_damage_hit() -> void:
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(20, position)


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

func _die() -> void:
	is_alive = false
	animated_sprite_2d.play("die")
	set_collision_layer_value(3, false) 
	$CollisionShape2D.set_deferred("disabled", true)
	reward_ap_to_player()
	ScoreManager.add_score(10)

func process_animation() -> void:
	if not is_alive: return

	var current_dist = 9999.0
	if target:
		current_dist = position.distance_to(target.position)

	if hero_in_attack_range or current_dist <= STOP_DISTANCE + 10.0:
		if not is_attacking:
			is_attacking = true
			play_animation("attack", last_direction)
	elif velocity != Vector2.ZERO:
		is_attacking = false
		play_animation("run", last_direction)
	else:
		is_attacking = false
		play_animation("idle", last_direction)


func play_animation(prefix: String, dir: Vector2) -> void:
	animated_sprite_2d.flip_h = (last_direction.x > 0)
	if last_direction.x > 0: attack_area.scale.x = 1
	else: attack_area.scale.x = -1
	animated_sprite_2d.play(prefix + "_left")
	
func reward_ap_to_player() -> void:
	# Tìm nhân vật chính trong nhóm "player"
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		
		# Cộng AP cho player
		if player.has_method("gain_ap"):
			var ap_reward = 10.0
			player.gain_ap(ap_reward)
			
			# Hiện chữ thông báo chuẩn pixel trên đầu player
			if player.has_method("show_message"):
				player.show_message("+ " + str(int(ap_reward)) + " AP", Color.CYAN)
	
