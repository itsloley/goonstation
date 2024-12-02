// if you are reading this, this is a bunch of in-jokes and misc goofy shit for ly and i to be silly with on a local server

/obj/item/instrument/bikehorn/hector
	name = "hector's bell"
	desc = "Ding ding ding!"
	icon = 'icons/obj/items/bell.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	icon_state = "bell"
	notes = list("c4")
	sounds_instrument = list('code/WorkInProgress/ly/sounds/hector-bell.ogg')
	randomized_pitch = 0
	desc_verb = list("dings")
	desc_sound = list("old man's")
	desc_music = list("bell")
	note_time = 0
	note_range = list("c2", "c7")

/obj/item/kity
	name = "kity"
	desc = "<img src='https://i.postimg.cc/0j72t8xq/kity.png'><br>"
	icon = 'code/WorkInProgress/ly/icons/32x32.dmi'
	icon_state = "kity"
	inhand_image_icon = 'code/WorkInProgress/ly/icons/32x32.dmi'
	w_class = W_CLASS_TINY
	hit_type = DAMAGE_CUT
	throwforce = INFINITY
	force = INFINITY
	stamina_damage = INFINITY
	stamina_cost = 0

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if(ismob(target))
			playsound(target.loc, 'code/WorkInProgress/ly/sounds/guaw.ogg', 50, 1)
			target.gib()
		..()

	attack_self(mob/user as mob)
		playsound(src.loc, 'code/WorkInProgress/ly/sounds/guaw.ogg', 50, 1)
		..()

	New()
		..()
		src.setItemSpecial(/datum/item_special/slam)

/obj/gibshark/kity
	name = "kity"
	desc = "It's so over"
	icon = 'code/WorkInProgress/ly/icons/64x64.dmi'
	icon_state = "kity"

	process()
		while (!disposed)
			if ((BOUNDS_DIST(src, src.sharktarget2) == 0))
				for(var/mob/O in AIviewers(src, null))
					O.show_message(SPAN_ALERT("<B>[src]</B> bites [sharktarget2]!"), 1)
				sharktarget2.changeStatus("weakened", 1 SECOND)
				sharktarget2.changeStatus("stunned", 10 SECONDS)
				playsound(src.loc, 'code/WorkInProgress/ly/sounds/guaw.ogg', 50, 1, -1)
				gibproc()
				return
			else
				walk_towards(src, src.sharktarget2, sharkspeed)
				sleep(1 SECOND)

/client/proc/kitygib(mob/kitytarget as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Kity Gib"
	set popup_menu = 0
	var/startx = 1
	var/starty = 1
	if(!isadmin(src))
		boutput(src, "Only administrators may use this command.")
		return

	var/speed = input(usr,"How fast is the kity? Lower is faster.","speed","5") as num
	if(!speed)
		return

	sleep(1 SECONDS)
	startx = kitytarget.x - rand(-11, 11)
	starty = kitytarget.y - rand(-11, 11)

	var/turf/pickedstart = locate(startx, starty, kitytarget.z)
	var/obj/gibshark/kity/Q = new /obj/gibshark/kity(pickedstart)
	Q.sharktarget2 = kitytarget
	Q.caller = usr
	Q.sharkspeed = speed

/obj/gibshark/irios
	name = "ULTRA IRIOS"
	desc = "IT'S ULTRA IRIOS"
	icon = 'code/WorkInProgress/ly/icons/64x64.dmi'
	icon_state = "IRIOS"

	process()
		while (!disposed)
			if ((BOUNDS_DIST(src, src.sharktarget2) == 0))
				for(var/mob/O in AIviewers(src, null))
					O.show_message(SPAN_ALERT("<B>[src]</B> OBLITERATES [sharktarget2]!"), 1)
				sharktarget2.changeStatus("weakened", 1 SECOND)
				sharktarget2.changeStatus("stunned", 10 SECONDS)
				sharktarget2.client.sound_playing[VOLUME_CHANNEL_ADMIN][1] = 0
				gibproc()
				return
			else
				walk_towards(src, src.sharktarget2, sharkspeed)
				sleep(1 SECOND)

/client/proc/iriosgib(mob/iriostarget as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Ultra Irios Gib"
	set popup_menu = 0
	var/startx = 1
	var/starty = 1
	if(!isadmin(src))
		boutput(src, "Only administrators may use this command.")
		return

	var/speed = input(usr,"How fast is the irio? Lower is faster.","speed","5") as num
	if(!speed)
		return

	iriostarget.playsound_local_not_inworld('code/WorkInProgress/ly/sounds/IRIOS_short.ogg', 100, 0, 1, 0, VOLUME_CHANNEL_ADMIN)
	sleep(1 SECONDS)
	startx = iriostarget.x - rand(-11, 11)
	starty = iriostarget.y - rand(-11, 11)

	var/turf/pickedstart = locate(startx, starty, iriostarget.z)
	var/obj/gibshark/irios/Q = new /obj/gibshark/irios(pickedstart)
	Q.sharktarget2 = iriostarget
	Q.caller = usr
	Q.sharkspeed = speed

/proc/robloxfilter(var/string)
	if(prob(3))
		var/nope
		for(var/i = 0, i < length(string), i++)
			nope += "#"
		return nope

	var/list/phrase = list(
		"fuck" = "####",
		"shit" = "####",
		"bitch" = "#####",
		"piss" = "####",
		"ass" = "###",
		"cock" = "####",
		"dick" = "####",
		"penis" = "#####",
		"pussy" = "#####",
		"jesus" = "#####",
		"christ" = "######",
		"damn" = "####",
		"bastard" = "#######",
		"hell" = "####"
	)

	var/substitute = null
	for(var/i=1,i <= length(phrase),i++)
		substitute = phrase[i]
		string = replacetext(string, substitute, phrase[substitute])

	var/final_string
	if(prob(25))
		var/list/tokens = splittext(string, regex("\\b", "i"))
		var/regex/word_check = regex("^\\w+$", "i")
		var/list/just_words = list()
		var/sentence_ended = TRUE
		for(var/token in tokens)
			if (length(token) > 2 && word_check.Find(token))
				if (sentence_ended)
					token = lowertext(token)
				just_words += token
				sentence_ended = FALSE
			else
				var/last_char = copytext(token, length(token), 0)
				if (last_char in list(".", "!", "?"))
					sentence_ended = TRUE
				else
					sentence_ended = FALSE
		for (var/c in just_words)
			if(prob(50))
				for(var/i = 0, i < length(c), i++)
					final_string += "#"
				final_string += " "
			else
				final_string += c + " "
	else
		final_string = string

	return final_string

/datum/bioEffect/speech/roblox
	name = "Frontal Gyrus Alteration Type-RBLX"
	desc = "Forces the language center of the subject's brain to be overseen by the subconscious, replacing (presumed) vulgarity."
	id = "accent_roblox"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "You feel like you'd be safe at work."
	msgLose = "You no longer feel censored."
	probability = 0
	occur_in_genepools = FALSE
	scanner_visibility = FALSE
	can_research = FALSE
	can_make_injector = FALSE
	can_copy = FALSE
	can_reclaim = FALSE
	can_scramble = FALSE
	curable_by_mutadone = FALSE

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = robloxfilter(message)
		return message
