--this script should allow for built part to follow player cursor

local buildEvent = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("BuildEvent")
local buildGuiSwitch = game:GetService("ReplicatedStorage")["BindableEvents"]:FindFirstChild("BuildGuiSwitch")
local buildGuiDevice = game:GetService("ReplicatedStorage")["BindableEvents"]:FindFirstChild("BuildGuiDevice")
local ControlChange = game:GetService("ReplicatedStorage")["BindableEvents"]:FindFirstChild("ControlChange")

local UIS = game:GetService("UserInputService")

local mobileBuildDebounce = false


local function buildMode(mouse, newModel, relativePart)	
	
	--just make a bindable that requests the input type from the controls thingy if oyu need to detect whether keyboard or controlelr chosen
	
	--parent to workspace
	newModel.Parent = workspace

	--get children of the model to change characteristics
	local children = newModel:GetChildren()
	
	--position the part
	local pos = Vector3.new(0, 0, 0)
	local lookVector = Vector3.new(relativePart.CFrame.LookVector.X, relativePart.CFrame.LookVector.Y, relativePart.CFrame.LookVector.Z)
	local upVector = Vector3.new(newModel.Outline.CFrame.UpVector.X, newModel.Outline.CFrame.UpVector.Y, newModel.Outline.CFrame.UpVector.Z)
	local rightVector = lookVector:Cross(upVector)
	local relativeCFrame = CFrame.fromMatrix(pos, rightVector, upVector, -lookVector)

	--for all children change characteristics
	for i=1, table.maxn(children), 1 do
		
		if children[i]:IsA("Script") then
			
			--do nothing
		else
			
			children[i].CanCollide = false
			children[i].CanTouch = false
			children[i].CanQuery = false
			children[i].Transparency = 0.5
			children[i].Color = Color3.new(0.0431373, 0.713725, 1)
			if children[i].Name == "Outline" then 
				
				children[i].Transparency = 1
			end

			--when the loop ends
			if i >= table.maxn(children) then
				
				local build = true
				local rotationCount = 0
				
				
				local clickConnection = UIS.InputBegan:Connect(function(input, gameProcessed)
					
					if build == true then

						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2 then

							if math.abs(newModel.PrimaryPart.Position.X - relativePart.Position.X) < relativePart.Parent.Part.Size.X/2 and math.abs(newModel.PrimaryPart.Position.Z - relativePart.Position.Z) < relativePart.Parent.Part.Size.Z/2 then

								buildEvent:FireServer(mouse.Hit.Position, rotationCount)

								newModel:Destroy()
							else

								print("cannot build outside of owned area")
							end
						elseif input.KeyCode == Enum.KeyCode.R or input.KeyCode == Enum.KeyCode.DPadRight then

							--one count for every 90 degrees turned
							if rotationCount >= 3 then

								rotationCount = 0
							else

								rotationCount += 1
							end
						end
					end
				end)
				
				local player = game.Players.LocalPlayer
				local mobileFrame = player.PlayerGui.MobileChoiceGui.Frame

				local swipeConnection = UIS.TouchSwipe:Connect(function()
					
					if newModel.PrimaryPart == nil then return end
					
					if mobileBuildDebounce == false then

						mobileBuildDebounce = true

						--one count for every 90 degrees turned
						if rotationCount >= 3 then

							rotationCount = 0
						else

							rotationCount += 1
						end

						--set the models CFrame to its current pos at gnd lvl
						newModel.PrimaryPart.CFrame = CFrame.new(
							math.floor(newModel.PrimaryPart.Position.X),
							math.floor(newModel.PrimaryPart.Position.Y),
							math.floor(newModel.PrimaryPart.Position.Z))*CFrame.Angles(0, math.rad(90*rotationCount), 0)*relativeCFrame

						print("activated Choice 2")

						task.wait(0.2)

						mobileBuildDebounce = false
					end
				end)

				local tapConnection = UIS.TouchTap:Connect(function()
					
					if mobileBuildDebounce == false then

						mobileBuildDebounce = true

						if newModel.PrimaryPart ~= nil then

							local player = game.Players.LocalPlayer
							local mobileFrame = player.PlayerGui.MobileChoiceGui.Frame

							if math.abs(newModel.PrimaryPart.Position.X - relativePart.Position.X) < relativePart.Parent.Part.Size.X/2 and math.abs(newModel.PrimaryPart.Position.Z - relativePart.Position.Z) < relativePart.Parent.Part.Size.Z/2 then

								local newModelPos = Vector3.new(math.floor(newModel.PrimaryPart.Position.X), 
																newModel.PrimaryPart.Position.Y - newModel:GetExtentsSize().Y/2,
																math.floor(newModel.PrimaryPart.Position.Z))

								buildEvent:FireServer(newModelPos, rotationCount)

								newModel:Destroy()

								game.Players.LocalPlayer.PlayerGui.MobileChoiceGui.Enabled = false
							else

								print("cannot build outside of owned area")
							end
						end

						print("activated Choice 1")

						task.wait(0.2)

						mobileBuildDebounce = false
					end
				end)
				
				local buildTask = task.spawn(function(buildTask)
					
					--activate build mode
					while true do
						
						if build == true then
							
							if newModel.PrimaryPart == nil then
								
								print("build off")
								build = false

								return
							else

								--set the models CFrame to the mouse position at ground level
								newModel.PrimaryPart.CFrame = CFrame.new(
									math.floor(mouse.Hit.Position.X),
									mouse.Hit.Position.Y + newModel.PrimaryPart:GetAttribute("YOffset"),
									math.floor(mouse.Hit.Position.Z))*CFrame.Angles(0, math.rad(90*rotationCount), 0)*relativeCFrame
							end
						else
							
							print("task destroyed")
							task.cancel(buildTask)
							swipeConnection:Disconnect()
							tapConnection:Disconnect()
							clickConnection:Disconnect()
						end

						--every tenth of a second
						task.wait(0.1)
					end
				end)
			end
		end
	end
end






buildEvent.OnClientEvent:Connect(function(name)
	
	--get player whose mouse we reference
	local mouse = game.Players.LocalPlayer:GetMouse()
	
	--get the actual items name we want to copy
	local box = game:GetService("ReplicatedStorage")["ShopItems"]:FindFirstChild(name)
	
	local relativePart
	
	for i=1, 6, 1 do
		
		if workspace.PlayerBases:FindFirstChild(tostring("Base" .. i)):FindFirstChild("RelativePart"):GetAttribute("plyrId") == game.Players.LocalPlayer.UserId then

			relativePart = workspace.PlayerBases[tostring("Base" .. i)].RelativePart
		end
	end
	
	--if the instance is a box, treat it the normal way
	if box then
		
		local newModel = game:GetService("ReplicatedStorage")["Buildables"]:FindFirstChild(box:FindFirstChildWhichIsA("Model").Name):Clone()
		
		buildMode(mouse, newModel, relativePart)
	else --otherwise pass the item we already know were working with
		
		print("from buildable")
		
		local newModel = game:GetService("ReplicatedStorage")["Buildables"]:FindFirstChild(name):Clone()
		
		buildMode(mouse, newModel, relativePart)
	end
end)



