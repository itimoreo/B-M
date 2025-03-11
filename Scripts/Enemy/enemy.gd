extends CharacterBody2D

# 📌 Variables d'ennemi
@export var speed : float = 100.0  # Vitesse de l’ennemi
@export var damage : int = 10  # Dégâts infligés au joueur
@export var max_health : int = 50  # Points de vie de l'ennemi
@export var attack_cooldown: float = 1.5  # Temps entre chaque attaque

var current_health : int
var can_attack: bool = true
var is_alive := true  # Booléen pour savoir si l'ennemi est vivant
var damage_handler: Node  # Référence au gestionnaire de dégâts


@export var target : Node2D = null  # Référence au joueur

@export_group("Particule")
@export var deathParticule : PackedScene

func _ready():
	current_health = max_health
	add_to_group("enemies")

	# 📌 Attendre la fin du chargement de la scène
	await get_tree().process_frame  

	var damage_handler_path = "/root/Main/DamageHandler"
	damage_handler = get_node_or_null(damage_handler_path)

	if damage_handler == null:
		print("❌ Erreur : DamageHandler n'a pas été trouvé à", damage_handler_path)
	else:
		print("✅ DamageHandler trouvé !")

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]
		#print("🎯 Ennemi suit :", target.name)
	else:
		return
		#print("⚠️ Aucun joueur trouvé !")

	var game_manager = get_node("/root/GameManager")
	game_manager.connect("game_state_changed", Callable(self, "_on_game_state_changed"))

	var hitbox = $Hitbox
	if hitbox:
		hitbox.connect("area_entered", Callable(self, "_on_hitbox_entered"))

func _process(delta):
	if is_alive and target:
		move_towards_target(delta)

func move_towards_target(delta):
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

# 📌 Détection du joueur dans la hitbox
func _on_hitbox_entered(area):
	if area.is_in_group("player"):
		#print("💥 L'ennemi attaque le joueur ! Dégâts :", damage)
		damage_handler.apply_damage(area.get_parent(), damage)  # 📌 On passe par `DamageHandler`

		# 📌 Désactiver temporairement la détection pour éviter les doubles attaques
		var hitbox = $Hitbox
		hitbox.disconnect("area_entered", Callable(self, "_on_hitbox_entered"))


# 📌 Détection quand le joueur quitte la hitbox

func _on_hitbox_exited(area):
	if area.is_in_group("player"):
		#print("🚶‍♂️ Joueur a quitté la hitbox, reset de l'attaque")
		can_attack = true  # 📌 Réactive l’attaque quand le joueur sort

# 📌 Réactivation de l’attaque après le cooldown
func _reset_attack():
	#print("🔄 Cooldown terminé, l'ennemi peut attaquer à nouveau !")
	can_attack = true  # Réactive l’attaque après le cooldown
	
	# 📌 Réactiver la détection des collisions
	var hitbox = $Hitbox
	if not hitbox.is_connected("area_entered", Callable(self, "_on_hitbox_entered")):
		hitbox.connect("area_entered", Callable(self, "_on_hitbox_entered"))


func take_damage(amount):
	if not is_alive:
		return

	current_health -= amount
	if current_health <= 0:
		die()

func die():
	if is_alive:
		is_alive = false
		
		# 📌 Ajouter le kill à l'UI
		var ui_nodes = get_tree().get_nodes_in_group("ui")
		if ui_nodes.size() > 0:
			var ui = ui_nodes[0]
			ui.increase_kills()
		else:
			print("⚠️ UI introuvable !")
		
		# 📌 Effet de mort
		if deathParticule:
			var _particule = deathParticule.instantiate()
			_particule.position = global_position
			_particule.rotation = global_rotation
			_particule.emitting = true
			get_tree().current_scene.add_child(_particule)
		
		queue_free()  # Détruit l’ennemi proprement

func _on_game_state_changed(state):
	if state == GameManager.GameState.GAME_OVER:
		is_alive = false
		velocity = Vector2.ZERO
