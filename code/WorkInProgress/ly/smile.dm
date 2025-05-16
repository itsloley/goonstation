#define EVOLVE_COUNT 1
#define SPEAK_COOLDOWN 5 SECONDS
#define CONSUME_DURATION 1 SECONDS

/obj/item/ego_smile
	name = "Smile"
	desc = "It has the pale faces of nameless employees and a giant mouth on it. Upon striking with the weapon, the monstrous mouth opens wide to devour the target, its hunger insatiable."
	icon = 'code/WorkInProgress/ly/icons/smile.dmi'
	inhand_image_icon = 'code/WorkInProgress/ly/icons/smile_inhand.dmi'
	icon_state = "smile"
	item_state = "smile"
	c_flags = EQUIPPED_WHILE_HELD
	hit_type = DAMAGE_CUT
	tool_flags = TOOL_SAWING | TOOL_CHOPPING
	contraband = 8
	w_class = W_CLASS_BULKY
	force = 15
	throwforce = 10
	stamina_damage = 10
	stamina_cost = 30
	stamina_crit_chance = 5
	two_handed = 1
	hitsound = 'code/WorkInProgress/ly/sounds/smile_hit_flesh.ogg'

	var/corpses = 0
	var/evolution_state = 0

	New()
		..()
		processing_items.Add(src)

	setupProperties()
		..()
		setProperty("movespeed", 1)

	attack_self(var/mob/user)
		if (corpses != EVOLVE_COUNT)
			speak_horrors()
		else
			actions.start(new/datum/action/bar/icon/smileMerge(user, src), user)
		..()

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (ishuman(target) && !isnpc(target))
			if(isdead(target))
				actions.start(new/datum/action/bar/icon/smileConsume(user, target, src), user)
				return
		else
			if(isdead(target))
				speak_horrors(pick("Grrggh... Too we..ak... Need more...", "Smal…l scraps… No… grow…", "No... I want.. bod..ies…!"))
				return
		..()

	equipped(mob/user as mob)
		user.add_ability_holder(/datum/abilityHolder/smile)
		var/datum/abilityHolder/smile/ability_holder = user.get_ability_holder(/datum/abilityHolder/smile)
		ability_holder.stored_corpse_count = src.corpses
		ability_holder.updateText()
		..()

	unequipped(mob/user as mob)
		user.remove_ability_holder(/datum/abilityHolder/smile)
		..()

	proc/evolve(user)
		playsound(src.loc, 'code/WorkInProgress/ly/sounds/smile_merge.ogg', 50, 1)
		new /obj/effects/smile_merge(get_turf(user))
		for (var/mob/C in viewers(user))
			shake_camera(C, 5, 8)

	proc/consume_body(mob/user as mob, blood_color)
		var/datum/abilityHolder/smile/ability_holder = user.get_ability_holder(/datum/abilityHolder/smile)
		playsound(src.loc, 'code/WorkInProgress/ly/sounds/smile_absorb_corpse.ogg', 50, 1)
		src.corpses++

		var/image/blood_overlay
		blood_overlay = image('code/WorkInProgress/ly/icons/smile.dmi', "smile_overlay")
		blood_overlay.color = blood_color
		UpdateOverlays(blood_overlay, "blood_overlay")
		ability_holder.stored_corpse_count = src.corpses
		ability_holder.updateText()


	proc/speak_horrors(custom_message = null)
		var/list/messages
		var/message
		if(custom_message)
			message = custom_message
		else
			if(corpses >= EVOLVE_COUNT)
				messages = list(
					"Grr… Ghrrrgh… Consume… eat all…!",
					"Sweep them all… Get more bodies…!!!"
				)
			else if(corpses >= 1)
				messages = list(
					"Not… enough… More bodies… Grow bigger…",
					"Can… grow… larger… more… me…at…"
				)
			else
				messages = list(
					"Grgh… It… hurts… Krrgh…",
					"Ghhrg… H…elp… Help…",
					"Smell blood… Tasty scen…t…",
					"Meat… wanna e…at…",
					"Need… bo…dies… So I can… gr…ow…",
					"Krrrrh… Tasty… meat… before m…e…"
				)
			message = pick(messages)

		var/image/chat_maptext/chat_text = make_chat_maptext(src, "<span style='color: white; text-shadow: 0 0 3px black; -dm-text-outline: 2px black;'>[message]</span>", alpha = 180)

		if(ON_COOLDOWN(src, "smile_speak", SPEAK_COOLDOWN))
			return

		src.visible_message(SPAN_ALERT("<b>[src] [pick("moans", "snarls", "growls", "croaks")], \"[message]\"</b>"))

		if(chat_text)
			chat_text.pixel_x += 16
			chat_text.pixel_y += 8
			for(var/mob/O in all_hearers(7, src))
				chat_text.show_to(O.client)
				oscillate_colors(chat_text, list("#ffffff", "#a68787"))
				playsound(src.loc, 'code/WorkInProgress/ly/sounds/smile_whisper.ogg', 50, 1)

/datum/action/bar/icon/smileConsume
	duration = CONSUME_DURATION
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'code/WorkInProgress/ly/icons/32x32.dmi'
	icon_state = "smile_eat"
	bar_icon_state = "bar-vampire"
	border_icon_state = "border"
	color_active = "#9f0f0f"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/mob/living/target
	var/mob/living/user
	var/obj/item/ego_smile/smile
	var/next_sound_time = 0 // Time when the next sound should play
	var/last_complete = 0

	New(User, Target, Smile)
		user = User
		target = Target
		smile = Smile
		owner = user
		..()

	onStart()
		..()
		if (!owner || !ismob(owner) || !target || !isdead(target) || BOUNDS_DIST(owner, target) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return

		owner.visible_message(SPAN_ALERT("<b>[smile] begins devouring [target]!</b>"))
		playsound(owner, 'code/WorkInProgress/ly/sounds/smile_eat1.ogg', 50, TRUE)

		// Initialize the next sound time
		next_sound_time = world.time + 1 SECONDS

	onUpdate()
		..()
		if (!owner || !ismob(owner) || !target || !isdead(target) || BOUNDS_DIST(owner, target) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return

		// More reliable time check using world.time
		if (world.time >= next_sound_time)
			playsound(owner, pick('code/WorkInProgress/ly/sounds/smile_eat2.ogg',
								'code/WorkInProgress/ly/sounds/smile_eat3.ogg',
								'code/WorkInProgress/ly/sounds/smile_eat4.ogg'), 50, TRUE)
			next_sound_time = world.time + 1.5 SECONDS

		var/complete = clamp(time_spent() / duration, 0, 1)
		last_complete = complete

	onEnd()
		..()
		if (owner && target && isdead(target) && BOUNDS_DIST(owner, target) == 0)
			owner.visible_message(SPAN_ALERT("<b>[smile] finishes devouring [target]!</b>"))
			smile.consume_body(user, target.blood_color)
			gibs(target.loc, blood_DNA=target.bioHolder.Uid, blood_type=target.bioHolder.bloodType, headbits=FALSE, source=target)
			qdel(target)


/datum/action/bar/icon/smileMerge
	duration = CONSUME_DURATION
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'code/WorkInProgress/ly/icons/32x32.dmi'
	icon_state = "smile_merge"
	bar_icon_state = "bar-vampire"
	border_icon_state = "border"
	color_active = "#9f0f0f"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/mob/living/user
	var/obj/item/ego_smile/smile
	var/next_sound_time = 0 // Time when the next sound should play
	var/last_complete = 0

	New(User, Smile)
		user = User
		smile = Smile
		owner = user
		..()

	onStart()
		..()
		if (!owner || !ismob(owner))
			interrupt(INTERRUPT_ALWAYS)
			return

		owner.visible_message(SPAN_ALERT("<b>[smile] begins rapidly contorting..!</b>"))
		playsound(owner, 'code/WorkInProgress/ly/sounds/smile_eat1.ogg', 50, TRUE)

		// Initialize the next sound time
		next_sound_time = world.time + 1 SECONDS

	onUpdate()
		..()
		if (!owner || !ismob(owner))
			interrupt(INTERRUPT_ALWAYS)
			return

		// More reliable time check using world.time
		if (world.time >= next_sound_time)
			playsound(owner, pick('code/WorkInProgress/ly/sounds/smile_eat2.ogg',
								'code/WorkInProgress/ly/sounds/smile_eat3.ogg',
								'code/WorkInProgress/ly/sounds/smile_eat4.ogg'), 50, TRUE)
			next_sound_time = world.time + 1.5 SECONDS

		var/complete = clamp(time_spent() / duration, 0, 1)
		last_complete = complete

	onEnd()
		..()
		if (owner)
			owner.visible_message(SPAN_ALERT("<b>[smile] merges with the corpses and becomes stronger!</b>"))
			smile.evolve(owner)

/datum/abilityHolder/smile
	usesPoints = FALSE
	regenRate = FALSE

	var/stored_corpse_count = 0

	onAbilityStat()
		. = ..()
		. = list()
		.["Corpses:"] = src.stored_corpse_count

/// EFFECTS

/obj/effects/smile_merge
	name = "shockwave"
	desc = ""
	density = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "shockwave"
	mouse_opacity = 0

	New(var/x_val, var/y_val)
		..()
		pixel_x = x_val
		pixel_y = y_val
		src.Scale(0.4, 0.4)
		src.color = "#0a0a0a"

		var/matrix/end_mat = matrix()
		end_mat.Scale(8, 8)

		// Animation: fast out, slow down, fade out
		animate(
			src,
			transform = end_mat,
			alpha = 0,
			time = 5,
			easing = SINE_EASING
		)

		// Delete after animation finishes
		SPAWN(0.5 SECONDS) qdel(src)
