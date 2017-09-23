mob
	Test_Dummy
		icon = 'Male.dmi'
		attacking = 100000000000000000000000
		Mpowerlevel = 100


mob
	verb
		Attack()
			set category = "Skills"
			set hidden = 1
			if(src.attackCD>world.time)
				return
			if(src.guard)
				return
			var/mob/M = null
			for(var/mob/V in get_step(src,src.dir))
				M = V
				break
			if(!M)
				return
			//src.cooldown=(world.time+src.attackdelay)
			var/effect = null
			var/dmg = 0
			var/powerdmg = (M.powerlevel/(src.powerlevel+M.powerlevel))*0.10
			dmg = (src.str+(src.off*0.05)-M.end+(M.def*0.035))+powerdmg
			src.attackCD=(world.time+src.attackdelay)
			src.attacking = (world.time+(15*10))
			flick("Attack",src)
			var/wascountered=0
			var/wasblocked = 0
			world<<"Damage = [dmg]"
			if(M.dir==src.dir)
				dmg*=1.2
				world<<"Back hit, 20% damage bonus.([dmg])"
			wascountered = src.Counter_Attack(M,dmg)
			if(!wascountered)
				wasblocked = src.Block_Attack(M,dmg)
				//world<<"Block Damage = [wasblocked]"
			if(wascountered||wasblocked)//>0)
				dmg = wascountered+wasblocked
				world<<"Counter/Block Damage = [dmg]"
			if(dmg<0)
				dmg = 0
				world<<"Damage Too low, set to 0."
			if(prob(30)&&src.SuperSonicCheck(M))
				src.SuperSonicStart(M)
			var/mob/R = null
			var/mob/E = null
			if(wascountered)
				world<<"Counter Damage Delt = [dmg]"
				src.combat(dmg,0,M)
				R=M
				E=src
			else
				world<<"Final Damage Delt = [dmg]."
				M.combat(dmg,0,src)
				R=src
				E=M
			if(prob(35))
				if(R.attacking>=world.time&&E.attacking>=world.time)
					R.Mstr+=R.sgain(0.7,R.modstr)
					R.Moff+=R.sgain(0.9,R.modoff)
					E.Mend+=E.sgain(0.8,E.modend)
					R.str=R.Mstr
					R.off=R.Moff
					E.end=R.Mend
			if(R.Mpowerlevel<(E.Mpowerlevel*leechAM))
				if(prob(5))
					var/PLgain = R.pgain((E.Mpowerlevel*leechAM))
					if(prob(70))
						PLgain = R.pgain((R.Mpowerlevel*0.10))
					R.Mpowerlevel+=PLgain
					R.powerlevel+=PLgain
					R<<"\green You gained [PLgain] powerlevel."
					E<<"[R] gained [PLgain] powerlevel from you."
				//world<<"[R] powerlevel is now [R.powerlevel]/[R.Mpowerlevel]."
				//world<<"Block Damage = [dmg]"
			//add armor thing here for those wearing armor that will absorb some of the damage
			//M.combat(dmg,0,src)
			//M.health-=dmg
			//death proc here







mob
	proc
		SuperSonicCheck(mob/M)
			if(src.attacking>=world.time&&M.attacking>=world.time)
				if(src.dir==NORTH&&M.dir==SOUTH)
					return 1
				if(src.dir==SOUTH&&M.dir==NORTH)
					return 1
				if(src.dir==EAST&&M.dir==WEST)
					return 1
				if(src.dir==WEST&&M.dir==EAST)
					return 1
				if(src.dir==NORTHEAST&&M.dir==SOUTHWEST)
					return 1
				if(src.dir==SOUTHWEST&&M.dir==NORTHEAST)
					return 1
				if(src.dir==NORTHWEST&&M.dir==SOUTHEAST)
					return 1
				if(src.dir==SOUTHEAST&&M.dir==NORTHWEST)
					return 1
			else
				return 0
		SuperSonicStart(mob/M)//,Times=2)
			if(src.powerlevel>=75000&&M.powerlevel>=75000)
				var/turf/L1=src.loc
				var/turf/L2=M.loc
				src.Frozen+=1
				M.Frozen+=1
				var/randx=rand(-5,5)
				var/randy=rand(-5,5)
				var/safe=0
				//sleep(2)
				if((src.x+randx)<world.maxx&&(M.x+randx)<world.maxx)
					if((src.x+randx)>0&&(M.x+randx)>0)
						safe+=1
				if((src.y+randy)<world.maxy&&(M.y+randy)<world.maxy)
					if((src.y+randy)>0&&(M.y+randy)>0)
						safe+=1
				if(safe>=2)
					src.loc=locate(src.x+randx,src.y+randy,src.z)
					M.loc=locate(M.x+randx,M.y+randy,M.z)
				sleep(2)
				if(prob(5))
					src.loc=L1
					M.loc=L2
				else
					if(src.x==0||M.x==0||src.y==0||M.y==0)
						src.loc=L1
						M.loc=L2
						world<<"Bug Report: Returning [src] and [M] to starting position due to sonic combat bug."
				src.Frozen-=1
				M.Frozen-=1



mob/proc/Counter_Attack(mob/M,damage)
	if(M.attacking>=world.time)
		var/countercan = ((M.spe+(M.def*0.70)+(M.off*0.30))/((src.spe+src.off+src.def+M.spe+M.def+M.off)*3))*100
		if(countercan>=100)
			countercan=99
		if(countercan<=0)
			countercan=1
		if(M.dir==src.dir)
			countercan = (countercan*0.10)
		if(prob(countercan))
			M.dir = get_dir(M,src)
			var/powerdmg = (src.powerlevel/(src.powerlevel+M.powerlevel))*0.10
			damage = (M.str+(M.off*0.05)-src.end+(src.def*0.035))+powerdmg
			flick("Attack",M)
			src << "\green [M] Counters your attack!"
			damage*=0.75
			if(countercan>85)
				M << "\green You easily counter [src]'s attack!"
				world << "\green [M] easily counters [src]'s attack!"
				damage*=0.55
			else if(countercan>35)
				M << "\green You counter [src]'s attack!"
				world << "\green [M] counters [src]'s attack!"
				damage*=0.35
			else
				M << "\green You barely counter [src]'s attack!"
				world << "\green [M] barely counters [src]'s attack!"
				damage*=0.15
			if(prob(30))
				M.Moff+=M.sgain(0.1,M.modoff)
				M.Mdef+=M.sgain(0.2,M.moddef)
				M.off=M.Moff
				M.def=M.Mdef
			return damage
		else
			return 0
	else
		return 0
mob/proc/Block_Attack(mob/M,damage)
	if(src.guard)
		return 0
	var/dmg = damage
	var/powerdmg = (M.powerlevel/(M.powerlevel+src.powerlevel))*0.10
	dmg = (src.str+(src.off*0.05)-M.end+(M.def*0.035))+powerdmg
	var/blockcan = ((M.spe+(M.off*0.15)+M.def)/(src.spe+src.off+M.spe+(M.off*0.10)+M.def))*100
	if(blockcan>=100)
		blockcan=99
	if(blockcan<=0)
		blockcan=1
	if(M.dir==src.dir)
		blockcan=0
	if(prob(blockcan))
		M.dir = get_dir(M,src)
		//flick("block",M)
		src << "\green [M] Blocks your attack!"
		M << "\green You Block [src]'s attack!"
		dmg = dmg-(src.end*2.5)
		if(prob(30))
			M.Mdef+=M.sgain(0.15,M.moddef)
			M.def=M.Mdef
			M.Mend+=M.sgain(0.15,M.modend)
			M.end=M.Mend
		return dmg
	else
		return 0






/*		SuperSonicStart(mob/M,Times=2)
			var/turf/L1=src.loc
			var/turf/L2=M.loc
			src.doing=1
			M.doing=1
			src.Frozen=1
			M.Frozen=1
			var/t=Times
			Repeat
			if(t)
				t-=1
				sleep(7)
				if(prob(50))
					spawn(1)
						flick("Attack",src)
						flick("IT",M)
						flick("IT",src)
						flick("Attack",M)
					if(src.x+5&&M.x+5<world.maxx)
						src.loc=locate(src.x+4,src.y,src.z)
						M.loc=locate(M.x+4,M.y,M.z)
					else
						if(src.y+5&&M.y+5<world.maxy)
							src.loc=locate(src.x,src.y+4,src.z)
							M.loc=locate(M.x,M.y+4,M.z)
				else
					spawn(1)
						flick("Attack",src)
						flick("IT",M)
						flick("IT",src)
						flick("Attack",M)
					if(src.y+5&&M.y+5<world.maxy)
						src.loc=locate(src.x,src.y+4,src.z)
						M.loc=locate(M.x,M.y+4,M.z)
					else
						if(src.x+5&&M.x+5<world.maxx)
							src.loc=locate(src.x+4,src.y,src.z)
							M.loc=locate(M.x+4,M.y,M.z)
				sleep(12)
				src.loc=L1
				M.loc=L2
				sleep(12)
				if(prob(50))
					spawn(1)
						flick("Attack",src)
						flick("IT",M)
						flick("IT",src)
						flick("Attack",M)
					if(src.x+5&&M.x+5<world.maxx)
						src.loc=locate(src.x+4,src.y,src.z)
						M.loc=locate(M.x+4,M.y,M.z)
					else
						if(src.y+5&&M.y+5<world.maxy)
							src.loc=locate(src.x,src.y+4,src.z)
							M.loc=locate(M.x,M.y+4,M.z)
				else
					spawn(1)
						flick("Attack",src)
						flick("IT",M)
						flick("IT",src)
						flick("Attack",M)
					if(src.y+5&&M.y+5<world.maxy)
						src.loc=locate(src.x,src.y+4,src.z)
						M.loc=locate(M.x,M.y+4,M.z)
					else
						if(src.x+5&&M.x+5<world.maxx)
							src.loc=locate(src.x+4,src.y,src.z)
							M.loc=locate(M.x+4,M.y,M.z)
				sleep(12)
				src.loc=L1
				M.loc=L2
				src.doing=0
				M.doing=0
				src.frozen=0
				M.frozen=0
				if(t)
					goto Repeat
				else
					src.doing=0
					M.doing=0
					src.frozen=0
					M.frozen=0
			else
				src.doing=0
				M.doing=0
				src.frozen=0
				M.frozen=0
*/

/*
mob
	var
		combolimit=2
		combospeed=20000
		tmp
			combocount=0
			lastkick="1"
			lastpunch="1"
			lastpk=""
			incombo=0
			thrown=0
			throwing=0
			attacking=0
			attacker=""
			spar=0
	proc
		RemoveArmor(var/mob/M,var/D)
			if(prob(src.armorblock))
				src << "\blue Your armor absorbs some of [M]'s attack!"
				M << "\blue [src]'s armor absorbs some of your attack!"
				src.powerlevel -= D
				for(var/obj/Equipment/Armor/A in src)
					A.condition -= D
					if(A.condition <= 0)
						src << "\blue Your armor has been destroyed!"
						src.overlays -= A
						src.armor_eq = 0
						src.armor = 0
						src.armorblock=0
						del(A)
		Thrown(var/mob/T)
			if(!src)return
			if(!T)return
			var/fail=70
			if(usr.unarmed_skill>3000)
				fail=60
			if(usr.unarmed_skill>5000)
				fail=50
			if(usr.unarmed_skill>7000)
				fail=40
			if(usr.unarmed_skill>9000)
				fail=30
			if(usr.unarmed_skill>10000)
				fail=20
			if(usr.unarmed_skill>12000)
				fail=10
			if(usr.unarmed_skill>14000)
				fail=5
			if(prob(fail))
				T<<"\blue You failed to throw [src]!"
				return
			var/atk=T.strength+T.powerlevel*0.05+src.unarmed_skill
			var/def=src.defence+src.powerlevel*0.05+src.ki*0.05+src.unarmed_skill*0.8
			if(atk<def)
				T<<"\blue [src] overpowers your throw!"
				return
			T<<"\blue You Threw [src]!"
			src<<"\blue [T] Threw you!"
			var/D=1
			if(atk>def*2)
				D=2
			if(atk>def*3)
				D=3
			if(atk>def*4)
				D=4
			if(atk>def*5)
				D=5
			if(atk>def*6)
				D=6
			if(atk>def*7)
				D=7
			if(atk>def*8)
				D=8
			if(atk>def*9)
				D=9
			if(atk>def*10)
				D=10
			src.icon_state="thrown"
			src.thrown=1
			src.density=0
			src.boxing=0
			src.dualtrain=0
			src.rest=0
			var/DT=T.dir
			var/PT=atk-def
			while(D)
				D-=1
				for(var/atom/A in get_step(src,DT))
					if(istype(A,/obj/Buildings/Door1))
						var/obj/Buildings/Door1/DO=A
						DO.OpenDoor()
					if(istype(A,/obj/Buildings/Door2))
						var/obj/Buildings/Door2/DO=A
						DO.OpenDoor()
					if(A.density)
						src.powerlevel-=PT*(D/10)
						spawn(0)src.KO()
						if(istype(A,/mob))
							var/mob/M=A
							if(M.pk&&!M.safe)
								M.powerlevel-=PT*(D/10)
								spawn(0)M.KO()
						if(istype(A,/obj/Buildings))
							var/obj/O=A
							O.hp-=PT*(D/10)
							spawn(0)O.DestroyIt()
					sleep(0)
					if(A.density)
						src.thrown=0
						src.density=1
						src.icon_state=""
						src.boxing=0
						src.dualtrain=0
						D=0
						break
				step(src,DT)
				if(D<=0)
					switch(DT)
						if(NORTH)
							src.dir=SOUTH
						if(SOUTH)
							src.dir=NORTH
						if(EAST)
							src.dir=WEST
						if(WEST)
							src.dir=EAST
						if(NORTHEAST)
							src.dir=SOUTHWEST
						if(NORTHWEST)
							src.dir=SOUTHEAST
						if(SOUTHEAST)
							src.dir=NORTHWEST
						if(SOUTHWEST)
							src.dir=NORTHEAST
					src.thrown=0
					src.density=1
					src.icon_state=""
					src.boxing=0
					src.dualtrain=0
					break
				sleep(1)
	PC
		verb
			Throw()
				set category = "Combat"
				if(!src.pk)
					src << "You are not a Combatant!"
					return
				if(src.doing)
					return
				if(src.throwing)
					return
				if(src.dead)
					src << "You are dead."
					return
				if(src.FuseFollower)
					return
				if(src.cooldown)
					return
				if(src.KO)
					return
				if(src.attack_lock)
					return
				spawn(5+(src.speed/1000))
					src.throwing=0
				var/turf/T=get_step(src,src.dir)
				for(var/mob/M in T)
					if(istype(M,/mob/PC))
						for(var/turf/Floors/Safe_Zone/S in view(8))
							src << "[M] is in a Safe Zone!"
							return
					if(!M)
						return
					if(!M in T)
						return
					if(M.FuseFollower)
						continue
					if(M.safe)
						src << "[M] is safe and cannot be attacked."
						continue
					if(M.dead)
						src << "[M] is dead."
						continue
					if(!M.pk)
						src << "[M] is not a Combatant!"
						continue
					if(ismob(M)&&M.loc)
						M.Thrown(src)
		/*	Punch()
				set category = "Combat"
				if(!src.pk)
					src << "You are not a Combatant!"
					return
				if(src.KO)
					return
				if(src.doing)
					return
				if(src.dead)
					src << "You are dead."
					return
				if(src.FuseFollower)
					return
				if(src.cooldown)
					return
				if(src.attack_lock)
					return
				src.cooldown=1
				spawn((src.speed/1000)+2)
					src.cooldown=0
				flick("attack",src)
				for(var/mob/M in get_step(src,src.dir))
					if(istype(M,/mob/PC))
						for(var/turf/Floors/Safe_Zone/S in view(8))
							if(S in view(8))
								src << "[M] is in a Safe Zone!"
								return
					if(!M)
						return
					if(!M in get_step(src,src.dir))
						return
					if(M.FuseFollower)
						continue
					if(M.safe)
						src << "[M] is safe and cannot be attacked."
						continue
					if(M.dead)
						src << "[M] is dead."
						continue
					if(M.KO)
						src << "[M] is already K.O!"
						continue
					if(!M.pk)
						src << "[M] is not a Combatant!"
						continue
					var/attackpower=(src.strength+((src.powerlevel+(src.unarmed_skill*10))*0.1))+(src.unarmed_skill/1.5)
					var/defensepower=(M.defence+((M.powerlevel+(M.unarmed_skill*10))*0.1))+(M.unarmed_skill/1.5)
					var/damage=attackpower-defensepower
					if(src.spar)
						attackpower=(src.strength/500+((src.powerlevel/500+(src.unarmed_skill*10))*0.1))+(src.unarmed_skill/1.5)
						defensepower=(M.defence+((M.powerlevel+(M.unarmed_skill*10))*0.1))+(M.unarmed_skill/1.5)
						damage=attackpower-defensepower
					if(damage<=0)
						damage=1
					src.attacking=1
					spawn(4)src.attacking=0
					if(src.attacker==M&&M.spar)
						src.exp+=7
					M.attacker=src
					spawn(20)
						if(M)
							M.attacker=""
					if(M.armorblock)
						if(prob(M.armorblock))
							if(M.Counter_Attack(src,M.strength,src.defence)==TRUE)
								return
							else
								if(M.Block_Attack(src,src.strength,M.defence)==TRUE)
									return
							M.RemoveArmor(src,damage/5)
							M.KO()
					if(prob(1+(src.critical/5)))
						M << "\red [src] Punches you!"
						src << "\red You Punch [M]!"
						M.powerlevel -= round(damage * 2)
						M.KO()
						spawn(0)M.Thrown(src)
					else
						if(M.Counter_Attack(src,M.strength,src.defence)==TRUE)
							return
						else
							if(M.Block_Attack(src,src.strength,M.defence)==TRUE)
								return
						M << "\red [src] Punches you!"
						src << "\red You Punch [M]!"
						M.powerlevel -= round(damage)
						M.KO()*/
	/*		Kick()
				set category = "Combat"
				if(!src.pk)
					src << "You are not a Combatant!"
					return
				if(src.doing)
					return
				if(src.dead)
					src << "You are dead."
					return
				if(src.FuseFollower)
					return
				if(src.cooldown)
					return
				if(src.attack_lock)
					return
				src.cooldown=1
				spawn(3)
					src.incombo-=1
					if(src.incombo<0)
						src.incombo=0
						src.combocount=0
				if(src.lastpunch=="2")
					flick("kick1",src)
					src.lastpunch="1"
				else
					flick("kick2",src)
					src.lastpunch="2"
				src.incombo+=1
				if(src.incombo>src.combolimit)
					src.incombo=src.combolimit
				if(!src.lastpk)
					src.lastpk="p"
				if(src.lastpk=="p")
					if(src.combocount<src.combolimit)
						src.combocount+=1
						spawn(src.combospeed/10000)
							src.cooldown=0
					else
						spawn(10+(src.speed/1000))
							src.cooldown=0
				else
					spawn(10+(src.speed/1000))
						src.cooldown=0
				src.lastpk="k"
				for(var/mob/M in get_step(src,src.dir))
					if(M.type == /mob/PC)
						var/turf/T=M.loc
						for(var/turf/Floors/Safe_Zone/S in T)
							src << "Safe Zone!"
							return
					if(!M)
						continue
					if(M.FuseFollower)
						continue
					if(M.safe)
						src << "[M] is safe and cannot be attacked."
						continue
					if(M.dead)
						src << "[M] is dead."
						continue
					if(M.KO)
						src << "[M] is already K.O!"
						continue
					if(!M.pk)
						src << "[M] is not a Combatant!"
						continue
					var/attackpower=(src.strength+((src.powerlevel+(src.unarmed_skill*10))*0.1))+(src.unarmed_skill/1.5)
					var/defensepower=(M.defence+((M.powerlevel+(M.unarmed_skill*10))*0.1))+(M.unarmed_skill/1.5)
					var/damage=attackpower-defensepower
					if(src.spar)
						attackpower=(src.strength/500+((src.powerlevel/500+(src.unarmed_skill*10))*0.1))+(src.unarmed_skill/1.5)
						defensepower=(M.defence+((M.powerlevel+(M.unarmed_skill*10))*0.1))+(M.unarmed_skill/1.5)
						damage=attackpower-defensepower
					if(damage<=0)
						damage=1
					if(damage>M.powerlevel_max*5)
						damage=M.powerlevel_max*5
					src.attacking=1
					spawn(4)src.attacking=0
					if(src.attacker==M&&M.spar)
						src.exp+=7
					M.attacker=src
					spawn(20)
						if(M)
							M.attacker=""
					if(M.armorblock)
						if(prob(M.armorblock))
							if(M.Counter_Attack(src,M.strength,src.defence)==TRUE)
								return
							else
								if(M.Block_Attack(src,src.strength,M.defence)==TRUE)
									return
							M.RemoveArmor(src,damage/5)
							M.KO()
					if(prob(1+(src.critical/5)))
						M << "\red [src] Kicks you!"
						src << "\red You Kick [M]!"
						M.powerlevel -= round(damage * 2)
						M.KO()
						spawn(0)M.Thrown(src)
					else
						if(M.Counter_Attack(src,M.strength,src.defence)==TRUE)
							return
						else
							if(M.Block_Attack(src,src.strength,M.defence)==TRUE)
								return
						M << "\red [src] Kicks you!"
						src << "\red You Kick [M]!"
						M.powerlevel -= round(damage)
						M.KO()*/



























	/*



			PunchLOL()
				set category = "Combat"
				if(!src.pk)
					src << "You are not a Combatant!"
					return
				if(src.doing)
					return
				if(src.dead)
					src << "You are dead."
					return
				if(src.FuseFollower)
					return
				if(src.cooldown)
					return
				if(src.attack_lock)
					return
				src.cooldown=1
				spawn(4)
					src.incombo-=1
					if(src.incombo<0)
						src.incombo=0
				if(src.lastpunch=="2")
					flick("punch1",src)
					src.lastpunch="1"
				else
					flick("punch2",src)
					src.lastpunch="2"
				src.punchcount+=1
				src.incombo+=1
				if(src.incombo>3)
					src.incombo=3
				if(src.punchcount<3)
					if(src.incombo)
						if(src.kickcount+src.punchcount<src.combolimit)
							spawn(src.combospeed/10000)
								src.punchcount-=1
								if(src.punchcount<1)
									src.punchcount=1
								src.cooldown=0
								src.icon_state=""
						else
							src.cooldown=1
							spawn(15)
								src.punchcount-=1
								if(src.punchcount<1)
									src.punchcount=1
								src.cooldown=0
								src.icon_state=""
					else
						src.cooldown=1
						spawn(15)
							src.punchcount-=1
							if(src.punchcount<1)
								src.punchcount=1
							src.cooldown=0
							src.icon_state=""
				else
					src.cooldown=1
					spawn(15)
						src.punchcount-=1
						if(src.punchcount<1)
							src.punchcount=1
						src.icon_state=""
						src.cooldown=0
				for(var/mob/M in get_step(src,src.dir))
					if(M.type == /mob/PC)
						var/turf/T=M.loc
						for(var/turf/Floors/Safe_Zone/S in T)
							src << "Safe Zone!"
							return
					if(!M)
						continue
					if(M.FuseFollower)
						continue
					if(M.safe)
						src << "[M] is safe and cannot be attacked."
						continue
					if(M.dead)
						src << "[M] is dead."
						continue
					if(M.KO)
						src << "[M] is already K.O!"
						continue
					if(!M.pk)
						src << "[M] is not a Combatant!"
						continue
					var/attackpower=(src.strength+((src.powerlevel+(src.unarmed_skill*10))*0.1))+(src.unarmed_skill/1.5)
					var/defensepower=(M.defence+((M.powerlevel+(M.unarmed_skill*10))*0.1))+(M.unarmed_skill/1.5)
					var/damage=attackpower-defensepower
					if(src.spar)
						attackpower=(src.strength/500+((src.powerlevel/500+(src.unarmed_skill*10))*0.1))+(src.unarmed_skill/1.5)
						defensepower=(M.defence+((M.powerlevel+(M.unarmed_skill*10))*0.1))+(M.unarmed_skill/1.5)
						damage=attackpower-defensepower
					if(damage<=0)
						damage=1
					if(damage>=M.powerlevel*0.2&&damage<M.powerlevel*0.4)
						damage*=0.2
					if(damage>=M.powerlevel*0.4&&damage<M.powerlevel*0.6)
						damage*=0.4
					if(damage>=M.powerlevel*0.6&&damage<M.powerlevel*0.8)
						damage*=0.5
					if(damage>=M.powerlevel*0.8&&damage<M.powerlevel)
						damage*=0.7
					if(damage>=M.powerlevel)
						damage*=0.9
					src.attacking=1
					spawn(4)src.attacking=0
					if(src.attacker==M&&M.spar)
						src.exp+=7
					M.attacker=src
					spawn(20)
						if(M)
							M.attacker=""
					if(M.armorblock)
						if(prob(M.armorblock))
							flick("attack",src)
							if(M.Counter_Attack(src,M.strength,src.defence)==TRUE)
								return
							else
								if(M.Block_Attack(src,src.strength,M.defence)==TRUE)
									return
							M << "\blue Your armor absorbs some of [src]'s attack!"
							src << "\blue [M]'s armor absorbs some of your attack!"
							M.powerlevel -= damage/5
							for(var/obj/Equipment/Armor/A in M.contents)
								A.condition -= damage/5
								if(A.condition <= 0)
									M << "\blue Your armor has been destroyed!"
									M.overlays -= A
									M.armor_eq = 0
									M.armor = 0
									M.armorblock=0
									del(A)
							M.KO()
							src.cooldown = 1
							spawn((src.speed/1000)*2)src.cooldown = 0
					if(prob(1+(src.critical/5)))
						flick("attack",src)
						M << "\red [src] Attacks you and sends you flying back!"
						src << "\red You Attack [M] with a Critical Hit!"
						var/FallDir = get_dir(src,M)
						src.dir = FallDir
						step(M,FallDir)
						switch(FallDir)
							if(NORTH)M.dir = SOUTH
							if(NORTHWEST)M.dir = SOUTHEAST
							if(WEST)M.dir = EAST
							if(SOUTHWEST)M.dir = NORTHEAST
							if(SOUTH)M.dir = NORTH
							if(SOUTHEAST)M.dir = NORTHWEST
							if(EAST)M.dir = WEST
							if(NORTHEAST)M.dir = SOUTHWEST
						M.frozen-=1
						spawn(10)
							M.frozen+=1
						M.powerlevel -= round(damage * 2)
						M.KO()
						src.cooldown = 1
						spawn((src.speed/1000)*2)src.cooldown = 0
					else
						flick("attack",src)
						if(M.Counter_Attack(src,M.strength,src.defence)==TRUE)
							return
						else
							if(M.Block_Attack(src,src.strength,M.defence)==TRUE)
								return
						M << "\red [src] Attacks you!"
						src << "\red You Attack [M]!"
						M.powerlevel -= round(damage)
						M.KO()
						src.cooldown = 1
						spawn((src.speed/1000)*2)src.cooldown = 0
			Kick()
				set category = "Combat"
				if(!src.pk)
					src << "You are not a Combatant!"
					return
				if(src.doing)
					return
				if(src.dead)
					src << "You are dead."
					return
				if(src.FuseFollower)
					return
				if(src.cooldown)
					return
				if(src.attack_lock)
					return
				src.cooldown=1
				spawn(4)
					src.incombo-=1
					if(src.incombo<0)
						src.incombo=0
				if(src.lastkick=="2")
					src.icon_state="kick1"
					src.lastkick="1"
				else
					src.icon_state="kick2"
					src.lastkick="2"
				src.kickcount+=1
				src.incombo+=1
				if(src.incombo>3)
					src.incombo=3
				if(src.kickcount<3)
					if(src.incombo)
						if(src.kickcount+src.punchcount<src.combolimit)
							src.cooldown=1
							spawn(src.combospeed/10000)
								src.kickcount-=1
								if(src.kickcount<1)
									src.kickcount=1
								src.cooldown=0
								src.icon_state=""
						else
							src.cooldown=1
							spawn(15)
								src.kickcount-=1
								if(src.kickcount<1)
									src.kickcount=1
								src.cooldown=0
								src.icon_state=""
					else
						src.cooldown=1
						spawn(15)
							src.kickcount-=1
							if(src.kickcount<1)
								src.kickcount=1
							src.cooldown=0
							src.icon_state=""
				else
					src.cooldown=1
					spawn(15)
						src.kickcount-=1
						if(src.kickcount<1)
							src.kickcount=1
						src.icon_state=""
						src.cooldown=0
				for(var/mob/M in get_step(src,src.dir))
					if(M.type == /mob/PC)
						var/turf/T=M.loc
						for(var/turf/Floors/Safe_Zone/S in T)
							src << "Safe Zone!"
							return
					if(!M)
						continue
					if(M.FuseFollower)
						continue
					if(M.safe)
						src << "[M] is safe and cannot be attacked."
						continue
					if(M.dead)
						src << "[M] is dead."
						continue
					if(M.KO)
						src << "[M] is already K.O!"
						continue
					if(!M.pk)
						src << "[M] is not a Combatant!"
						continue
					var/attackpower=(src.strength+((src.powerlevel+(src.unarmed_skill*10))*0.1))+(src.unarmed_skill/1.5)
					var/defensepower=(M.defence+((M.powerlevel+(M.unarmed_skill*10))*0.1))+(M.unarmed_skill/1.5)
					var/damage=attackpower-defensepower
					if(src.spar)
						attackpower=(src.strength/500+((src.powerlevel/500+(src.unarmed_skill*10))*0.1))+(src.unarmed_skill/1.5)
						defensepower=(M.defence+((M.powerlevel+(M.unarmed_skill*10))*0.1))+(M.unarmed_skill/1.5)
						damage=attackpower-defensepower
					if(damage<=0)
						damage=1
					if(damage>=M.powerlevel*0.2&&damage<M.powerlevel*0.4)
						damage*=0.2
					if(damage>=M.powerlevel*0.4&&damage<M.powerlevel*0.6)
						damage*=0.4
					if(damage>=M.powerlevel*0.6&&damage<M.powerlevel*0.8)
						damage*=0.5
					if(damage>=M.powerlevel*0.8&&damage<M.powerlevel)
						damage*=0.7
					if(damage>=M.powerlevel)
						damage*=0.9
					src.attacking=1
					spawn(4)src.attacking=0
					if(src.attacker==M&&M.spar)
						src.exp+=7
					M.attacker=src
					spawn(20)
						if(M)
							M.attacker=""
					if(M.armorblock)
						if(prob(M.armorblock))
							flick("attack",src)
							if(M.Counter_Attack(src,M.strength,src.defence)==TRUE)
								return
							else
								if(M.Block_Attack(src,src.strength,M.defence)==TRUE)
									return
							M << "\blue Your armor absorbs some of [src]'s attack!"
							src << "\blue [M]'s armor absorbs some of your attack!"
							M.powerlevel -= damage/5
							for(var/obj/Equipment/Armor/A in M.contents)
								A.condition -= damage/5
								if(A.condition <= 0)
									M << "\blue Your armor has been destroyed!"
									M.overlays -= A
									M.armor_eq = 0
									M.armor = 0
									M.armorblock=0
									del(A)
							M.KO()
							src.cooldown = 1
							spawn((src.speed/1000)*2)src.cooldown = 0
					if(prob(1+(src.critical/5)))
						flick("attack",src)
						M << "\red [src] Attacks you and sends you flying back!"
						src << "\red You Attack [M] with a Critical Hit!"
						var/FallDir = get_dir(src,M)
						src.dir = FallDir
						step(M,FallDir)
						switch(FallDir)
							if(NORTH)M.dir = SOUTH
							if(NORTHWEST)M.dir = SOUTHEAST
							if(WEST)M.dir = EAST
							if(SOUTHWEST)M.dir = NORTHEAST
							if(SOUTH)M.dir = NORTH
							if(SOUTHEAST)M.dir = NORTHWEST
							if(EAST)M.dir = WEST
							if(NORTHEAST)M.dir = SOUTHWEST
						M.frozen-=1
						spawn(10)
							M.frozen+=1
						M.powerlevel -= round(damage * 2)
						M.KO()
						src.cooldown = 1
						spawn((src.speed/1000)*2)src.cooldown = 0
					else
						flick("attack",src)
						if(M.Counter_Attack(src,M.strength,src.defence)==TRUE)
							return
						else
							if(M.Block_Attack(src,src.strength,M.defence)==TRUE)
								return
						M << "\red [src] Attacks you!"
						src << "\red You Attack [M]!"
						M.powerlevel -= round(damage)
						M.KO()
						src.cooldown = 1
						spawn((src.speed/1000)*2)src.cooldown = 0








*/
















			Spar()
				set category = "Combat"
				if(src.spam_delay)
					src<<"You must wait a moment."
					return
				src.spam_delay=1
				if(src.spar)
					src.spar=0
					view(8)<<"\white [src] is no longer in a sparring stance."
					spawn(25)src.spam_delay=0
				else
					src.spar=1
					view(8)<<"\white [src] is now in a sparring stance."
					spawn(25)src.spam_delay=0
			AttackNormal(mob/M in get_step(src,src.dir))
				set category = "Combat"
				set name = "Punch"
				if(istype(M,/mob))
					if(M in get_step(src,src.dir))
						if(!M)
							return
						if(src.doing || src.KO)
							return
						if(src.dead)
							src << "You are dead"
							return
						if(M.FuseFollower)
							return
						if(src.FuseFollower)
							return
						if(M.safe)
							src << "[M] is safe and cannot be attacked"
							return
						if(M.KO)
							src << "[M] is already K.O!"
							return
						if(src.cooldown)
							return
						if(src.attack_lock)
							return
						var/attackpower=(src.strength+((src.powerlevel+(src.unarmed_skill*10))*0.1))+(src.unarmed_skill/1.5)
						var/defensepower=(M.defence+((M.powerlevel+(M.unarmed_skill*10))*0.1))+(M.unarmed_skill/1.5)
						var/damage=attackpower-defensepower
						if(src.spar)
							attackpower=(src.strength/500+((src.powerlevel/500+(src.unarmed_skill*10))*0.1))+(src.unarmed_skill/1.5)
							defensepower=(M.defence+((M.powerlevel+(M.unarmed_skill*10))*0.1))+(M.unarmed_skill/1.5)
							damage=attackpower-defensepower
						if(damage<=0)
							damage=1
						if(damage>=M.powerlevel*0.2&&damage<M.powerlevel*0.4)
							damage*=0.2
						if(damage>=M.powerlevel*0.4&&damage<M.powerlevel*0.6)
							damage*=0.4
						if(damage>=M.powerlevel*0.6&&damage<M.powerlevel*0.8)
							damage*=0.5
						if(damage>=M.powerlevel*0.8&&damage<M.powerlevel)
							damage*=0.7
						if(damage>=M.powerlevel)
							damage*=0.9
						if(M.type == /mob/PC)
							for(var/turf/Floors/Safe_Zone/S in view(8))
								if(S in view(8))
									src << "[M] is in a Safe Zone!"
									return
							if(src.safe)
								src << "You cannot attack at the moment."
								return
							if(!src.pk)
								src << "You are not a Combatant!"
								return
							if(!M.pk)
								src << "[M] is not a Combatant!"
								return
							if(M.dead)
								src << "[M] is Dead!"
								return
							if(!M)return
							src.attacking=1
							spawn(4)src.attacking=0
							if(src.SuperSonicCheck(M)==TRUE)
								src.SuperSonicStart(M)
								return
							if(src.attacker==M&&M.spar)
								src.exp+=7
							M.attacker=src
							spawn(20)
								if(M)
									M.attacker=""
							if(M.armorblock)
								if(prob(M.armorblock))
									flick("attack",src)
									if(M.Counter_Attack(src,M.strength,src.defence)==TRUE)
										return
									else
										if(M.Block_Attack(src,src.strength,M.defence)==TRUE)
											return
									M << "\blue Your armor absorbs some of [src]'s attack!"
									src << "\blue [M]'s armor absorbs some of your attack!"
									M.powerlevel -= damage/5
									for(var/obj/Equipment/Armor/A in M.contents)
										A.condition -= damage/5
										if(A.condition <= 0)
											M << "\blue Your armor has been destroyed!"
											M.overlays -= A
											M.armor_eq = 0
											M.armor = 0
											M.armorblock=0
											del(A)
									M.KO()
									src.cooldown = 1
									spawn((src.speed/1000)*2)src.cooldown = 0
							if(prob(1+(src.critical/5)))
								flick("attack",src)
								M << "\red [src] Attacks you and sends you flying back!"
								src << "\red You Attack [M] with a Critical Hit!"
								var/FallDir = get_dir(src,M)
								src.dir = FallDir
								step(M,FallDir)
								switch(FallDir)
									if(NORTH)M.dir = SOUTH
									if(NORTHWEST)M.dir = SOUTHEAST
									if(WEST)M.dir = EAST
									if(SOUTHWEST)M.dir = NORTHEAST
									if(SOUTH)M.dir = NORTH
									if(SOUTHEAST)M.dir = NORTHWEST
									if(EAST)M.dir = WEST
									if(NORTHEAST)M.dir = SOUTHWEST
								M.frozen-=1
								spawn(10)
									M.frozen+=1
								M.powerlevel -= round(damage * 2)
								M.KO()
								src.cooldown = 1
								spawn((src.speed/1000)*2)src.cooldown = 0
							else
								flick("attack",src)
								if(M.Counter_Attack(src,M.strength,src.defence)==TRUE)
									return
								else
									if(M.Block_Attack(src,src.strength,M.defence)==TRUE)
										return
								M << "\red [src] Attacks you!"
								src << "\red You Attack [M]!"
								M.powerlevel -= round(damage)
								M.KO()
								src.cooldown = 1
								spawn((src.speed/1000)*2)src.cooldown = 0
						else
							flick("attack",src)
							M << "\red [src] Attacks [M]!"
							src << "\red You Attack [M]!"
							M.powerlevel -= round(damage)
							M.KO()
							src.cooldown = 1
							spawn((src.speed/1000)*2)src.cooldown = 0
	proc
		SuperSonicCheck(mob/M)
			if(src.attacking&&M.attacking)
				if(src.dir==NORTH&&M.dir==SOUTH)
					return TRUE
				if(src.dir==SOUTH&&M.dir==NORTH)
					return TRUE
				if(src.dir==EAST&&M.dir==WEST)
					return TRUE
				if(src.dir==WEST&&M.dir==EAST)
					return TRUE
				if(src.dir==NORTHEAST&&M.dir==SOUTHWEST)
					return TRUE
				if(src.dir==SOUTHWEST&&M.dir==NORTHEAST)
					return TRUE
				if(src.dir==NORTHWEST&&M.dir==SOUTHEAST)
					return TRUE
				if(src.dir==SOUTHEAST&&M.dir==NORTHWEST)
					return TRUE
			else
				return FALSE
		SuperSonicStart(mob/M,Times=2)
			var/turf/L1=src.loc
			var/turf/L2=M.loc
			src.doing=1
			M.doing=1
			src.frozen=1
			M.frozen=1
			var/t=Times
			Repeat
			if(t)
				t-=1
				sleep(7)
				if(prob(50))
					spawn(1)
						flick("attack",src)
						flick("IT",M)
						flick("IT",src)
						flick("attack",M)
					if(src.x+5&&M.x+5<world.maxx)
						src.loc=locate(src.x+4,src.y,src.z)
						M.loc=locate(M.x+4,M.y,M.z)
					else
						if(src.y+5&&M.y+5<world.maxy)
							src.loc=locate(src.x,src.y+4,src.z)
							M.loc=locate(M.x,M.y+4,M.z)
				else
					spawn(1)
						flick("attack",src)
						flick("IT",M)
						flick("IT",src)
						flick("attack",M)
					if(src.y+5&&M.y+5<world.maxy)
						src.loc=locate(src.x,src.y+4,src.z)
						M.loc=locate(M.x,M.y+4,M.z)
					else
						if(src.x+5&&M.x+5<world.maxx)
							src.loc=locate(src.x+4,src.y,src.z)
							M.loc=locate(M.x+4,M.y,M.z)
				sleep(12)
				src.loc=L1
				M.loc=L2
				sleep(12)
				if(prob(50))
					spawn(1)
						flick("attack",src)
						flick("IT",M)
						flick("IT",src)
						flick("attack",M)
					if(src.x+5&&M.x+5<world.maxx)
						src.loc=locate(src.x+4,src.y,src.z)
						M.loc=locate(M.x+4,M.y,M.z)
					else
						if(src.y+5&&M.y+5<world.maxy)
							src.loc=locate(src.x,src.y+4,src.z)
							M.loc=locate(M.x,M.y+4,M.z)
				else
					spawn(1)
						flick("attack",src)
						flick("IT",M)
						flick("IT",src)
						flick("attack",M)
					if(src.y+5&&M.y+5<world.maxy)
						src.loc=locate(src.x,src.y+4,src.z)
						M.loc=locate(M.x,M.y+4,M.z)
					else
						if(src.x+5&&M.x+5<world.maxx)
							src.loc=locate(src.x+4,src.y,src.z)
							M.loc=locate(M.x+4,M.y,M.z)
				sleep(12)
				src.loc=L1
				M.loc=L2
				src.doing=0
				M.doing=0
				src.frozen=0
				M.frozen=0
				if(t)
					goto Repeat
				else
					src.doing=0
					M.doing=0
					src.frozen=0
					M.frozen=0
			else
				src.doing=0
				M.doing=0
				src.frozen=0
				M.frozen=0


mob/proc/Deflect_Attack(mob/M)
	if(src.deflecting)
		return FALSE
	if(src.doing)
		return FALSE
	if(prob(src.reflect/5))
		if(M.dir==src.dir)
			return FALSE
		src.deflecting=1
		spawn(src.speed+4)src.deflecting=0
		flick("attack",src)
		M << "\green [src] Deflects your attack!"
		src << "\green You Deflect [M]'s attack!"
		return TRUE
	else
		return FALSE
mob/proc/Dodge_Attack(mob/M)
	if(src.dodging)
		return
	if(src.doing)
		return
	if(prob(src.dodge/5))
		src.dodging=1
		spawn(src.speed+4)src.dodging=0
		flick("IT",src)
		M << "\green [src] Dodges your attack!"
		src << "\green You Dodge [M]'s attack!"
		return TRUE
	else
		return FALSE





*/