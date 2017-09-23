mob
	proc
		combat(amm,blood,who,effect)//called by the person taking the damage
			if(who)
				if(!src)
					return
				spawn(1)
					var/bonus=effect
					var/mob/F=who
					var/TR=null
					var/damage = amm
					if(F.owner!=null)
						TR=F.owner
					else
						TR=who
					var/mob/O = TR
					if(!O)
						return
					/*if(O.guard)
						damage-=(O.end*5)*/
					if(damage<0)
						damage=0
					src.health-=damage
					if(src.client)
						winset(src,"Bars.Health","value=[(src.health/src.Mhealth)*100]")
					//O.Death(O)