mob
	Login()
		if(usr.key=="Guest")
			if(allowguest==0)
				usr << "<b>NO guests allowed at the moment sorry, we need true players!"
				del(usr)
		//src.loc=locate(6,6,1)
		src.loc=locate(/turf/LoginStuff/loginspawn)
		src.client.screen+=new/obj/HUD/testhud1
		src.client.screen+=new/obj/HUD/testhud2
		src.client.screen+=new/obj/HUD/testhud3
		src.Techs += new /obj/skill/Run
		src.Techs += new /obj/skill/Jump
		src.Techs += new /obj/skill/Move
		src.Techs += new /obj/skill/Stop
		src.Techs += new /obj/skill/Jog
		src.Techs += new /obj/skill/Teleport
		src.Techs += new /obj/skill/Kick
		src.Techs += new /obj/skill/Fight
		winshow(src, "Skills", 1)
		spawn(50)
			src.UpdateInv()
		//src.client.screen+=new/obj/HUD/Genders/shade1


turf
	LoginStuff
		density = 1
		icon='Buttons.dmi'
		layer = 999
		New
			icon_state="New"
			Click()
				var/charactername = input("","Name") as text|null
				if(length(charactername) < 2)
					alert("Your name must be longer than 2 letters!")
					return
				if(length(charactername) > 50)
					alert("Your name can not be longer then 20 letters!")
					return
				usr.name="[html_encode(charactername)]"
				usr.Racepick()
				//usr.Genderpick()
				//usr.Iconpick()
				//usr.loc = locate(110,374,3)
				//racepick
				//genderpick
				//iconpick
		Load
			icon_state="Load"
			/*Click()
				names.Add(usr.key)
				usr.LoadPlayer()*/
		Quit
			icon_state="Quit"
			Click()
				del(usr)
		loginspawn
			icon='Turf1.dmi'
			icon_state = "grass1"
mob
	Logout()
		world << output("<font color = #F9DB13>World News: <font color = red>[usr.key]([usr.name]) has been eaten by a big scary monster.","chat")
		/*names.Remove(usr.key)
		Kages.Remove(usr.key)*/
		alert("Buh bye.")
		//del(mob)
		..()
mob
	verb
		quitme()
			set hidden = 1
			usr.Logout()
/*
client
	Del()
		world << output("<font color = #F9DB13>World News: <font color = red>[usr.key]([usr.name]) has been eatin by a big scary monster.","chat")
		/*names.Remove(usr.key)
		Kages.Remove(usr.key)*/
		alert("Buh bye.")
		del(mob)
		..()
*/
mob
	var
		prefergender=null
	proc
		Genderpick()
			//src.Race = "Human"
			var/canbe = list()
			if(src.Race == "Human"||src.Race == "Saiyan"||src.Race == "Alien"||src.Race == "Demon")
				canbe += "Male"
				canbe += "Female"
			if(src.Race == "Alien"||src.Race == "Namekian")
				canbe += "Egg Layer"//plural
			if(src.Race == "Alien"||src.Race == "Changeling"||src.Race == "Demon")
				canbe += "None"//nueter
			var/newgender = input("Select a gender for your character.","Your Gender",src.gender) in list() + canbe//"Male","Female","Neuter")
			if(newgender=="Male")
				src.gender = MALE
			if(newgender=="Female")
				src.gender = FEMALE
			if(newgender=="Egg Layer")
				src.gender = NEUTER
			if(newgender=="None")
				src.gender = PLURAL
			if(src.Race == "Alien"||src.Race == "Demon")
				if(src.gender==PLURAL||src.gender==NEUTER)
					src.prefergender = input("What Gender does your character identify as?","Your Gender",src.gender) in list("Nothing","Male","Female")

		Iconpick()
			src<<"This would be where the window to choose an icon would appear."
			var/canlook = list()
			if(src.Race == "Human"||src.Race == "Saiyan"||src.Race == "Alien"||src.Race == "Demon")
				canlook += typesof(/obj/HUD/Skincolors/Genders/)
			for(var/Y in canlook)
				var/obj/O = new Y(locate(src.client.screen))
				if(src.gender==MALE||src.prefergender=="Male")
					O.icon = 'Male.dmi'
					O.icon+=rgb(O.R,O.G,O.B)
					src.client.screen+=O
				else if(src.gender==FEMALE||src.prefergender=="Female")
					O.icon = 'Female.dmi'
					O.icon+=rgb(O.R,O.G,O.B)
					src.client.screen+=O
				else
					src<<"Gender based icon removed..."


		Racepick()
			/*var/races = list()
			for(var/obj/HUD/racetotem/O in world)
				if(O)
					races+=O
			var/newrace = input("Select a Race/Species for your character.","Your Race/Species",src.Race) in list() + races*/
			///just for testing
			var/races2 = list()
			races2 += typesof(/obj/HUD/racetotem/)
			for(var/Y in races2)
				var/atom/O = new Y(locate(src.client.screen))
				src.client.screen+=O
			///

obj
	var
		Race = "None"
		selected=0
		gotostate=""
	HUD
		racetotem
			//takes care names for races
			icon='Male.dmi'
			Click()
				if(src.selected==1)
					usr.Race=src.Race
					CloseToolTip(usr,"HUD ToolTip")
					for(var/obj/HUD/racetotem/J in usr.client.screen)
						if(J&&J!=src)
							del J
					src.invisibility = 1
					usr.Genderpick()
					usr.Iconpick()
					del src
				if(src.selected==0)
					for(var/obj/HUD/racetotem/H in usr.client.screen)
						H.selected=0
						H.icon_state = ""
						animate(H, transform = matrix()*1, time = 2)
					src.selected=1
					animate(src, transform = matrix()*1.5, time = 3.5)
					if(src.gotostate == "Random")
						src.icon_state=pick("","Attack","Meditate")
					else
						src.icon_state = src.gotostate
			Human
				Race = "Human"
				desc = "A balanced race that's very customizable."
				screen_loc = "5,8"
				gotostate=""
			Saiyan
				Race = "Saiyan"
				desc = "A weaker starting race whos members gradually become stronger as they fight."
				screen_loc = "7,7"
				gotostate="Attack"
			Namekian
				Race = "Namekian"
				desc = "Peaceful MALE group who live long lives and are easy to manage."
				screen_loc = "3,7"
				gotostate="Meditate"
			Alien
				Race = "Alien"
				desc = "An extremely customizable race who's overall gameplay can range from easy to difficult. It's a gamble."
				screen_loc = "5,4"
				gotostate="Random"



obj
	var
		R=0
		G=0
		B=0
	HUD
		layer=10
		Skincolors
			icon='Male.dmi'
			//screen_loc = "4,4"
			New()
				src.icon+=rgb(R,G,B);return
			Click()
				var/R=src.R;var/G=src.G;var/B=src.B
				usr.BaseR=R;usr.BaseG=G;usr.BaseB=B//;usr.FixMyIcon()
				usr.icon = src.icon
				for(var/obj/HUD/Skincolors/S in usr.client.screen)
					if(S&&S!=src)
						del S
				//temp thing
				usr.loc=locate(/turf/planets/earthspawn)
				del src
			Genders
				shade1
					R=96;G=95;B=95
					screen_loc = "1,11"
				shade2
					R=192;G=135;B=90
					screen_loc = "2,11"
				shade3
					R=177;G=120;B=75
					screen_loc = "3,11"
				shade4
					R=172;G=115;B=70
					screen_loc = "4,11"
				shade5
					R=122;G=65;B=20
					screen_loc = "5,11"
				shade6
					R=117;G=60;B=15
					screen_loc = "6,11"

