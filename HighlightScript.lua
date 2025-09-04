--[[
	Welcome! This is the client sided highlight script that would draw a white outline around rocks.
	This program changes the highlight colour to be gradually more red dependant on the targets health.
	Updated comments will be marked with a capital U at the start.
]]--


local mouse = game.Players.LocalPlayer:GetMouse()
local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()

-- U This is what we will call to get a ray object which we should be able to derive the target instance from.
local function rayCast(rayDest, rayLength, ignorePart)
	
	if character == nil then return end
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

	-- U this returns the entire ray object, we could just return the target.
	return ray
end


	
local highlighter = nil
local toolHighlight = nil

--[[ U
	this program constantly runs once per frame, instead of using while, it would be better to use heartbeat service.

	runservice.HeartBeat:Connect(function()
		then put everything in here :D
	end)
]]--
while true do

	-- U should define that 10 is the ray distance.
	local ray = rayCast(mouse.Hit.Position, 10)

	-- U good to check if the ray exists! The instance is not returned if it hits nothing.
	if ray then

		if ray.Instance:GetAttribute("hp") ~= nil then

			local rockAttributes = game:GetService("ReplicatedStorage")["Boulders"]:FindFirstChild(ray.Instance.Name)
			local currentHp = ray.Instance:GetAttribute("hp")
			local maxHp = rockAttributes:GetAttribute("hp")
			local subtractVal = (maxHp - currentHp)/maxHp

			--[[ U 
				because the highlighter object can only exist with up to 30 instances at once, they need to be cleared.
				instead of doing this in cases, one highlighter object should be defined and reparented as appropriate instead of creating a new instance every reselection.
			]]--
			if highlighter == nil then

				local highlight = Instance.new("Highlight")

				highlighter = highlight

				highlight.FillTransparency = 1
				highlight.OutlineColor = Color3.new(1,1 - subtractVal,1 - subtractVal)
				highlight.Parent = ray.Instance

				print("highlighted!")
			else

				if ray.Instance:FindFirstChild("Highlight") == nil then

					highlighter:Destroy()

					local highlight = Instance.new("Highlight")

					highlighter = highlight

					highlight.FillTransparency = 1
					highlight.OutlineTransparency = 1
					highlight.Parent = ray.Instance
				else

					highlighter.OutlineTransparency = 0
					highlighter.OutlineColor = Color3.new(1,1 - subtractVal,1 - subtractVal)
				end
			end
		elseif ray.Instance.Parent:IsA("Tool") then
			
			local outline = ray.Instance.Parent:FindFirstChild("Outline")
			
			if outline then

				--[[ U
					This was a bandaid fix for a problem as a product of disorganization. Having a consistent system where all primary parts have an attribute would
					have made much more sense with the current context. Outlines usually mean there is a tool or some form of interactable instance.
				]]--
				if outline:GetAttribute("type") ~= nil then
					
					if outline:GetAttribute("type") == "pickaxe" then
						
						toolHighlight = outline.Parent.Highlight
						
						toolHighlight.Enabled = true
					elseif outline:GetAttribute("type") == "lantern" then
						
						toolHighlight = outline.Parent.Highlight

						toolHighlight.Enabled = true
					elseif outline:GetAttribute("type") == "box" then
						
						if outline:GetAttribute("buy") == true then
							
							if highlighter == nil then
								
								local highlight = Instance.new("Highlight")

								highlighter = highlight

								highlight.FillTransparency = 0.8
								highlight.OutlineColor = Color3.new(1, 1, 1)
								highlight.Parent = outline.Parent
							else
								
								if outline.Parent:FindFirstChild("Highlight") == nil then

									highlighter:Destroy()

									local highlight = Instance.new("Highlight")

									highlighter = highlight

									highlight.FillTransparency = 0.8
									highlight.OutlineTransparency = 1
									highlight.Parent = outline.Parent
								else
									
									--what am I supposed to do? work on my life? fall over rules?
									highlighter.OutlineTransparency = 0
									highlighter.OutlineColor = Color3.new(1, 1, 1)
								end
							end
						end
					end
				end
			end
		else
			if highlighter ~= nil then

				highlighter:Destroy()
			elseif toolHighlight ~= nil then
				
				toolHighlight.Enabled = false
				toolHighlight = nil
			end
		end
	else

		if highlighter ~= nil then

			highlighter:Destroy()
		elseif toolHighlight ~= nil then
			
			toolHighlight.Enabled = false
			toolHighlight = nil
		end
	end

	task.wait()
end
