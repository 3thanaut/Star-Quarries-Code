local saveRemote = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("SaveRemote")
local SaveQueue = game:GetService("ReplicatedStorage")["BindableEvents"]:FindFirstChild("SaveQueue")
local ManualSaveCoolDown = {}
local getOwnedItems = {}

--when a player joins
game.Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Connect(function(character)

		--every minute can manually save
		ManualSaveCoolDown[player] = 0
	end)
end)

--when a player hits the button
saveRemote.OnServerInvoke = function(player)
	
	--cooldown for save, make sure!
	if tick() - ManualSaveCoolDown[player] > 60 then
		
		ManualSaveCoolDown[player] = tick()
		
		print("manual saving")
		SaveQueue:Fire(player)
		
		return true
	else
		
		return false
	end
end
