/mob/living/critter/robotic/drone/ar
	drone_designation = "AR"
	desc = "A highly dangerous Syndicate artillery drone."
	icon = 'icons/mob/critter/robotic/drone/artillery.dmi'
	icon_state = "drone_artillery"
	alert_sounds = list('sound/machines/engine_alert1.ogg')

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/artillery
		HH.name = "S-42 Cluster Munition Shells"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handart"
		HH.limb_name = "S-42 Cluster Munition Shells"
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1

	setup_loot_table()
		..()
		loot_table[/obj/item/shipcomponent/secondary_system/crash] = 100

	setup_healths()
		add_hh_robot(125, 1)
		add_hh_robot_burn(125, 1)
