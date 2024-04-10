// mannequin for displaying clothes and customizing wigs
/obj/mannequin
	name = "mannequin"
	desc = "A sturdy mannequin for customizing wigs or showcasing stylish clothing."
	icon = 'icons/obj/mannequin.dmi'
	icon_state = "mannequin"
	density = 1
	flags = FPRINT | USEDELAY
	var/list/scoot_sounds = list('sound/misc/chair/office/scoot1.ogg', 'sound/misc/chair/office/scoot2.ogg', 'sound/misc/chair/office/scoot3.ogg', 'sound/misc/chair/office/scoot4.ogg', 'sound/misc/chair/office/scoot5.ogg')
	var/fallen = FALSE
	var/obj/item/clothing/head/head = null
	var/obj/item/clothing/glasses/glasses = null
	var/obj/item/clothing/under/under = null
	var/obj/item/clothing/suit/suit = null
	var/obj/item/clothing/mask/mask = null
	HELP_MESSAGE_OVERRIDE("You can dress the mannequin by clicking on it with <b>clothes</b> in hand.<br>If you have <b>scissors</b> or a <b>dye bottle</b>, you can customize a <b>wig</b> on the mannequin by using them while the <b>wig</b> is on it.")

	Move(atom/target)
		. = ..()
		if (. && islist(scoot_sounds) && scoot_sounds.len && prob(75))
			playsound( get_turf(src), pick( scoot_sounds ), 50, 1 )

/obj/mannequin/attack_hand(mob/user)
	if (user.a_intent == INTENT_HARM && fallen == FALSE)
		user.visible_message(SPAN_ALERT("You lean back and punch \the [src] as hard as you can! <b>FUCK!</b> That hurt!"))
		user.TakeDamage(user.hand == LEFT_HAND ? "l_arm": "r_arm", 3, 0, 0, DAMAGE_BLUNT) // ow
		step_away(src, user, 15)
		src.fall()
	else
		if (fallen)
			user.visible_message("[user] starts to prop \the [src] back up.", "You start to prop \the [src] back up.")
			SETUP_GENERIC_ACTIONBAR(user, src, 1.5 SECONDS, /obj/mannequin/proc/raise, list(), src.icon, src.icon_state,\
			"[user] props the mannequin back up.", null)
		else
			var/list/clothingList = list(src.head, src.glasses, src.under, src.suit, src.mask)
			var/selectedClothing = tgui_input_list(user, "What to remove?", "What to remove?", clothingList)
			if(!selectedClothing)
				return
			src.removeClothing(selectedClothing, user)

/obj/mannequin/attackby(obj/item/W, mob/user)
	if (istype(W,/obj/item/scissors))
		boutput(user, SPAN_NOTICE("Wow! Scissors!"))

	if (istype(W,/obj/item/dye_bottle/))
		boutput(user, SPAN_NOTICE("Wow! A dye bottle!!"))

	if (istype(W, /obj/item/clothing))

		if (istype(W, /obj/item/clothing/gloves) || istype(W, /obj/item/clothing/ears) || istype(W, /obj/item/clothing/shoes))
			user.visible_message(SPAN_ALERT("\The [src] isn't built for those kinds of clothing!"))
		else
			user.visible_message("[user] starts to dress \the [src] with \the [W].", "You start to dress \the [src] with \the [W].")
			SETUP_GENERIC_ACTIONBAR(user, src, 1.5 SECONDS, /obj/mannequin/proc/dress, list(W, user), W.icon, W.icon_state,\
			"[user] puts \the [W] on \the [src].", null)

	else if(user.a_intent == INTENT_HARM && fallen == FALSE)
		user.visible_message(SPAN_ALERT("You lean back and hit \the [src] with \the [W] as hard as you can!"))
		step_away(src, user, 15)
		src.fall()

	else
		user.visible_message(SPAN_ALERT("\The [W] doesn't belong there!"))

/obj/mannequin/bullet_act(var/obj/projectile/P)
	if(!fallen)
		step_away(src, P, 15)
		src.fall()

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

/obj/mannequin/proc/dress(obj/item/clothing/W as obj, mob/user as mob)
	var/image/clothingImage = null
	var/clothingType = ""

	user.drop_item(W)
	W.set_loc(src)

	// Determine clothing type
	if (istype(W, /obj/item/clothing/head))
		clothingType = "head"
		src.head = W
	else if (istype(W, /obj/item/clothing/glasses))
		clothingType = "glasses"
		src.glasses = W
	else if (istype(W, /obj/item/clothing/under))
		clothingType = "under"
		src.under = W
	else if (istype(W, /obj/item/clothing/suit))
		clothingType = "suit"
		src.suit = W
	else if (istype(W, /obj/item/clothing/mask))
		clothingType = "mask"
		src.mask = W

	// Create wear image
	clothingImage = image(icon = W.wear_image, icon_state = W.icon_state, layer = W.wear_layer)
	clothingImage.alpha = W.alpha
	clothingImage.color = W.color
	clothingImage.filters = W.filters
	clothingImage.overlays = W.overlays

	// Add clothing overlay
	UpdateOverlays(clothingImage, clothingType)

/obj/mannequin/proc/removeClothing(selectedClothing as obj, mob/user as mob)
	var/clothingType = ""

	// Determine clothing type
	if (istype(selectedClothing, /obj/item/clothing/head))
		clothingType = "head"
		src.head = null
	else if (istype(selectedClothing, /obj/item/clothing/glasses))
		clothingType = "glasses"
		src.glasses = null
	else if (istype(selectedClothing, /obj/item/clothing/under))
		clothingType = "under"
		src.under = null
	else if (istype(selectedClothing, /obj/item/clothing/suit))
		clothingType = "suit"
		src.suit = null
	else if (istype(selectedClothing, /obj/item/clothing/mask))
		clothingType = "mask"
		src.mask = null

	// Remove clothing overlay
	UpdateOverlays(null, clothingType)
	user.put_in_hand_or_eject(selectedClothing)

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
