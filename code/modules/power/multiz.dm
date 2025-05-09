#define RELAY_OK 1
#define RELAY_ADD_CABLE 2
#define RELAY_ADD_METAL 3

/obj/machinery/power/deck_relay //This bridges powernets
	name = "Multi-deck power adapter"
	desc = "A huge bundle of double insulated cabling which seems to run up into the ceiling."
	icon = 'icons/obj/power.dmi'
	icon_state = "cablerelay-off"
	max_integrity = 350
	integrity_failure = 0.25
	var/broken_status = RELAY_OK
	var/obj/machinery/power/deck_relay/below ///The relay that's below us (for bridging powernets)
	var/obj/machinery/power/deck_relay/above ///The relay that's above us (for bridging powernets)
	anchored = TRUE
	density = FALSE

/obj/machinery/power/deck_relay/examine(mob/user)
	. += ..()
	if(!anchored)
		. += span_notice("The securing bolts are undone.")
	if(broken_status == RELAY_ADD_CABLE)
		. += span_notice("The cable insulation is torn apart and the wires are frayed beyond use.")
	if(broken_status == RELAY_ADD_METAL)
		. += span_notice("The cable insulation is torn apart and the wiring is exposed.")

/obj/machinery/power/deck_relay/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		if(!anchored && broken_status == RELAY_OK)
			break_connections()
		return FALSE

	else if(istype(I, /obj/item/stack/cable_coil) && broken_status == RELAY_ADD_CABLE)
		var/obj/item/stack/C = I
		if(C.use(15))
			to_chat(user, span_notice("You fix the frayed wires inside [src]."))
			icon_state = "cablerelay-broken-cable"
			broken_status = RELAY_ADD_METAL
		else
			to_chat(user, "You need 15 cables to rewire [src].")

	else if(istype(I, /obj/item/stack/sheet/metal) && broken_status == RELAY_ADD_METAL)
		var/obj/item/stack/S = I
		if(S.use(10))
			to_chat(user, span_notice("You reseal the insulation for [src]."))
			icon_state = "cablerelay"
			broken_status = RELAY_OK
			obj_integrity = max_integrity
		else
			to_chat(user, "You need 10 metal to mend [src].")

	else
		return ..()

/obj/machinery/power/deck_relay/obj_break()
	..()
	if(broken_status == RELAY_OK)
		break_connections()
		visible_message(span_warning("[src]'s insulation breaks, fraying and severing the cable bundle!"))
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
		icon_state = "cablerelay-broken"
		broken_status = RELAY_ADD_CABLE

/obj/machinery/power/deck_relay/obj_destruction()
	return //this shouldn't break under usual means

/obj/machinery/power/deck_relay/Destroy()
	break_connections()
	return ..()

///Every time the network is propogated, check the connections and make sure they're merged again
/obj/machinery/power/deck_relay/connect_to_network(refresh = TRUE)
	. = ..()
	if(refresh)
		find_relays()

///Lose connections and reset the merged powernet so it makes 2 new seperated ones
/obj/machinery/power/deck_relay/proc/break_connections()
	if(above)
		var/turf/above_deck_relay = get_turf(above)
		var/obj/structure/cable/above_cable = above_deck_relay.get_cable_node()
		if(above_cable)
			var/datum/powernet/above_powernet = new()
			propagate_network(above_cable, above_powernet)
		above.below = null
		above = null
	if(below)
		var/turf/below_deck_relay = get_turf(below)
		var/obj/structure/cable/below_cable = below_deck_relay.get_cable_node()
		if(below_cable)
			var/datum/powernet/below_powernet = new()
			propagate_network(below_cable, below_powernet)
		below.above = null
		below = null

///Allows you to scan the relay with a multitool to see stats/reconnect relays
/obj/machinery/power/deck_relay/multitool_act(mob/user, obj/item/I)
	if(!anchored)
		to_chat(user, span_danger("You need to wrench this into place before getting a reading!"))
		return TRUE
	if(broken_status == RELAY_ADD_CABLE || broken_status == RELAY_ADD_METAL)
		to_chat(user, span_danger("The [src] isn't in proper shape to get a reading!"))
		return TRUE
	if(powernet && (above || below))//we have a powernet and at least one connected relay
		to_chat(user, span_danger("Total power: [DisplayPower(powernet.avail)]\nLoad: [DisplayPower(powernet.load)]\nExcess power: [DisplayPower(surplus())]"))
	if(!above && !below)
		to_chat(user, span_danger("Cannot access valid powernet. Attempting to re-establish. Ensure any relays above and below are aligned properly and on cable nodes."))
		find_relays()
	return TRUE

/obj/machinery/power/deck_relay/Initialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(find_relays)), 30)

///Handles re-acquiring + merging powernets found by find_relays()
/obj/machinery/power/deck_relay/proc/refresh()
	if(above)
		above.merge(src)
	if(below)
		below.merge(src)

///Merges the two powernets connected to the deck relays
/obj/machinery/power/deck_relay/proc/merge(obj/machinery/power/deck_relay/DR)
	if(!DR)
		return
	var/turf/merge_from = get_turf(DR)
	var/turf/merge_to = get_turf(src)
	var/obj/structure/cable/C = merge_from.get_cable_node()
	var/obj/structure/cable/XR = merge_to.get_cable_node()
	if(C && XR)
		var/datum/powernet/new_powernet = merge_powernets(XR.powernet,C.powernet)//Bridge the powernets.
		if(new_powernet) //If there's a new powernet created, add both relays to it.
			new_powernet.add_machine(src)
			new_powernet.add_machine(DR)

///Locates relays that are above and below this object
/obj/machinery/power/deck_relay/proc/find_relays()
	var/turf/T = get_turf(src)
	if(!T || !istype(T))
		return FALSE
	below = null //in case we're re-establishing
	above = null
	var/obj/structure/cable/C = T.get_cable_node() //check if we have a node cable on the machine turf, the first found is picked
	if(C?.powernet)
		connect_to_network(FALSE)

	below = locate(/obj/machinery/power/deck_relay) in(T.below())
	above = locate(/obj/machinery/power/deck_relay) in(T.above())
	if(below || above)
		icon_state = "cablerelay-on"
		if(above)
			above.below = src
		if(below)
			below.above = src
		addtimer(CALLBACK(src, PROC_REF(refresh)), 20) //Wait a bit so we can find the one below, then get powering
	return TRUE
