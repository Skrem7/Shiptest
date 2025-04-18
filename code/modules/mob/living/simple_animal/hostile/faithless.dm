/mob/living/simple_animal/hostile/faithless
	name = "The Faithless"
	desc = "The Wish Granter's faith in humanity, incarnate."
	icon_state = "faithless"
	icon_living = "faithless"
	icon_dead = "faithless_dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	gender = MALE
	speak_chance = 0
	turns_per_move = 5
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	emote_taunt = list("wails")
	taunt_chance = 25
	speed = 0
	maxHealth = 80
	health = 80
	stat_attack = HARD_CRIT
	robust_searching = 1

	harm_intent_damage = 10
	obj_damage = 50
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "grips"
	attack_verb_simple = "grip"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	speak_emote = list("growls")

	atmos_requirements = IMMUNE_ATMOS_REQS
	minbodytemp = 0

	faction = list("faithless")

	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/faithless/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)

/mob/living/simple_animal/hostile/faithless/AttackingTarget()
	. = ..()
	if(. && prob(12) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.Paralyze(60)
		C.visible_message(span_danger("\The [src] knocks down \the [C]!"), \
				span_userdanger("\The [src] knocks you down!"))
