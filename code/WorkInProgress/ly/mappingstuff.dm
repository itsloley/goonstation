/area/z6/
	name = "Z6"
	icon_state = "blue"
	requires_power = 0
	area_parallax_render_source_group = /datum/parallax_render_source_group/area/cairngorm

area/z6/hub
	name = "Z6 Hub"
	icon_state = "blue"

/obj/warp_zone
	name = "warp zone"
	desc = "This could lead anywhere!"
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	var/teleport_x = 1
	var/teleport_y = 1
	var/teleport_z = 1
	density = 1
	anchored = 1

	var/list/destination

	New()
		..()
		destination = list(teleport_x, teleport_y, teleport_z)

	Bumped(atom/movable/A)
		if (istype(A, /atom/movable))
			var/obj/decal/teleport_swirl/swirl = new /obj/decal/teleport_swirl(get_turf(src))
			playsound(src, pick("sound/effects/warp1.ogg", "sound/effects/warp2.ogg"))

			SPAWN(0.7 SECONDS)
				qdel(swirl)

			var/turf/new_turf = locate(destination[1], destination[2], destination[3])
			if (new_turf)
				A.set_loc(new_turf)
				playsound(new_turf, pick("sound/effects/warp1.ogg", "sound/effects/warp2.ogg"))

				var/obj/decal/teleport_swirl/out/swirl_out = new /obj/decal/teleport_swirl/out(new_turf)
				SPAWN(0.7 SECONDS)
					qdel(swirl_out)
		..()

	proc/set_destination(var/x, var/y, var/z)
		destination = list(x, y, z)
