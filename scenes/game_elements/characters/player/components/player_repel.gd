# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
class_name PlayerRepel
extends Node2D

## Emitted when the repel starts or stops.
signal repelling_changed(repelling: bool)

const REPEL_ANTICIPATION_TIME: float = 0.3

## If false, [member repelling] should be changed by other means.
@export var player_controlled: bool = true

## If controlled by the player, which input action triggers the repel.
@export var input_action: StringName = &"repel"

# --- NUEVAS VARIABLES DE BALANCEO (COOLDOWN) ---
@export var max_duration: float = 0.8  # Tiempo máximo que puede mantenerse activo
@export var cooldown: float = 1.5      # Tiempo de espera antes de volver a usarlo
# -----------------------------------------------

## Current state of the repel.
@export var repelling: bool = false:
	set = _set_repelling

# --- VARIABLES INTERNAS PARA CONTROLAR TIEMPOS ---
var _is_on_cooldown: bool = false
var _active_time: float = 0.0
# -------------------------------------------------

@onready var air_stream: Area2D = %AirStream
@onready var repel_animation: AnimationPlayer = %RepelAnimation


# Controlamos el tiempo máximo que el escudo lleva activo
func _process(delta: float) -> void:
	if repelling:
		_active_time += delta
		# Si se excede el tiempo límite, forzamos el apagado y la recarga
		if _active_time >= max_duration:
			_trigger_cooldown()


func _set_repelling(new_repelling: bool) -> void:
	repelling = new_repelling
	if not is_node_ready():
		return
	repelling_changed.emit(repelling)
	if repelling:
		_animate()


func _unhandled_input(_event: InputEvent) -> void:
	if not player_controlled:
		return
		
	if Input.is_action_just_pressed(input_action):
		# Solo permitimos activar el escudo si NO está en tiempo de recarga
		if not _is_on_cooldown:
			_active_time = 0.0 # Reiniciamos el cronómetro de uso
			repelling = true
	elif Input.is_action_just_released(input_action):
		# Si el jugador suelta el botón antes del límite, inicia la recarga
		if repelling:
			_trigger_cooldown()


# Función encargada de apagar el escudo y castigar al jugador con tiempo de espera
func _trigger_cooldown() -> void:
	repelling = false
	_is_on_cooldown = true
	print("⏳ Escudo apagado. Esperando recarga...")
	
	await get_tree().create_timer(cooldown).timeout
	
	_is_on_cooldown = false
	print("✅ ¡Escudo listo para usarse de nuevo!")


func repel_once() -> void:
	if not _is_on_cooldown:
		repelling = true
		repelling = false


func _on_air_stream_body_entered(body: Node2D) -> void:
	if body.has_method("got_repelled"):
		var direction := global_position.direction_to(body.global_position)
		body.got_repelled(direction)


func _animate() -> void:
	# The repel animation is already ongoing. Prevent starting it again by smashing the buttons.
	if repel_animation.current_animation == &"repel":
		return

	# Repel animation is being played for the first time. So skip the anticipation and go
	# directly to the action.
	repel_animation.play(&"repel")
	repel_animation.seek(REPEL_ANTICIPATION_TIME, false, false)


func _on_repel_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"repel" and repelling:
		repel_animation.play(&"repel")
