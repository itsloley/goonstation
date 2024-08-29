/mob/living/critter/small_animal/mothplush
	name = "silly moth plush"
	desc = "This is a monster."
	icon = 'icons/misc/tutorial.dmi'
	icon_state = "mystery"
	icon_state_alive = "mystery"
	icon_state_dead = "mystery"
	blood_id = "hemolymph"
	speechverb_say = "bumbles"
	speechverb_exclaim = "buzzes"
	speechverb_ask = "bombles"
	can_bleed = FALSE
	is_npc = FALSE
	has_genes = FALSE
	hand_count = 2
	flags = TABLEPASS | DOORPASS
	fits_under_table = TRUE
	voice_type = "bloop"
	var/scream_sound = 'sound/items/rubberduck.ogg'
	var/scream_pitch = 3
	var/update_icon_state = TRUE

	New()
		. = ..()
		AddComponent(/datum/component/waddling)

		abilityHolder.addAbility(/datum/targetable/critter/moth_plushie/teleport)
		abilityHolder.addAbility(/datum/targetable/gimmick/reveal/mothplush)
		abilityHolder.addAbility(/datum/targetable/critter/moth_plushie/yippee)
		abilityHolder.updateButtons()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, scream_sound, 40, TRUE, 0.1, scream_pitch, channel=VOLUME_CHANNEL_EMOTE)
					animate_smush(src)
					return SPAN_EMOTE("<b>[src]</b> squeaks!")
			if ("dance")
				if (src.emote_check(voluntary, 50))
					animate_bouncy(src) // bouncy!
					return SPAN_EMOTE("<b>[src]</b> [pick("bounces","dances","boogies","frolics","prances","hops")] around with [pick("joy","fervor","excitement","vigor","happiness")]!")
		return ..()

	animate_lying(lying)
		animate_rest(src, !lying)

	Login()
		..()
		src.bioHolder.AddEffect("xray", power = 2, magical=1)
		update_moth_icon()

	proc/update_moth_icon()
		if (src.mind && update_icon_state)
			if (src.ckey == "lyy")
				src.icon_state = "lyplush"
				src.icon_state_alive = "lyplush"
				src.icon_state_dead = "lyplush"
				src.speechpopupstyle = "color: #5D99D2 !important; font-family: 'Inhuman BB'; font-size: 8px; -dm-text-outline: 1px black;"
			else if (src.ckey == "beshemoth" || src.ckey == "lythine")
				src.icon_state = "lilyplush"
				src.icon_state_alive = "lilyplush"
				src.icon_state_dead = "lilyplush"
				src.speechpopupstyle = "color: #948BFF !important; font-family: 'Inhuman BB'; font-size: 8px; -dm-text-outline: 1px black;"

/mob/living/critter/small_animal/mothplush/ly
	icon_state = "lyplush"
	icon_state_alive = "lyplush"
	icon_state_dead = "lyplush"
	speechpopupstyle = "color: #5D99D2 !important; font-family: 'Inhuman BB'; font-size: 8px; -dm-text-outline: 1px black;"
	update_moth_icon()
		return

/mob/living/critter/small_animal/mothplush/lily
	icon_state = "lilyplush"
	icon_state_alive = "lilyplush"
	icon_state_dead = "lilyplush"
	speechpopupstyle = "color: #948BFF !important; font-family: 'Inhuman BB'; font-size: 8px; -dm-text-outline: 1px black;"
	update_moth_icon()
		return

/datum/targetable/gimmick/reveal/mothplush
	cast(atom/T)
		..()
		usr.flags = DOORPASS | TABLEPASS

/datum/targetable/critter/moth_plushie/teleport
	name = "Teleport"
	desc = "Phase yourself to a nearby visible spot."
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "blink"
	cooldown = 0
	targeted = 1
	target_anything = 1
	var/animation_ripples = 4
	var/animation_waves = 3

	cast(atom/target)
		if (..())
			return 1
		if (!isturf(target))
			if(istype(target, /obj/storage))
				target = target
			else
				target = get_turf(target)
		if (target == get_turf(holder.owner))
			return 1

		if (target)
			SPAWN(0)
				playsound(holder.owner, 'sound/effects/ghostbreath.ogg', 75, 1)
				animate(holder.owner, alpha=0, time=1.5 SECONDS)
				animate_ripple(holder.owner, animation_ripples)
				animate_wave(holder.owner, animation_waves)

				SPAWN(1.5 SECONDS)
					holder.owner.set_loc(target)
					for(var/i=1, i<=animation_ripples, ++i)
						holder.owner.remove_filter("ripple-[i]")
					for(var/i=1, i<=animation_waves, ++i)
						holder.owner.remove_filter("wave-[i]")
					animate(holder.owner, alpha=0)
					animate(holder.owner, alpha=255, time=1.5 SECONDS)
		else
			return

/datum/targetable/critter/moth_plushie/yippee
	name = "Yippee!"
	desc = "Celebrate a selected object!"
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "pandemonium"
	cooldown = 0
	targeted = 1
	target_anything = 1

	cast(atom/target)
		..()
		var/tloc = target
		if (!isturf(target))
			tloc = target.loc
		particleMaster.SpawnSystem(new /datum/particleSystem/confetti(tloc))
		SPAWN(1 SECOND)
			playsound(tloc, 'sound/voice/yayyy.ogg', 50, 1)

/mob/living/critter/small_animal/mothplush/kity
	name = "kity"
	desc = "ohhhhhhhhhhhh noooooooooooooo"
	icon_state = "kity"
	icon_state_alive = "kity"
	icon_state_dead = "kity"
	update_icon_state = FALSE
	scream_sound = 'sound/misc/tutorial/guaw.ogg'
	scream_pitch = 1
	speechverb_say = "says"
	speechverb_exclaim = "screams"
	speechverb_ask = "whines"
