/area/tutorial/
	name = "Tutorial"
	icon_state = "blue"
	requires_power = 0
	area_parallax_render_source_group = /datum/parallax_render_source_group/area/cairngorm

/area/tutorial/basics/
	name = "Tutorial General"
	icon_state = "blue"

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

/area/tutorial/basics/bar
	name = "Tutorial Bar"
	icon_state = "cafeteria"

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

/area/shuttle/tutorial
	var/warp_dir = EAST // fuck you

	Entered(atom/movable/Obj, atom/OldLoc)
		..()
		if (ismob(Obj))
			var/mob/M = Obj
			if (src.warp_dir & NORTH || src.warp_dir & SOUTH)
				M.addOverlayComposition(/datum/overlayComposition/shuttle_warp)
			else
				M.addOverlayComposition(/datum/overlayComposition/shuttle_warp/ew)

	Exited(atom/movable/Obj)
		..()
		if (ismob(Obj))
			var/mob/M = Obj
			if (src.warp_dir & NORTH || src.warp_dir & SOUTH)
				M.removeOverlayComposition(/datum/overlayComposition/shuttle_warp)
			else
				M.removeOverlayComposition(/datum/overlayComposition/shuttle_warp/ew)

/area/tutorial/basics/dock
	name = "Tutorial Shuttle Dock"
	icon_state = "shuttle_escape"

/area/shuttle/tutorial/transit
	name = "Tutorial Shuttle Transit"
	icon_state = "shuttle_escape"

/area/shuttle/tutorial/syndicates
	name = "Tutorial Shuttle Syndicates"
	icon_state = "shuttle_escape"

/area/shuttle/tutorial/syndicateship
	name = "Tutorial Shuttle Syndicate Ship"
	icon_state = "shuttle_escape"

/area/shuttle/tutorial/scrappile
	name = "Tutorial Scrap Pile For Scrap Like When The Ship Is Destroyed Done Lazily"
	icon_state = "shuttle_escape"

/// ID CARDS ///

/// PURPLE

/obj/item/card/id/constructed_id/tutorial
	name = "purple card"
	desc = "That was a lot of work for a simple—Hey, this is just a painted-on Dave & Busters power card!"
	icon = 'icons/misc/tutorial.dmi'
	icon_state = "id_tutorial"
	access = list(access_tutorialbasics)
	registered = null
	assignment = null
	title = null

/obj/item/tutorial/constructed_id/id_fragment/tutorial
	name = "purple card fragment"
	desc = "A torn section of what seems to be a purple identification card. Maybe there's more around?"
	icon = 'icons/misc/tutorial.dmi'
	icon_state = "tutorialfragment_1"
	target_assembly = /obj/item/assembly/constructed_id/id_partial/tutorial
	target_id = /obj/item/card/id/constructed_id/tutorial

/obj/item/assembly/constructed_id/id_partial/tutorial
	desc = "A somewhat put together purple ID card. Looks like you still have a little more to go."
	name = "partial purple card"
	icon = 'icons/misc/tutorial.dmi'
	icon_state = "tutorial_partial"
	nearly_completed_icon = "tutorial_partial2"
	target_fragment = /obj/item/tutorial/constructed_id/id_fragment/tutorial
	target_id = /obj/item/card/id/constructed_id/tutorial

/// RAINBOW

/obj/item/card/id/constructed_id/tutorial_end
	name = "rainbow card"
	desc = "A rough, uncomfortable, glittery mess and, frankly, a very sorry excuse for an ID card."
	icon = 'icons/misc/tutorial.dmi'
	icon_state = "id_tutorialwin"
	access = list(access_tutorialend)
	registered = null
	assignment = null
	title = null

/obj/item/tutorial/constructed_id/id_fragment/tutorial_end
	name = "rainbow card fragment"
	desc = "A torn section of what seems to be a rainbow identification card. Maybe there's more around?"
	icon = 'icons/misc/tutorial.dmi'
	icon_state = "winfragment_1"
	target_assembly = /obj/item/assembly/constructed_id/id_partial/tutorial_end
	target_id = /obj/item/card/id/constructed_id/tutorial_end

/obj/item/assembly/constructed_id/id_partial/tutorial_end
	desc = "A somewhat put together rainbow ID card. Looks like you still have a little more to go."
	name = "partial rainbow card"
	icon = 'icons/misc/tutorial.dmi'
	icon_state = "win_partial"
	nearly_completed_icon = "win_partial2"
	target_fragment = /obj/item/tutorial/constructed_id/id_fragment/tutorial_end
	target_id = /obj/item/card/id/constructed_id/tutorial_end

// BASE ID CARDS

/obj/item/tutorial/constructed_id/id_fragment
	name = "card fragment"
	desc = "A torn section of what seems to be an identification card. Maybe there's more around?"
	icon = 'icons/misc/tutorial.dmi'
	icon_state = null
	var/target_assembly = /obj/item/assembly/constructed_id/id_partial
	var/target_id = /obj/item/card/id

	attackby(item, mob/user)
		if(istype(item, src.type))
			if(item == src) return // Prevent combining the fragment with itself

			// Combine two fragments into a partial card
			var/obj/item/assembly/constructed_id/id_partial/partial_id = new target_assembly(get_turf(src)) // Spawn on the turf
			user.show_message(SPAN_NOTICE("You combine the two fragments into a partial card."), 1)
			playsound(get_turf(partial_id), 'sound/machines/click.ogg', 50, 1)
			qdel(src)
			qdel(item)
		else if(istype(item, target_assembly))
			var/obj/item/assembly/constructed_id/id_partial/partial_id = item
			partial_id.fragments_attached += 1
			user.show_message(SPAN_NOTICE("You attach the fragment to the partial card."), 1)
			playsound(get_turf(partial_id), 'sound/machines/click.ogg', 50, 1)
			qdel(src)

			// Update icon when 3 fragments are attached
			if(partial_id.fragments_attached == 3)
				partial_id.icon_state = "id_partial2"

			// Complete the card if enough fragments are attached
			if(partial_id.fragments_attached >= 4)
				var/obj/item/card/id/completed_card = new target_id(get_turf(partial_id))
				user.show_message(SPAN_NOTICE("The card is fully assembled!"), 1)
				playsound(get_turf(completed_card), 'sound/machines/click.ogg', 50, 1)
				particleMaster.SpawnSystem(new /datum/particleSystem/confetti(get_turf(completed_card)))
				playsound(get_turf(completed_card), 'sound/voice/yayyy.ogg', 50, 1)
				qdel(partial_id)
		else
			return ..()

/obj/item/assembly/constructed_id/id_partial
	desc = "A somewhat put together ID card. Looks like you still have a little more to go."
	name = "partial card"
	icon = 'icons/misc/tutorial.dmi'
	icon_state = null
	var/nearly_completed_icon = null
	var/target_fragment = /obj/item/tutorial/constructed_id/id_fragment
	var/target_id = /obj/item/card/id

	var/fragments_attached = 2

	// Complete the card if enough fragments are attached
	proc/complete_card(var/mob/user)
		var/obj/item/card/id/completed_card = new target_id(get_turf(src))
		user.show_message(SPAN_NOTICE("The card is fully assembled!"), 1)
		playsound(get_turf(completed_card), 'sound/machines/click.ogg', 50, 1)
		particleMaster.SpawnSystem(new /datum/particleSystem/confetti(get_turf(completed_card)))
		playsound(get_turf(completed_card), 'sound/voice/yayyy.ogg', 50, 1)
		qdel(src)

	attackby(item, mob/user)
		if(istype(item, target_fragment))
			fragments_attached += 1
			user.show_message(SPAN_NOTICE("You attach the fragment to the partial card."), 1)
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			qdel(item)

			// Update icon when 3 fragments are attached
			if(fragments_attached == 3)
				icon_state = nearly_completed_icon

			// Complete the card if enough fragments are attached
			if(fragments_attached >= 4)
				complete_card(user)

		else if(istype(item, src.type))
			var/obj/item/assembly/constructed_id/id_partial/other_assembly = item
			fragments_attached += other_assembly.fragments_attached
			user.show_message(SPAN_NOTICE("You combine the two partial cards."), 1)
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			qdel(other_assembly)

			// Update icon when 3 fragments are attached
			if(fragments_attached >= 3)
				icon_state = nearly_completed_icon

			// Complete the card if enough fragments are attached
			if(fragments_attached >= 4)
				complete_card(user)
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

/obj/fakeobject/beepsky
	name = "Officer Beepsky"
	desc = "It's Officer Beepsky! He's a loose cannon but he gets the job done. He's on break, though."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "secbot1"

	var/list/voice_lines = list('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg', 'sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/bcreep.ogg')

	New()
		..()
		var/static/image/bothat = image('icons/obj/bots/aibots.dmi', "hat-nt")
		UpdateOverlays(bothat, "secbot_hat")

	attack_hand(mob/user)
		beepsky_talk()

	proc/beepsky_talk()
		if (!ON_COOLDOWN(src, "beepsky_talk", 3 SECONDS))
			animate_bouncy(src)
			var/say_thing = pick(voice_lines)

			if(say_thing && prob(5))
				say_thing = 'sound/voice/binsultbeep.ogg'

			switch(say_thing)
				if('sound/voice/bcriminal.ogg')
					src.beepsky_whine("CRIMINAL DETECTED.")
				if('sound/voice/bjustice.ogg')
					src.beepsky_whine("PREPARE FOR JUSTICE.")
				if('sound/voice/bfreeze.ogg')
					src.beepsky_whine("FREEZE. SCUMBAG.")
				if('sound/voice/bgod.ogg')
					src.beepsky_whine("GOD MADE TOMORROW FOR THE CROOKS WE DON'T CATCH TO-DAY.")
				if('sound/voice/biamthelaw.ogg')
					src.beepsky_whine("I-AM-THE-LAW.")
				if('sound/voice/bsecureday.ogg')
					src.beepsky_whine("HAVE A SECURE DAY.")
				if('sound/voice/bradio.ogg')
					src.beepsky_whine("YOU CANT OUTRUN A RADIO.")
				if('sound/voice/bcreep.ogg')
					src.beepsky_whine("YOUR MOVE. CREEP.")
				if('sound/voice/binsultbeep.ogg')
					var/qbert = ""
					for(var/i in 1 to rand(5,20))
						qbert += "[pick("!", "@", "#", "$", "%", "&", "*", ">:(", 20;"SHUT YOUR ", 20;"ASS-ENDING ", 20;"FROM THE DEPTHS OF ")]"
						if(prob(10))
							qbert += " "
					for(var/j in 1 to rand(2,5))
						qbert += "[pick("!","?")]"
					src.beepsky_whine("[qbert]")
			playsound(src, say_thing, 50, FALSE)

	proc/beepsky_whine(message)
		playsound(src, 'sound/misc/talk/bottalk_1.ogg', 50, FALSE)
		var/image/chat_maptext/chat_text = make_chat_maptext(src, message, "color: '#A4BAE0';", alpha = 255)

		var/list/mob/targets = null
		var/mob/holder = src
		while(holder && !istype(holder))
			holder = holder.loc
		ENSURE_TYPE(holder)
		if(!holder)
			targets = hearers(src, null)
		else
			targets = list(holder)
			chat_text.plane = PLANE_HUD
			chat_text.layer = 999

		for(var/mob/O in targets)
			O.show_message(SPAN_SAY("[SPAN_NAME("[src.name]")] says, [SPAN_MESSAGE("\"[message]\"")]"), 2, assoc_maptext = chat_text)

	Crossed(atom/movable/AM)
		if(istype(AM, /obj/projectile))
			animate_stomp(src)
			beepsky_talk()
			src.visible_message(SPAN_ALERT("<b>[src]</b> jumps into the air and dodges with immense acrobatic ability!"))
		return ..()

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
	name = "artifact prison (tutorial)"
	associated_datum = /datum/artifact/prison/tutorial_artifact

/datum/artifact/prison/tutorial_artifact
	min_triggers = 1
	max_triggers = 1
	validtriggers = list(/datum/artifact_trigger/silicon_touch)
	living = TRUE

	New()
		..()
		imprison_time = 200

/obj/item/tutorial/wrestlingbell
	name = "Odd Bell"
	desc = "A weird looking bell. I wonder what this is for?"
	anchored = ANCHORED
	density = 1
	icon = 'icons/obj/wrestlingbell.dmi'
	icon_state = "wrestlingbell"
	var/last_ring = 0
	var/list/macho_arena_turfs // To track the ring turfs
	var/ring_radius = 3 // Variable to change the ring size
	var/objpath = /obj/item/chair/folded // Default item to spawn on sides
	var/distance_from_ring = 2 // Distance of bats from the ring
	var/list/spawned_items = list() // List to track spawned items
	var/player_count = 2 // Number of players fighting
	var/admin_only = 1

	attack_hand(mob/user)
		if(!isadmin(user) && admin_only == 1)
			user.visible_message(SPAN_ALERT("You seem to lack the physical dexterity to interact with this thing specifically... Huh."))
			return
		else
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

/obj/item/tutorial/shuttlecaller
	name = "Shuttle Caller"
	desc = "A device used to call the shuttle sequence for the tutorial."
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle-embed"
	var/activated = FALSE
	anchored = 1

	attack_hand(mob/user)
		if (isadmin(user) && activated == FALSE)
			activated = TRUE
			user.visible_message(SPAN_ALERT("You initiate the shuttle sequence..."))
			SPAWN(5 SECONDS)
				playsound_global(world, 'sound/effects/ship_engage.ogg', 75)
				SPAWN(4.5 SECONDS)
					// Play the boost sound after 10 seconds
					playsound_global(world, 'sound/machines/boost.ogg', 50)
					playsound_global(world, 'sound/effects/flameswoosh.ogg', 50)
					playsound_global(world, 'sound/effects/explosion_new2.ogg', 10)
					playsound_global(world, 'sound/misc/shuttle_enroute.ogg', 100)

					// Step 1: Teleport all moveables from /area/shuttle/tutorial/dock to /area/shuttle/tutorial/transit
					var/area/shuttle_dock = locate(/area/tutorial/basics/dock)
					var/area/shuttle_transit = locate(/area/shuttle/tutorial/transit)
					teleport_all_moveables(shuttle_dock, shuttle_transit)

					SPAWN(26 SECONDS)
						playsound_global(world, 'sound/machines/disaster_alert.ogg', 40)
						src.visible_message(SPAN_ALERT("<b>WARNING: INCOMING PROJECTILE. BRACE.</b>"))
						SPAWN(4 SECONDS)
							// Step 2: Teleport all moveables from /area/shuttle/tutorial/transit to /area/shuttle/tutorial/syndicates
							var/area/shuttle_syndicates = locate(/area/shuttle/tutorial/syndicates)
							var/area/shuttle_syndicateship = locate(/area/shuttle/tutorial/syndicateship)
							var/area/shuttle_scrappile = locate(/area/shuttle/tutorial/scrappile)
							teleport_all_moveables(shuttle_transit, shuttle_syndicates)
							playsound_global(world, 'sound/effects/Explosion1.ogg', 10)
							playsound_global(world, 'sound/effects/explosion_new3.ogg', 10)

							for (var/obj/stool/S in view(30))
								S.unbuckle()

							for (var/mob/living/M in view(30))
								shake_camera(M, 15, 48)
								M.emote("scream")
								M.apply_sonic_stun(20, 20, 20)
								M.changeStatus("knockdown", 40)
								M.changeStatus("stunned", 40)
								M.flash(30)

							SPAWN(37.5 SECONDS)
								playsound_global(world, 'sound/machines/pod_alarm.ogg', 20)
								src.visible_message(SPAN_ALERT("<b>WARNING: HULL INTEGRITY LOW.</b>"))
								SPAWN(2.5 SECONDS)
									// Step 3: Scatter moveables from /area/shuttle/tutorial/syndicates to Z-level 2, scattered within the target coordinates
									src.icon_state = null
									src.icon = null
									teleport_and_scatter_zlevel(shuttle_syndicates, 2, 215, 271, 226, 260)
									teleport_and_scatter_zlevel(shuttle_syndicateship, 2, 215, 271, 226, 260)
									teleport_and_scatter_zlevel(shuttle_scrappile, 2, 215, 271, 226, 260)

									for (var/obj/stool/S in view(30))
										S.unbuckle()

									for (var/mob/living/M in view(30))
										shake_camera(M, 15, 48)
										M.apply_sonic_stun(50, 50, 50)
										M.changeStatus("knockdown", 80)
										M.changeStatus("stunned", 80)
										M.flash(30)

									var/gib_count = 0 // Initialize a counter for the number of gibs
									for (var/mob/living/critter/human/syndicate/syndie in view(30))
										if (gib_count < 2)
											syndie.gib() // Gib the syndie
											gib_count++

										syndie.death() // Call .death() for every syndie


									playsound_global(world, 'sound/effects/Explosion2.ogg', 20)
									playsound_global(world, 'sound/effects/explosion_new4.ogg', 20)
									SPAWN(5 SECONDS)
										playsound_global(world, 'sound/effects/explosionfar.ogg', 20)
										SPAWN(20 SECONDS)
											playsound_global(world, 'sound/misc/shuttle_centcom.ogg', 100)
											emergency_shuttle.location = SHUTTLE_LOC_RETURNED
		else
			user.visible_message(SPAN_ALERT("You have no idea how to operate the shuttle controls! You might want to wait..."))

/proc/teleport_all_moveables(var/area/source_area, var/area/target_area)
	var/list/movable_atoms = list()

	// Collect all mobs and movable items in the source area
	for (var/atom/movable/A in source_area)
		if (A.anchored == 0 || istype(A, /obj/stool) || istype(A, /obj/item/tutorial/shuttlecaller) || istype(A, /mob/living))
			movable_atoms += A

	// Get the top-left corner of the source and target areas
	var/turf/source_top_left = get_top_left_corner(source_area)
	var/turf/target_top_left = get_top_left_corner(target_area)

	// Teleport each atom to the target area's relative position
	for (var/atom/movable/A in movable_atoms)
		var/turf/old_turf = get_turf(A)
		if (old_turf)
			var/relative_x = old_turf.x - source_top_left.x
			var/relative_y = old_turf.y - source_top_left.y

			// Calculate the new turf in the target area using the relative position
			var/turf/new_turf = locate(target_top_left.x + relative_x, target_top_left.y + relative_y, target_area.z)

			if (new_turf)
				A.set_loc(new_turf)

/proc/get_top_left_corner(var/area/target_area)
	// Loop through all turfs in the area and find the top-left corner
	var/turf/top_left = null
	for (var/turf/T in target_area)
		if (!top_left || (T.x <= top_left.x && T.y <= top_left.y))
			top_left = T
	return top_left

/proc/teleport_and_scatter_zlevel(var/area/source_area, var/z_level_target, var/start_x, var/start_y, var/end_x, var/end_y, var/actuallyeverything)
	var/list/movable_atoms = list()

	// Collect all mobs and movable items in the source area
	for (var/atom/movable/A in source_area)
		if (A.anchored == 0 || istype(A, /obj/stool) || istype(A, /mob/living) || istype(A, /obj/item/tutorial/shuttlecaller))
			movable_atoms += A

	// Randomly scatter each movable atom to a target Z-level within the specified coordinates
	for (var/atom/movable/A in movable_atoms)
		var/random_x = rand(start_x, end_x) // Random x coordinate within the given range
		var/random_y = rand(start_y, end_y) // Random y coordinate within the given range

		// Find the new location on the target Z-level
		var/turf/new_turf = locate(random_x, random_y, z_level_target)

		if (new_turf)
			A.set_loc(new_turf)
