local leftwheel = script.Parent.Parent.LeftWheel

local leftwheel2 = script.Parent.Parent.LeftWheel2

local rightwheel = script.Parent.Parent.RightWheel

local rightwheel2 = script.Parent.Parent.RightWheel2

local steer = script.parent.Parent.Steer



local speed = script.Parent.Parent.Outline:GetAttribute("speed")

script.Parent.Changed:Connect(function(property)

	leftwheel.AngularVelocity = speed * -script.Parent.Throttle

	leftwheel2.AngularVelocity = speed * -script.Parent.Throttle

	rightwheel.AngularVelocity = speed * script.Parent.Throttle

	rightwheel2.AngularVelocity = speed * script.Parent.Throttle

	steer.TargetAngle = 20 * script.Parent.Steer

end)

local Seat =  script.Parent -- Path to seat
local Players = game:GetService("Players")
local PlayerTable = Players:GetPlayers()

Seat:GetPropertyChangedSignal("Occupant"):Connect(function()
	
	if Seat.Occupant ~= nil then
		
		for i=1, table.maxn(PlayerTable), 1 do
			
			if Players:GetPlayerFromCharacter(Seat.Occupant.Parent).UserId ~= Seat.Parent.Outline:GetAttribute("ownerId") then
				
				
				while Seat.Occupant ~= nil do
					
					task.wait(1)
					if Seat.Occupant ~= nil then
						
						Seat.Occupant.Health -= 20
						leftwheel.Anchored = true
						leftwheel2.Anchored = true
						rightwheel.Anchored = true
						rightwheel2.Anchored = true
					else
						
						break
					end
				end
			else
				
				leftwheel.Anchored = false
				leftwheel2.Anchored = false
				rightwheel.Anchored = false
				rightwheel2.Anchored = false
			end
		end
	end
end)
