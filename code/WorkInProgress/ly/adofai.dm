// this is the jankiest thing i ever did make
/mob/living/critter/adofai
	icon_state = null
	appearance_flags = KEEP_TOGETHER | PIXEL_SCALE | LONG_GLIDE | RESET_COLOR
	layer = MOB_LAYER + 1
	health_brute = 200
	health_brute_vuln = 1
	use_stamina = FALSE
	custom_gib_handler = /proc/robogibs
	canspeak = 0
	flags = TABLEPASS
	fits_under_table = 1
	density = 0
	hand_count = 0
	can_burn = FALSE
	can_throw = 0
	can_grab = 0
	canbegrabbed = FALSE
	can_disarm = 0
	can_lie = 0
	anchored = 1
	metabolizes = FALSE
	can_bleed = FALSE
	blood_id = null
	emote_allowed = 0
	base_move_delay = 0
	base_walk_delay = 0
	glide_size = 32
	var/obj/fakeobject/planet_a
	var/obj/fakeobject/planet_b
	var/obj/fakeobject/adofai_ring/planet_ring = null
	var/swapped_planets = TRUE
	var/laststeptime = 0
	var/bpm_speed = 4
	var/previous_rot
	var/diagonals = FALSE
	var/spin_dir = "clockwise"
	var/timing_offset = 0
	var/damaging = 1 // 0 does no harm, 1 hurts, 2 gibs
	var/a_color = "#0088FF"
	var/b_color = "#FF2200"

	friendly
		damaging = 0

	instakill
		damaging = 2

	New()
		..()
		planet_a = new /image('code/WorkInProgress/ly/icons/32x32.dmi', "adofai")
		planet_a.layer = MOB_LAYER + 1
		planet_b = new /image('code/WorkInProgress/ly/icons/32x32.dmi', "adofai")
		planet_b.pixel_x = 32
		planet_b.layer = MOB_LAYER + 1
		planet_life()

		remove_lifeprocess(/datum/lifeprocess/radiation)
		remove_lifeprocess(/datum/lifeprocess/stuns_lying)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT, src, 100)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_HEATPROT, src, 100)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_COLDPROT, src, 100)

		abilityHolder.addAbility(/datum/targetable/critter/adofai/move)
		abilityHolder.addAbility(/datum/targetable/critter/adofai/diagonals)
		//abilityHolder.addAbility(/datum/targetable/critter/adofai/change_rotation)
		abilityHolder.addAbility(/datum/targetable/critter/adofai/set_color)

	proc/handle_ring()
		if (!isnull(planet_ring))
			var/matrix/M3 = matrix()
			M3.Scale(0,0)
			var/obj/fakeobject/adofai_ring/delete_me = planet_ring
			animate(delete_me, transform = M3, time = 10/bpm_speed, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
			SPAWN(1 SECOND)
				qdel(delete_me)
		planet_ring = new /obj/fakeobject/adofai_ring
		planet_ring.set_loc(src.loc)
		var/matrix/M = matrix()
		M.Scale(0,0)
		planet_ring.transform = M
		var/matrix/M2 = matrix()
		M2.Scale(1,1)
		animate(planet_ring, transform = M2, time = 10/bpm_speed, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
		animate_spin(planet_ring, "R", 25/bpm_speed, -1)

	proc/planet_life()
		playsound(src.loc, 'code/WorkInProgress/ly/sounds/adofai_kick.ogg', 50, 0)
		animate(src)
		laststeptime = TIME
		if (previous_rot)
			src.transform = turn(src.transform, -previous_rot)
		previous_rot = ((laststeptime/(5/bpm_speed))*45)%360
		src.transform = turn(src.transform, previous_rot)
		src.transform = turn(src.transform, 180)
		var/matrix/M = src.transform
		var/turn = 90
		if (spin_dir == "counter-clockwise")
			turn = -90
		var/old_a = a_color
		a_color = b_color
		b_color = old_a
		swapped_planets = !swapped_planets
		handle_ring()
		update_colors()
		while(laststeptime == TIME)
			sleep(0.1)
		animate(src, transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = 10/bpm_speed, loop = -1)
		animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = 10/bpm_speed, loop = -1)
		animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = 10/bpm_speed, loop = -1)
		animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = 10/bpm_speed, loop = -1)

	proc/change_direction() // shit dont work right btw
		animate(src)
		if (spin_dir == "clockwise")
			spin_dir = "counter-clockwise"
		else
			spin_dir = "clockwise"
		laststeptime = TIME
		if (previous_rot)
			src.transform = turn(src.transform, -previous_rot)
		previous_rot = ((laststeptime/(5/bpm_speed))*45)%360
		src.transform = turn(src.transform, previous_rot)
		var/matrix/M = src.transform
		var/turn = 90
		if (spin_dir == "counter-clockwise")
			turn = -90
		animate(src, transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = 10/bpm_speed, loop = -1)
		animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = 10/bpm_speed, loop = -1)
		animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = 10/bpm_speed, loop = -1)
		animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = 10/bpm_speed, loop = -1)

	proc/update_colors()
		planet_a.color = a_color
		planet_b.color = b_color
		planet_ring.color = a_color
		src.UpdateOverlays(planet_a, "planet_a")
		src.UpdateOverlays(planet_b, "planet_b")

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("flip")
				return
		return null

	death(var/gibbed, var/do_drop_equipment = 1)
		..()
		qdel(src)

	disposing()
		qdel(planet_a)
		qdel(planet_b)
		qdel(planet_ring)
		..()

	is_heat_resistant()
		return TRUE

	can_eat()
		return FALSE

	can_drink()
		return FALSE

	isBlindImmune()
		return TRUE

	shock(var/atom/origin, var/wattage, var/zone = "chest", var/stun_multiplier = 1, var/ignore_gloves = 0)
		return 0

	electric_expose(var/power = 1)
		return 0

	vomit()
		return

	movement_delay()
		return -1

	process_move()
		return

/obj/fakeobject/adofai_ring
	icon = 'code/WorkInProgress/ly/icons/96x96.dmi'
	icon_state = "adofai_ring_small_l"
	appearance_flags = KEEP_TOGETHER | LONG_GLIDE | RESET_COLOR
	density = 0
	anchored = 1
	layer = MOB_LAYER + 0.5
	glide_size = 32
	pixel_x = -32
	pixel_y = -32

/datum/targetable/critter/adofai/move
	name = "Step"
	desc = "Move to where the other planet currently is."
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "pandemonium"
	cooldown = 0
	targeted = 0

	cast(atom/target)
		if(!holder)
			return
		..()
		if(!istype(holder.owner, /mob/living/critter/adofai))
			return
		var/mob/living/critter/adofai/A = holder.owner
		var/decide_dir = A.swapped_planets ? (((TIME/(5/A.bpm_speed))*45+22.5)%360) : (((TIME/(5/A.bpm_speed))*45+180+22.5)%360)
		var/decision = EAST
		if (A.diagonals)
			switch (decide_dir)
				if (0 to 45)         decision = EAST
				if (45 to 90)        decision = SOUTHEAST
				if (90 to 135)       decision = SOUTH
				if (135 to 180)      decision = SOUTHWEST
				if (180 to 225)      decision = WEST
				if (225 to 270)      decision = NORTHWEST
				if (270 to 315)      decision = NORTH
				if (315 to 360)      decision = NORTHEAST
		else
			switch (decide_dir)
				//if (0 to 90)       decision = EAST
				//if (90 to 180)   decision = SOUTH
				//if (180 to 270)  decision = WEST
				//if (270 to 360)  decision = NORTH
				if (0 to 67.5)       decision = EAST
				if (67.5 to 157.5)   decision = SOUTH
				if (157.5 to 247.5)  decision = WEST
				if (247.5 to 337.5)  decision = NORTH
				if (337.5 to 360)    decision = EAST
		step(A, decision)
		if (A.damaging > 0)
			var/newturf = get_turf(A)
			for (var/atom/B in newturf)
				if (B.invisibility || istype(B, /obj/overlay/tile_effect))
					continue
				if (ismob(B))
					var/mob/M = B
					if (istype(M, /mob/living/critter/adofai))
						continue
					if (A.damaging > 1)
						if (A.swapped_planets)
							M.firegib()
						else
							M.become_statue_ice()
					else
						M.TakeDamage("All", 0, 15)
						if (A.swapped_planets)
							M.bodytemperature += 10
							M.changeStatus("burning", 10 SECONDS)
						else
							M.bodytemperature -= 30
							var/obj/icecube/I = new/obj/icecube(get_turf(M), M)
							I.health = 8
		A.planet_life()

/datum/targetable/critter/adofai/diagonals
	name = "Toggle Diagonals"
	desc = "Toggle diagonal movement or just orthogonals."
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "pandemonium"
	cooldown = 0
	targeted = 0

	cast(atom/target)
		if(!holder)
			return
		..()
		if(!istype(holder.owner, /mob/living/critter/adofai))
			return
		var/mob/living/critter/adofai/A = holder.owner
		if (A.diagonals)
			A.diagonals = FALSE
			boutput(A, "You will no longer move diagonally.")
		else
			A.diagonals = TRUE
			boutput(A, "You can now move diagonally.")
/*
/datum/targetable/critter/adofai/change_rotation // currently broken, will need to be made on step and only works on step and only works on step
	name = "Change Spin Direction"
	desc = "Swap rotation direction."
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "pandemonium"
	cooldown = 0
	targeted = 0

	cast(atom/target)
		if(!holder)
			return
		..()
		if(!istype(holder.owner, /mob/living/critter/adofai))
			return
		var/mob/living/critter/adofai/A = holder.owner
		A.change_direction()
*/
/datum/targetable/critter/adofai/set_color
	name = "Set Color"
	desc = "Choose what color you want your blob to be. This will be removed when you start the blob."
	icon = 'icons/mob/blob_ui.dmi'
	icon_state = "blob-color"
	targeted = 0

	cast(atom/target)
		if(!holder)
			return
		..()
		if(!istype(holder.owner, /mob/living/critter/adofai))
			return
		var/mob/living/critter/adofai/A = holder.owner
		A.a_color = input("Planet A Color","Planet A Color", A.a_color) as null|color
		A.b_color = input("Planet B Color","Planet B Color", A.b_color) as null|color
		A.update_colors()
