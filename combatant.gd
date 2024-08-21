extends Node2D
class_name Combatant

# Переменные для хранения значений
var hp: int
var initiative: int
var combatant_name: String

func _init(initial_hp: int, initial_initiative: int, initial_name: String) -> void:
	hp = initial_hp
	initiative = initial_initiative
	name = initial_name

# Метод для атаки
func attack(target: Combatant) -> void:
	var damage: int = randi_range(1, 10)
	target.take_damage(damage)

# Метод для получения урона
func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	queue_free()
