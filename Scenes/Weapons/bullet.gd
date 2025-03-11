extends Node2D

# 📌 Variables
var speed: float = 500
var damage: int = 10
var direction: Vector2 = Vector2.RIGHT  # Direction de la balle

func _process(delta):
	position += direction * speed * delta  # Déplacement de la balle

func _on_area_2d_area_entered(area: Area2D) -> void:
	#print("💥 Balle a touché :", area.name, " Type :", area)

	if area.is_in_group("enemies"):
		var enemy = area.get_parent()  # Remonter au parent si nécessaire
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)
			queue_free()
		else:
			print("⚠️ Problème : L'ennemi n'a pas take_damage() !")
