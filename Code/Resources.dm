obj
	proc
		removeAmount(AMOUNT)
			amount -= AMOUNT
			if(amount <= 0)
				del src
			if(src)
				src.updateSuffix()

		updateSuffix()
			if(src.stackable)
				src.suffix = "[src.amount]"
	resource
		icon = 'Resources.dmi'
		Thatch

		Wood

		Stick

		Stone

		Metal