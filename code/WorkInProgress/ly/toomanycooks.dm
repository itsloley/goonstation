/datum/ailment/disease/intronitis
	name = "Intronitis"
	scantype = "Medical Emergency"
	max_stages = 1
	spread = "Airborne"
	cure_flags = CURE_INCURABLE
	affected_species = list("Human","Monkey")
	var/css = "color: #E6D140 !important; font-family: \"Georgia, serif\"; font-size: 7px; text-shadow: 1px 1px #000, 1px 1px .1px #000;"

	setup_strain()
		var/datum/ailment_data/disease/strain = ..()
		strain.virulence = src.virulence
		strain.develop_resist = src.develop_resist
		return strain

/datum/ailment/disease/intronitis/on_infection(var/mob/living/affected_mob,var/datum/ailment_data/disease/D)
	var/obj/maptext_junk/indicator = new(src)
	indicator.alpha = 0
	indicator.maptext_x = -113
	indicator.maptext_y = 4
	indicator.maptext_width = 256
	indicator.maptext_height = 64
	var/splitName = splittext(uppertext(affected_mob.name), " ")
	var/processedName = ""
	for (var/S in splitName)
		processedName += "<span style='font-size: 9px;'>" + copytext(S, 1, 2) + "</span>" + copytext(S, 2) + " "
	indicator.maptext = "<span class='c vb ps2p' style='[css]'><i>[processedName]</i></span>"
	D.strain_data[affected_mob] = indicator
	affected_mob.vis_contents += D.strain_data[affected_mob]
	animate(indicator, alpha = 255, time = 10)
	..()
	return

/datum/ailment/disease/intronitis/on_remove(var/mob/living/affected_mob,var/datum/ailment_data/disease/D)
	// for some fucking reason curing this disease means curing the ENTIRE STRAIN ACROSS EVERY PERSON and i can't figure out how to fix it so
	// if you cure this manually, expect it to disappear off of some random other guys halfway across the station too atm
	for (var/mob/living/M in D.strain_data)
		M.vis_contents -= D.strain_data[M]
	..()
	return

/datum/ailment/disease/intronitis/stage_act(var/mob/living/carbon/human/H, var/datum/ailment/D, mult)
	if (prob(1))
		H.emote("smile")

var/global/too_many_cooks_mode = FALSE

/client/proc/too_many_cooks()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Toggle Too Many Cooks"
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(holder && src.holder.level >= LEVEL_ADMIN)
		if(!too_many_cooks_mode)
			switch(alert("Really infect everyone with Intronitis?", "Bad Idea??","Yes","No"))
				if("Yes")
					too_many_cooks_mode = TRUE
					vox_play("toomanycooks")
					for_by_tcl(H, /mob/living/carbon/human)
						H?.contract_disease(/datum/ailment/disease/intronitis, null, null, 1)
					logTheThing(LOG_ADMIN, src, "has enabled Too Many Cooks mode.")
					logTheThing(LOG_DIARY, src, "has enabled Too Many Cooks mode.", "admin")
					message_admins("[key_name(src)] has enabled Too Many Cooks mode!")
				if("No")
					return
		else
			too_many_cooks_mode = FALSE
			for_by_tcl(H, /mob/living/carbon/human)
				H?.cure_disease_by_path(/datum/ailment/disease/intronitis, null, null, 1)
			logTheThing(LOG_ADMIN, src, "has disabled Too Many Cooks mode.")
			logTheThing(LOG_DIARY, src, "has disabled Too Many Cooks mode.", "admin")
			message_admins("[key_name(src)] has disabled Too Many Cooks mode.")
			return
	else
		boutput(src, "You must be at least an Administrator to use this command.")
