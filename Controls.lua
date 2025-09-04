--[[ U 
  This is the client side of the main script.
]]--

--neat stuffs
local ActionEvents = game:GetService("ReplicatedStorage")["RemoteEvents"]["Actions"]
local BindableEvents = game:GetService("ReplicatedStorage")["BindableEvents"]
local ContextActionService = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")

--remote stuffs
--bound to LMB, or RT on console (default)
local MineAction = ActionEvents:FindFirstChild("MineRemote")
local PressAction = ActionEvents:FindFirstChild("PressAction")
local PickUpAction = ActionEvents:FindFirstChild("PickUpRemote")

--bound to E key, or X on console (default)
local NPCAction = ActionEvents:FindFirstChild("NPCAction")
local OpenAction = ActionEvents:FindFirstChild("OpenAction")

--bound to M key, or Y on console (default)
local BuildAction = ActionEvents:FindFirstChild("BuildRemote")

--bound to G, or B on console (default)
local DropAction = ActionEvents:FindFirstChild("DropRemote")

--rebinding keys
local ControlChange = BindableEvents:FindFirstChild("ControlChange")

--player stuffs
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local playerHeldItem = nil
local character = player.Character or game.Players.LocalPlayer.CharacterAdded:Wait()


--functions!

--raycast function
local function rayCast(rayDest, rayLength, ignorePart)
	
	--raydirection and parameter
	local rayOrigin = character.Head.Position
	local rayDirection = (rayDest - rayOrigin).Unit
	local rayParams = RaycastParams.new()

	--exclude player character
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {

		game.Players.LocalPlayer.Character,
		--workspace["Map Parts"],
		ignorePart

	}
	
	--raycast to check if the player is actually hitting something
	local ray = workspace:Raycast(rayOrigin, rayDirection * rayLength, rayParams)
	return ray
end


--description function
local function getDescription(outline)

	if outline ~= nil then

		local descGui = game.Players.LocalPlayer.PlayerGui.DescriptionGui.Frame
		local modelInside
		local buildable

		if outline.Parent:FindFirstChildOfClass("Model") ~= nil then

			modelInside = outline.Parent:FindFirstChildOfClass("Model")

			if outline:GetAttribute("cube") == true then

				buildable = game:GetService("ReplicatedStorage")["CompressionCubes"]:FindFirstChild(modelInside.Name)
			else

				buildable = game:GetService("ReplicatedStorage")["Buildables"]:FindFirstChild(modelInside.Name)
			end

		elseif outline.Parent:FindFirstChildOfClass("Tool") ~= nil then

			modelInside = outline.Parent:FindFirstChildOfClass("Tool")
			buildable = game:GetService("ReplicatedStorage")["Tools"]:FindFirstChild(modelInside.Name)
		end

		descGui.TextLabel.Text = outline.Parent.Sign.SurfaceGui.TextLabel.Text

		if buildable ~= nil then
			
			local price = tostring("\n" .. "Price: " .. outline:GetAttribute("price"))
			if buildable.Outline:GetAttribute("polisher") == true then

				descGui.Description.Text = tostring("Increase: " .. buildable.Outline:GetAttribute("increase") .. "x + 10$" .. "\n" .. "Polish Power: " .. buildable.Outline:GetAttribute("polishLvl") .. "\n" .. "Only works on rocks and gems." .. "\n" .. price)
				descGui.Parent.Enabled = true
			elseif buildable.Outline:GetAttribute("type") == "pickaxe" then

				descGui.Description.Text = tostring("Damage: " .. buildable.Outline:GetAttribute("dmg") .. "\n" .. "Swing Time: " .. buildable.Outline:GetAttribute("spd") .. price)
				descGui.Parent.Enabled = true
			elseif buildable.Outline:GetAttribute("drill") == true then

				descGui.Description.Text = tostring("Depth: " .. buildable.Outline:GetAttribute("depth") .. "\n" .. "Drill Time: " .. buildable.Outline:GetAttribute("time") .. price)
				descGui.Parent.Enabled = true
			elseif buildable.Outline:GetAttribute("blaster") == true then

				descGui.Description.Text = tostring("Increase: " .. buildable.Outline:GetAttribute("increase") .. "x \n" ..  "Polish Power: " .. buildable.Outline:GetAttribute("polishLvl1") .. "\nOnly works on washed gems." .. price)
				descGui.Parent.Enabled = true
			elseif buildable.Outline:GetAttribute("washer") == true then

				descGui.Description.Text = tostring("Increase: " .. buildable.Outline:GetAttribute("increase") .. "x + 10$" .. "\nOnly works on rocks and gems." .. price)
				descGui.Parent.Enabled = true
			elseif buildable.Outline:GetAttribute("type") == "cube" then

				descGui.Description.Text = tostring("Capacity: " .. buildable.Outline:GetAttribute("capacity") .. " rocks." .. "\nActivate near rocks to contain them." .. price)
				descGui.Parent.Enabled = true
			elseif buildable.Outline:GetAttribute("seller") == true then

				descGui.Description.Text = tostring("Sells items when they are dropped into the lava. Awesome for the atmosphere!" .. price)
				descGui.Parent.Enabled = true
			elseif buildable.Outline:GetAttribute("speed") ~= nil then

				descGui.Description.Text = tostring("Adds direction and magnitude, oh yeah!" .. price)
				descGui.Parent.Enabled = true
			elseif buildable.Outline:GetAttribute("furnace") == true then
				
				descGui.Description.Text = tostring("Increase: " .. buildable.Outline:GetAttribute("increase") .. "x + 10$" .. "\n" .. "Smelt Power: " .. buildable.Outline:GetAttribute("smeltLvl") .. "\n" .. "Only works on metals." .. "\n" .. price)
				descGui.Parent.Enabled = true
			end
		end
	end
end



--pick up item function
local function PickUpFunc(ActionName, InputState, InputObject)
	
	if InputState == Enum.UserInputState.Begin then
		
		local ray = rayCast(mouse.Hit.Position, 10)

		if ray then

			if (ray.Instance:GetAttribute("ownerId") == player.UserId or ray.Instance:GetAttribute("ownerId") == 0) and ray.Instance:GetAttribute("pickUp") == true then
				
				print("pickUp")
				PickUpAction:FireServer(mouse.Hit.Position, ray.Instance)
				playerHeldItem = ray.Instance
				
				--play the pick up noise!
				local sound = Instance.new("Sound", playerHeldItem)
				sound.SoundId = "rbxassetid://8031021863"

				--volume degrades over distance by roblox already
				sound.Volume = 0.5

				--play the sound
				sound:Play()
				
				return Enum.ContextActionResult.Sink
			else
				
				return Enum.ContextActionResult.Pass
			end
		else
			
			return Enum.ContextActionResult.Pass
		end
	end
end

--press button function
local function PressFunc(ActionName, InputState, InputObject)
	
	if InputState == Enum.UserInputState.Begin then
		
		local ray = rayCast(mouse.Hit.Position, 10)

		if ray then
			
			if ray.Instance.Parent:FindFirstChild("Outline") == nil then print("no outline") return Enum.ContextActionResult.Pass end
			
			if ray.Instance.Parent.Outline:GetAttribute("ownerId") == player.UserId and ray.Instance:GetAttribute("type") == "button" then
				
				if mouse.Target == ray.Instance then
					
					print("button fired")
					PressAction:FireServer(mouse.Hit.Position, ray.Instance)
					
					--play button sound
					local sound = Instance.new("Sound", ray.Instance)
					sound.SoundId = "rbxassetid://16480560696"

					--volume degrades over distance by roblox already
					sound.Volume = 0.5

					--play the sound
					sound:Play()
					
					return Enum.ContextActionResult.Sink
				else
					
					return Enum.ContextActionResult.Pass
				end
			else
				
				return Enum.ContextActionResult.Pass
			end
		else
			
			return Enum.ContextActionResult.Pass
		end
	end
end

--mine rock function
local function MineFunc(ActionName, InputState, InputObject)
	
	if InputState == Enum.UserInputState.Begin then
		
		local ray = rayCast(mouse.Hit.Position, 10)

		if ray then

			if player.Character:FindFirstChildOfClass("Tool") ~= nil then
				
				MineAction:FireServer(mouse.Hit.Position, ray.Instance)
				return Enum.ContextActionResult.Sink
			end
		end
	end
end


--description GUI function
local function DescFunc(ActionName, InputState, InputObject)

	if InputState == Enum.UserInputState.Begin then

		local ray = rayCast(mouse.Hit.Position, 10)

		if ray then

			if ray.Instance:GetAttribute("buy") == true and ray.Instance:GetAttribute("type") == "box" then
				
				getDescription(ray.Instance)
				return Enum.ContextActionResult.Sink
			else

				return Enum.ContextActionResult.Pass
			end
		else

			return Enum.ContextActionResult.Pass
		end
	end
end

--open box function
local function OpenFunc(ActionName, InputState, InputObject)

	if InputState == Enum.UserInputState.Begin then

		local ray = rayCast(mouse.Hit.Position, 10)

		if ray then

			if ray.Instance:GetAttribute("buy") ~= true and ray.Instance:GetAttribute("type") == "box" then
				
				print("trying to open")
				OpenAction:FireServer(mouse.Hit.Position, ray.Instance)
				return Enum.ContextActionResult.Sink
			else

				return Enum.ContextActionResult.Pass
			end
		else

			return Enum.ContextActionResult.Pass
		end
	end
end

--talk to NPC function
local function NPCFunc(ActionName, InputState, InputObject)

	if InputState == Enum.UserInputState.Begin then

		local ray = rayCast(mouse.Hit.Position, 10)

		if ray then
				
			if ray.Instance.Parent:GetAttribute("NPC") == true then
				
				NPCAction:FireServer(mouse.Hit.Position, ray.Instance.Parent)
				return Enum.ContextActionResult.Sink
			end
		else
			
			print("doesnt work")
		end
	end
end

local function BuildFunc(ActionName, InputState, InputObject)
	
	if InputState == Enum.UserInputState.Begin then

		local ray = rayCast(mouse.Hit.Position, 10)

		if ray then

			if ray.Instance.Parent:FindFirstChild("Outline") ~= nil then
				
				if ray.Instance.Parent.Outline:GetAttribute("type") == "buildable" and ray.Instance.Parent.Outline:GetAttribute("ownerId") == player.UserId then
					
					BuildAction:FireServer(mouse.Hit.Position, ray.Instance.Parent.Outline)
					return Enum.ContextActionResult.Sink
				end
			end
		end
	end
end

local function DropFunc(ActionName, InputState, InputObject)
	
	if playerHeldItem == nil then return end
	
	if InputState == Enum.UserInputState.Begin then
		
		local ray
		
		if playerHeldItem.Name == "Outline" then
			
			ray = rayCast(mouse.Hit.Position, 10, playerHeldItem.Parent)
		else
			
			ray = rayCast(mouse.Hit.Position, 10, playerHeldItem)
		end

		if ray then
			
			print("going to mouse pose")
			DropAction:FireServer(ray.Position, playerHeldItem)
			
			--play kerplunk sound
			local sound = Instance.new("Sound", playerHeldItem)
			sound.SoundId = "rbxassetid://12222054"

			--volume degrades over distance by roblox already
			sound.Volume = 0.5

			--play the sound
			sound:Play()
			
			playerHeldItem = nil
			
			return Enum.ContextActionResult.Sink
		else
			
			print("failed ray")
			DropAction:FireServer(nil, playerHeldItem)
			
			if playerHeldItem ~= nil then
				
				--play kerplunk sound
				local sound = Instance.new("Sound", playerHeldItem)
				sound.SoundId = "rbxassetid://12222054"

				--volume degrades over distance by roblox already
				sound.Volume = 0.5

				--play the sound
				sound:Play()
			end

			playerHeldItem = nil
			
			return Enum.ContextActionResult.Sink
		end
	end
end



--should trigger LMB or buttonRT (default)
ContextActionService:BindActionAtPriority("PickUpAction", PickUpFunc, false, 10, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)
ContextActionService:BindActionAtPriority("PressAction", PressFunc, false, 9, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)
ContextActionService:BindActionAtPriority("MineAction", MineFunc, false, 8, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)

--should trigger E or buttonX (default)
ContextActionService:BindActionAtPriority("DescAction",	DescFunc, false, 10, Enum.KeyCode.E, Enum.KeyCode.ButtonX)
ContextActionService:BindActionAtPriority("OpenAction", OpenFunc, false, 9, Enum.KeyCode.E, Enum.KeyCode.ButtonX)
ContextActionService:BindActionAtPriority("NPCAction", NPCFunc, false, 8, Enum.KeyCode.E, Enum.KeyCode.ButtonX)

--triggers on button M (default)
ContextActionService:BindActionAtPriority("BuildAction", BuildFunc, false, 10, Enum.KeyCode.M, Enum.KeyCode.ButtonY)

--triggers on button G (default)
ContextActionService:BindActionAtPriority("DropAction", DropFunc, false, 10, Enum.KeyCode.G, Enum.KeyCode.ButtonB)



--stupid mobile functionality
UIS.TouchTap:Connect(function(touchPos, gameProcessed)
	
	if gameProcessed == true then return end
	
	--if you tap, you press button or pickup or swing pick, or drop if holding rock
	local ray = rayCast(mouse.Hit.Position, 10)

	if ray then
		
		if playerHeldItem ~= nil then
		
			local dropRay

			if playerHeldItem.Name == "Outline" then

				dropRay = rayCast(mouse.Hit.Position, 10, playerHeldItem.Parent)
			else

				dropRay = rayCast(mouse.Hit.Position, 10, playerHeldItem)
			end

			if dropRay then

				print("going to mouse pose")
				DropAction:FireServer(dropRay.Position, playerHeldItem)
				playerHeldItem = nil
			else

				print("failed ray")
				DropAction:FireServer(nil, playerHeldItem)
				playerHeldItem = nil
			end
			
		elseif (ray.Instance:GetAttribute("ownerId") == player.UserId or ray.Instance:GetAttribute("ownerId") == 0) and ray.Instance:GetAttribute("pickUp") == true then

			print("pickUp")
			PickUpAction:FireServer(mouse.Hit.Position, ray.Instance)
			playerHeldItem = ray.Instance
			
		elseif ray.Instance:GetAttribute("hp") ~= nil and player.Character:FindFirstChildOfClass("Tool") ~= nil then
			
			MineAction:FireServer(mouse.Hit.Position, ray.Instance)
			
		elseif ray.Instance.Parent:FindFirstChild("Outline") ~= nil then
			
			if ray.Instance.Parent.Outline:GetAttribute("ownerId") == player.UserId and ray.Instance:GetAttribute("type") == "button" then

				if mouse.Target == ray.Instance then

					print("button fired")
					PressAction:FireServer(mouse.Hit.Position, ray.Instance)
				end
			end
		end
	end
end)


UIS.TouchLongPress:Connect(function(touchPos, gameProcessed)
	
	if gameProcessed == true then return end
	
	--if you hold press, check descriptions, talk to npc's, and enter build mode, and open boxes
	local ray = rayCast(mouse.Hit.Position, 10)
	
	if ray.Instance.Parent:GetAttribute("NPC") == true then --talk to NPC

		NPCAction:FireServer(mouse.Hit.Position, ray.Instance.Parent)
		
	elseif ray.Instance:GetAttribute("buy") == true and ray.Instance:GetAttribute("type") == "box" then --open description
		
		getDescription(ray.Instance)
		
	elseif ray.Instance:GetAttribute("buy") ~= true and ray.Instance:GetAttribute("type") == "box" then --open box
		
		OpenAction:FireServer(mouse.Hit.Position, ray.Instance)
		
	elseif ray.Instance.Parent:FindFirstChild("Outline") ~= nil then --for things where we have to find outline
		
		if ray.Instance.Parent.Outline:GetAttribute("type") == "buildable" then --if the thing is buildable

			BuildAction:FireServer(mouse.Hit.Position, ray.Instance.Parent.Outline)
		end
	end
end)


game.Players.LocalPlayer.PlayerGui.DescriptionGui.Frame.exitButton.Activated:Connect(function()

	game.Players.LocalPlayer.PlayerGui.DescriptionGui.Enabled = false
end)
