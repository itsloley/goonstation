/obj/machinery/video_player
	name = "suspicious TV"
	icon = 'code/WorkInProgress/ly/icons/tv.dmi'
	icon_state = "tv"
	var/on = FALSE
	var/image/videooverlay
	var/updating = FALSE

	New()
		..()
		videooverlay = image('code/WorkInProgress/ly/icons/tv.dmi', "blank")
		videooverlay.layer = EFFECTS_LAYER_BASE

	attack_hand(mob/user)
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		on = !on
		if(on)
			icon_state = "tv-on"
			user.visible_message("[user] turns \the [src] on.", "You turn \the [src] on.")
			UpdateOverlays(videooverlay, "video", 0, 1)
			start_fast_updates()
			update_icon()
		else
			icon_state = "tv"
			user.visible_message("[user] turns \the [src] off.", "You turn \the [src] off.")
			UpdateOverlays(null, "video", 0, 1)
			updating = FALSE
			update_icon()
		return

	proc/start_fast_updates()
		if(!updating)
			updating = TRUE
			spawn(0)
				while(on && updating)
					var/icon/new_frame = file("C:\\Users\\loley\\Desktop\\psycho_shit\\img_output\\frame.png")
					if(new_frame) // Check if file exists and loaded properly
						videooverlay.icon = new_frame
						UpdateOverlays(videooverlay, "video", 0, 1)
					sleep(3) // Update at 10 fps (1 decisecond)
