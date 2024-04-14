// Mannequin for Displaying Clothes and Customizing Wigs
/obj/mannequin
	name = "mannequin"
	desc = "A sturdy mannequin for showcasing most of the stylish clothing you could ever think of. It won't judge what you consider to be fashion! ...Probably."
	icon = 'icons/obj/mannequin.dmi'
	icon_state = "mannequin"
	density = 1
	flags = FPRINT
	object_flags = NO_GHOSTCRITTER
	appearance_flags = KEEP_TOGETHER | PIXEL_SCALE | LONG_GLIDE
	var/list/scoot_sounds = list('sound/misc/chair/office/scoot1.ogg', 'sound/misc/chair/office/scoot2.ogg', 'sound/misc/chair/office/scoot3.ogg', 'sound/misc/chair/office/scoot4.ogg', 'sound/misc/chair/office/scoot5.ogg')
	var/fallen = FALSE
	var/obj/item/clothing/head/head = null
	var/obj/item/clothing/glasses/glasses = null
	var/obj/item/clothing/under/under = null
	var/obj/item/clothing/suit/suit = null
	var/obj/item/clothing/mask/mask = null
	HELP_MESSAGE_OVERRIDE("You can dress the <b>mannequin</b> by clicking on it with <b>clothes</b> in hand.")

	disposing()
		for(var/obj/item/I as anything in src.contents)
			I.loc = loc
		..()

	Move(atom/target)
		. = ..()
		if (. && islist(scoot_sounds) && scoot_sounds.len && prob(75))
			playsound( get_turf(src), pick( scoot_sounds ), 50, 1, -5 )

/obj/mannequin/attackby(obj/item/W, mob/user)

	/* ---------- Start Dressing ---------- */

	if (istype(W, /obj/item/clothing))
		if (istype(W, /obj/item/clothing/gloves) || istype(W, /obj/item/clothing/ears) || istype(W, /obj/item/clothing/shoes))
			user.visible_message(SPAN_ALERT("\The [src] isn't built for those kinds of clothing!"))
		else
			if (istype(W, /obj/item/clothing/head) && !isnull(src.head))
				user.visible_message(SPAN_ALERT("There's already something there!"))
			else if (istype(W, /obj/item/clothing/glasses) && !isnull(src.glasses))
				user.visible_message(SPAN_ALERT("There's already something there!"))
			else if (istype(W, /obj/item/clothing/under) && !isnull(src.under))
				user.visible_message(SPAN_ALERT("There's already something there!"))
			else if (istype(W, /obj/item/clothing/suit) && !isnull(src.suit))
				user.visible_message(SPAN_ALERT("There's already something there!"))
			else if (istype(W, /obj/item/clothing/mask) && !isnull(src.mask))
				user.visible_message(SPAN_ALERT("There's already something there!"))
			else
				user.visible_message("[user] starts to dress \the [src] with \the [W].", "You start to dress \the [src] with \the [W].")
				SETUP_GENERIC_ACTIONBAR(user, src, 1.5 SECONDS, /obj/mannequin/proc/dress, list(W, user), W.icon, W.icon_state, \
				"[user] puts \the [W] on \the [src].", \
				INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)

	/* ---------- Punch Mannequin ---------- */

	else if(user.a_intent == INTENT_HARM && fallen == FALSE)
		user.visible_message(SPAN_ALERT("You lean back and hit \the [src] with \the [W] as hard as you can!"))
		step_away(src, user, 15)
		src.fall()

	else
		user.visible_message(SPAN_ALERT("\The [W] doesn't belong there!"))

/obj/mannequin/attack_hand(mob/user)

	/* ---------- Punch Mannequin ---------- */

	if (user.a_intent == INTENT_HARM && fallen == FALSE)
		user.visible_message(SPAN_ALERT("You lean back and punch \the [src] as hard as you can! <b>FUCK!</b> That hurt!"))
		user.TakeDamage(user.hand == LEFT_HAND ? "l_arm": "r_arm", 3, 0, 0, DAMAGE_BLUNT) // ow
		step_away(src, user, 15)
		src.fall()
	else

		/* ---------- Fix Mannequin ---------- */

		if (fallen)
			user.visible_message("[user] starts to prop \the [src] back up.", "You start to prop \the [src] back up.")
			SETUP_GENERIC_ACTIONBAR(user, src, 1.5 SECONDS, /obj/mannequin/proc/raise, list(), src.icon, src.icon_state, \
			"[user] props the mannequin back up.", \
			INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)
		else

			/* ---------- Start Removing Clothes ---------- */

			var/list/clothingList = list(src.head, src.glasses, src.under, src.suit, src.mask)
			var/obj/item/clothing/selectedClothing = tgui_input_list(user, "What to remove?", "What to remove?", clothingList)
			if(!isnull(selectedClothing) && BOUNDS_DIST(user, src) == 0)
				SETUP_GENERIC_ACTIONBAR(user, src, 1.5 SECONDS, /obj/mannequin/proc/removeClothing, list(selectedClothing, user), selectedClothing.icon, selectedClothing.icon_state, \
				"[user] removes \the [selectedClothing] from \the [src].", \
				INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)

/* ---------- Inspect Clothing ---------- */

/obj/mannequin/get_desc()
	if (src.head)
		. += "<br><span class='[src.head.blood_DNA ? "alert" : "notice"]'>\The [src] is wearing [bicon(src.head)] \an [src.head.name].</span>"
	if (src.glasses)
		. += "<br><span class='[src.glasses.blood_DNA ? "alert" : "notice"]'>\The [src] is wearing [bicon(src.glasses)] \an [src.glasses.name].</span>"
	if (src.under)
		. += "<br><span class='[src.under.blood_DNA ? "alert" : "notice"]'>\The [src] is wearing [bicon(src.under)] \an [src.under.name].</span>"
	if (src.suit)
		. += "<br><span class='[src.suit.blood_DNA ? "alert" : "notice"]'>\The [src] is wearing [bicon(src.suit)] \an [src.suit.name].</span>"
	if (src.mask)
		. += "<br><span class='[src.mask.blood_DNA ? "alert" : "notice"]'>\The [src] is wearing [bicon(src.mask)] \an [src.mask.name].</span>"

/* ---------- Wear Clothing ---------- */

/obj/mannequin/proc/dress(obj/item/clothing/W as obj, mob/user as mob)
	var/image/clothingImage = null
	var/clothingType = ""

	// determine clothing type, also make absolutely sure the slots are still null or it will be disasterous
	if (istype(W, /obj/item/clothing/head))
		if (isnull(src.head))
			clothingType = "head"
			src.head = W
		else
			return
	else if (istype(W, /obj/item/clothing/glasses))
		if (isnull(src.glasses))
			clothingType = "glasses"
			src.glasses = W
		else
			return
	else if (istype(W, /obj/item/clothing/under))
		if (isnull(src.under))
			clothingType = "under"
			src.under = W
		else
			return
	else if (istype(W, /obj/item/clothing/suit))
		if (isnull(src.suit))
			clothingType = "suit"
			src.suit = W
		else
			return
	else if (istype(W, /obj/item/clothing/mask))
		if (isnull(src.mask))
			clothingType = "mask"
			src.mask = W
		else
			return

	user.drop_item(W)
	W.set_loc(src)

	// create wear image
	clothingImage = image(icon = W.wear_image, icon_state = W.icon_state, layer = W.wear_layer)
	clothingImage.alpha = W.alpha
	clothingImage.color = W.color
	clothingImage.filters = W.filters
	clothingImage.overlays = W.overlays

	// add clothing overlay
	UpdateOverlays(clothingImage, clothingType)

/* ---------- Remove Clothing ---------- */

/obj/mannequin/proc/removeClothing(selectedClothing as obj, mob/user as mob)
	var/clothingType = ""

	// determine clothing type, also make absolutely sure the slots are not null or it will be disasterous
	if (istype(selectedClothing, /obj/item/clothing/head))
		if (!isnull(src.head))
			clothingType = "head"
			src.head = null
		else
			return
	else if (istype(selectedClothing, /obj/item/clothing/glasses))
		if (!isnull(src.glasses))
			clothingType = "glasses"
			src.glasses = null
		else
			return
	else if (istype(selectedClothing, /obj/item/clothing/under))
		if (!isnull(src.under))
			clothingType = "under"
			src.under = null
		else
			return
	else if (istype(selectedClothing, /obj/item/clothing/suit))
		if (!isnull(src.suit))
			clothingType = "suit"
			src.suit = null
		else
			return
	else if (istype(selectedClothing, /obj/item/clothing/mask))
		if (!isnull(src.mask))
			clothingType = "mask"
			src.mask = null
		else
			return

	// remove clothing overlay
	UpdateOverlays(null, clothingType)
	user.put_in_hand_or_eject(selectedClothing)

/* ---------- Mannequin Falling ---------- */

/obj/mannequin/bullet_act(var/obj/projectile/P)
	if(!fallen)
		step_away(src, P, 15)
		src.fall()

/obj/mannequin/proc/fall()
	if(!fallen)
		fallen = TRUE
		density = 0
		playsound(src.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', 50, 1)
		animate_rest(src, !src.fallen)
		src.visible_message("<b>[SPAN_ALERT("\The [src] gets knocked over!")]</b>")

/obj/mannequin/proc/raise()
	if(fallen)
		fallen = FALSE
		density = 1
		playsound(src.loc, pick(sounds_rustle), 50, 1)
		animate_rest(src, !src.fallen)

/obj/item/mannequin_head
	name = "mannequin head"
	desc = "A small, smooth and featureless head designed for displaying hats and customizing wigs."
	icon = 'icons/obj/mannequin.dmi'
	icon_state = "mannequin_head"
	flags = FPRINT
	object_flags = NO_GHOSTCRITTER
	appearance_flags = KEEP_TOGETHER | PIXEL_SCALE | LONG_GLIDE
	var/head = null
	var/glasses = null
	var/mask = null
	HELP_MESSAGE_OVERRIDE("You can dress the <b>mannequin head</b> by clicking on it with <b>hats, masks, glasses,</b> or a <b>wig</b> in hand.<br>If you have <b>scissors</b> or a <b>dye bottle</b>, you can customize a <b>wig</b> on the mannequin by using them while the <b>wig</b> is on it.")

	disposing()
		for(var/obj/item/I as anything in src.contents)
			I.loc = loc
		..()

/obj/item/mannequin_head/mouse_drop(mob/user as mob)
	if (user == usr && !user.restrained() && !user.stat && (user.contents.Find(src) || in_interact_range(src, user)))
		if (!user.put_in_hand(src))
			return ..()

/obj/item/mannequin_head/attackby(obj/item/W, mob/user)

	/* ---------- Start Dressing ---------- */

	if (istype(W, /obj/item/clothing))
		if (istype(W, /obj/item/clothing/gloves) || istype(W, /obj/item/clothing/ears) || istype(W, /obj/item/clothing/shoes) || istype(W, /obj/item/clothing/under) || istype(W, /obj/item/clothing/suit))
			user.visible_message(SPAN_ALERT("\The [src] isn't built for those kinds of clothing!"))
		else
			if (istype(W, /obj/item/clothing/head) && !isnull(src.head))
				user.visible_message(SPAN_ALERT("There's already something there!"))
			else if (istype(W, /obj/item/clothing/glasses) && !isnull(src.glasses))
				user.visible_message(SPAN_ALERT("There's already something there!"))
			else if (istype(W, /obj/item/clothing/mask) && !isnull(src.mask))
				user.visible_message(SPAN_ALERT("There's already something there!"))
			else
				user.visible_message("[user] starts to dress \the [src] with \the [W].", "You start to dress \the [src] with \the [W].")
				SETUP_GENERIC_ACTIONBAR(user, src, 1.5 SECONDS, /obj/item/mannequin_head/proc/dress, list(W, user), W.icon, W.icon_state, \
				"[user] puts \the [W] on \the [src].", \
				INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)

	/* ---------- Wear Clothing ---------- */

/obj/item/mannequin_head/attack_hand(mob/user)

	/* ---------- Start Removing Clothes ---------- */
	var/list/clothingList = list(src.head, src.glasses, src.mask)
	var/obj/item/clothing/selectedClothing = tgui_input_list(user, "What to remove?", "What to remove?", clothingList)

	if(!isnull(selectedClothing) && BOUNDS_DIST(user, src) == 0)
		SETUP_GENERIC_ACTIONBAR(user, src, 1.5 SECONDS, /obj/item/mannequin_head/proc/removeClothing, list(selectedClothing, user), selectedClothing.icon, selectedClothing.icon_state, \
		"[user] removes \the [selectedClothing] from \the [src].", \
		INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)

/obj/item/mannequin_head/proc/dress(obj/item/clothing/W as obj, mob/user as mob)
	var/image/clothingImage = null
	var/clothingType = ""

	// determine clothing type, also make absolutely sure the slots are still null or it will be disasterous
	if (istype(W, /obj/item/clothing/head))
		if (isnull(src.head))
			clothingType = "head"
			src.head = W
		else
			return
	else if (istype(W, /obj/item/clothing/glasses))
		if (isnull(src.glasses))
			clothingType = "glasses"
			src.glasses = W
		else
			return
	else if (istype(W, /obj/item/clothing/mask))
		if (isnull(src.mask))
			clothingType = "mask"
			src.mask = W
		else
			return

	user.drop_item(W)
	W.set_loc(src)

	// create wear image
	clothingImage = image(icon = W.wear_image, icon_state = W.icon_state, layer = W.wear_layer)
	clothingImage.alpha = W.alpha
	clothingImage.color = W.color
	clothingImage.filters = W.filters
	clothingImage.overlays = W.overlays
	clothingImage.pixel_y = -6

	// add clothing overlay
	UpdateOverlays(clothingImage, clothingType)

/* ---------- Remove Clothing ---------- */

/obj/item/mannequin_head/proc/removeClothing(selectedClothing as obj, mob/user as mob)
	var/clothingType = ""

	// determine clothing type, also make absolutely sure the slots are not null or it will be disasterous
	if (istype(selectedClothing, /obj/item/clothing/head))
		if (!isnull(src.head))
			clothingType = "head"
			src.head = null
		else
			return
	else if (istype(selectedClothing, /obj/item/clothing/glasses))
		if (!isnull(src.glasses))
			clothingType = "glasses"
			src.glasses = null
		else
			return
	else if (istype(selectedClothing, /obj/item/clothing/mask))
		if (!isnull(src.mask))
			clothingType = "mask"
			src.mask = null
		else
			return

	// remove clothing overlay
	UpdateOverlays(null, clothingType)
	user.put_in_hand_or_eject(selectedClothing)

// Custom type for spawning pre-set mannequins for mappers
/* Example:
 * head_contents = /obj/item/clothing/head/foo
 * glasses_contents = /obj/item/clothing/glasses/foo
 * under_contents = /obj/item/clothing/under/foo
 * suit_contents = /obj/item/clothing/suit/foo
 * mask_contents = /obj/item/clothing/mask/foo
 */
/obj/mannequin/spawnable
	var/head_contents = null
	var/glasses_contents = null
	var/under_contents = null
	var/suit_contents = null
	var/mask_contents = null

	New()
		..()

		// add the new items to contents if they are not null
		if (!isnull(src.head_contents))
			src.head = new src.head_contents
			src.contents += src.head
		if (!isnull(src.glasses_contents))
			src.glasses = new src.glasses_contents
			src.contents += src.glasses
		if (!isnull(src.under_contents))
			src.under = new src.under_contents
			src.contents += src.under
		if (!isnull(src.suit_contents))
			src.suit = new src.suit_contents
			src.contents += src.suit
		if (!isnull(src.mask_contents))
			src.mask = new src.mask_contents
			src.contents += src.mask

		var/list/clothingTypes = list("head", "glasses", "under", "suit", "mask")
		var/list/clothingObjects = list(src.head, src.glasses, src.under, src.suit, src.mask)

		// check every clothing slot
		for(var/i in 1 to length(clothingTypes))
			var/clothingType = clothingTypes[i]
			if (isnull(clothingObjects[i]))
				continue
			else
				clothingType = clothingTypes[i]
				var/obj/item/clothing/clothingObject = clothingObjects[i]
				var/image/clothingImage = image(
					icon = clothingObject.wear_image,
					icon_state = clothingObject.icon_state,
					layer = clothingObject.wear_layer
				)
				clothingImage.alpha = clothingObject.alpha
				clothingImage.color = clothingObject.color
				clothingImage.filters = clothingObject.filters
				clothingImage.overlays = clothingObject.overlays

				UpdateOverlays(clothingImage, clothingType)

/obj/item/mannequin_head/spawnable
	var/head_contents = null
	var/glasses_contents = null
	var/mask_contents = null

	New()
		..()

		// add the new items to contents if they are not null
		if (!isnull(src.head_contents))
			src.head = new src.head_contents
			src.contents += src.head
		if (!isnull(src.glasses_contents))
			src.glasses = new src.glasses_contents
			src.contents += src.glasses
		if (!isnull(src.mask_contents))
			src.mask = new src.mask_contents
			src.contents += src.mask

		var/list/clothingTypes = list("head", "glasses", "mask")
		var/list/clothingObjects = list(src.head, src.glasses, src.mask)

		// check every clothing slot
		for(var/i in 1 to length(clothingTypes))
			var/clothingType = clothingTypes[i]
			if (isnull(clothingObjects[i]))
				continue
			else
				clothingType = clothingTypes[i]
				var/obj/item/clothing/clothingObject = clothingObjects[i]
				var/image/clothingImage = image(
					icon = clothingObject.wear_image,
					icon_state = clothingObject.icon_state,
					layer = clothingObject.wear_layer
				)
				clothingImage.alpha = clothingObject.alpha
				clothingImage.color = clothingObject.color
				clothingImage.filters = clothingObject.filters
				clothingImage.overlays = clothingObject.overlays
				clothingImage.pixel_y = -6

				UpdateOverlays(clothingImage, clothingType)

// for the mannequin randroom
/obj/mannequin/creepy
	name = "creepy mannequin"
	desc = "A lifelike mannequin used for showcasing clothing. It's damp, rotten, and it's covered in cobwebs. What the hell is this thing?"
	icon_state = "creepy"
	var/scary = TRUE

	New()
		spawn(0)
			src.move_randomly()
		src.scary = TRUE // become scary after the first proc call so it doesn't get stuck
		..()

	disposing()
		scary = FALSE
		if(locate(/obj/machinery/crusher) in get_turf(src)) // funny
			playsound(src.loc, 'sound/voice/screams/male_scream.ogg', 50, 1)
			gibs(src.loc)
		..()

/obj/mannequin/creepy/proc/move_randomly()
	while(scary)
		if(!is_being_watched() && !fallen)
			step(src, pick(NORTH, SOUTH, EAST, WEST))
		else if (!is_being_watched() && fallen)
			src.raise()
		else
			if(prob(40))
				for (var/mob/O in viewers(src, null))
					O.show_message(SPAN_EMOTE("\The <B>[src]</B> " + pick("shakes", "rattles", "creaks", "twitches", "wriggles") + "."))
				var/old_x = src.pixel_x // twitch anim
				var/old_y = src.pixel_y
				src.pixel_x += rand(-2,2)
				src.pixel_y += rand(-1,1)
				sleep(0.2 SECONDS)
				src.pixel_x = old_x
				src.pixel_y = old_y
		sleep(rand(5 SECONDS, 20 SECONDS))

/obj/mannequin/creepy/proc/is_being_watched()
	for(var/mob/M in viewers("21x15", src)) // default values would make it still move on-screen
		if(M.client && isalive(M) && !isintangible(M))
			return TRUE
	return FALSE
