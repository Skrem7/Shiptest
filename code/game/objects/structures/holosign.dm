
//holographic signs and barriers

/obj/structure/holosign
	name = "holo sign"
	icon = 'icons/effects/effects.dmi'
	anchored = TRUE
	max_integrity = 1
	armor = list("melee" = 0, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 20)
	var/obj/item/holosign_creator/projector
	var/lifespan = 5 MINUTES
	var/death_time
	var/infinite = FALSE //for infinite holosigns

	var/countdown_color
	var/obj/effect/countdown/holosign/countdown

/obj/structure/holosign/New(loc, source_projector)
	if(source_projector)
		projector = source_projector
		projector.signs += src
	..()

/obj/structure/holosign/Initialize(mapload, source, new_lifespan)
	. = ..()
	alpha = 0
	SSvis_overlays.add_vis_overlay(src, icon, icon_state, ABOVE_MOB_LAYER, plane, dir, add_appearance_flags = RESET_ALPHA) //you see mobs under it, but you hit them like they are above it

	if(!infinite)
		START_PROCESSING(SSobj, src)

		if(new_lifespan)
			lifespan = new_lifespan
		death_time = world.time + lifespan
		countdown = new(src)
		if(countdown_color)
			countdown.color = countdown_color
		countdown.start()

/obj/structure/holosign/process(seconds_per_tick)
	if(countdown.invisibility && death_time < (world.time + 60 SECONDS))
		countdown.invisibility = 0
		playsound(src, 'sound/machines/triple_beep.ogg', 50, TRUE)

	if(death_time < world.time)
		playsound(src, 'sound/effects/empulse.ogg', 50, TRUE)
		qdel(src)

/obj/structure/holosign/Destroy()
	if(projector)
		projector.signs -= src
		projector = null
	qdel(countdown)
	return ..()

/obj/structure/holosign/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	user.changeNext_move(CLICK_CD_MELEE)
	take_damage(5 , BRUTE, "melee", 1)

/obj/structure/holosign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/weapons/egloves.ogg', 80, TRUE)
		if(BURN)
			playsound(loc, 'sound/weapons/egloves.ogg', 80, TRUE)

/obj/structure/holosign/wetsign
	name = "wet floor sign"
	desc = "The words flicker as if they mean nothing."
	icon = 'icons/effects/effects.dmi'
	icon_state = "holosign"
	countdown_color = "#FCFF00"

/obj/structure/holosign/barrier
	name = "holobarrier"
	desc = "A short holographic barrier which can only be passed by walking."
	icon_state = "holosign_sec"
	countdown_color = "#FF0000"
	pass_flags_self = PASSTABLE | PASSGRILLE | PASSGLASS | LETPASSTHROW
	density = TRUE
	max_integrity = 20
	var/allow_walk = TRUE //can we pass through it on walk intent

/obj/structure/holosign/barrier/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return
	if(iscarbon(mover))
		var/mob/living/carbon/C = mover
		if(C.stat)	// Lets not prevent dragging unconscious/dead people.
			return TRUE
		if(allow_walk && C.m_intent == MOVE_INTENT_WALK)
			return TRUE

/obj/structure/holosign/barrier/wetsign
	name = "wet floor holobarrier"
	desc = "When it says walk it means walk."
	icon = 'icons/effects/effects.dmi'
	icon_state = "holosign"
	countdown_color = "#FCFF00"
	lifespan = 2 MINUTES

/obj/structure/holosign/barrier/wetsign/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(iscarbon(mover))
		var/mob/living/carbon/C = mover
		if(C.stat)	// Lets not prevent dragging unconscious/dead people.
			return TRUE
		if(allow_walk && C.m_intent != MOVE_INTENT_WALK)
			return FALSE

/obj/structure/holosign/barrier/engineering
	icon_state = "holosign_engi"
	flags_1 = RAD_PROTECT_CONTENTS_1 | RAD_NO_CONTAMINATE_1
	rad_insulation = RAD_LIGHT_INSULATION
	countdown_color = "#FF6600"

/obj/structure/holosign/barrier/atmos
	name = "holofirelock"
	desc = "A holographic barrier resembling a firelock. Though it does not prevent solid objects from passing through, gas is kept out."
	icon_state = "holo_firelock"
	countdown_color = "#FFE156"
	density = FALSE
	anchored = TRUE
	CanAtmosPass = ATMOS_PASS_NO
	alpha = 150
	flags_1 = RAD_PROTECT_CONTENTS_1 | RAD_NO_CONTAMINATE_1
	rad_insulation = RAD_LIGHT_INSULATION

/obj/structure/holosign/barrier/atmos/Initialize()
	. = ..()
	air_update_turf(TRUE)

/obj/structure/holosign/barrier/cyborg
	name = "Energy Field"
	desc = "A fragile energy field that blocks movement. Excels at blocking lethal projectiles."
	density = TRUE
	max_integrity = 10
	allow_walk = FALSE

/obj/structure/holosign/barrier/cyborg/bullet_act(obj/projectile/P)
	take_damage((P.damage / 5) , BRUTE, "melee", 1)	//Doesn't really matter what damage flag it is.
	if(istype(P, /obj/projectile/energy/electrode))
		take_damage(10, BRUTE, "melee", 1)	//Tasers aren't harmful.
	if(istype(P, /obj/projectile/beam/disabler))
		take_damage(5, BRUTE, "melee", 1)	//Disablers aren't harmful.
	return BULLET_ACT_HIT

/obj/structure/holosign/barrier/medical
	name = "\improper PENLITE holobarrier"
	desc = "A holobarrier that uses biometrics to detect human viruses. Denies passing to personnel with easily-detected, malicious viruses. Good for quarantines."
	icon_state = "holo_medical"
	countdown_color = "#82B9FF"
	alpha = 125 //lazy :)
	lifespan = 10 MINUTES
	var/force_allaccess = FALSE
	var/buzzcd = 0

/obj/structure/holosign/barrier/medical/examine(mob/user)
	. = ..()
	. += span_notice("The biometric scanners are <b>[force_allaccess ? "off" : "on"]</b>.")

/obj/structure/holosign/barrier/medical/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(force_allaccess)
		return TRUE
	if(istype(mover, /obj/vehicle/ridden))
		for(var/M in mover.buckled_mobs)
			if(ishuman(M))
				if(!CheckHuman(M))
					return FALSE
	if(ishuman(mover))
		return CheckHuman(mover)
	return TRUE

/obj/structure/holosign/barrier/medical/Bumped(atom/movable/AM)
	. = ..()
	icon_state = "holo_medical"
	if(ishuman(AM) && !CheckHuman(AM))
		if(buzzcd < world.time)
			playsound(get_turf(src),'sound/machines/buzz-sigh.ogg',65,TRUE,4)
			buzzcd = (world.time + 60)
		icon_state = "holo_medical-deny"

/obj/structure/holosign/barrier/medical/proc/CheckHuman(mob/living/carbon/human/sickboi)
	var/threat = sickboi.check_virus()
	if(get_disease_severity_value(threat) > get_disease_severity_value(DISEASE_SEVERITY_MINOR))
		return FALSE
	return TRUE

/obj/structure/holosign/barrier/medical/attack_hand(mob/living/user)
	if(user.a_intent == INTENT_HELP && CanPass(user, get_dir(src, user)))
		force_allaccess = !force_allaccess
		to_chat(user, span_warning("You [force_allaccess ? "deactivate" : "activate"] the biometric scanners.")) //warning spans because you can make the station sick!
	else
		return ..()

/obj/structure/holosign/barrier/cyborg/hacked
	name = "Charged Energy Field"
	desc = "A powerful energy field that blocks movement. Energy arcs off it."
	max_integrity = 20
	var/shockcd = 0

/obj/structure/holosign/barrier/cyborg/hacked/bullet_act(obj/projectile/P)
	take_damage(P.damage, BRUTE, "melee", 1)	//Yeah no this doesn't get projectile resistance.
	return BULLET_ACT_HIT

/obj/structure/holosign/barrier/cyborg/hacked/proc/cooldown()
	shockcd = FALSE

/obj/structure/holosign/barrier/cyborg/hacked/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!shockcd)
		if(ismob(user))
			var/mob/living/M = user
			M.electrocute_act(15,"Energy Barrier", flags = SHOCK_NOGLOVES)
			shockcd = TRUE
			addtimer(CALLBACK(src, PROC_REF(cooldown)), 5)

/obj/structure/holosign/barrier/cyborg/hacked/Bumped(atom/movable/AM)
	if(shockcd)
		return

	if(!ismob(AM))
		return

	var/mob/living/M = AM
	M.electrocute_act(15,"Energy Barrier", flags = SHOCK_NOGLOVES)
	shockcd = TRUE
	addtimer(CALLBACK(src, PROC_REF(cooldown)), 5)

/* Infinite Holosigns for admin/etc use */

/obj/structure/holosign/wetsign/infinite
	infinite = TRUE

/obj/structure/holosign/barrier/infinite
	infinite = TRUE

/obj/structure/holosign/barrier/wetsign/infinite
	infinite = TRUE

/obj/structure/holosign/barrier/engineering/infinite
	infinite = TRUE

/obj/structure/holosign/barrier/atmos/infinite
	infinite = TRUE

/obj/structure/holosign/barrier/cyborg/infinite
	infinite = TRUE

/obj/structure/holosign/barrier/medical/infinite
	infinite = TRUE

/obj/structure/holosign/barrier/cyborg/hacked/infinite
	infinite = TRUE
