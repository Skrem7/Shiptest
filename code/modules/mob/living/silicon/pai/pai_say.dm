/mob/living/silicon/pai/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(silent)
		to_chat(src, span_warning("Communication circuits remain unitialized."))
	else
		..(message)

/mob/living/silicon/pai/binarycheck()
	return radio?.translate_binary
