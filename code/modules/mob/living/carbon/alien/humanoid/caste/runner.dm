//ALIEN RUNNER - UPDATED 11APR2015 - APOPHIS
/mob/living/carbon/alien/humanoid/runner
	name = "alien runner"
	caste = "Runner"
	maxHealth = 100
	health = 100
	icon_state = "Runner Walking"
	damagemin = 23
	damagemax = 28
	tacklemin = 1
	tacklemax = 3
	tackle_chance = 70 //Should not be above 100%
	psychiccost = 25
	var/usedpounce = 0
	//class = 1


	//RUNNERS NOW USE JELLY, SINCE THEY EVOLVE INTO HUNTERS
	var/hasJelly = 0
	var/jellyProgress = 0
	var/jellyProgressMax = 750
	Stat()
		..()
		stat(null, "Jelly Progress: [jellyProgress]/[jellyProgressMax]")
	proc/growJelly()
		spawn while(1)
			if(hasJelly)
				if(jellyProgress < jellyProgressMax)
					jellyProgress = min(jellyProgress + 1, jellyProgressMax)
			sleep(10)
	proc/canEvolve()
		if(!hasJelly)
			return 0
		if(jellyProgress < jellyProgressMax)
			return 0
		return 1

/mob/living/carbon/alien/humanoid/runner/New()
	internal_organs += new /obj/item/organ/internal/alien/plasmavessel/runner
	//var/datum/reagents/R = new/datum/reagents(100)
	src.frozen = 1
	spawn (25)
		src.frozen = 0
	//reagents = R
	//R.my_atom = src
	//if(name == "alien runner")
	//	name = text("alien runner ([rand(1, 1000)])")
	//real_name = name
	growJelly()
	//verbs -= /atom/movable/verb/pull
	//verbs -= /mob/living/carbon/alien/humanoid/verb/plant
	//var/matrix/M = matrix()
	//M.Scale(1.15,1.1)
	//src.transform = M
	//pixel_y = 3
	..()

/mob/living/carbon/alien/humanoid/runner/handle_hud_icons_health()
	if (healths)
		if (stat != 2)
			switch(health)
				if(100 to INFINITY)
					healths.icon_state = "health0"
				if(80 to 100)
					healths.icon_state = "health1"
				if(60 to 80)
					healths.icon_state = "health2"
				if(40 to 60)
					healths.icon_state = "health3"
				if(20 to 40)
					healths.icon_state = "health4"
				if(0 to 20)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

/mob/living/carbon/alien/humanoid/runner/verb/evolve2() // -- TLE
	set name = "Evolve (Jelly)"
	set desc = "Evolve into a Warrior"
	set category = "Alien"
	if(!hivemind_check(psychiccost))
		src << "\red Your queen's psychic strength is not powerful enough for you to evolve further."
		return
	if(!canEvolve())
		if(hasJelly)
			src << "You are not ready to evolve yet"
		else
			src << "You need a mature royal jelly to evolve"
		return
	if(src.stat != CONSCIOUS)
		src << "You are unable to do that now."
		return
	if(health<maxHealth)
		src << "\red You are too hurt to Evolve."
		return
	src << "\blue <b>You are growing into a Warrior!</b>"

	var/mob/living/carbon/alien/humanoid/new_xeno

	new_xeno = new /mob/living/carbon/alien/humanoid/hunter(loc)
	src << "\green You begin to evolve!"

	for(var/mob/O in viewers(src, null))
		O.show_message(text("\green <B>[src] begins to twist and contort!</B>"), 1)
	if(mind)	mind.transfer_to(new_xeno)

	del(src)


	return

/mob/living/carbon/alien/humanoid/runner/ClickOn(var/atom/A, params)
	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		pounce()
		return
	..()

/mob/living/carbon/alien/humanoid/runner/proc/pounce()
	if(usedpounce)
		src << "<span class='noticealien'>We must wait before pouncing again..</span>"
		return

	var/targets[] = list()
	for(var/mob/living/carbon/human/M in oview())
		if(M.stat)	continue//Doesn't target corpses or paralyzed persons.
		targets.Add(M)

	if(targets.len)
		var/mob/living/carbon/human/target=pick(targets)
		var/atom/targloc = get_turf(target)
		if (!targloc || !istype(targloc, /turf) || get_dist(src.loc,targloc)>=3)
			src << "<span class='noticealien'>We cannot reach our prey!</span>"
			return

		if(src.weakened >= 1 || src.paralysis >= 1 || src.stunned >= 1)
			src << "<span class='noticealien'>We cannot pounce if we are stunned..</span>"
			return

		if(usePlasma(25))
			src.usedpounce = 1
			visible_message("<span class='userdanger'>[src] pounces on [target]!</span>")
			if(src.m_intent == "walk")
				src.m_intent = "run"
				src.hud_used.move_intent.icon_state = "running"
			src.loc = targloc

			if(target.r_hand && istype(target.r_hand, /obj/item/weapon/shield/riot) || target.l_hand && istype(target.l_hand, /obj/item/weapon/shield/riot))
				if (prob(35))	// If the human has riot shield in his hand
					src.weakened = 5//Stun the fucker instead
					visible_message("<span class='userdanger'>[target] blocked [src] with his shield!</span>")
				else
					src.canmove = 0
					src.frozen = 1
					target.Weaken(2)
					spawn(15)
						src.frozen = 0
			else
				src.canmove = 0
				src.frozen = 1
				target.Weaken(3)

			spawn(15)
				src.frozen = 0
			spawn(50)
				src.usedpounce = 0
		else
			src << "<span class='noticealien'>We need more plasma.</span>"
	else
		src << "<span class='noticealien'>We sense no prey..</span>"

//Stops runners from pulling APOPHIS775 03JAN2015
/mob/living/carbon/alien/humanoid/runner/start_pulling(var/atom/movable/AM)
	src << "<span class='warning'>You don't have the dexterity to pull anything.</span>"
	return
