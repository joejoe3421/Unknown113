var
	allowguest=1
	statgain=1//default stat gain gain multiplier, global
	powergain=1//default powerlevel gain multiplier, global
	leechAM = 0.30 // 30% max leech from a person, 1 = 100%. 30% by default

atom
	var
		tmp/Frozen=0
		secondeffect = "" //So certain moves can have not only one effect but two.
		owner=null
		strperc=100
		endperc=100
		speperc=100
		offperc=100
		defperc=100
		regenperc=100
		recovperc=100
		form=null


mob
	var
		attackdelay=4
		tmp/attacking=0
		tmp/attackCD = 0
		tmp/guard=0
		alignment=0//nuetral
		auraicon=null
		auracolor=""
		Race = "None" //true race, or at least the one that's dominant in hybrids if one is dominant
		RaceCalled = "Nothing"//what players will be called when they are born such as if born on earth your race called woudl be earthling etc
		Mhealth=100
		health=100
		Menergy=10
		energy=10
		Econtrol=10//Econtrol = energy control
		Mpowerlevel=10
		powerlevel=10
		Mstr=1
		str=1
		Mend=1
		end=1
		Mspe=1
		spe=1
		Moff=1
		off=1
		Mdef=1
		def=1
		regen=1
		recov=1
		////////----Stat gain Modifyers
		modpowerlevel=0.01
		modenergy=0.01
		modstr=0.01
		modend=0.01
		modspe=0.01
		modoff=0.01
		moddef=0.01
		////////////////////////
		BaseR=0
		BaseG=0
		BaseB=0
		Techs = list()
		ko=0
		resting=0
		bind=0
		////////----Creation stats
		cooking = 0 //Allows the ability to cook better things, food is more filling
		construction = 0 //Allows the building of houses with more material use
		crafting = 0 //Allows the creation of a wide range of items such as jewellery, leather armour and battlestaves
		divination = 0 //Gather the scattered divine energy of Gods and weave it into powerful portents, signs, and temporary skilling locations.
		farming = 0 //Allows crops to be grown for use in other skills, notably herbs for Herblore.
		fishing = 0 //Allows easier and quicker catches of fish from water.
		herblore = 0 //Allows the creation of potions from herbs, used to temporarily bestow a variety of different effects.
		hunter = 0 //Allows the creation of traps for animals and players.
		magic = 0 //Allows the ability to learn/understand spells.
		mining = 0 //Allows the chance of gaining a bit more when mining.
		prayer = 0 // Grants access to modal buffs, which are useful in many areas of the game. Levelling unlocks new prayers, and allows prayers to stay active for longer.
		runecrafting = 0 //Allows the creation of runes for use in magic spells.
		slayer = 0 //Allows otherwise-resilient creatures to be damaged, often using specialist equipment.
		smithing = 0 //Allows metallic bars and items to be made from ore.
		summoning = 0 //Allows familiars to be summoned, which help in combat and other activities.
		thieving = 0 //Allows the player to steal from NPC/Players, disarm traps and open certain locked things.
		woodcutting = 0 //Increases the ammount of wood gained from cutting down trees.
		/////////////////////////////



obj
	var
		tmp/cooldown = null
