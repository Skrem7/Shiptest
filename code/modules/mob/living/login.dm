/mob/living/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	//Mind updates
	sync_mind()
	mind.show_memory(src, 0)

	//Round specific stuff
	if(SSticker.mode)
		switch(SSticker.mode.name)
			if("sandbox")
				CanBuild()

	update_damage_hud()
	update_health_hud()


	var/virtual_z = virtual_z()
	if(virtual_z)
		LAZYADDASSOCLIST(SSmobs.players_by_virtual_z, "[virtual_z]", src)
		SSidlenpcpool.try_wakeup_virtual_z(virtual_z)

	//Vents
	if(ventcrawler)
		to_chat(src, span_notice("You can ventcrawl! Use alt+click on vents to quickly travel about the station."))

	if(ranged_ability)
		ranged_ability.add_ranged_ability(src, span_notice("You currently have <b>[ranged_ability]</b> active!"))

	var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
	if(changeling)
		changeling.regain_powers()

	update_fov_client()
	player_logged = FALSE
