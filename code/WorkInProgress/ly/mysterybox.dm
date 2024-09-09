// the different states of the mystery box
/// Closed, can't interact
#define MYSTERY_BOX_COOLING_DOWN 0
/// Closed, ready to be interacted with
#define MYSTERY_BOX_STANDBY 1
/// The box is choosing the prize
#define MYSTERY_BOX_CHOOSING 2
/// The box is presenting the prize, for someone to claim it
#define MYSTERY_BOX_PRESENTING 3

// delays for the different stages of the box's state, the visuals, and the audio
/// How long the box takes to decide what the prize is
#define MBOX_DURATION_CHOOSING (4.85 SECONDS)
/// How long the box takes to start expiring the offer, though it's still valid until MBOX_DURATION_EXPIRING finishes. Timed to the sound clips
#define MBOX_DURATION_PRESENTING (3 SECONDS)
/// How long the box takes to start lowering the prize back into itself. When this finishes, the prize is gone
#define MBOX_DURATION_EXPIRING (2.6 SECONDS)
/// How long after the box closes until it can go again
#define MBOX_DURATION_STANDBY (0 SECONDS)

/obj/mystery_box
	name = "mystery box"
	desc = "A crate that seems equally magical and mysterious, capable of granting the user all kinds of different pieces of gear. I wonder what's inside?"
	density = 1
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "crate"
	var/icon_closed = "crate"
	var/icon_opened = "crateopen"
	var/crate_open_sound = 'sound/machines/click.ogg'
	var/crate_close_sound = 'sound/machines/click.ogg'
	var/music = 'code/WorkInProgress/ly/sounds/mbox.ogg'
	var/box_state = MYSTERY_BOX_STANDBY
	var/animated = TRUE // the randomized animation, disabling it just pick an items from the list and goes
	var/single_type = FALSE // instead of picking random children from the parent type, it picks directly from selectable_types and no more
	var/chaos_mode = FALSE // show abtract types & types w/o any icon
	var/force_pickup = FALSE // you cannot choose if you want this or not. it is MANDATORY
	var/obj/mystery_box_item/presented_item
	var/list/selectable_types = list()
	var/list/valid_types
	var/list/rigged_items = list() // will only actually pick an item from this list at the end, making the animation a lie. only works if animated = true because that's when you'd need it
	var/list/blacklist = list() // list of types & subtypes that you don't want to show up : TODO
	var/list/single_type_blacklist  = list() // ditto, but only for single types : TODO

	attack_hand(mob/user)
		. = ..()
		switch(box_state)
			if(MYSTERY_BOX_STANDBY)
				activate(user)

			if(MYSTERY_BOX_PRESENTING)
				if(presented_item.claimable)
					presented_item.claimable = FALSE
					box_state = MYSTERY_BOX_COOLING_DOWN
					grant_item(user)

	New()
		generate_valid_types()
		..()

/obj/mystery_box/proc/activate(mob/user)
	animate_shake(src)
	box_state = MYSTERY_BOX_CHOOSING
	SPAWN(0.5 SECOND)
		update_icon_state()
		anchored = 1
		playsound(src.loc, music, 50, 0)
		playsound(src.loc, crate_open_sound, 15, 1, -3)
		presented_item = new(loc)
		presented_item.start_animation(src)

/// The box has finished choosing, mark it as available for grabbing
/obj/mystery_box/proc/present_item()
	if(force_pickup)
		visible_message(SPAN_ALERT("\The [src] drops \a [presented_item]!"))
		var/atom/movable/instantiated_item = new presented_item.selected_path(loc)
		if(presented_item)
			qdel(presented_item)
		if(instantiated_item)
			instantiated_item.loc = get_turf(src)

		SPAWN(MBOX_DURATION_EXPIRING)
			playsound(src.loc, crate_close_sound, 15, 1, -3)
			anchored = 0
			box_state = MYSTERY_BOX_COOLING_DOWN
			update_icon_state()
			SPAWN(MBOX_DURATION_STANDBY)
				box_state = MYSTERY_BOX_STANDBY
	else
		visible_message(SPAN_NOTICE("\The [src] presents \a [presented_item]!"))
		box_state = MYSTERY_BOX_PRESENTING
		SPAWN(MBOX_DURATION_PRESENTING)
			presented_item.expire_animation()
			SPAWN(MBOX_DURATION_EXPIRING)
				if(presented_item)
					qdel(presented_item)
				playsound(src.loc, crate_close_sound, 15, 1, -3)
				anchored = 0
				box_state = MYSTERY_BOX_COOLING_DOWN
				update_icon_state()
				SPAWN(MBOX_DURATION_STANDBY)
					box_state = MYSTERY_BOX_STANDBY

/obj/mystery_box/proc/grant_item(mob/user)
	var/atom/movable/instantiated_item = new presented_item.selected_path(loc)
	qdel(presented_item)

	if(!isitem(instantiated_item))
		instantiated_item.loc = get_turf(src)
	else
		user.put_in_hand_or_drop(instantiated_item)

/obj/mystery_box/proc/update_icon_state()
	icon_state = "[initial(icon_state)][box_state > MYSTERY_BOX_STANDBY ? "open" : ""]"
	return

/obj/mystery_box/proc/generate_valid_types()
	valid_types = list()

	if (!single_type)
		// Iterate over each type path in selectable_types
		for (var/selected_type in selectable_types)
			// Get all subtypes of the current selected_type
			for (var/subtype in typesof(selected_type))
				var/obj/item/iter_item = subtype

				if(!chaos_mode)
					// Skip if the item is abstract or lacks an initial icon state
					if (IS_ABSTRACT(iter_item.type) || !initial(iter_item.icon_state))
						continue

				// Skip if the item is in the blacklist
				var/blacklisted = FALSE
				for (var/blacklisted_type in blacklist)
				{
					if (istype(iter_item, blacklisted_type))
					{
						blacklisted = TRUE
						break
					}
				}
				if (blacklisted)
					continue  // Skip to the next iteration of the outer loop

				// Add the item to valid_types if all checks pass
				valid_types += subtype

		return valid_types
	else
		for (var/selected_type in selectable_types)
			valid_types += selected_type
		return valid_types


/obj/mystery_box_item
	name = "???"
	desc = "Who knows what it'll be??"
	icon = 'icons/obj/items/guns/kinetic.dmi'
	icon_state = "revolver"
	anchored = 1

	/// The currently selected item. Constantly changes while choosing, determines what is spawned if the prize is claimed, and its current icon
	var/selected_path = /obj/item/gun/kinetic/revolver
	/// The box that spawned this
	var/obj/mystery_box/parent_box
	/// Whether this prize is currently claimable
	var/claimable = FALSE

	New()
		. = ..()
		var/matrix/starting = matrix()
		starting.Scale(0.5, 0.5)
		transform = starting
		add_filter("item_rays", 3, list("type" = "rays", "size" = 28, "color" = "#FBFF23"))

	attack_hand(mob/user)
		. = ..()
		if(claimable)
			claimable = FALSE
			parent_box.grant_item(user)

/// Start pushing the prize up
/obj/mystery_box_item/proc/start_animation(atom/parent)
	parent_box = parent
	loop_icon_changes()

/obj/mystery_box_item/proc/loop_icon_changes()
	var/change_delay = 0.25 // the running count of the delay
	var/change_delay_delta = 0.05 // How much to increment the delay per step so the changing slows down
	var/change_counter = 0 // The running count of the running count

	var/matrix/starting = matrix()
	animate(src, pixel_y = 10, transform = starting, time = MBOX_DURATION_CHOOSING, easing = CUBIC_EASING | EASE_OUT)

	SPAWN(MBOX_DURATION_CHOOSING)
		if(selected_path == /obj/item/toy/plush/small)
			message_admins("[selected_path]")
			src.blackops_bear()
			message_admins("BEAR!")
			message_admins("[selected_path]")
		else
			message_admins("[selected_path]")
			src.present_item()
			message_admins("NOT A BEAR!")
			message_admins("[selected_path]")

	selected_path = pick(parent_box.valid_types)
	src.update_random_icon(selected_path)

	if(parent_box.animated)
		while((change_counter + change_delay_delta + change_delay) < MBOX_DURATION_CHOOSING)
			change_delay += change_delay_delta
			change_counter += change_delay
			selected_path = pick(parent_box.valid_types)
			sleep(change_delay) // Use a constant delay
			src.update_random_icon(selected_path)
		if(parent_box.rigged_items)
			selected_path = pick(parent_box.rigged_items)
			src.update_random_icon(selected_path)


/// animate() isn't up to the task for queueing up icon changes, so this is the proc we call with timers to update our icon
/obj/mystery_box_item/proc/update_random_icon(new_item_type)
	var/atom/movable/new_item = new_item_type
	icon = new_item::icon
	icon_state = new_item::icon_state

/obj/mystery_box_item/proc/present_item()
	var/atom/movable/selected_item = selected_path
	add_filter("ready_outline", 2, list("type" = "outline", "color" = "#FBFF23", "size" = 0.2))
	name = selected_item::name
	desc = selected_item::desc
	parent_box.present_item()
	claimable = TRUE

/// Sink back into the box
/obj/mystery_box_item/proc/expire_animation()
	var/matrix/shrink_back = matrix()
	shrink_back.Scale(0.5,0.5)
	animate(src, pixel_y = 0, transform = shrink_back, time = MBOX_DURATION_EXPIRING)

/obj/mystery_box/black_ops
	crate_open_sound = 'code/WorkInProgress/ly/sounds/mbox_open_blackops.ogg'
	crate_close_sound = 'code/WorkInProgress/ly/sounds/mbox_close_blackops.ogg'
	music = 'code/WorkInProgress/ly/sounds/mbox_music_blackops.ogg'

/obj/mystery_box_item/proc/blackops_bear()
	var/atom/movable/selected_item = selected_path
	var/matrix/starting = matrix()
	name = selected_item::name
	desc = selected_item::desc
	playsound(src.loc, 'code/WorkInProgress/ly/sounds/mbox_bear.ogg', 50, 0)
	SPAWN(2 SECONDS)
		animate(src, pixel_y = 500, transform = starting, time = 4 SECONDS, easing = CUBIC_EASING | EASE_IN)
		SPAWN(6 SECONDS)
			playsound(src.loc, 'code/WorkInProgress/ly/sounds/mbox_bear_byebye.ogg', 50, 0)
			animate(parent_box, pixel_y = 25, transform = starting, time = 2 SECONDS, easing = CUBIC_EASING | EASE_IN)
			SPAWN(4 SECONDS)
				animate(parent_box, pixel_y = 10, transform = starting, time = 1 SECONDS, easing = CUBIC_EASING | EASE_OUT)
				SPAWN(3 SECONDS)
					animate(parent_box, pixel_y = 500, transform = starting, time = 1 SECONDS, easing = CUBIC_EASING | EASE_OUT)
					SPAWN(4 SECONDS)
						src.blowthefuckup(500)
						qdel(parent_box)
						qdel(src)

/obj/mystery_box/black_ops/black_ops_bear
	selectable_types = list(/obj/item/gun)
	rigged_items = list(/obj/item/toy/plush/small)
