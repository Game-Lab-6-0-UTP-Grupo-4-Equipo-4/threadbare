# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
class_name FillGameLogic
extends Node
## Manages the logic of the fill-matching game.

signal goal_reached

@export var barrels_to_win: int = 1
@export var autostart: bool = false
var barrels_completed: int = 0

# --- NUESTRA VARIABLE ESTÁTICA TIPO JAVA ---
# Sobrevivirá a los reinicios de escena (reload_current_scene)
static var batalla_iniciada: bool = false
# ------------------------------------------

func start() -> void:
	batalla_iniciada = true # Marcamos globalmente que el combate ya arrancó
	_update_allowed_colors()
	get_tree().call_group("throwing_enemy", "start")


func _ready() -> void:
	var filling_barrels: Array = get_tree().get_nodes_in_group("filling_barrels")
	barrels_to_win = clampi(barrels_to_win, 0, filling_barrels.size())
	for barrel: FillingBarrel in filling_barrels:
		barrel.completed.connect(_on_barrel_completed)
		
	# Lógica inteligente de auto-inicio
	if autostart or FillGameLogic.batalla_iniciada:
		# Pequeña pausa para asegurar que el SceneTree cargó todos los nodos
		await get_tree().create_timer(0.5).timeout
		start()


func _update_allowed_colors() -> void:
	var allowed_labels: Array[String] = []
	var color_per_label: Dictionary[String, Color]
	for filling_barrel: FillingBarrel in get_tree().get_nodes_in_group("filling_barrels"):
		if filling_barrel.is_queued_for_deletion():
			continue
		if filling_barrel.label not in allowed_labels:
			allowed_labels.append(filling_barrel.label)
			if not filling_barrel.color:
				continue
			color_per_label[filling_barrel.label] = filling_barrel.color
	for enemy: ThrowingEnemy in get_tree().get_nodes_in_group("throwing_enemy"):
		enemy.allowed_labels = allowed_labels
		enemy.color_per_label = color_per_label


func _on_barrel_completed() -> void:
	barrels_completed += 1
	_update_allowed_colors()
	if barrels_completed < barrels_to_win:
		return
	get_tree().call_group("throwing_enemy", "remove")
	get_tree().call_group("projectiles", "remove")
	goal_reached.emit()
