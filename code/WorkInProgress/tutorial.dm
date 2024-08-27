/area/tutorial/basics/
	name = "Tutorial"
	icon_state = "blue"
	requires_power = 0
	area_parallax_render_source_group = /datum/parallax_render_source_group/area/cairngorm

/area/tutorial/basics/pool
	name = "Tutorial Pool"
	icon_state = "yellow"

/area/tutorial/basics/engineering
	name = "Tutorial Engineering"
	icon_state = "yellow"

/area/tutorial/basics/botany
	name = "Tutorial Botany"
	icon_state = "green"

/area/tutorial/basics/civilian
	name = "Tutorial Civilian"
	icon_state = "pink"

/area/tutorial/basics/science
	name = "Tutorial Science"
	icon_state = "purple"

/area/tutorial/basics/medbay
	name = "Tutorial Medbay"
	icon_state = "yellow"

/area/tutorial/basics/shooting_range
	name = "Tutorial Shooting Range"
	icon_state = "red"
	sanctuary = 1

/area/tutorial/basics/space
	name = "Tutorial Space"
	icon_state = "death"

/obj/item/card/id/tutorial
	name = "card"
	desc = "That was a lot of work for a simple—Hey, this is just a painted-on Dave & Busters power card!"
	icon = 'icons/misc/tutorial.dmi'
	icon_state = "id_tutorial"
	access = list(access_tutorialbasics)
	registered = null
	assignment = null
	title = null

/obj/item/tutorial/id_fragment
	name = "card fragment"
	desc = "A torn section of what seems to be an identification card. Maybe there's more around?"
	icon = 'icons/misc/tutorial.dmi'
	icon_state = "idfragment_1"

	attackby(item, mob/user)
		if(istype(item, /obj/item/tutorial/id_fragment))
			if(item == src) return // Prevent combining the fragment with itself

			// Combine two fragments into a partial card
			var/obj/item/assembly/tutorial_id/partial_id = new /obj/item/assembly/tutorial_id(get_turf(src)) // Spawn on the turf
			user.show_message(SPAN_NOTICE("You combine the two fragments into a partial card."), 1)
			playsound(get_turf(partial_id), 'sound/machines/click.ogg', 50, 1)
			qdel(src)
			qdel(item)
		else if(istype(item, /obj/item/assembly/tutorial_id))
			var/obj/item/assembly/tutorial_id/partial_id = item
			partial_id.fragments_attached += 1
			user.show_message(SPAN_NOTICE("You attach the fragment to the partial card."), 1)
			playsound(get_turf(partial_id), 'sound/machines/click.ogg', 50, 1)
			qdel(src)

			// Complete the card if enough fragments are attached
			if(partial_id.fragments_attached >= 4)
				var/obj/item/card/id/tutorial/completed_card = new /obj/item/card/id/tutorial(get_turf(partial_id))
				user.show_message(SPAN_NOTICE("The card is fully assembled!"), 1)
				playsound(get_turf(completed_card), 'sound/machines/click.ogg', 50, 1)
				particleMaster.SpawnSystem(new /datum/particleSystem/confetti(get_turf(completed_card)))
				playsound(get_turf(completed_card), 'sound/voice/yayyy.ogg', 50, 1)
				qdel(partial_id)
		else
			return ..()

/obj/item/assembly/tutorial_id
	desc = "A somewhat put together ID card. Looks like you still have a little more to go."
	name = "partial card"
	icon = 'icons/misc/tutorial.dmi'
	icon_state = "id_partial"

	var/fragments_attached = 2

	attackby(item, mob/user)
		if(istype(item, /obj/item/tutorial/id_fragment))
			fragments_attached += 1
			user.show_message(SPAN_NOTICE("You attach the fragment to the partial card."), 1)
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			qdel(item)

			// Complete the card if enough fragments are attached
			if(fragments_attached >= 4)
				var/obj/item/card/id/tutorial/completed_card = new /obj/item/card/id/tutorial(get_turf(src))
				user.show_message(SPAN_NOTICE("The card is fully assembled!"), 1)
				playsound(get_turf(completed_card), 'sound/machines/click.ogg', 50, 1)
				particleMaster.SpawnSystem(new /datum/particleSystem/confetti(get_turf(completed_card)))
				playsound(get_turf(completed_card), 'sound/voice/yayyy.ogg', 50, 1)
				qdel(src)
		else if(istype(item, /obj/item/assembly/tutorial_id))
			var/obj/item/assembly/tutorial_id/other_assembly = item
			if(other_assembly.fragments_attached + fragments_attached > 4)
				user.show_message(SPAN_NOTICE("The fragments don't fit together. You have too many."), 1)
				return

			fragments_attached += other_assembly.fragments_attached
			user.show_message(SPAN_NOTICE("You combine the two partial cards."), 1)
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			qdel(other_assembly)

			// Complete the card if enough fragments are attached
			if(fragments_attached >= 4)
				var/obj/item/card/id/tutorial/completed_card = new /obj/item/card/id/tutorial(get_turf(src))
				user.show_message(SPAN_NOTICE("The card is fully assembled!"), 1)
				playsound(get_turf(completed_card), 'sound/machines/click.ogg', 50, 1)
				particleMaster.SpawnSystem(new /datum/particleSystem/confetti(get_turf(completed_card)))
				playsound(get_turf(completed_card), 'sound/voice/yayyy.ogg', 50, 1)
				qdel(src)
		else
			return ..()

/mob/living/carbon/human/clown_immortal
	real_name = "Boo-Boo The Immortal Clown"
	desc = "In addition to being completely indestructible, Boo-Boo cannot move his body, yet he feels and remembers everything. There is truly no greater hell."
	gloves = new/obj/item/clothing/gloves/latex
	shoes = new/obj/item/clothing/shoes/clown_shoes
	w_uniform = new/obj/item/clothing/under/misc/clown
	wear_mask = new/obj/item/clothing/mask/clown_hat
	var/isFuckingDying = FALSE
	var/list/death_lines = list("BOO! Did I get you?", "Why won’t this nightmare end?", "Did you know? There's no afterlife. I've been in between worlds, there's nothing!", "HEY! Are you TRYING to kill me!?", "I feel every single wound, every single bit of soul-crushing pain you inflict upon me!")

	death(var/gibbed)
		. = ..()
		for (var/obj/item/implant/I in implant) //no infinite item stacks
			if (istype(I, /obj/item/implant/projectile))
				I.on_remove(src)
				implant.Remove(I)
				qdel(I)
		if (src.isFuckingDying == FALSE)
			src.isFuckingDying = TRUE
			booboo_prank()


	face_visible()
		return TRUE

	gib()
		src.limbs.l_arm.sever()
		src.limbs.r_arm.sever()
		src.limbs.l_leg.sever()
		src.limbs.r_leg.sever()
		gibs(src.loc)

		src.death()

	proc/booboo_prank()
		SPAWN(3 SECONDS)
			src.full_heal()
			src.isFuckingDying = FALSE
			src.emote("scream")
			SPAWN(2 SECONDS)
				src.say(pick(src.death_lines))

/obj/machinery/door/airlock/pyro/weapons/secure/indestructible
	desc = "An EXTREMELY indestructible airlock. An absurdly robust one at that."
	var/initialPos
	anchored = ANCHORED_ALWAYS
	New()
		..()
		initialPos = loc

	disposing()
		SHOULD_CALL_PARENT(0) //These are ACTUALLY indestructible.

		SPAWN(0)
			loc = initialPos
			qdeled = 0// L   U    L

	set_loc()
		SHOULD_CALL_PARENT(FALSE)
		loc = initialPos
		return

	Del()
		if(!initialPos)
			return ..()
		loc = initialPos//LULLE

	hitby()
		SHOULD_CALL_PARENT(FALSE)
	reagent_act()
	bullet_act()
	ex_act()
	blob_act()
	meteorhit()
	damage_heat()
	damage_corrosive()
	damage_piercing()
	damage_slashing()
	damage_blunt()
	take_damage()

/obj/item/seed/superseeds
	name = "Happy Plant Mixture™ Infused Seeds"
	desc = "<span class='alert'><b>WARNING: THIS PRODUCT CONTAINS CHEMICALS KNOWN TO CAUSE CANCER AND BIRTH DEFECTS OR OTHER REPRODUCTIVE HARM.</b></span> - Now with 200% more Growth Hormones!"
	dont_mutate = 1

	New()
		..()
		name = "Happy Plant Mixture™ Infused [name]"
		plantgenes = new /datum/plantgenes
		plantgenes.growtime = 70
		plantgenes.harvtime = 120
		plantgenes.cropsize = 3
		plantgenes.harvests = INFINITY

/obj/artifact/prison/tutorial_artifact
	New()
		..()
		artifact = new /datum/artifact/prison(src)
		if(istype(artifact, /datum/artifact/prison))
			var/datum/artifact/prison/prison_artifact = artifact
			prison_artifact.validtriggers = list(/datum/artifact_trigger/silicon_touch)
			prison_artifact.imprison_time = 200

/obj/item/tutorial/magicbell
	name = "Magical Congratulations Bell"
	desc = "A bell used to signal the awesome congratulations of some newcomers!"
	anchored = ANCHORED
	density = 1
	icon = 'icons/obj/wrestlingbell.dmi'
	icon_state = "wrestlingbell"
	var/last_ring = 0
	var/list/macho_arena_turfs // To track the ring turfs
	var/ring_radius = 4 // Variable to change the ring size
	var/objpath = /obj/item/bat // Default item to spawn on sides
	var/distance_from_ring = 2 // Distance of bats from the ring
	var/list/spawned_items = list() // List to track spawned items
	var/player_count = 0 // Number of players fighting

	attack_hand(mob/user)
		if (last_ring + 20 >= world.time) // Prevent spam
			return
		else
			last_ring = world.time
			playsound(src.loc, 'sound/misc/Boxingbell.ogg', 50, 1)
			var/turf/Aloc = get_turf(src)
			var/turf/T = locate(Aloc.x, Aloc.y - (ring_radius + 1), Aloc.z) // Target location 1 tile below the northern rope
			if (macho_arena_turfs) // If the ring already exists, remove it
				clean_up_arena_turfs(src.macho_arena_turfs)
				macho_arena_turfs = null
				clean_up_spawned_items()
			else // Summon the ring with animations
				var/list/arenaropes = list()

				// Summon the ropes and corners with animations
				for (var/turf/Turf in range(ring_radius, T))
					if (GET_DIST(T, Turf) == ring_radius) // boundaries
						if (abs(T.x - Turf.x) == ring_radius && abs(T.y - Turf.y) == ring_radius) // arena corners
							var/obj/stool/chair/boxingrope_corner/FF = new/obj/stool/chair/boxingrope_corner(Turf)
							FF.alpha = 0 // Start with invisible ropes
							arenaropes += FF
							if (Turf.x < T.x) // to the west
								if (Turf.y > T.y) // north-west corner
									FF.set_dir(NORTHWEST)
								else
									FF.set_dir(SOUTHWEST)
							else // to the east
								if (Turf.y > T.y) // north-east
									FF.set_dir(NORTHEAST)
								else
									FF.set_dir(SOUTHEAST)
							var/random_deviation = rand(0, 5)
							SPAWN(random_deviation) // Delay for animation
								spawn_animation1(FF)
								sleep(10) // animation, also to simulate them coming in and slamming into the ground
								FF.visible_message(SPAN_ALERT("<B>[FF] slams and anchors itself into the ground!</B>"))
								playsound(T, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, TRUE)
								for (var/mob/living/M in oviewers(ring_radius * 2, T))
									shake_camera(M, 8, 24) // Camera shake effect for dramatic impact
						else // arena ropes
							var/obj/decal/boxingrope/Rope = new/obj/decal/boxingrope(Turf)
							Rope.alpha = 0 // Start with invisible ropes
							arenaropes += Rope
							if (abs(T.x - Turf.x) == ring_radius) // side ropes
								if (Turf.x - T.x < 0)  // west rope
									Rope.set_dir(WEST)
								else // east rope
									Rope.set_dir(EAST)
							else // top/bottom ropes
								if (Turf.y - T.y > 0) // north ropes
									Rope.set_dir(NORTH)
								else
									Rope.set_dir(SOUTH)
							SPAWN(1) // Add a delay for each rope
								spawn_animation1(Rope)

				// Define positions based on player count and ring size
				var/list/positions = list()
				if (player_count >= 1)
					positions += locate(T.x - ring_radius + distance_from_ring, T.y, T.z) // Left
				if (player_count >= 2)
					positions += locate(T.x + ring_radius - distance_from_ring, T.y, T.z) // Right
				if (player_count >= 3)
					positions += locate(T.x, T.y - ring_radius + distance_from_ring, T.z) // Up
				if (player_count >= 4)
					positions += locate(T.x, T.y + ring_radius - distance_from_ring, T.z) // Down
				if (player_count >= 5)
					positions += locate(T.x - ring_radius + distance_from_ring, T.y - ring_radius + distance_from_ring, T.z) // Top Left
				if (player_count >= 6)
					positions += locate(T.x + ring_radius - distance_from_ring, T.y - ring_radius + distance_from_ring, T.z) // Top Right
				if (player_count >= 7)
					positions += locate(T.x - ring_radius + distance_from_ring, T.y + ring_radius - distance_from_ring, T.z) // Bottom Left
				if (player_count >= 8)
					positions += locate(T.x + ring_radius - distance_from_ring, T.y + ring_radius - distance_from_ring, T.z) // Bottom Right

				// Spawn items based on the number of players
				for (var/i = 1; i <= min(player_count, 8); i++)
					var/turf/pos = positions[i]
					var/obj/itemspecialeffect/poof/P = new /obj/itemspecialeffect/poof
					P.setup(pos)
					playsound(pos, 'sound/effects/poff.ogg', 50, TRUE, pitch = 1)
					var/obj/Item = new objpath(pos) // Track spawned items
					spawned_items += Item

				sleep(1.4 SECONDS) // Allow the ropes to "form" in
				macho_arena_turfs = arenaropes

	proc/clean_up_arena_turfs(var/list/arena_turfs_to_cleanup)
		for (var/obj/decal/boxingrope/Rope in arena_turfs_to_cleanup)
			SPAWN(0)
				leaving_animation(Rope)
				qdel(Rope)
		for (var/obj/stool/chair/boxingrope_corner/Corner in arena_turfs_to_cleanup)
			SPAWN(0)
				leaving_animation(Corner)
				qdel(Corner)

	proc/clean_up_spawned_items()
		for (var/obj/Item in spawned_items)
			SPAWN(0)
				leaving_animation(Item)
				qdel(Item)
		spawned_items = list() // Clear the list after cleanup
