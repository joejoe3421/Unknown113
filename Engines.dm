proc/Split(var/text2split,var/SplitBy=",")
	var/CurPos=1
	var/list/SplitList=list()
	while(findtext(text2split,SplitBy,CurPos,0))
		var/NextPos=findtext(text2split,SplitBy,CurPos,0)
		SplitList+=copytext(text2split,CurPos,NextPos)
		CurPos=NextPos+1
	if(CurPos<=length(text2split))	SplitList+=copytext(text2split,CurPos,0)
	return SplitList




mob/proc/UpdateInv()
	set background = 1
	if(!src.client)
		return
	/*var/I = 0
	for(var/obj/O in src.contents)//Loop through all the items in the players contents
		winset(src, "InventoryStuff.inventory", "current-cell=1,[++I]")	//Add multiple cells horizontally for each obj
		src << output(O, "InventoryStuff.inventory")//Send the obj's in src.contents to the Grid
	winset(src,"InventoryStuff.inventory", "cells=[I]")*/
	var/X=0
	for(var/obj/skill/O in src.Techs)//Loop through all the items in the players contents
		winset(src, "Skills.Skill", "current-cell=1,[++X]")	//Add multiple cells horizontally for each obj
		src << output(O, "Skills.Skill")//Send the obj's in src.contents to the Grid
	winset(src,"Skills.Skill", "cells=[X]")
//jutsuu is the window name
//jutsus is the grid inside the window's name



obj
	skill
		icon = 'HUD.dmi'
		icon_state = "BiggestButton"
		Jump

		Run

		Move

		Jog

		Teleport

		Kick

		Fight

		Hang

		Stop

///////////////////////////////////////////////////////////////
/////////////////////////-------------Movement System-------//////////////
//////////////////////////////////////////////////////////////////
mob
	Move()
		if(src.moving==1||src.Frozen==1||src.ko>=1||src.bind>=1||src.resting)
			return
		src.moving = 1
		..()
		var/takefrom=(src.spe/1000)
		var/normaltake=src.movedelay-takefrom
		if(normaltake<1.5)
			normaltake=1.5//if flying make it go down to 1.2 lowest
		var/result=normaltake
		spawn(result)
			src.moving = 0


mob
	var
		tmp/movedelay = 2.0
		tmp/moving = 0
		tmp/savedspeed = 1.6


//////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////
/////////////////////////------------------Gain Procs------////////
/////////////////////////////////////////////////////////
mob
	proc
		pgain(number)
			if(number==null)
				world<<"Value was null."
				number=0.001
			var/N = (src.modpowerlevel*number)/(rand(100,300))//500
			N=(N*powergain)
			if(N<0)
				N=0
			//world<<"Returning [N] power to [src]."
			return N
			/*
			Ex.src.Mpowerlevel+=src.pgain(a number)
			*/
		sgain(number,mod)//stat gains, might have to make a seperate one for each stat
			if(number==null)
				world<<"Value was null."
				number=0.001
			if(mod==null)
				mod=0
			var/N = (mod*number)/(rand(1.5,5))
			N=(N*statgain)
			if(N<0)
				N=0
			//world<<"Returning [N] stat increase to [src]."
			return N
			/*
			Ex.src.Mstr+=src.sgain(a number,src.modstr)
			*/
////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////
///////////////////////////////////////////--Crafting Systems---///////////
/////////////////////////////////////////////////////////////////

obj
	var
		craft_requirements=list()
		stackable=1
		amount=1

mob
	proc
		craft(obj/craft/SOMETHING)

			// Do we have the ability to craft this?
			var/canCraft = SOMETHING.canCraft()

			// Can we craft? Do we pocess the nessersary tools and stations?
			if(!canCraft)
				return 0

			// Do we have all the components?
			var/list/usrComponents = SOMETHING.findComponents()

			if(usrComponents)

				// Go through all the components we found
				for(var/obj/resource/component in usrComponents)

					// Stackable component?
					if(component.stackable)

						// Remove the amount we associated with it earlier
						component.removeAmount(usrComponents[component])

					// It wasn't stackable but maybe we need to del more than one
					else
						for(var/nextUsrComponent = 0, nextUsrComponent < usrComponents[component], nextUsrComponent++)
							var/obj/resource/next = locate(component.type) in usr.contents
							if(next == src)
								next.loc = null
							else
								del next

				//SOMETHING.whileCrafting()

				// Now we can give the user the craftable.
				//var/obj/craft/Gimmie = SOMETHING.type
				var/obj/i = new SOMETHING.type(usr.loc)
				//usr.Get(i)
				i.loc=usr.loc


			// We didn't have the components
			else
				var/missingComponents = "\n"
				for(var/componentType in SOMETHING.craft_requirements)
					var/obj/component = new componentType
					missingComponents += "\t[SOMETHING.craft_requirements[componentType]]x [component.name]\n"
				missingComponents = copytext(missingComponents, 1, length(missingComponents))

				alert("You were missing something to craft this.\n\nYou need a total of:\n[missingComponents]","Missing Components For [SOMETHING.name]")

				return 0

atom
	proc
		canCraft()

			// Do we not have enough space left to fit something new?
			//if(!usr.weight>usr.weight*3)

				/*
					We might have space for the item after crafting is completed. The logic being used is
					that if we have at least one non stackable then it will vanish during crafting leaving
					space for this new item.
				*/
				/*for(var/componentType in components)
					var/obj/Item/component = new componentType
					if(!component.stackable)
						return 1

				usr.spaceError()*/
				//return 0
			// Do we have all the tools required?
			/*for(var/toolType in tools)

				var/foundTool = 0
				for(var/obj/Item/object in usr.contents)
					if(object.type == toolType)
						foundTool = 1
						break

				if(!foundTool)
					var/atom/toolNeeded = new toolType
					alert("You will need a [toolNeeded.name] to make that.","Missing [toolNeeded.name]")
					return 0

			// Are we adjacent the required stations?
			for(var/stationType in craftedAt)

				var/foundStation = 0
				for(var/obj/object in oview(1))
					if(stationType == object.type)
						foundStation = 1
						break

				if(!foundStation)
					var/atom/stationNeeded = new stationType
					alert("You will need to be next to a [stationNeeded.name] to make that.","Crafted at [stationNeeded.name]")
					return 0*/

			return 1
atom
	proc
		findComponents(obj/H)
			H=src
			world<<"src is [src], H is [H]"
			if(H==null)
				return

			var/list/usrComponents = new/list()

			// Check for all components needed
			for(var/componentType in H.craft_requirements)

				// Take a component
				var/obj/resource/componentObj = new componentType

				// How many do we need to find?
				var/amountNeeded = H.craft_requirements[componentType]

				// It's stackable
				//if(componentObj.stackable)
				world<<"[H] needs [amountNeeded] of [componentType]."
				if(componentObj.stackable)

					/* Check for all stacks of this type in the usr */

					// Go to the smallest 1 first
					var/obj/resource/smallestComponent
					for(var/obj/resource/object in usr)
						if(object.type == componentType && object.amount < 99)
							smallestComponent = object
							break

					// Is this all we need?
					if(smallestComponent)

						// Was it more than what we needed?
						if(smallestComponent.amount >= amountNeeded)
							usrComponents[smallestComponent] = amountNeeded
							amountNeeded = 0
							continue

						// Was it less than what we needed?
						else
							usrComponents[smallestComponent] = smallestComponent.amount
							amountNeeded -= smallestComponent.amount

					// Nope, go into any other stacks they have
					for(var/obj/resource/object in usr)
						if(object.type == componentType && object != smallestComponent)

							// Was it more than what we needed?
							if(object.amount >= amountNeeded)
								usrComponents[object] = amountNeeded
								amountNeeded = 0
								break

							// Was it less than what we needed?
							else
								usrComponents[object] = object.amount
								amountNeeded -= object.amount

					// After that did we find enough?
					if(amountNeeded > 0)
						return null

				// It's not stackable, so we need to find a number of objects
				else

					// How many of these components are in usr contents?
					var/amountFound = 0
					for(var/object in usr.contents)
						if(istype(object,componentType))
							amountFound ++

					// Not enough
					if(amountFound < amountNeeded)
						return null // Return false (null)

					// Enough
					else
						usrComponents[componentObj] = amountNeeded

				// Continue on, enough of this component type were found

			return usrComponents

mob
	var
		tmp/skilltreeview=0//the menu that shows up when trying to buy or learn more about an item
		tmp/craftview=1 //the menu that shows up when crafting or trying to build
		learnedtobuild=list()


///////////////////////////////////////////////////////////////
//////////////////////////////////////////
///////////////////////////////////////////////////////