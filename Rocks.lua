

--bindable event triggers this script, break rock, add it to table, rebuild it later. Also dont forget to drop a part for the player
local rockBreak = game:GetService("ReplicatedStorage")["BindableEvents"]:FindFirstChild("RockBreak")

--table for storing all the broken rocks in game, will loop through this when replacing
local brokenRocks = {}

--makes the boulders and all their random rocks
local function buildBoulder(folder)
	
	local boulders = folder:GetChildren()
	
	for i=1, table.maxn(boulders), 1 do
		
		if boulders[i]:IsA("Model") then
			
			local rocks = boulders[i]:GetChildren()
			
			for t=1, table.maxn(rocks), 1 do
				
				if rocks[t].Name == "place" or rocks[t].Name == "Outline" then
					
					local range = boulders[i]:GetAttribute("range")
					local choice = math.random(1,range)
					local choiceRock = game:GetService("ReplicatedStorage")["Boulders"]:FindFirstChild(boulders[i]:GetAttribute(choice))
					
					rocks[t].Name = boulders[i]:GetAttribute(choice)
					rocks[t]:SetAttribute("hp", choiceRock:GetAttribute("hp"))
					rocks[t].Material = Enum.Material[choiceRock.Material.Name]
					rocks[t].Color = choiceRock.Color
				end
			end
		end
	end
end

local boulders = game.Workspace.Boulders
local mazecave = boulders.mazecave

buildBoulder(boulders.spawn)
buildBoulder(boulders.mushroomcave)
buildBoulder(boulders.HighRise)
buildBoulder(boulders.IndustryCave)
buildBoulder(boulders.TheChalk)

buildBoulder(mazecave.ironroom)
buildBoulder(mazecave.diamondcave)
buildBoulder(mazecave.lowtiergemcorner)
buildBoulder(mazecave.mediumtiergemcorner)

buildBoulder(boulders.GoldPlatform)
buildBoulder(boulders.North.Entrance)
buildBoulder(boulders.North.CopperField)
buildBoulder(boulders.IronField)

--determine size of rock
local function rockSize()
	
	--randomly choose between the 5 options
	local choice = math.random(1, 4)
	
	--determine size based on choice
	if choice then
		
		return Vector3.new(1 + 1-(0.25*choice), 1 + 1-(0.25*choice), 1 + 1-(0.25*choice))
	end
end

--when this bindable is passed, it comes with an instance
local function makeRock(player, rock)
		
	-- break the rock
	--fireclient rock break sound
	table.insert(brokenRocks, rock)

	--make rock invisible and untouchable
	rock.CanCollide = false
	rock.CanTouch = false
	rock.CanQuery = false
	rock.Transparency = 1
	
	--make a new part at the rocks position
	local newPart = game:GetService("ReplicatedStorage")["Rocks"]:FindFirstChild(rock.Name):Clone()
	newPart.Parent = workspace
	newPart.Position = rock.Position
	newPart.Size = rockSize()
	newPart:SetAttribute("ownerId", player.UserId)
	newPart:SetAttribute("value", math.round(newPart:GetAttribute("value")*newPart.Size.X))
	
	return newPart
end

rockBreak.OnInvoke = makeRock






local Lighting = game:GetService("Lighting")
local TweenS = game:GetService("TweenService")
local TweenI = TweenInfo.new(1440,Enum.EasingStyle.Linear, Enum.EasingDirection.In) --first value is how long you want it to take

Lighting.ClockTime = 6
local toMidnight = TweenS:Create(Lighting, TweenI, {ClockTime = 24})

while true do
	
	toMidnight:Play()
	toMidnight.Completed:Wait()
	
	--fire the event that makes all the rocks come back
	for i=1, table.maxn(brokenRocks), 1 do

		--set health and visibility back
		brokenRocks[i]:SetAttribute("hp", game:GetService("ReplicatedStorage")["Boulders"]:FindFirstChild(brokenRocks[i].Name):GetAttribute("hp"))

		brokenRocks[i].CanCollide = true
		brokenRocks[i].CanTouch = true
		brokenRocks[i].CanQuery = true

		brokenRocks[i].Transparency = 0

		--once loop is done clear rocks
		if i >= table.maxn(brokenRocks) then
			
			print("replaced")
			brokenRocks = {}
		end
	end
end

