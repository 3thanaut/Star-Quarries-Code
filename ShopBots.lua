--for pathing and animating the shop bots

local animateBots = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("AnimateShopBots")

local objectives = {}
local shopParent = {}

local debounce = true


while true do
	
	--delay so it doesnt crash
	task.wait(1)
	
	local parts = workspace:GetPartsInPart(workspace["Map Parts"].RidgeShop.RidgeShopFloor)
	
	for i=1, table.maxn(parts), 1 do
		
		if parts[i]:GetAttribute("buy") then
			
			if parts[i]:GetAttribute("ownerId") ~= 0 then
				
				--add this to a table of parts that boomba needs to trace to
				table.insert(objectives, parts[i])
				table.insert(shopParent, "RidgeShop")
				--index of item and shop parent are therefore identical	
			end	
		end
		
		if i >= table.maxn(parts) then
			
			--check if anything to go to
			if table.maxn(objectives) > 0 then

				
				--take the first index of objectives and start checking them off
				animateBots:FireAllClients("boomba", objectives[1].Position)
				
				workspace["Map Parts"].RidgeShop.boombaTrack.Position = Vector3.new(objectives[1].Position.X, workspace["Map Parts"].RidgeShop.boomba.PrimaryPart.Position.Y, objectives[1].Position.Z)

				table.remove(objectives, 1)
				
				task.wait(3)--wait for roomba to get there then delete
				
				local deleteParts = workspace:GetPartsInPart(workspace["Map Parts"].RidgeShop.boombaTrack)
				
				for t=1, table.maxn(deleteParts), 1 do
					
					if deleteParts[t]:GetAttribute("buy") and deleteParts[t]:GetAttribute("ownerId") ~= 0 then
						
						deleteParts[t].Parent:Destroy()
						
						for c=1, table.maxn(objectives), 1 do
							
							if objectives[c] == deleteParts[t] then
								
								table.remove(objectives, c)
								
								print(objectives)
							end
						end
					end
				end
			end
		end
	end
end






