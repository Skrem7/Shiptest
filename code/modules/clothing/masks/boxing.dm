/obj/item/clothing/mask/balaclava
	name = "balaclava"
	desc = "A stretchy fabric hood with eye holes meant for keeping the face warm in cold weather. Also useful for concealing one's identity."
	icon_state = "balaclava"
	item_state = "balaclava"
	clothing_flags = ALLOWINTERNALS
	visor_flags = ALLOWINTERNALS
	flags_inv = HIDEFACIALHAIR|HIDEFACE|HIDEEARS|HIDEHAIR
	visor_flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	alternate_worn_layer = BODY_LAYER
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.1
	permeability_coefficient = 0.5
	actions_types = list(/datum/action/item_action/adjust)
	flags_cover = MASKCOVERSMOUTH
	visor_flags_cover = MASKCOVERSMOUTH
	resistance_flags = NONE
	supports_variations = SNOUTED_VARIATION | SNOUTED_SMALL_VARIATION | VOX_VARIATION | KEPORI_VARIATION

	equipping_sound = EQUIP_SOUND_VFAST_GENERIC
	unequipping_sound = UNEQUIP_SOUND_VFAST_GENERIC
	equip_delay_self = EQUIP_DELAY_MASK
	equip_delay_other = EQUIP_DELAY_MASK * 1.5
	strip_delay = EQUIP_DELAY_MASK * 1.5
	equip_self_flags = EQUIP_ALLOW_MOVEMENT

/obj/item/clothing/mask/balaclava/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/balaclava/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	else
		adjustmask(user)

/obj/item/clothing/mask/balaclava/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click [src] to adjust it.")

/obj/item/clothing/mask/infiltrator
	name = "infiltrator balaclava"
	desc = "It makes you feel safe in your anonymity, but for a stealth outfit you sure do look obvious that you're up to no good. It seems to have a built in heads-up display."
	icon_state = "syndicate_balaclava"
	item_state = "syndicate_balaclava"
	clothing_flags = ALLOWINTERNALS
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_SMALL
	armor = list("melee" = 10, "bullet" = 5, "laser" = 5,"energy" = 5, "bomb" = 0, "bio" = 0, "rad" = 10, "fire" = 100, "acid" = 40)
	resistance_flags = FIRE_PROOF | ACID_PROOF

	var/voice_unknown = FALSE ///This makes it so that your name shows up as unknown when wearing the mask.

/obj/item/clothing/mask/infiltrator/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_MASK)
		return
	to_chat(user, "You roll the balaclava over your face, and a data display appears before your eyes.")
	ADD_TRAIT(user, TRAIT_DIAGNOSTIC_HUD, MASK_TRAIT)
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
	H.add_hud_to(user)
	voice_unknown = TRUE

/obj/item/clothing/mask/infiltrator/dropped(mob/living/carbon/human/user)
	to_chat(user, "You pull off the balaclava, and the mask's internal hud system switches off quietly.")
	REMOVE_TRAIT(user, TRAIT_DIAGNOSTIC_HUD, MASK_TRAIT)
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
	H.remove_hud_from(user)
	voice_unknown = FALSE
	return ..()

/obj/item/clothing/mask/luchador
	name = "Luchador Mask"
	desc = "Worn by robust fighters, flying high to defeat their foes!"
	icon_state = "luchag"
	item_state = "luchag"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_SMALL
	modifies_speech = TRUE

	equipping_sound = EQUIP_SOUND_VFAST_GENERIC
	unequipping_sound = UNEQUIP_SOUND_VFAST_GENERIC
	equip_delay_self = EQUIP_DELAY_MASK
	equip_delay_other = EQUIP_DELAY_MASK * 1.5
	strip_delay = EQUIP_DELAY_MASK * 1.5
	equip_self_flags = EQUIP_ALLOW_MOVEMENT

/obj/item/clothing/mask/luchador/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = replacetext(message, "captain", "CAPITÁN")
		message = replacetext(message, "station", "ESTACIÓN")
		message = replacetext(message, "sir", "SEÑOR")
		message = replacetext(message, "the ", "el ")
		message = replacetext(message, "my ", "mi ")
		message = replacetext(message, "is ", "es ")
		message = replacetext(message, "it's", "es")
		message = replacetext(message, "friend", "amigo")
		message = replacetext(message, "buddy", "amigo")
		message = replacetext(message, "hello", "hola")
		message = replacetext(message, " hot", " caliente")
		message = replacetext(message, " very ", " muy ")
		message = replacetext(message, "sword", "espada")
		message = replacetext(message, "library", "biblioteca")
		message = replacetext(message, "traitor", "traidor")
		message = replacetext(message, "wizard", "mago")
		message = uppertext(message)	//Things end up looking better this way (no mixed cases), and it fits the macho wrestler image.
		if(prob(25))
			message += " OLE!"
	speech_args[SPEECH_MESSAGE] = message

/obj/item/clothing/mask/luchador/tecnicos
	name = "Tecnicos Mask"
	desc = "Worn by robust fighters who uphold justice and fight honorably."
	icon_state = "luchador"
	item_state = "luchador"

/obj/item/clothing/mask/luchador/rudos
	name = "Rudos Mask"
	desc = "Worn by robust fighters who are willing to do anything to win."
	icon_state = "luchar"
	item_state = "luchar"
