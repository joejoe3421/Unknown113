obj
	var
		reusable=0
	craft
		New()
			..()
			spawn(rand(30,50))
				if(src&&src.lightdistance&&src.luminosity)
					src.burn()
		var
			fuel = 0
			tmp/active=0
			lightdistance=0
			fuelcap=0
		proc
			burn()
				if(src.active)
					animate(src,luminosity=((src.fuel/src.fuelcap)*src.lightdistance), time = 3)//src.luminosity=((src.fuel/src.fuelcap)*src.lightdistance)
					return
				else
					src.active=1
					while(src&&src.fuel>=1)
						src.fuel-=pick(0.1,0.2)
						if(src.fuel>src.fuelcap)
							animate(src,luminosity=src.lightdistance, time = 3)
						else
							animate(src,luminosity=((src.fuel/src.fuelcap)*src.lightdistance), time = 3)//src.luminosity=((src.fuel/src.fuelcap)*src.lightdistance)
						sleep(rand(30,70))
					src.luminosity=0
					if(src.active)
						if(src.reusable)
							range(6,src)<<"The [src] goes out."
						else
							range(6,src)<<"The [src] turns to ash"
							if(src)
								del src
					src.active=0
		CampFire
			//icon = 'Things.dmi'
			//icon_state = "small fire"
			density = 1
			fuelcap=5
			lightdistance=3.5
			craft_requirements=list(/obj/resource/Stick = 5, /obj/resource/Stone = 8)
			desc = "A normal campfire to keep things lit. Careful not to let it go out."
			Click()
				if(usr in range(1,src))
					if(src.fuel<src.fuelcap)
						usr<<"You add fuel to the fire."
						src.fuel+=2
						if(src.fuel>src.fuelcap)
							src.fuel=src.fuelcap
						spawn(1)
							src.burn()
					else
						usr<<"The fire can't hold any more fuel at the moment."
		FirePit
			//icon = 'Things.dmi'
			//icon_state = "fire"
			density = 1
			reusable=1
			fuelcap=12
			lightdistance=5.5
			craft_requirements=list(/obj/resource/Stick = 3, /obj/resource/Stone = 4)
			desc = "A firepit that even when it goes out it  can be easily restarted by just adding fuel to it."
			Click()
				if(usr in range(1,src))
					if(src.fuel<src.fuelcap)
						usr<<"You add fuel to the fire."
						src.fuel+=2
						if(src.fuel>src.fuelcap)
							src.fuel=src.fuelcap
						spawn(1)
							src.burn()
					else
						usr<<"The fire can't hold any more fuel at the moment."