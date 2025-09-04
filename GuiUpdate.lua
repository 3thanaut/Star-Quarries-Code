--[[ U
  This is another client sided script which would have benefitted from me knowing that runservice heartbeat existed.
  Also using the dialogue tree node editor and having the editing knowledge I do today would have saved me eons of work.
  I am so thankful for this knowledge, I am so much more aware of technical debt now than I was at the time of this game.
]]--



--update the money textbox for given player--
local money = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("Money")

--on server event at given player
money.OnClientEvent:Connect(function(money)
	
	--for players gui, set text to money
	local player = game.Players.LocalPlayer
	local moneyGui = player.PlayerGui:WaitForChild("MoneyGui")
	
	--actually setting the text
	moneyGui.Frame.MoneyLabel.Text = money .. "$"
	
	print("should be updated...")
end)


--load control select
local ControlSelect = game.Players.LocalPlayer.PlayerGui:WaitForChild("ControlSelect")
local MoneyGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("MoneyGui")
ControlSelect.Enabled = true
local ChosenDevice = nil
--load main menu
local mainMenu = game.Players.LocalPlayer.PlayerGui:WaitForChild("MainMenuGui")
game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 0

ControlSelect.Frame.Keyboard.Activated:Connect(function()
	
	--set keyboard as chosen device
	ChosenDevice = "Keyboard"
	mainMenu.Enabled = true
	ControlSelect.Enabled = false
	MoneyGui.Enabled = true
end)

ControlSelect.Frame.Controller.Activated:Connect(function()

	--set keyboard as chosen device
	ChosenDevice = "Controller"
	mainMenu.Enabled = true
	ControlSelect.Enabled = false
	MoneyGui.Enabled = true
end)

ControlSelect.Frame.Tablet.Activated:Connect(function()

	--set keyboard as chosen device
	ChosenDevice = "Tablet"
	mainMenu.Enabled = true
	ControlSelect.Enabled = false
	MoneyGui.Enabled = true
end)


--recieve inputs from main menu
game.Players.LocalPlayer.PlayerGui.MainMenuGui.Frame.Play.Activated:Connect(function()
	
	--get rid of the main menu
	game.Players.LocalPlayer.PlayerGui.MainMenuGui.Enabled = false
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
end)


while ChosenDevice == nil do

	task.wait()
end

--TUTORIAL

local tutorialGui = game.Players.LocalPlayer.PlayerGui.TutorialGui
local tutorialIndex = 1


game.Players.LocalPlayer.PlayerGui.MainMenuGui.Frame.Tutorial.Activated:Connect(function()

	game.Players.LocalPlayer.PlayerGui.MainMenuGui.Enabled = false
	game.Players.LocalPlayer.PlayerGui.TutorialGui.Enabled = true
	
	tutorialGui.Frame[ChosenDevice].TakeBoxDemo.Visible = true
	tutorialGui.Frame[ChosenDevice].TakeBox.Visible = true
end)

game.Players.LocalPlayer.PlayerGui.MoneyGui.Frame.MainButtons.TutorialButton.Activated:Connect(function()
	
	game.Players.LocalPlayer.PlayerGui.MoneyGui.Enabled = false
	game.Players.LocalPlayer.PlayerGui.TutorialGui.Enabled = true
end)

--now that tutorial is enabled, get table and check buttons
--[[ U 
  This made me give up on making a fancy tutorial, the amount of work that went into placing so many image files into this was atrocious.
  In the future I would just make a dialogue editor or use the node editor plugin with some changes.
  Time saves like these will allow me to make larger projects going forward.
  I chose ROBLOX so that I could make mistakes like this and still make tangible progress, it was to teach me to organize.
  I now am making my own framework and its been very slow, but I have substantially better practices drilled in now.
]]--
local tutorialTable = {

	tutorialGui.Frame[ChosenDevice].TakeBoxDemo,
	tutorialGui.Frame[ChosenDevice].DropBoxDemo,
	tutorialGui.Frame[ChosenDevice].TalkToNPCDemo,
	tutorialGui.Frame[ChosenDevice].DialogueDemo,
	tutorialGui.Frame[ChosenDevice].OpenBoxDemo,
	tutorialGui.Frame[ChosenDevice].BreakRocks,
	tutorialGui.Frame[ChosenDevice].BuildBoxDemo,
	tutorialGui.Frame[ChosenDevice].BuildingDemo,
	tutorialGui.Frame[ChosenDevice].StopBuilding
}

local tutorialTableText = {

	tutorialGui.Frame[ChosenDevice].TakeBox,
	tutorialGui.Frame[ChosenDevice].DropBox,
	tutorialGui.Frame[ChosenDevice].TalkToNPC,
	tutorialGui.Frame[ChosenDevice].Dialogue,
	tutorialGui.Frame[ChosenDevice].OpenBox,
	tutorialGui.Frame[ChosenDevice].BreakRocks,
	tutorialGui.Frame[ChosenDevice].BuildBox,
	tutorialGui.Frame[ChosenDevice].Building,
	tutorialGui.Frame[ChosenDevice].StopBuilding
}


--check tutorial buttons
tutorialGui.Frame.NextButton.Activated:Connect(function()
	
	if tutorialIndex < 9 then
		
		tutorialIndex += 1
		
		for i=1, table.maxn(tutorialTable), 1 do
			
			if i == tutorialIndex then
				
				tutorialTable[i].Visible = true
				tutorialTableText[i].Visible = true
			else
				
				tutorialTable[i].Visible = false
				tutorialTableText[i].Visible = false
			end
		end
	else
		
		tutorialIndex = 1
		
		for i=1, table.maxn(tutorialTable), 1 do

			if i == tutorialIndex then

				tutorialTable[i].Visible = true
				tutorialTableText[i].Visible = true
			else

				tutorialTable[i].Visible = false
				tutorialTableText[i].Visible = false
			end
		end
	end
end)


tutorialGui.Frame.BackButton.Activated:Connect(function()
	
	if tutorialIndex > 0 then

		tutorialIndex -= 1

		for i=1, table.maxn(tutorialTable), 1 do

			if i == tutorialIndex then

				tutorialTable[i].Visible = true
				tutorialTableText[i].Visible = true
			else

				tutorialTable[i].Visible = false
				tutorialTableText[i].Visible = false
			end
		end
	else

		tutorialIndex = 9

		for i=1, table.maxn(tutorialTable), 1 do

			if i == tutorialIndex then

				tutorialTable[i].Visible = true
				tutorialTableText[i].Visible = true
			else

				tutorialTable[i].Visible = false
				tutorialTableText[i].Visible = false
			end
		end
	end
end)


tutorialGui.Frame.CloseButton.Activated:Connect(function()
	
	tutorialGui.Enabled = false
	MoneyGui.Enabled = true
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
end)

--[[ U 
  Using for loops to fill in the button text and getting the names of the enumerators used to identify keys in roblox would have been
  so much faster and easier to change than this. Since I could just edit one string in one for loop and it would change characteristics
  for every other gui info thingy.
]]--
local function ChooseControlDesc(device, control)
	
	if device == "Keyboard" then
		
		if control.Name == "LMBLabel" then
			
			control.Text = "Left Click"
		elseif control.Name == "ELabel" then
			
			control.Text = "Key: E"
		elseif control.Name == "GLabel" then
			
			control.Text = "Key: G"
		elseif control.Name == "MLabel" then
			
			control.Text = "Key: M"
		elseif control.Name == "RLabel" then
			
			control.Text = "Key: R"
		end
		
	elseif device == "Controller" then
		
		if control.Name == "LMBLabel" then

			control.Text = "Right Trigger"
		elseif control.Name == "ELabel" then

			control.Text = "Button: X"
		elseif control.Name == "GLabel" then

			control.Text = "Button: B"
		elseif control.Name == "MLabel" then

			control.Text = "Button: Y"
		elseif control.Name == "RLabel" then

			control.Text = "D-Pad: Right"
		end
		
	elseif device == "Tablet" then
		
		if control.Name == "LMBLabel" then

			control.Text = "Tap"
		elseif control.Name == "ELabel" then

			control.Text = "Hold Tap"
		elseif control.Name == "GLabel" then

			control.Text = "Tap"
		elseif control.Name == "MLabel" then

			control.Text = "Hold Tap"
		elseif control.Name == "RLabel" then

			control.Text = "Swipe"
		end
	end
end


local settingsGui = game.Players.LocalPlayer.PlayerGui.MoneyGui
local settingsOpen = settingsGui.Frame.Settings
local controlsOpen = settingsGui.Frame.MainButtons.ControlsButton
local mainButtonsTable = settingsGui.Frame.MainButtons:GetChildren()
local controlsTable = settingsGui.Frame.Controls:GetChildren()
local settingsAreOpen = false
local controlsAreOpen = false

settingsOpen.Activated:Connect(function()
	
	if settingsAreOpen == false then
		
		for i=1, table.maxn(mainButtonsTable), 1 do

			mainButtonsTable[i].Visible = true
			
		end
		
		settingsAreOpen = true
	elseif settingsAreOpen == true then
		
		for i=1, table.maxn(mainButtonsTable), 1 do

			mainButtonsTable[i].Visible = false
		end
		
		for i=1, table.maxn(controlsTable), 1 do
			
			controlsTable[i].Visible = false
		end
		controlsAreOpen = false
		settingsAreOpen = false
	end
end)

controlsOpen.Activated:Connect(function()
	
	print('activated!')
	if controlsAreOpen == false then
		
		for i=1, table.maxn(controlsTable), 1 do

			controlsTable[i].Visible = true
			
			ChooseControlDesc(ChosenDevice, controlsTable[i])
		end
		
		controlsAreOpen = true
	elseif controlsAreOpen == true then
		
		for i=1, table.maxn(controlsTable), 1 do

			controlsTable[i].Visible = false
		end

		controlsAreOpen = false
	end
end)


local SaveCoolDown = 0
local DisplayTime = false
local SaveRemote = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("SaveRemote")
local SaveSuccess = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("SaveSuccess")
local AutoSaveUpdate = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("AutoSaveUpdate")

local saveButton = settingsGui.Frame.MainButtons.SaveButton

saveButton.Activated:Connect(function()
	
	if tick() - SaveCoolDown > 60 then
		
		SaveCoolDown = tick()
		--save remote should be a remote function so that we may recieve a return that says if the save was successful or not.
		local saveBool = SaveRemote:InvokeServer()
		
		if saveBool == true then
			
			DisplayTime = false
			saveButton.Text = "Saving..."
		end
	end
end)


SaveSuccess.OnClientEvent:Connect(function(saveBool)
	
	if saveBool == true then
		
		saveButton.Text = "Saved!"
	else
		
		saveButton.Text = "Failed!"
	end
	
	task.wait(5)
	
	DisplayTime = true
end)


AutoSaveUpdate.OnClientEvent:Connect(function()
	
	
	DisplayTime = false
	saveButton.Text = "Saving..."
end)

--counts down the time to save
while true do
	
	if DisplayTime == true then
		
		if tick() - SaveCoolDown < 60 then
			
			saveButton.Text = tostring(math.floor(60 - (tick() - SaveCoolDown)))
		else
			
			DisplayTime = false
			saveButton.Text = "Save"
		end
	end
	
	task.wait(1)
end
