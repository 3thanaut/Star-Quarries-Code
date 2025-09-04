--this will handle cave darkness and events
local player = game.Players.LocalPlayer
local LanternNear = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("LanternNear")


LanternNear.OnClientEvent:Connect(function(lanternBool)
	
	local character = player.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
	local torso = character.Torso

	local sightIncrease = 90*lanternBool
	
	--mushroom cave area
	if  (torso.Position.X < 471 and torso.Position.X > 287) and
		(torso.Position.Y > 392 and torso.Position.Y < 430) and
		(torso.Position.Z > 434 and torso.Position.Z < 614) then

		--can check if the player is holding a light so they can see further
		game.Lighting.FogColor = Color3.new(0, 0, 0)
		game.Lighting.FogEnd = 10 + sightIncrease

		--maze cave area
	elseif  (torso.Position.X > 182 and torso.Position.X < 434) and
		(torso.Position.Y > 269 and torso.Position.Y < 384) and
		(torso.Position.Z < 957 and torso.Position.Z > 691) then

		--can check if the player is holding a light so they can see further
		game.Lighting.FogColor = Color3.new(0, 0, 0)
		game.Lighting.FogEnd = 10 + sightIncrease

		--cobalt cave
	elseif  (torso.Position.X < 611 and torso.Position.X > 434) and
		(torso.Position.Y > 280 and torso.Position.Y < 384) and
		(torso.Position.Z < 949 and torso.Position.Z > 739) then

		--can check if the player is holding a light so they can see further
		game.Lighting.FogColor = Color3.new(0, 0, 0)
		game.Lighting.FogEnd = 10 + sightIncrease

		--Topaz Corner
	elseif  (torso.Position.X < 643 and torso.Position.X > 528) and
		(torso.Position.Y > 327 and torso.Position.Y < 384) and
		(torso.Position.Z < 767 and torso.Position.Z > 634) then

		--can check if the player is holding a light so they can see further
		game.Lighting.FogColor = Color3.new(0, 0, 0)
		game.Lighting.FogEnd = 10 + sightIncrease

		--the chalk
	elseif 	(torso.Position.X < -884 and torso.Position.X > -1752) and
		(torso.Position.Y > 266 and torso.Position.Y < 571) and
		(torso.Position.Z < -1349 and torso.Position.Z > -2225) then

		game.Lighting.FogColor = Color3.new(0.6, 0.8, 1)
		game.Lighting.FogEnd = 50
	else

		game.Lighting.FogColor = Color3.new(0.8, 0.8, 0.8)
		game.Lighting.FogEnd = 10000
	end
		
end)
