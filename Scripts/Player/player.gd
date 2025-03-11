extends CharacterBody2D

# 📌 Signals
signal player_died

# 📌 Variables
@export var speed : float = 200.0  # Vitesse du joueur
@export var max_health : int = 100
@export var weapon_scene: PackedScene  # La scène d'arme

var current_health : int
var is_alive := true  # Le joueur est vivant ou non
var weapon: Node2D = null  # Arme attachée
var damage_handler: Node  # Référence au gestionnaire de dégâts

func _ready():
	current_health = max_health
	attach_weapon()

	var damage_handler_path = "/root/Main/DamageHandler"
	if get_node_or_null(damage_handler_path) == null:
		print("❌ Erreur : DamageHandler n'a pas été trouvé dans la scène !")
	else:
		print("✅ DamageHandler trouvé !")
	
	damage_handler = get_node(damage_handler_path)

	var hurtbox = $Hurtbox
	if hurtbox:
		hurtbox.connect("area_entered", Callable(self, "_on_hurtbox_entered"))

	var game_manager = get_node("/root/GameManager")
	game_manager.connect("game_state_changed", Callable(self, "_on_game_state_changed"))

func _process(delta):
	if is_alive:
		handle_movement(delta)

func handle_movement(delta):
	var direction = Vector2.ZERO
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if direction.length() > 0:
		direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()

func attach_weapon():
	if weapon_scene:
		weapon = weapon_scene.instantiate()
		add_child(weapon)  # Attache l’arme au joueur
		weapon.global_position = global_position

func _on_game_state_changed(state):
	if state == GameManager.GameState.GAME_OVER:
		die()

func take_damage(amount):
	if not is_alive:
		return

	current_health -= amount

	var ui_nodes = get_tree().get_nodes_in_group("ui")
	if ui_nodes.size() > 0:
		var ui = ui_nodes[0]
		ui.update_health(current_health)
	else:
		print("⚠️ UI introuvable !")

	if current_health <= 0:
		die()

func die():
	if is_alive:
		is_alive = false
		velocity = Vector2.ZERO
		emit_signal("player_died")


func _on_hurtbox_entered(area):
	if area.is_in_group("enemies"):
		#print("💥 Joueur touché par un ennemi !")
		damage_handler.apply_damage(self, 10)  # 📌 On passe par `DamageHandler`
