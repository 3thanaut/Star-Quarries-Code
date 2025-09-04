--script for purchasing items!

--TO REMEMBER
--the instance which has a buy tag is NOT ADDED TO OWNED ITEMS therefore must be added AFTER PURCHASING THE ITEM.

local checkCounter = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("CheckCounter")

local money = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("Money")

local buyItems = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("Buy")

local addItem = game:GetService("ReplicatedStorage")["BindableEvents"]:FindFirstChild("AddItem")

local clearCounter = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("ClearCounter")

local deleteEvent = game:GetService("ReplicatedStorage")["BindableEvents"]:FindFirstChild("Delete")



local itemsFor = {}


game.Players.PlayerAdded:Connect(function(player)
	
	--no items for player yet
	itemsFor[player] = {}
end)


--when check counter fired, check the counter at the npc name
checkCounter.OnServerEvent:Connect(function(player, npcName)
	
	--check which npc it is and navigate to their counter checker
	if npcName == "Ridge Potens" then
		
		--check the parts in the area of the counter checker
		local itemsOnCounter = workspace:GetPartsInPart(workspace["Map Parts"].RidgeShop.RidgeDesk.CounterChecker)
		
		--price of all items found
		local price = 0

			
		if table.maxn(itemsOnCounter) == 0 then
			
			checkCounter:FireClient(player, price)
		else
		
			--check all items on counter
			for i=1, table.maxn(itemsOnCounter), 1 do

				--check if part has an outline
				if itemsOnCounter[i].Name == "Outline" then
					
					if itemsOnCounter[i]:GetAttribute("ownerId") == player.UserId then
						
						--add price of these items
						price += itemsOnCounter[i]:GetAttribute("price")
					end
				end
				
				if i >= table.maxn(itemsOnCounter) then

					--send price to player
					checkCounter:FireClient(player, price)
					
					break
				end
			end
		end
	elseif npcName == "Felicity Habilis" then
		
		--check the parts in the area of the counter checker
		local itemsOnCounter = workspace:GetPartsInPart(workspace["Map Parts"].FelicityShop.FelicityDesk.CounterChecker)

		--price of all items found
		local price = 0


		if table.maxn(itemsOnCounter) == 0 then

			checkCounter:FireClient(player, price)
		else

			--check all items on counter
			for i=1, table.maxn(itemsOnCounter), 1 do

				--check if part has an outline
				if itemsOnCounter[i].Name == "Outline" then

					if itemsOnCounter[i]:GetAttribute("ownerId") == player.UserId then

						--add price of these items
						price += itemsOnCounter[i]:GetAttribute("price")
					end
				end

				if i >= table.maxn(itemsOnCounter) then

					--send price to player
					checkCounter:FireClient(player, price)

					break
				end
			end
		end
	elseif npcName == "Aarne Gnarus" then
		
		--check the parts in the area of the counter checker
		local itemsOnCounter = workspace:GetPartsInPart(workspace["Map Parts"].AarneShop.AarneDesk.CounterChecker)

		--price of all items found
		local price = 0


		if table.maxn(itemsOnCounter) == 0 then

			checkCounter:FireClient(player, price)
		else

			--check all items on counter
			for i=1, table.maxn(itemsOnCounter), 1 do

				--check if part has an outline
				if itemsOnCounter[i].Name == "Outline" then

					if itemsOnCounter[i]:GetAttribute("ownerId") == player.UserId then

						--add price of these items
						price += itemsOnCounter[i]:GetAttribute("price")
					end
				end

				if i >= table.maxn(itemsOnCounter) then

					--send price to player
					checkCounter:FireClient(player, price)

					break
				end
			end
		end
	end
end)


--buy the items currently on the counter
buyItems.OnServerEvent:Connect(function(player, npcName)
	
	--check which npc it is and navigate to their counter checker
	if npcName == "Ridge Potens" then
		
		--check the parts in the area of the counter checker
		local itemsOnCounter = workspace:GetPartsInPart(workspace["Map Parts"].RidgeShop.RidgeDesk.CounterChecker)
		
		--price of all items found
		local price = 0
	
		--check all items on counter
		for i=1, table.maxn(itemsOnCounter), 1 do

			--check if part has an outline
			if itemsOnCounter[i].Name == "Outline" then
				
				--only buy if not already bought
				if itemsOnCounter[i]:GetAttribute("buy") == true then
					
					if itemsOnCounter[i]:GetAttribute("ownerId") == player.UserId then
						
						--add price of these items
						price += itemsOnCounter[i]:GetAttribute("price")

						if player.Money.Value - price >= 0 then

							--make it so item is actually bought
							itemsOnCounter[i]:SetAttribute("buy", false)

							--adds item to the list of owned items
							addItem:Fire(player, itemsOnCounter[i])
						end
					end
				end
			end
			
			if i >= table.maxn(itemsOnCounter) then
				
				--make sure player cant buy things they cant afford
				if player.Money.Value - price < 0 then
					
					--update GUI for this decision
					buyItems:FireClient(player, npcName, false)
				else
					
					--take price off of player money
					player.Money.Value -= price

					--send money update
					money:FireClient(player, player.Money.Value)

					--update GUI for this decision
					buyItems:FireClient(player, npcName, true)
				end
			end
		end
	elseif npcName == "Felicity Habilis" then
		
		--check the parts in the area of the counter checker
		local itemsOnCounter = workspace:GetPartsInPart(workspace["Map Parts"].FelicityShop.FelicityDesk.CounterChecker)

		--price of all items found
		local price = 0

		--check all items on counter
		for i=1, table.maxn(itemsOnCounter), 1 do

			--check if part has an outline
			if itemsOnCounter[i].Name == "Outline" then

				--only buy if not already bought
				if itemsOnCounter[i]:GetAttribute("buy") == true then

					if itemsOnCounter[i]:GetAttribute("ownerId") == player.UserId then

						--add price of these items
						price += itemsOnCounter[i]:GetAttribute("price")

						if player.Money.Value - price >= 0 then

							--make it so item is actually bought
							itemsOnCounter[i]:SetAttribute("buy", false)

							--adds item to the list of owned items
							addItem:Fire(player, itemsOnCounter[i])
						end
					end
				end
			end

			if i >= table.maxn(itemsOnCounter) then

				--make sure player cant buy things they cant afford
				if player.Money.Value - price < 0 then

					--update GUI for this decision
					buyItems:FireClient(player, npcName, false)
				else

					--take price off of player money
					player.Money.Value -= price

					--send money update
					money:FireClient(player, player.Money.Value)

					--update GUI for this decision
					buyItems:FireClient(player, npcName, true)
				end
			end
		end
	elseif npcName == "Aarne Gnarus" then
		
		--check the parts in the area of the counter checker
		local itemsOnCounter = workspace:GetPartsInPart(workspace["Map Parts"].AarneShop.AarneDesk.CounterChecker)

		--price of all items found
		local price = 0

		--check all items on counter
		for i=1, table.maxn(itemsOnCounter), 1 do

			--check if part has an outline
			if itemsOnCounter[i].Name == "Outline" then

				--only buy if not already bought
				if itemsOnCounter[i]:GetAttribute("buy") == true then

					if itemsOnCounter[i]:GetAttribute("ownerId") == player.UserId then

						--add price of these items
						price += itemsOnCounter[i]:GetAttribute("price")

						if player.Money.Value - price >= 0 then

							--make it so item is actually bought
							itemsOnCounter[i]:SetAttribute("buy", false)

							--adds item to the list of owned items
							addItem:Fire(player, itemsOnCounter[i])
						end
					end
				end
			end

			if i >= table.maxn(itemsOnCounter) then

				--make sure player cant buy things they cant afford
				if player.Money.Value - price < 0 then

					--update GUI for this decision
					buyItems:FireClient(player, npcName, false)
				else

					--take price off of player money
					player.Money.Value -= price

					--send money update
					money:FireClient(player, player.Money.Value)

					--update GUI for this decision
					buyItems:FireClient(player, npcName, true)
				end
			end
		end
	end
end)


--event fires when a player clicks the cancel purchase button.
clearCounter.OnServerEvent:Connect(function(player, plyrId, npcName)
	
	--check which npc's counter we need to use
	if npcName == "Ridge Potens" then
		
		--check the parts in the area of the counter checker
		local itemsOnCounter = workspace:GetPartsInPart(workspace["Map Parts"].RidgeShop.RidgeDesk.CounterChecker)

		--check all items on counter
		for i=1, table.maxn(itemsOnCounter), 1 do

			--check if part has an outline
			if itemsOnCounter[i].Name == "Outline" then
				
				if itemsOnCounter[i]:GetAttribute("ownerId") == player.UserId then
					
					if itemsOnCounter[i]:GetAttribute("buy") == true then

						itemsOnCounter[i].Parent:Destroy()
					end
				end

			end
			
			if i >= table.maxn(itemsOnCounter) then

				break
			end
		end
	elseif npcName == "Felicity Habilis" then
		
		--check the parts in the area of the counter checker
		local itemsOnCounter = workspace:GetPartsInPart(workspace["Map Parts"].FelicityShop.FelicityDesk.CounterChecker)

		--check all items on counter
		for i=1, table.maxn(itemsOnCounter), 1 do

			--check if part has an outline
			if itemsOnCounter[i].Name == "Outline" then

				if itemsOnCounter[i]:GetAttribute("ownerId") == player.UserId then

					if itemsOnCounter[i]:GetAttribute("buy") == true then

						itemsOnCounter[i].Parent:Destroy()
					end
				end

			end

			if i >= table.maxn(itemsOnCounter) then

				break
			end
		end
	end
end)
