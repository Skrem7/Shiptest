/obj/item/electronics/airlock
	name = "airlock electronics"
	req_access = list(ACCESS_MAINT_TUNNELS)
	custom_price = 50
	///how fast the constructed airlock will close
	var/close_speed = 15 SECONDS
	/// A list of all granted accesses
	var/list/accesses = list()
	/// If the airlock should require ALL or only ONE of the listed accesses
	var/one_access = 0
	/// Unrestricted sides, or sides of the airlock that will open regardless of access
	var/unres_sides = 0
	/// A holder of the electronics, in case of them working as an integrated part
	var/holder

/obj/item/electronics/airlock/examine(mob/user)
	. = ..()
	. += span_notice("Has a neat <i>selection menu</i> for modifying airlock access levels.")

/obj/item/electronics/airlock/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/electronics/airlock/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirlockElectronics", name)
		ui.open()

/obj/item/electronics/airlock/ui_static_data(mob/user)
	var/list/data = list()
	var/list/regions = list()
	for(var/i in 1 to 7)
		var/list/accesses = list()
		for(var/access in get_region_accesses(i))
			if (get_access_desc(access))
				accesses += list(list(
					"desc" = replacetext(get_access_desc(access), "&nbsp", " "),
					"ref" = access,
				))

		regions += list(list(
			"name" = get_region_accesses_name(i),
			"regid" = i,
			"accesses" = accesses
		))

	data["regions"] = regions
	return data

/obj/item/electronics/airlock/ui_data()
	var/list/data = list()
	data["close_speed"] = close_speed
	data["accesses"] = accesses
	data["oneAccess"] = one_access
	data["unres_direction"] = unres_sides
	return data

/obj/item/electronics/airlock/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("clear_all")
			accesses = list()
			one_access = 0
			. = TRUE
		if("grant_all")
			accesses = get_all_accesses()
			. = TRUE
		if("one_access")
			one_access = !one_access
			. = TRUE
		if("set")
			var/access = text2num(params["access"])
			if (!(access in accesses))
				accesses += access
			else
				accesses -= access
			. = TRUE
		if("direc_set")
			var/unres_direction = text2num(params["unres_direction"])
			unres_sides ^= unres_direction //XOR, toggles only the bit that was clicked
			. = TRUE
		if("grant_region")
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			accesses |= get_region_accesses(region)
			. = TRUE
		if("deny_region")
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			accesses -= get_region_accesses(region)
			. = TRUE
		if("close_speed")
			var/tune = params["tune"]
			var/adjust = text2num(params["adjust"])
			if(adjust)
				tune = close_speed + adjust SECONDS
				. = TRUE
			else if(text2num(tune) != null)
				tune = tune SECONDS
				. = TRUE
			if(.)
				close_speed = clamp(tune, 0, 300)
			. = TRUE

/obj/item/electronics/airlock/ui_host()
	if(holder)
		return holder
	return src
