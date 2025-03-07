#define WEATHER_ALERT_CLEAR 0
#define WEATHER_ALERT_INCOMING 1
#define WEATHER_ALERT_IMMINENT_OR_ACTIVE 2

/// Component which makes you yell about what the weather is
/datum/component/weather_announcer
	/// Currently displayed warning level
	var/warning_level = WEATHER_ALERT_CLEAR
	/// Whether the incoming weather is actually going to harm you
	var/is_weather_dangerous = TRUE
	/// Are we actually turned on right now?
	var/enabled = TRUE
	/// Overlay added when things are alright
	var/state_normal
	/// Overlay added when you should start looking for shelter
	var/state_warning
	/// Overlay added when you are in danger
	var/state_danger

/datum/component/weather_announcer/Initialize(
	state_normal,
	state_warning,
	state_danger,
)
	. = ..()
	if (!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSprocessing, src)
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_MACHINERY_POWER_RESTORED, PROC_REF(on_powered))
	RegisterSignal(parent, COMSIG_MACHINERY_POWER_LOST, PROC_REF(on_power_lost))

	src.state_normal = state_normal
	src.state_warning = state_warning
	src.state_danger = state_danger
	var/atom/speaker = parent
	speaker.update_appearance(UPDATE_ICON)
	update_light_color()

/datum/component/weather_announcer/Destroy(force)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/// Add appropriate overlays
/datum/component/weather_announcer/proc/on_update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER
	if (!enabled || !state_normal || !state_warning || !state_danger)
		return

	switch (warning_level)
		if(WEATHER_ALERT_CLEAR)
			overlays += state_normal
		if(WEATHER_ALERT_INCOMING)
			overlays += state_warning
		if(WEATHER_ALERT_IMMINENT_OR_ACTIVE)
			overlays += (is_weather_dangerous) ? state_danger : state_warning

/// If powered, receive updates
/datum/component/weather_announcer/proc/on_powered()
	SIGNAL_HANDLER
	enabled = TRUE
	var/atom/speaker = parent
	speaker.update_appearance(UPDATE_ICON)

/// If no power, don't receive updates
/datum/component/weather_announcer/proc/on_power_lost()
	SIGNAL_HANDLER
	enabled = FALSE
	var/atom/speaker = parent
	speaker.update_appearance(UPDATE_ICON)

/datum/component/weather_announcer/process(seconds_per_tick)
	if (!enabled)
		return

	var/previous_level = warning_level
	var/previous_danger = is_weather_dangerous
	set_current_alert_level()
	if(previous_level == warning_level && previous_danger == is_weather_dangerous)
		return // No change
	var/atom/movable/speaker = parent
	speaker.say(get_warning_message())
	speaker.update_appearance(UPDATE_ICON)
	update_light_color()

/datum/component/weather_announcer/proc/update_light_color()
	var/atom/movable/light = parent
	switch(warning_level)
		if(WEATHER_ALERT_CLEAR)
			light.set_light_color(LIGHT_COLOR_GREEN)
		if(WEATHER_ALERT_INCOMING)
			light.set_light_color(LIGHT_COLOR_YELLOW)
		if(WEATHER_ALERT_IMMINENT_OR_ACTIVE)
			light.set_light_color(LIGHT_COLOR_INTENSE_RED)
	if(light.light_system == STATIC_LIGHT)
		light.update_light()

/// Returns a string we should display to communicate what you should be doing
/datum/component/weather_announcer/proc/get_warning_message()
	if (!is_weather_dangerous)
		return "No risk expected from incoming weather front."
	switch(warning_level)
		if(WEATHER_ALERT_CLEAR)
			return "All clear, no weather alerts to report."
		if(WEATHER_ALERT_INCOMING)
			return "Weather front incoming, begin to seek shelter."
		if(WEATHER_ALERT_IMMINENT_OR_ACTIVE)
			return "Weather front imminent, find shelter immediately."
	return "Error in meteorological calculation. Please report this deviation to a trained programmer."

/datum/component/weather_announcer/proc/time_till_storm()
	var/datum/weather_controller/local_weather_controller = SSmapping.get_map_zone_weather_controller(parent)
	if(!local_weather_controller?.next_weather)
		return null
	for(var/type_index in local_weather_controller.current_weathers)
		var/datum/weather/check_weather = local_weather_controller.current_weathers[type_index]
		if(!check_weather.barometer_predictable || check_weather.stage == WIND_DOWN_STAGE || check_weather.stage == END_STAGE)
			continue
		warning_level = WEATHER_ALERT_IMMINENT_OR_ACTIVE
		return 0

	var/time_until_next = INFINITY
	var/next_time = local_weather_controller.next_weather - world.time || INFINITY
	if (next_time && next_time < time_until_next)
		time_until_next = next_time
	return time_until_next

/// Polls existing weather for what kind of warnings we should be displaying.
/datum/component/weather_announcer/proc/set_current_alert_level()
	var/time_until_next = time_till_storm()
	if(isnull(time_until_next))
		return // No problems if there are no mining z levels
	if(time_until_next >= 2 MINUTES)
		warning_level = WEATHER_ALERT_CLEAR
		return

	if(time_until_next >= 30 SECONDS)
		warning_level = WEATHER_ALERT_INCOMING
		return

	// Weather is here, now we need to figure out if it is dangerous
	warning_level = WEATHER_ALERT_IMMINENT_OR_ACTIVE

	var/datum/weather_controller/local_weather_controller = SSmapping.get_map_zone_weather_controller(parent)
	for(var/type_index in local_weather_controller.current_weathers)
		var/datum/weather/check_weather = local_weather_controller.current_weathers[type_index]
		if(!check_weather.barometer_predictable || check_weather.stage == WIND_DOWN_STAGE || check_weather.stage == END_STAGE)
			continue
		is_weather_dangerous = !check_weather.aesthetic
		return

/datum/component/weather_announcer/proc/on_examine(atom/radio, mob/examiner, list/examine_texts)
	var/time_until_next = time_till_storm()
	if(isnull(time_until_next))
		return
	if (time_until_next == 0)
		examine_texts += span_warning ("A storm is currently active, please seek shelter.")
	else
		examine_texts += span_notice("The next storm is inbound in [DisplayTimeText(time_until_next)].")

/datum/component/weather_announcer/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/weather_announcer/UnregisterFromParent()
	.=..()
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)

#undef WEATHER_ALERT_CLEAR
#undef WEATHER_ALERT_INCOMING
#undef WEATHER_ALERT_IMMINENT_OR_ACTIVE
