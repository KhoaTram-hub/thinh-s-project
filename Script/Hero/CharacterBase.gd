extends CharacterBody2D
class_name CharacterBase 

const BASE_SPEED = 500.0
var speed = 800.0
const KNOCKBACK_FORCE = 150.0 

var health: int = 500
var is_alive: bool = true
var is_attacking: bool = false
var enemies_already_hit: Array = []
var damage_output_factor: float = 1.0

# --- QUAN TRỌNG: Giữ lại các biến dùng chung này ---
var damage_reduction_factor: float = 1.0 
var max_ap: float = 100.0
var current_ap: float = 0.0


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

var last_direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	add_to_group("player")
	attack_shape.disabled = true

func _physics_process(_delta: float) -> void:
	if not is_alive: return


	# Gọi hàm xử lý nút bấm của skill (con sẽ tự viết đè)
	handle_skill_input()

	process_movement()
	
	if Input.is_action_just_pressed("attack"):
		attack()
		
	process_animation()
	move_and_slide()

func process_movement() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO:
		velocity = direction * speed # Ăn theo biến speed để tăng tốc được
		last_direction = direction
	else:
		velocity = Vector2.ZERO
	update_hitbox_direction()

func update_hitbox_direction() -> void:
	if last_direction.x < 0:
		attack_area.scale.x = -1
	elif last_direction.x > 0:
		attack_area.scale.x = 1

func attack() -> void:
	is_attacking = true
	attack_shape.disabled = false
	enemies_already_hit.clear()
	animated_sprite_2d.play("attack_right")
	animated_sprite_2d.frame = 0 

func take_damage(damage: int, attacker_position: Vector2) -> void:
	if not is_alive: return
	
	# Áp dụng giảm sát thương tại đây
	var final_damage = int(damage * damage_reduction_factor)
	health -= final_damage
	print(name, " nhận sát thương thực tế: ", final_damage)
	print("Máu còn lại của Hero: ", health)
	
	if health <= 0:
		_die()
	else:
		var knockback_direction = (position - attacker_position).normalized()
		var target_knockback_position = position + (knockback_direction * KNOCKBACK_FORCE)
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", target_knockback_position, 0.3)

func _die() -> void:
	is_alive = false
	velocity = Vector2.ZERO
	animated_sprite_2d.play("death_right")
	
func process_animation() -> void:
	if not is_alive: return
	if is_attacking: return 
	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)

func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
	animated_sprite_2d.play(prefix + "_right")

func gain_ap(amount: float) -> void:
	current_ap = min(current_ap + amount, max_ap)

# Hàm trống để con viết đè
func handle_skill_input() -> void:
	pass

# Hàm hiện chữ dùng chung cho cả bố lẫn con
func show_message(text_content: String, text_color: Color = Color.WHITE) -> void:
	var label = Label.new()
	label.text = text_content
	label.add_theme_color_override("font_color", text_color)
	label.add_theme_font_size_override("font_size", 7) 
	label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST  
	
	label.scale = Vector2(0.5, 0.5)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF 
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER 
	
	add_child(label)
	await get_tree().process_frame 
	
	var label_size = label.get_combined_minimum_size()
	var target_x = -(label_size.x * label.scale.x) / 2
	var target_y = -label_size.y - 35   
	
	label.position = Vector2(target_x, target_y)
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 8, 1.5).set_trans(Tween.TRANS_LINEAR)
	tween.finished.connect(func(): label.queue_free()) 

# --- SIGNALS ---
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack_right":
		is_attacking = false
		attack_shape.disabled = true
		enemies_already_hit.clear()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and body != self:
		if not enemies_already_hit.has(body):
			enemies_already_hit.append(body) 
			var current_damage = int(500 * damage_output_factor)
			body.take_damage(current_damage, global_position)
