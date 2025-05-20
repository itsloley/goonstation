/datum/projectile/special/piercing/black_butterfly
	name = "black butterfly"
	sname = "black butterfly"
	icon = 'code/WorkInProgress/ly/icons/32x32.dmi'
	icon_state = "butterfly_b"
	window_pass = 0
	damage = 2
	dissipation_delay = 2
	damage_type = D_ENERGY
	scale = 0.6

/datum/projectile/special/piercing/white_butterfly
	name = "white butterfly"
	sname = "white butterfly"
	icon = 'code/WorkInProgress/ly/icons/32x32.dmi'
	icon_state = "butterfly_w"
	window_pass = 0
	damage = 2
	dissipation_delay = 2
	damage_type = D_KINETIC
	scale = 0.6

/datum/projectile/special/spreader/buckshot_burst/black_butterflies
	name = "black butterflies"
	sname = "butterfly spread"
	cost = 20
	pellets_to_fire = 8
	spread_projectile_type = /datum/projectile/special/piercing/black_butterfly
	casing = null
	shot_sound = 'code/WorkInProgress/ly/sounds/butterfly_black.ogg'
	shot_pitch = 0
	shot_volume = 10
	speed_max = 40
	speed_min = 5
	spread_angle_variance = 8
	dissipation_variance = 2

/datum/projectile/special/spreader/buckshot_burst/white_butterflies
	name = "white butterflies"
	sname = "butterfly spread"
	cost = 20
	pellets_to_fire = 8
	spread_projectile_type = /datum/projectile/special/piercing/white_butterfly
	casing = null
	shot_sound = 'code/WorkInProgress/ly/sounds/butterfly_white.ogg'
	shot_pitch = 0
	shot_volume = 10
	speed_max = 40
	speed_min = 5
	spread_angle_variance = 8
	dissipation_variance = 2

/obj/item/gun/energy/ego_solemn_lament
	name = "Solemn Lament"
	icon = 'code/WorkInProgress/ly/icons/32x32.dmi'
	force = 10
	rechargeable = 0
	cell_type = /obj/item/ammo/power_cell/self_charging/big
	can_swap_cell = 0
	icon_recoil_enabled = TRUE
	camera_recoil_enabled = TRUE
	shoot_delay = 1.2 SECONDS
	var/dual_wield_shoot_delay = 0.6 SECONDS

	pixelaction(atom/target, params, mob/user, reach, continuousFire = 0) // thanks for hardcoding dual wield shot time guys
		if (reach)
			return 0
		if (!isturf(user.loc))
			return 0

		var/pox = text2num(params["icon-x"]) - 16 + target.pixel_x
		var/poy = text2num(params["icon-y"]) - 16 + target.pixel_y
		var/turf/user_turf = get_turf(user)
		var/turf/target_turf = get_turf(target)

		//if they're holding a gun in each hand... why not shoot both!
		var/is_dual_wield = 0
		if (can_dual_wield)
			if(ishuman(user))
				var/obj/item/gun/G
				if(user.hand && istype(user.r_hand, /obj/item/gun))
					G = user.r_hand
				else if(!user.hand && istype(user.l_hand, /obj/item/gun))
					G = user.l_hand

				if (G && G.can_dual_wield && G.canshoot(user))
					is_dual_wield = 1
					if(!ON_COOLDOWN(G, "shoot_delay", G.shoot_delay))
						SPAWN(dual_wield_shoot_delay)
							if(!(G in user.equipped_list())) return
							G.Shoot(target_turf,user_turf,user, pox+rand(-2,2), poy+rand(-2,2), is_dual_wield, target)

			else if(ismobcritter(user))
				var/mob/living/critter/M = user
				var/list/obj/item/gun/guns = list()
				for(var/datum/handHolder/H in M.hands)
					if(H.item && H.item != src && istype(H.item, /obj/item/gun) && H.item:can_dual_wield)
						is_dual_wield = 1
						if (H.item:canshoot(user))
							guns += H.item
				SPAWN(0)
					for(var/obj/item/gun/gun in guns)
						if(!ON_COOLDOWN(gun, "shoot_delay", gun.shoot_delay))
							sleep(dual_wield_shoot_delay)
							if(!(gun in user.equipped_list())) return
							gun.Shoot(target_turf,user_turf,user, pox+rand(-2,2), poy+rand(-2,2), is_dual_wield, target)

		if(!ON_COOLDOWN(src, "shoot_delay", src.shoot_delay))
			Shoot(target_turf, user_turf, user, pox, poy, is_dual_wield, target)


		return 1

	shoot_point_blank(atom/target, var/mob/user as mob, var/second_shot = 0)
		if (!target || !user)
			return FALSE

		if (isghostdrone(user))
			user.show_text("<span class='combat bold'>Your internal law subroutines kick in and prevent you from using [src]!</span>")
			return FALSE

		var/is_dual_wield = 0
		var/obj/item/gun/second_gun
		//Ok. i know it's kind of dumb to add this param 'second_shot' to the shoot_point_blank proc just to make sure pointblanks don't repeat forever when we could just move these checks somewhere else.
		//but if we do the double-gun checks here, it makes stuff like double-hold-at-gunpoint-pointblanks easier!
		if (can_dual_wield && !second_shot)
			//brutal double-pointblank shots
			if (ishuman(user))
				if(user.hand && istype(user.r_hand, /obj/item/gun) && user.r_hand:can_dual_wield)
					second_gun = user.r_hand
					var/target_turf = get_turf(target)
					is_dual_wield = 1
					SPAWN(dual_wield_shoot_delay)
						if(user.r_hand != second_gun) return
						if (BOUNDS_DIST(user, target) == 0)
							second_gun.ShootPointBlank(target,user,second_shot = 1)
						else
							second_gun.shoot(target_turf,get_turf(user), user, rand(-5,5), rand(-5,5), is_dual_wield, target)
				else if(!user.hand && istype(user.l_hand, /obj/item/gun) && user.l_hand:can_dual_wield)
					second_gun = user.l_hand
					var/target_turf = get_turf(target)
					is_dual_wield = 1
					SPAWN(dual_wield_shoot_delay)
						if(user.l_hand != second_gun) return
						if (BOUNDS_DIST(user, target) == 0)
							second_gun.ShootPointBlank(target,user,second_shot = 1)
						else
							second_gun.shoot(target_turf,get_turf(user), user, rand(-5,5), rand(-5,5), is_dual_wield, target)

	black
		icon_state = "solemn_lament_b"
		item_state = "solemn_lament_b"
		desc = "The somber design is a reminder that not a sliver of frivolity is allowed for the minds of those who mourn. This handgun symbolizes grief for the dead."

		New()
			set_current_projectile(new/datum/projectile/special/spreader/buckshot_burst/black_butterflies)
			projectiles = list(new/datum/projectile/special/spreader/buckshot_burst/black_butterflies)
			..()

	white
		icon_state = "solemn_lament_w"
		item_state = "solemn_lament_w"
		desc = "The somber design is a reminder that not a sliver of frivolity is allowed for the minds of those who mourn. This handgun symbolizes early lament for the living."

		New()
			set_current_projectile(new/datum/projectile/special/spreader/buckshot_burst/white_butterflies)
			projectiles = list(new/datum/projectile/special/spreader/buckshot_burst/white_butterflies)
			..()

/obj/item/clothing/suit/solemn_lament
	name = "undertaker's outfit"
	desc = "If you see a mound standing out in the middle of the desert, please do not desecrate it. It is the grave of the countless butterflies that have died in this place."
	icon = 'code/WorkInProgress/ly/icons/32x32.dmi'
	wear_image_icon = 'code/WorkInProgress/ly/icons/32x32.dmi'
	icon_state = "solemn_lament_suit"
	item_state = "solemn_lament_suit"

/obj/storage/crate/solemn_lament
	icon_state = "attachecase"
	icon_opened = "attachecase_open"
	icon_closed = "attachecase"
	spawn_contents = list(/obj/item/gun/energy/ego_solemn_lament/black = 1, /obj/item/gun/energy/ego_solemn_lament/white = 1, /obj/item/clothing/suit/solemn_lament = 1)
