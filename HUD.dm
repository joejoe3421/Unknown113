obj
	HUD
		icon='HUD.dmi'
		layer=10
		MouseEntered()
			if(src.desc)
				var/list/SplitList=Split(src.screen_loc,",")
				for(var/v in SplitList)
					var/PreListSize=SplitList.len
					SplitList+=Split(v,":")
					if(SplitList.len==PreListSize+1)	SplitList+=0
				var/X=text2num(SplitList[3])//;var/Xoff=text2num(SplitList[4])
				var/Y=text2num(SplitList[5])//;var/Yoff=text2num(SplitList[6])
				//X=(X-1)*32;Y=(18-Y)*32
				var/Xset=1;if(X>=10)	Xset=-6
				var/Yset=1;if(Y<=1)	Yset=5
				CustToolTip(usr,"[src.name] > > [src.desc]",X+Xset,Y+Yset-4,X+Xset+5,Y+Yset-2,"HUD ToolTip")
		MouseExited()
			if(src.desc)
				CloseToolTip(usr,"HUD ToolTip")
		testhud1
			icon_state="BigButton"
			desc = "test test test test test test test test test test test test test test test test test test test test test etste tstetets tetetets tetststte tstst"
			screen_loc="1,12"
		testhud2
			icon_state="DuelRequest"
			desc = "It works!"
			screen_loc="2,12"
		testhud3
			icon_state="BiggestButton"
			desc = "This is a test"
			screen_loc="3,12"






mob/var/Chatting
mob/var/Chosen

obj/HUD/OnScreenText
	icon='hud.dmi'
	layer=21
	var/ID
	New(mob/M,var/SX,var/SY,var/IS)
		src.icon_state=IS
		screen_loc = "[SX],[SY]"
		M.client.screen+=src
	MessageLetter
		icon='alphabet.dmi'
		var/WordID
		New(var/newx,var/newxo,var/newy,var/newyo,var/letter)
			src.icon_state="[letter]"
			var/LowerOffset=0
			if(LowLetter(letter))	LowerOffset=2
			src.screen_loc="[newx]:[newxo+9],[newy]:[newyo+1-LowerOffset]"
	CustBG
		icon='ChatBG.dmi'
		layer=20
		New(var/xp,var/yp,var/IS,var/ThisID)
			src.ID=ThisID
			src.icon_state="[IS]"
			src.screen_loc="[xp],[yp]"
	Next
		//NextBUTTON
		icon_state="Next"
		mouse_opacity=0
		New(mob/M)
			src.screen_loc="14,7"
			M.client.screen+=src
		Click()
			for(var/obj/HUD/OnScreenText/O in usr.client.screen)
				if(O.name=="LineLetter")	continue
				if(O!=src)	usr.client.screen-=O
			usr.Chatting=0
			//PlaySound(usr,'50561__broumbroum__sf3_sfx_menu_select.ogg',VolChannel="Menu")
			usr.client.screen-=src
	BG

mob/proc/ShowBG()
	src.CustBG(5,6,13,14);return

mob/proc/CustBG(var/FromX,var/FromY,var/EndX,var/EndY,var/ThisID)
	var/CurX=FromX;var/CurY=FromY
	while(CurX<=EndX)
		var/IS="MM"
		if(CurX==FromX)	IS="ML"
		if(CurX==EndX)	IS="MR"
		if(CurY==FromY)	IS="BM"
		if(CurY==EndY)	IS="TM"
		if(CurX==FromX && CurY==FromY)	IS="BL"
		if(CurX==FromX && CurY==EndY)	IS="TL"
		if(CurX==EndX && CurY==FromY)	IS="BR"
		if(CurX==EndX && CurY==EndY)	IS="TR"
		src.client.screen+=new/obj/HUD/OnScreenText/CustBG(CurX,CurY,IS,ThisID)
		CurX+=1;if(CurX>EndX && CurY<EndY)	{CurX=FromX;CurY+=1}

mob/proc/ShowChoice(var/Choice,var/Slot)
	src.CustChoice(Choice,Slot,5,6);return

mob/proc/CustChoice(var/Choice,var/Slot,var/X,var/Y,var/EndX)
	X+=1;Y+=1
	var/obj/PO
	if(length(Choice)>6)
		PO=new/obj/HUD/OnScreenText/ChoiceSelectBG
		PO.pixel_x=(length(Choice)-5)*-6
	if(Slot==1)
		src.client.screen+=new/obj/HUD/OnScreenText/ChoiceSelect(X,16,Y,16,,Choice)
		src.client.screen+=new/obj/HUD/OnScreenText/ChoiceSelect(X+1,16,Y,16,"ChoiceBGR",Choice,PO)
		src.WriteLine(X,26,Y,28,"Choice","[Choice]",0)
	if(Slot==2)
		src.client.screen+=new/obj/HUD/OnScreenText/ChoiceSelect(X+3,16,Y,16,,Choice)
		src.client.screen+=new/obj/HUD/OnScreenText/ChoiceSelect(X+4,16,Y,16,"ChoiceBGR",Choice,PO)
		src.WriteLine(X+3,26,Y,28,"Choice","[Choice]",0)
	if(Slot==3)
		src.client.screen+=new/obj/HUD/OnScreenText/ChoiceSelect(min(X+6,EndX-1),16,Y,16,,Choice)
		src.client.screen+=new/obj/HUD/OnScreenText/ChoiceSelect(min(X+7,EndX),16,Y,16,"ChoiceBGR",Choice,PO)
		src.WriteLine(min(X+6,EndX-1),26,Y,28,"Choice","[Choice]",0)

proc/CustAlert(var/mob/M,var/text2show,var/list/Choices=list("OK"),var/StartX,var/StartY,var/EndX,var/EndY)
	if(!M || M.Chatting)	return
	M.Chatting=1
	//PlaySound(usr,'50565__broumbroum__sf3_sfx_menu_validate.ogg',VolChannel="Menu")
	M.Chosen=null
	M.CustBG(StartX,StartY,EndX,EndY)//puts up BG behind text
	WriteMessage(M,text2show,StartX,EndX,EndY)
	if(Choices.len==1)	M.CustChoice(Choices[1],2,StartX,StartY,EndX)
	if(Choices.len==2)	{M.CustChoice(Choices[1],1,StartX,StartY,EndX);M.CustChoice(Choices[2],3,StartX,StartY,EndX)}
	if(Choices.len==3)
		M.CustChoice(Choices[1],1,StartX,StartY,EndX)
		M.CustChoice(Choices[2],2,StartX,StartY,EndX);M.CustChoice(Choices[3],3,StartX,StartY,EndX)
	while(!M.Chosen)
		sleep(1);if(!M)	return
	return M.Chosen

proc/CustToolTip(var/mob/M,var/text2show,var/StartX,var/StartY,var/EndX,var/EndY,var/ThisID)
	if(!M || M.Chatting)	return
	M.CustBG(StartX,StartY,EndX,EndY,ThisID)
	WriteMessage(M,text2show,StartX,EndX,EndY,ThisID)
proc/CloseToolTip(var/mob/M,var/ThisID)
	if(M.client && !M.Chatting)
		M.WriteLine(6,16,7,16,"Choice","",1)
		for(var/obj/HUD/OnScreenText/O in M.client.screen)
			if(O.name=="LineLetter")	continue
			if(ThisID==O.ID)	M.client.screen-=O

proc/WriteMessage(mob/M,var/text2show,var/StartX,var/EndX,var/StartY,var/ThisID)
	var/ThisView=EndX	//Determines when word-wrap should kick in
	var/PixelSpace=7	//sets the spacing between each letter
	var/hudx=StartX	//The begining X in the message, used for resetting on next lines
	var/hudxo=-PixelSpace	//Preps the pixel_x for the loop
	var/hudy=StartY	//Begining y
	var/hudyo=12	//Begining pixel_y
	var/CurPos=0	//Which letter position its currently on in the message
	var/LastPos=0	//Goes back to the begining of the last word when wrapping
	var/WordCount=0	//Used to remove the pre-wrapped letters
	var/WordWrapProtection=0	//Automaticaly Breaks on Continual Text
	var/list/TheseLetters=list()	//Contains letters to prevent removing old ones
	while(M)
		CurPos+=1;hudxo+=PixelSpace
		var/letter=copytext(text2show,CurPos,CurPos+1)
		if(!letter)	return
		if(letter==" ")	//skips to next word on spaces
			WordCount+=1;LastPos=CurPos;continue
		if(letter==">")	//force to next line
			WordCount+=1;hudx=ThisView;LastPos=CurPos+1
		if(hudx>=ThisView)	//word wrappage!
			hudyo-=12;hudx=StartX;hudxo=-PixelSpace
			if(hudyo==-96)	//only drop the actual y every 3 offsets
				hudy-=3;hudyo=0
			if(WordWrapProtection==WordCount)
				hudxo+=PixelSpace
				WordCount+=1;CurPos+=1
				WordWrapProtection=WordCount
			else
				for(var/obj/HUD/OnScreenText/MessageLetter/C1 in TheseLetters)	if(C1.WordID==WordCount)	del C1
				CurPos=LastPos;WordWrapProtection=WordCount;continue
		if(hudxo>=32)	{hudx+=1;hudxo-=32}	//moves to next x and resets x offset
		var/obj/HUD/OnScreenText/MessageLetter/C=new/obj/HUD/OnScreenText/MessageLetter(hudx,hudxo,hudy,hudyo,letter)
		C.ID=ThisID
		TheseLetters+=C
		if(SlimLetter(letter))	hudxo-=4
		C.WordID=WordCount;M.client.screen+=C

obj/HUD/OnScreenText
	ChoiceSelectBG/**/
		layer=21
		icon='HUD.dmi'
		icon_state="ChoiceBGM"
		New()
			return
	ChoiceSelect/**/
		layer=21
		icon='HUD.dmi'
		mouse_opacity=2
		var/Choice
		New(var/xp,xo,yp,yo,IS="ChoiceBGL",Choicey,var/obj/Underlay)
			src.Choice=Choicey
			src.icon_state="[IS]"
			src.screen_loc="[xp]:[xo],[yp]:[yo]"
			if(Underlay)
				src.underlays+=Underlay
				src.screen_loc="[xp]:[xo-Underlay.pixel_x],[yp]:[yo]"
		Click()
			usr.Chosen=src.Choice
			usr.WriteLine(6,16,7,16,"Choice","",1)
			for(var/obj/HUD/OnScreenText/O in usr.client.screen)
				if(O.name=="LineLetter")	continue
				usr.client.screen-=O
			usr.Chatting=0
			//PlaySound(usr,'50561__broumbroum__sf3_sfx_menu_select.ogg',VolChannel="Menu")

proc/ShowAlert(var/mob/M,var/text2show,var/list/Choices=list("OK"))
	return(CustAlert(M,text2show,Choices,5,6,13,14))

proc/ShowText(var/mob/M,var/text2show)
	if(!M)	return
	if(M.Chatting)	return
	M.Chatting=1
	for(var/obj/HUD/OnScreenText/O in M.client.screen)
		if(O.name=="LineLetter")	continue
		del O
	M.WriteLine(6,16,7,16,"Choice","",1)
	M.ShowBG()	//puts up BG behind texty!
	WriteMessage(M,text2show,5,13,14)
	sleep(5);if(!M)	return
	new/obj/HUD/OnScreenText/Next(M)
	while(M.Chatting==1)
		sleep(1);if(!M)	return


obj/HUD/OnScreenText
	icon='hud.dmi'
	layer=21
	mouse_opacity=0
	LineLetter
		icon='alphabet.dmi'
		New(var/hudx,var/hudxpix,var/hudy,var/hudypix,var/IS,var/newID)
			src.ID=newID
			src.icon_state=IS
			var/LowerOffset=0;if(LowLetter(IS))	LowerOffset=2
			src.screen_loc = "[hudx]:[hudxpix],[hudy]:[hudypix-LowerOffset]"
mob/proc/WriteLine(var/hudx,var/hudxpix,var/hudy,var/hudypix,var/ID,var/word,var/ClearScreen=1)
	if(!src.client)	return
	if(ClearScreen)
		for(var/obj/HUD/OnScreenText/LineLetter/C in src.client.screen)	if(C.ID==ID)	src.client.screen-=C
	if(!word)	return
	var/PixelSpace=7
	var/CurPos=0
	while(src)
		CurPos+=1
		var/letter=copytext(word,CurPos,CurPos+1)
		if(!letter)	return
		if(letter==" ")
			hudxpix+=PixelSpace;continue
		src.client.screen+=new/obj/HUD/OnScreenText/LineLetter(hudx,hudxpix,hudy,hudypix,letter,"[ID]")
		if(SlimLetter(letter))	hudxpix-=4
		hudxpix+=PixelSpace
		if(hudxpix>=32)
			hudx+=1;hudxpix-=32

obj/HUD/OnScreenText
	MapLetter
		icon='alphabet.dmi'
		New(var/hudx,var/hudxpix,var/hudy,var/hudypix,var/hudz=2,var/IS)
			src.icon_state=IS
			src.loc=locate(hudx,hudy,hudz)
			var/LowerOffset=0;if(LowLetter(IS))	LowerOffset=2
			src.pixel_x=hudxpix;src.pixel_y=hudypix-LowerOffset
proc/WriteMapLine(var/hudx,var/hudxpix,var/hudy,var/hudypix,var/hudz,var/word)
	var/PixelSpace=7
	var/CurPos=0
	while(1)
		CurPos+=1
		var/letter=copytext(word,CurPos,CurPos+1)
		if(letter==" ")	{hudxpix+=PixelSpace;continue}
		if(!letter)	return
		var/obj/HUD/OnScreenText/MapLetter/CM=new(hudx,hudxpix,hudy,hudypix,hudz,letter)
		CM.layer=OBJ_LAYER
		if(SlimLetter(letter))	hudxpix-=4
		hudxpix+=PixelSpace
		if(hudxpix>=32)
			hudx+=1;hudxpix-=32


proc/LowLetter(var/L)
	if(L=="g"||L=="j"||L=="p"||L=="q"||L=="y"||L==",")	return 1
	else	return 0

proc/SlimLetter(var/L)
	if(L=="i"||L=="l"||L==","||L=="."||L=="'"||L=="!"||L==":")	return 1
	else	return 0


