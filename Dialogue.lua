--all dialogue for all NPC's

local dialogue = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("Dialogue")

local checkCounter = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("CheckCounter")

local buyItems = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("Buy")

local clearCounter = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("ClearCounter")

local UIS = game:GetService("UserInputService")

--things for each players gui
local dialogueGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("DialogueGui")
local npcNameBox = dialogueGui.Frame.NPCName
local dialogueBox = dialogueGui.Frame.Dialogue

local firstButton = dialogueGui.Frame.First
local secondButton = dialogueGui.Frame.Second



firstButton.MouseButton1Click:Connect(function()
	
	if firstButton.Text == "Make a purchase." then
		
		firstButton.Interactable = false
		secondButton.Interactable = false
		
		--check counter
		checkCounter:FireServer(npcNameBox.Text)
		
		task.wait(0.2)
		
		firstButton.Interactable = true
		secondButton.Interactable = true
		
	elseif firstButton.Text == "Confirm." then
		
		firstButton.Interactable = false
		secondButton.Interactable = false
		
		--buy the items which are on the counter
		buyItems:FireServer(npcNameBox.Text)
		
		task.wait(0.2)
		
		firstButton.Interactable = true
		secondButton.Interactable = true
		
	elseif firstButton.Text	== "Can I get a lantern?" then
		
		firstButton.Interactable = false
		secondButton.Interactable = false

		--fire Aarne's dialogue that asks for 5 iron
		dialogueBox.Text = "Sure thing! Just get me 5 iron, and put it in the drop off over there."		
		
		task.wait(0.2)

		firstButton.Interactable = true
		secondButton.Interactable = true
	end
end)



--simulate first button press from D-Pad up on controller
UIS.InputBegan:Connect(function(input, gameProcessed)
	
	--if the input is a controller D-pad input
	if input.KeyCode == Enum.KeyCode.DPadUp then
		
		if firstButton.Text == "Make a purchase." then

			firstButton.Interactable = false
			secondButton.Interactable = false

			--check counter
			checkCounter:FireServer(npcNameBox.Text)

			task.wait(0.2)

			firstButton.Interactable = true
			secondButton.Interactable = true

		elseif firstButton.Text == "Confirm." then

			firstButton.Interactable = false
			secondButton.Interactable = false

			--buy the items which are on the counter
			buyItems:FireServer(npcNameBox.Text)

			task.wait(0.2)

			firstButton.Interactable = true
			secondButton.Interactable = true
		end
	--second button from dpad down
	elseif input.KeyCode == Enum.KeyCode.DPadDown then
		
		if secondButton.Text == "Leave." then

			dialogueGui.Enabled = false

		elseif secondButton.Text == "Cancel." then

			secondButton.Interactable = false
			firstButton.Interactable = false

			dialogueBox.Text = "No problem, I'll just put this stuff back."
			firstButton.Text = " "
			secondButton.Text = " "

			task.wait(2)

			dialogueGui.Enabled = false

			secondButton.Interactable = true
			firstButton.Interactable = true

			--fire an event that clears the counter of player owned outlines that are unbought
			clearCounter:FireServer(game.Players.LocalPlayer.UserId, npcNameBox.Text)
		end
	end
end)


secondButton.MouseButton1Click:Connect(function()
	
	if secondButton.Text == "Leave." then
		
		dialogueGui.Enabled = false
		
	elseif secondButton.Text == "Cancel." then
		
		secondButton.Interactable = false
		firstButton.Interactable = false
		
		dialogueBox.Text = "No problem, I'll just put this stuff back."
		firstButton.Text = " "
		secondButton.Text = " "
		
		task.wait(2)
		
		dialogueGui.Enabled = false
		
		secondButton.Interactable = true
		firstButton.Interactable = true
		
		--fire an event that clears the counter of player owned outlines that are unbought
		clearCounter:FireServer(game.Players.LocalPlayer.UserId, npcNameBox.Text)
		
	end
end)


dialogue.OnClientEvent:Connect(function(npcName)
	
	
	--check which npc the player is talking to
	if npcName == "Ridge" then
		
		--make dialogue gui visible
		dialogueGui.Enabled = true
		
		--adjust GUI as required for player
		npcNameBox.Text = "Ridge Potens"
		
		dialogueBox.Text = "Welcome back."
		
		firstButton.Text = "Make a purchase."
		
		secondButton.Text = "Leave."
		
	elseif npcName == "Felicity" then
		
		--make dialogue gui visible
		dialogueGui.Enabled = true

		--adjust GUI as required for player
		npcNameBox.Text = "Felicity Habilis"

		dialogueBox.Text = "What can I get for ya?"

		firstButton.Text = "Make a purchase."

		secondButton.Text = "Leave."
	elseif npcName == "Aarne" then
		
		--make dialogue gui visible
		dialogueGui.Enabled = true

		--adjust GUI as required for player
		npcNameBox.Text = "Aarne Gnarus"

		dialogueBox.Text = "Hello! Need anything?"

		firstButton.Text = "Make a purchase."

		secondButton.Text = "Leave."
	end
end)

--when returned, check if there are actually items to purchase or not
checkCounter.OnClientEvent:Connect(function(price)
	
	--say price of items on counter, ask if they still want to purchase
	if price == 0 then 
		
		dialogueBox.Text = "Put something on the counter."
		
		task.wait(1)
		
		dialogueGui.Enabled = false
	else
		
		dialogueBox.Text = "That will be " .. price .. "$"
		
		firstButton.Text = "Confirm."
		secondButton.Text = "Cancel."
	end
end)


--when an item has been bought
buyItems.OnClientEvent:Connect(function(npcName, canBuy)
	
	--make sure plyr can buy
	if canBuy == true then
		
		--check which npc
		if npcName == "Ridge Potens" then

			dialogueBox.Text = "Thank you for your purchase."

			firstButton.Text = " "
			secondButton.Text = " "

			task.wait(1)

			dialogueGui.Enabled = false
		elseif npcName == "Felicity Habilis" then
			
			dialogueBox.Text = "Pleasure doing buisness."

			firstButton.Text = " "
			secondButton.Text = " "

			task.wait(1)

			dialogueGui.Enabled = false
		elseif npcName == "Aarne Gnarus" then
			
			dialogueBox.Text = "Thanks! Have a good one!"

			firstButton.Text = " "
			secondButton.Text = " "

			task.wait(1)

			dialogueGui.Enabled = false
		end
	else
		
		--check which npc
		if npcName == "Ridge Potens" then

			dialogueBox.Text = "That's not enough, Sorry."

			firstButton.Text = " "
			secondButton.Text = " "

			task.wait(3)

			dialogueGui.Enabled = false
			
		elseif npcName == "Felicity Habilis" then

			dialogueBox.Text = "You're gonna need more than that."

			firstButton.Text = " "
			secondButton.Text = " "

			task.wait(3)

			dialogueGui.Enabled = false
		elseif npcName == "Aarne Gnarus" then
			
			dialogueBox.Text = "Oh I don't think thats enough, Sorry :("

			firstButton.Text = " "
			secondButton.Text = " "

			task.wait(3)

			dialogueGui.Enabled = false
		end
	end
end)
