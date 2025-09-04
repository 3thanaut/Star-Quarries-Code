--this should make player experience with the shop actually enjoyable

--firstly, we want the item to instantly replace.
local itemRefresh = game:GetService("ReplicatedStorage")["BindableEvents"]:FindFirstChild("ItemRefresh")

--stores all store items in the game
local storeItems = game:GetService("CollectionService"):GetTagged("StoreItem")

--store item CFrames
local storeItemCFrame = {}

--make the original positions available
for i=1, table.maxn(storeItems), 1 do
	
	--index item = index position
	table.insert(storeItemCFrame, storeItems[i].CFrame)
end

--we want this to fire when a player picks up an item with the buy tag
itemRefresh.Event:Connect(function(item) --item is the outline of the object picked up
	
	--now that we have the item, we need to copy it and replace it at its old place
	local newItem = game:GetService("ReplicatedStorage")["ShopItems"]:FindFirstChild(item.Parent.Name):Clone()
	print(newItem.Name .. " new item!!")
	--find which index the item picked up is in
	for i=1, table.maxn(storeItems), 1 do
		
		--if outline stored is the same as our outline
		if storeItems[i] == item then
			
			--set parent of item to workspace
			newItem.Parent = workspace
			
			--replace the item in this index with newitem
			storeItems[i] = newItem.PrimaryPart
			
			task.wait(1)
			
			newItem.PrimaryPart.CFrame = storeItemCFrame[i]
			break
		end
	end
end)

local players = game:GetService("Players")
local playersInShop = {}

--when a player leaves the shop, all items inside that are theirs are eliminated
while true do
	
	local updatedStoreItems = game:GetService("CollectionService"):GetTagged("StoreItem")
	
	for i=1, table.maxn(players:GetPlayers()), 1 do
		
		local character = players:GetPlayers()[i].Character or players:GetPlayers()[i].CharacterAdded:Wait()
		local torso = character.Torso
		
		local leftPart = game.Workspace["Map Parts"].RidgeShop.LeftPart
		local rightPart = game.Workspace["Map Parts"].RidgeShop.RightPart
		
		local RidgeLeftPart = (torso.Position.X > leftPart.Position.X and torso.Position.X < rightPart.Position.X)
		local RidgeRightPart = (torso.Position.Z > rightPart.Position.Z and torso.Position.Z < leftPart.Position.Z)
		
		local frightPart = game.Workspace["Map Parts"].FelicityShop.RightPart
		local fleftPart = game.Workspace["Map Parts"].FelicityShop.LeftPart
		
		local FelicityLeftPart = (torso.Position.X < fleftPart.Position.X and torso.Position.X > frightPart.Position.X)
		local FelicityRightPart = (torso.Position.Z < frightPart.Position.Z and torso.Position.Z > fleftPart.Position.Z)
		
		local aleftPart = game.Workspace["Map Parts"].AarneShop.LeftPart
		local arightPart = game.Workspace["Map Parts"].AarneShop.RightPart
		
		local AarneLeftPart = (torso.Position.X > aleftPart.Position.X and torso.Position.X < arightPart.Position.X)
		local AarneRightPart = (torso.Position.Z > arightPart.Position.Z and torso.Position.Z < aleftPart.Position.Z)
		
		
		
		if (RidgeLeftPart and RidgeRightPart) or (FelicityLeftPart and FelicityRightPart) or (AarneLeftPart and AarneRightPart) then
			
			print("in a shop")
			playersInShop[players:GetPlayers()[i]] = true
		else
			
			if playersInShop[players:GetPlayers()[i]] == true then
				
				playersInShop[players:GetPlayers()[i]] = false
				
				--find all parts in shop which are theirs, unbought or bought, and delete them
				for t=1, table.maxn(updatedStoreItems), 1 do

					if updatedStoreItems[t]:GetAttribute("ownerId") == players:GetPlayers()[i].UserId then
						
						if updatedStoreItems[t]:GetAttribute("buy") == true then
							
							print("destroying")
							updatedStoreItems[t].Parent:Destroy()
						end
					end
				end
			end
		end
	end
	
	task.wait(1)
end

