local playerService = game:GetService("Players")
local players
local saveEvent = game:GetService("ReplicatedStorage")["BindableEvents"]:FindFirstChild("SaveQueue")
local GiveOwnedItems = game:GetService("ReplicatedStorage")["BindableEvents"]:FindFirstChild("GiveOwnedItems")
local playerSaveTime = {}
local getOwnedItems = {}
local loaded = false

--when a player joins
game.Players.PlayerAdded:Connect(function(player)
	
	player.CharacterAdded:Connect(function(character)
		
		--auto save every 5 minutes
		playerSaveTime[player] = 300
		players = playerService:GetPlayers()
		loaded = true
	end)
end)


while true do
	
	if loaded == true then
		
		players = playerService:GetPlayers()
		
		for i=1, table.maxn(players), 1 do
			
			if playerSaveTime[players[i]] > 0 then
				
				playerSaveTime[players[i]] -= 1
			else
				
				--adds them to the queue
				print("autosave fired")
				playerSaveTime[players[i]] = 300
				saveEvent:Fire(players[i])
			end
		end
	end
	
	task.wait(1)
end
