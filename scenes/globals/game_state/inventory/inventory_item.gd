# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
@tool
class_name InventoryItem
extends Resource

enum ItemType {
	MEMORY,
	IMAGINATION,
	SPIRIT,
	NONE,
}

const COLORS_PER_TYPE: Dictionary[ItemType, Color] = {
	ItemType.MEMORY: Color(0.459, 0.867, 0.0, 1.0),
	ItemType.IMAGINATION: Color(0.969, 0.792, 0.0, 1.0),
	ItemType.SPIRIT: Color(0.929, 0.0, 0.0, 1.0)
}

const HUD_TEXTURES: Dictionary[ItemType, Texture2D] = {
	ItemType.MEMORY: preload("D:/Game_Team04/NatureMax/threadbare/scenes/quests/story_quests/nature_max/mis_mosaicos/primersimboloderecompensa.png"),
	ItemType.IMAGINATION: preload("D:/Game_Team04/NatureMax/threadbare/scenes/quests/story_quests/nature_max/mis_mosaicos/segundosimboloderecompensa.png"),
	ItemType.SPIRIT: preload("D:/Game_Team04/NatureMax/threadbare/scenes/quests/story_quests/nature_max/mis_mosaicos/primer-recompensaHUB.png")
}

const WORLD_TEXTURES: Dictionary[ItemType, Texture2D] = {
	ItemType.MEMORY: preload("D:/Game_Team04/NatureMax/threadbare/scenes/quests/story_quests/nature_max/mis_mosaicos/primersimboloderecompensa.png"),
	ItemType.IMAGINATION: preload("D:/Game_Team04/NatureMax/threadbare/scenes/quests/story_quests/nature_max/mis_mosaicos/segundosimboloderecompensa.png"),
	ItemType.SPIRIT: preload("D:/Game_Team04/NatureMax/threadbare/scenes/quests/story_quests/nature_max/mis_mosaicos/primer-recompensaHUB.png")
}

@export var name: String
@export var type: ItemType


func get_hud_texture() -> Texture2D:
	return HUD_TEXTURES[type]


func get_world_texture() -> Texture2D:
	return WORLD_TEXTURES[type]


static func with_type(a_type: ItemType) -> InventoryItem:
	var item := new()
	item.type = a_type
	return item


func type_name() -> String:
	return ItemType.find_key(type).to_pascal_case()
