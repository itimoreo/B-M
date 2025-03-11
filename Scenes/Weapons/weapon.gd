extends Node2D

# 📌 Signals
signal weapon_fired(bullet_instance)

# 📌 Variables d'arme
@export var bullet_scene: PackedScene  # Scène de la balle
@export var fire_rate: float = 0.5  # Cadence de tir
@export var bullet_speed: float = 500  # Vitesse des balles
@export var damage: int = 10  # Dégâts infligés par la balle

var fire_timer: Timer

func _ready():
	# 📌 Création d'un Timer au lieu d'une boucle infinie
	fire_timer = Timer.new()
	fire_timer.wait_time = fire_rate
	fire_timer.autostart = true
	fire_timer.one_shot = false
	fire_timer.connect("timeout", Callable(self, "fire"))
	add_child(fire_timer)

func fire():
	# Vérifier s'il y a des ennemis avant de tirer
	if get_tree().get_nodes_in_group("enemies").size() == 0:
		#print("⛔ Pas d'ennemis, arrêt du tir.")
		return  # Arrête le tir si aucun ennemi

	#print("🔥 Fire() appelé !")

	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = get_closest_enemy_direction()
		bullet.speed = bullet_speed
		bullet.damage = damage
		get_tree().current_scene.add_child(bullet)
		
		#print("🚀 Balle tirée vers :", bullet.direction)
		emit_signal("weapon_fired", bullet)


# 📌 Trouver l'ennemi le plus proche
func get_closest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null

	var closest_enemy = enemies[0]
	var min_dist = global_position.distance_to(closest_enemy.global_position)

	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			closest_enemy = enemy
			min_dist = dist

	return closest_enemy

# 📌 Calculer la direction vers l'ennemi le plus proche
func get_closest_enemy_direction():
	var enemy = get_closest_enemy()
	if enemy:
		#print("🎯 Ennemi trouvé :", enemy.name, " Direction :", (enemy.global_position - global_position).normalized())
		return (enemy.global_position - global_position).normalized()
	return Vector2.RIGHT  # Si aucun ennemi, tirer vers la droite
