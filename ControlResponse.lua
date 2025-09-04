--[[ U

  This honestly should have been called "main". This script contains 90% of the games functionality, and reference points.
  I moved the save script functionality into this thing once I realized that bindable events had a weird tendancy to ignore queuing when fired too often.
  This caused a lot of limitations and issues. Instead of doing this, organize your save system so that it relies less on the core of the game and functions
  as if it was reading your game like a book, not being the book itself.

  Also profile service exists and would handle literally all of this for me.
  Also I could have saved most of this information to a player file instead of deriving it from the game physically.
  Also I should have rendered all machines and animations completely on the client and made every object and invisible outline so the server lag was lighter.

  It is always nice to look back and understand how far you have come since a year or so ago. So much to understand and learn!

]]--



-- IMPORTANT NOTES --

--[[
PLEASE MAKE IT SO THAT THE SAVES HAVE PREVIOUS VERSION NOTES SO THAT NEW PLAYERS ARE UPDATED SO YOU DONT SAVEWIPE THESE POOR INNOCENT KIND PEOPLE
currently on version -1
updating to version -2

]]--
local SAVEVERSION = -2

--neat stuffs
local ActionEvents = game:GetService("ReplicatedStorage")["RemoteEvents"]["Actions"]
local BindableEvents = game:GetService("ReplicatedStorage")["BindableEvents"]
local RemoteEvents = game:GetService("ReplicatedStorage")["RemoteEvents"]
local dataStore = game:GetService("DataStoreService"):GetDataStore("PLAYERITEMS14")

--remote stuffs
--bound to LMB, or RT on console (default)
local MineAction = ActionEvents:FindFirstChild("MineRemote")
local PressAction = ActionEvents:FindFirstChild("PressAction")
local PickUpAction = ActionEvents:FindFirstChild("PickUpRemote")

--bound to E key, or X on console (default)
local NPCAction = ActionEvents:FindFirstChild("NPCAction")
local OpenAction = ActionEvents:FindFirstChild("OpenAction")

--bound to M key, or Y on console (default)
local BuildAction = ActionEvents:FindFirstChild("BuildRemote")

--bound to G, or B on console (default)
local DropAction = ActionEvents:FindFirstChild("DropRemote")

--responses
local SaveQueue = BindableEvents:FindFirstChild("SaveQueue")
local Animate = RemoteEvents:FindFirstChild("Animate")
local Delete = BindableEvents:FindFirstChild("Delete")
local Dialogue = RemoteEvents:FindFirstChild("Dialogue")
local AddItem = BindableEvents:FindFirstChild("AddItem")
local BaseColor = RemoteEvents:FindFirstChild("BaseColor")
local BuildEvent = RemoteEvents:FindFirstChild("BuildEvent")
local RockBreak = BindableEvents:FindFirstChild("RockBreak")
local ItemRefresh = BindableEvents:FindFirstChild("ItemRefresh")
local Sparks = RemoteEvents:FindFirstChild("Sparks")

--remote event for updating player money
local plyrmoney = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("Money")
local cubeRefill = game:GetService("ReplicatedStorage")["BindableEvents"]:FindFirstChild("CubeRefill")


--player information
local playerSwingCoolDown = {}
local playerInfoQueue = {}
local playerSaveLoad = {} --true is save, false is load
local playerLoadList = {}
local playerRelativePart = {}
local playerOwnedItems = {}
local playerHeldItems = {}
local playerBuilding = {}

local previousDone = true

--updates from -1 to -2
local function saveVersionUpdate(items)
	
	for i=1, table.maxn(items), 1 do
		
		if typeof(items[i]) ~= "number" then
			
			-- this says item in workspace
			if items[i][1] == 0 then
				
				--searching for specifically buildables
				if game:GetService("ReplicatedStorage")["Buildables"]:FindFirstChild(items[i][2]) ~= nil then	
					
					local model = game:GetService("ReplicatedStorage")["Buildables"]:FindFirstChild(items[i][2])
					
					local totalOffset = model.PrimaryPart:GetAttribute("YOffset") - math.floor(model.PrimaryPart:GetAttribute("YOffset"))					
					
					--edit data so that it is readable without division or multiplication
					items[i][4] = items[i][4]/10
					
					items[i][4] = math.floor(items[i][4])
					
					local lookVector = Vector3.new(items[i][6], items[i][7], items[i][8])
					local direction
					
					if lookVector == Vector3.new(0, 0, 1) then

						direction = 1
					elseif lookVector == Vector3.new(-1, 0, 0) then

						direction = 2
					elseif lookVector == Vector3.new(0, 0, -1) then

						direction = 3
					elseif lookVector == Vector3.new(1, 0, 0) then

						direction = 4
					else
						
						print("bad direction value")
						direction = 1
					end
					
					--replace the 6th index with the direction
					items[i][6] = direction
					
					--remove all of these since direction is 6th index and upvector is always known
					table.remove(items[i], 11)
					table.remove(items[i], 10)
					table.remove(items[i], 9)
					table.remove(items[i], 8)
					table.remove(items[i], 7)
				end
			end
		else
			
			--update version number
			if items[i] < 0 then
				
				items[i] = SAVEVERSION
			end
		end
	end
	
	--returns the newly updated save
	return items
end


--the function which loads in players items
local function loadItems(player, relativePart)

	--table we r gonna read off of
	local success, readTable = pcall(function()

		return dataStore:GetAsync(player.UserId)
	end)

	if success then

		--owned objects
		local ownedItems = {}

		if readTable == nil then

			print("nothing to load")

			player.Money.Value = 10
			plyrmoney:FireClient(player, player.Money.Value)
			
			table.remove(playerInfoQueue, 1)
			return true
		else
			
			local currentVersion = false
			--loop through the table once, try to find the save version
			for s=1, table.maxn(readTable), 1 do
				
				if typeof(readTable[s]) == "number" then
					
					if readTable[s] < 0 then
						
						if readTable[s] ~= SAVEVERSION then
							
							print("outdated save version!")
							--update the save version
							currentVersion = true
							readTable = saveVersionUpdate(readTable)
						else
							
							print("clear")
							currentVersion = true
						end
					end
				end
				
				if s >= table.maxn(readTable) then
					
					if currentVersion == false then

						print("outdated save version!")

						currentVersion = true
						table.insert(readTable, SAVEVERSION)
						readTable = saveVersionUpdate(readTable)
					end	
				end
			end
			
			print(readTable)
			--loop through the tables stored in readTable
			for i=1, table.maxn(readTable) do
				
				--for readability
				local data = readTable[i] --data of each instance


				if typeof(data) ~= "number" then
					
					--find out whether model or single part
					--where to copy model to
					if data[1] == 0 then --worksapce
						
						print('workspace object')

						--check what the item is
						if game:GetService("ReplicatedStorage")["Buildables"]:FindFirstChild(data[2]) ~= nil then

							--make the model object
							local model = game:GetService("ReplicatedStorage")["Buildables"]:FindFirstChild(data[2]):Clone()

							--set model parent
							model.Parent = workspace

							--set model owner
							model.PrimaryPart:SetAttribute("ownerId", player.UserId)
							
							local lookVector
							
							if data[6] == 1 then
								
								print("vect found!")
								lookVector = Vector3.new(0, 0, 1)
							elseif data[6] == 2 then
								
								print("vect found!")
								lookVector = Vector3.new(-1, 0, 0)
							elseif data[6] == 3 then
								
								print("vect found!")
								lookVector = Vector3.new(0, 0, -1)
							elseif data[6] == 4 then
								
								print("vect found!")
								lookVector = Vector3.new(1, 0, 0)
							else -- if no value
								
								print("vect found!")
								lookVector = Vector3.new(1, 0, 0)
							end
							
							local totalYOffset = model.PrimaryPart:GetAttribute("YOffset") - math.floor(model.PrimaryPart:GetAttribute("YOffset"))
							
							--position the part
							local pos = Vector3.new(data[3], data[4] + totalYOffset, data[5])
							local upVector = Vector3.new(0,1,0)
							local rightVector = lookVector:Cross(upVector)
							local relativeCFrame = CFrame.fromMatrix(pos, rightVector, upVector, -lookVector)

							--set model CFrame
							model.PrimaryPart.CFrame = relativePart.CFrame:ToWorldSpace(relativeCFrame)

							--add the outline to owned items
							table.insert(ownedItems, model.PrimaryPart)

						elseif game:GetService("ReplicatedStorage")["Tools"]:FindFirstChild(data[2]) ~= nil then

							--make the model object
							local model = game:GetService("ReplicatedStorage")["Tools"]:FindFirstChild(data[2]):Clone()

							--set model parent
							model.Parent = workspace

							--set model owner
							model.PrimaryPart:SetAttribute("ownerId", player.UserId)

							--position the part
							local pos = Vector3.new(data[3]/10, data[4]/10, data[5]/10)
							local lookVector = Vector3.new(data[6], data[7], data[8])
							local upVector = Vector3.new(data[9], data[10], data[11])
							local rightVector = lookVector:Cross(upVector)
							local relativeCFrame = CFrame.fromMatrix(pos, rightVector, upVector, -lookVector)

							--set model CFrame
							model.PrimaryPart.CFrame = relativePart.CFrame:ToWorldSpace(relativeCFrame)

							--add the outline to owned items
							table.insert(ownedItems, model.PrimaryPart)

						elseif game:GetService("ReplicatedStorage")["Boxes"]:FindFirstChild(data[2]) ~= nil then

							--make the model object
							local model = game:GetService("ReplicatedStorage")["Boxes"]:FindFirstChild(data[2]):Clone()

							--set model parent
							model.Parent = workspace

							--set model owner
							model.PrimaryPart:SetAttribute("ownerId", player.UserId)

							--position the part
							local pos = Vector3.new(data[3]/10, data[4]/10, data[5]/10)
							local lookVector = Vector3.new(data[6], data[7], data[8])
							local upVector = Vector3.new(data[9], data[10], data[11])
							local rightVector = lookVector:Cross(upVector)
							local relativeCFrame = CFrame.fromMatrix(pos, rightVector, upVector, -lookVector)

							--set model CFrame
							model.PrimaryPart.CFrame = relativePart.CFrame:ToWorldSpace(relativeCFrame)

							--add the outline to owned items
							table.insert(ownedItems, model.PrimaryPart)
						elseif game:GetService("ReplicatedStorage")["Cars"]:FindFirstChild(data[2]) ~= nil then

							--make the model object
							local model = game:GetService("ReplicatedStorage")["Cars"]:FindFirstChild(data[2]):Clone()

							--set model parent
							model.Parent = workspace

							--set model owner
							model.PrimaryPart:SetAttribute("ownerId", player.UserId)

							--position the part
							local pos = Vector3.new(data[3], data[4]/10, data[5])
							local lookVector = Vector3.new(data[6]/10, data[7]/10, data[8]/10)
							local upVector = Vector3.new(data[9]/10, data[10]/10, data[11]/10)
							local rightVector = lookVector:Cross(upVector)
							local relativeCFrame = CFrame.fromMatrix(pos, rightVector, upVector, -lookVector)

							--set model CFrame
							model:PivotTo(relativePart.CFrame:ToWorldSpace(relativeCFrame))
							model.PrimaryPart.Anchored = false

							--add the outline to owned items
							table.insert(ownedItems, model.PrimaryPart)


						elseif game:GetService("ReplicatedStorage")["CompressionCubes"]:FindFirstChild(data[2]) ~= nil then

							--make the model object
							local model = game:GetService("ReplicatedStorage")["CompressionCubes"]:FindFirstChild(data[2]):Clone()

							--set model parent
							model.Parent = workspace

							--set model owner
							model.PrimaryPart:SetAttribute("ownerId", player.UserId)

							--position the part
							local pos = Vector3.new(data[3]/10, data[4]/10, data[5]/10)
							local lookVector = Vector3.new(data[6], data[7], data[8])
							local upVector = Vector3.new(data[9], data[10], data[11])
							local rightVector = lookVector:Cross(upVector)
							local relativeCFrame = CFrame.fromMatrix(pos, rightVector, upVector, -lookVector)

							--set model CFrame
							model.PrimaryPart.CFrame = relativePart.CFrame:ToWorldSpace(relativeCFrame)

							--add the outline to owned items
							table.insert(ownedItems, model.PrimaryPart)

							local rocksStored = {}

							if data[12] == nil then

								--just ignore since that means there are literally no rocks
								print("ignored rocks in compression cube")
							else

								--start at last index of data
								for t=12, table.maxn(data), 3 do

									if data[t] ~= nil then

										table.insert(rocksStored, {
											data[t],
											data[t+1],
											data[t+2]
										})
									end

									if t+3 >= table.maxn(data) then

										--add rocks to the corresponding cube
										task.wait(0.1)
										cubeRefill:Fire(model.PrimaryPart, rocksStored)
										print("firing refill")
									end
								end
							end

						elseif game:GetService("ReplicatedStorage")["Rocks"]:FindFirstChild(data[12]) ~= nil then
							
							print('rock')
							local pos = Vector3.new(data[2]/10, data[3]/10, data[4]/10)
							local lookVector = Vector3.new(data[5]/10, data[6]/10, data[7]/10)
							local upVector = Vector3.new(data[8]/10, data[9]/10, data[10]/10)
							local rightVector = lookVector:Cross(upVector)
							local relativeCFrame = CFrame.fromMatrix(pos, rightVector, upVector, -lookVector)

							local size = Vector3.new(data[11], data[11], data[11])

							local rock = game:GetService("ReplicatedStorage")["Rocks"]:FindFirstChild(data[12]):Clone()

							task.wait()

							rock:SetAttribute("pickUp", true)
							rock:SetAttribute("ownerId", player.UserId)
							rock:SetAttribute("value", data[13])

							rock.Parent = workspace

							rock.Size = size

							rock.CFrame = relativePart.CFrame:ToWorldSpace(relativeCFrame)

							table.insert(ownedItems, rock)
						end

					elseif data[1] == 1 then --backpack

						--will always be a tool if parented to backpack
						
						--make model object
						print(data[2])
							
						local model = game:GetService("ReplicatedStorage")["Tools"]:FindFirstChild(data[2]):Clone()

						--set model parent
						model.Parent = player.Backpack

						--set model owner
						model.PrimaryPart:SetAttribute("ownerId", player.UserId)

						--add outline to owned items
						table.insert(ownedItems, model.PrimaryPart)

					elseif data[1] == 2 then --character

						--will always be a tool if parented to character

						--make model object
						local model = game:GetService("ReplicatedStorage")["Tools"]:FindFirstChild(data[2]):Clone()

						--set model parent
						model.Parent = player.Backpack

						--set model owner
						model.PrimaryPart:SetAttribute("ownerId", player.UserId)

						--add outline to owned items
						table.insert(ownedItems, model.PrimaryPart)

					end
				else
					
					if data > 0 then
						
						print("firing player money from load items")
						player.Money.Value = data
						plyrmoney:FireClient(player, player.Money.Value)
					else
						
						print("save version detected!")
					end
				end
				
				if i >= table.maxn(readTable) then
					
					print("loaded!")
					
					--give back value of owned items
					print("from the load items function")
					print(ownedItems)
					playerOwnedItems[player] = ownedItems
					
					table.remove(playerInfoQueue, 1)
					return true
				end
			end
		end
	else

		print("FAILED TO LOAD")
	end
end


--should save information--
local Save = game:GetService("ReplicatedStorage")["BindableEvents"]:FindFirstChild("Save")

--datastore for players items
local dataStore = game:GetService("DataStoreService"):GetDataStore("PLAYERITEMS14")

--request the information of a cube
local cubeRequest = game:GetService("ReplicatedStorage")["BindableEvents"]:FindFirstChild("CubeRequest")

--recieve the information of a cube (cant use bindable function since we have to check every cube in game)
local cubeSave = game:GetService("ReplicatedStorage")["BindableEvents"]:FindFirstChild("CubeSave")

--gives info back to player that save was complete
local SaveSuccess = game:GetService("ReplicatedStorage")["RemoteEvents"]:FindFirstChild("SaveSuccess")
local itemsToDestroy = {}
local ownerTables = {}
local playerLeft = {}


--find base that the player is at
local function findBase(userId)

	--loop through all of the bases and check for the playerId
	for i=1, 6, 1 do

		if workspace["PlayerBases"][tostring("Base" .. i)].RelativePart:GetAttribute("plyrId") == userId then

			print("found base for " .. tostring(userId))
			return workspace["PlayerBases"][tostring("Base" .. i)].RelativePart
		end
	end
end

--distance finding function
local function distance(relativePart, part)

	--find magnitude of delta pos of parts
	local distX = math.abs(part.Position.X - relativePart.Position.X)
	local distZ = math.abs(part.Position.Z - relativePart.Position.Z)

	--if magnitude is larger on X or Z than the baseplate size then delete part
	if distX > 40 or distZ > 40 then

		--false to save
		print("false")
		return false
	else --less than six on either side

		--true to save
		return true
	end
end



--putting save in a function so that we can queue which player needs saving.
local function saveFunc(player, ownedItems)

	--table for adding info
	local writeTable = {}

	--can add a check to erase the players data at the key if they choose to obliterate the save file.

	if ownedItems == nil then

		if player.Money.Value < 10 then

			player.Money.Value = 10
		end

		table.insert(writeTable, player.Money.Value)

		print("trying to save")
		local success, errorMessage = pcall(function()
			print(writeTable)

			dataStore:UpdateAsync(tostring(player.UserId), function()

				return writeTable
			end)

		end)

		if not success then

			print(errorMessage)

			SaveSuccess:FireClient(player, false)

			
			table.remove(playerInfoQueue, 1)
			return true
		else

			print("successfully saved!")
			--fire a remote that updates players gui letting them know the save was successful
			SaveSuccess:FireClient(player, true)

			table.remove(playerInfoQueue, 1)
			return true
		end
	else

		local relativePart = findBase(player.UserId)

		--what writeTable should contain
		for i=1, table.maxn(ownedItems) do

			--if model or not
			if ownedItems[i].Name == "Outline" then

				if ownedItems[i].Parent ~= nil then

					if ownedItems[i].Parent.Parent == workspace then

						local distCheck = distance(relativePart, ownedItems[i])

						--check if save pos in workspace
						if distCheck == true then

							if ownedItems[i]:GetAttribute("type") == "buildable" then

								--make a localspace info thingy
								local localSpace = relativePart.CFrame:ToObjectSpace(ownedItems[i].CFrame)
								local direction = 1

								if localSpace.LookVector == Vector3.new(0, 0, 1) then
									
									direction = 1
								elseif localSpace.LookVector == Vector3.new(-1, 0, 0) then
									
									direction = 2
								elseif localSpace.LookVector == Vector3.new(0, 0, -1) then
									
									direction = 3
								elseif localSpace.LookVector == Vector3.new(1, 0, 0) then
									
									direction = 4
								else
									
									print("couldnt find a look vect")
									direction = 1
								end
								
								--find parent and keep its name
								table.insert(writeTable, {

									--where to copy the item to (0 for workspace, 1 for backpack, 2 for character)
									0,

									--name of the item, for copying from rep storage
									ownedItems[i].Parent.Name,

									--position
									math.floor(localSpace.Position.X),
									math.floor(localSpace.Position.Y),
									math.floor(localSpace.Position.Z),

									--direction facing
									direction,
								})
							else -- if the instance is abox or tool youll want more accurate position info

								--make a localspace info thingy
								local localSpace = relativePart.CFrame:ToObjectSpace(ownedItems[i].CFrame)

								--if its a compression cube
								if ownedItems[i]:GetAttribute("type") == "cube" then


									local cubeTable = {

										--where to copy the item to (0 for workspace, 1 for backpack, 2 for character)
										0,

										--name of the item, for copying from rep storage
										ownedItems[i].Parent.Name,

										--position
										math.round(localSpace.Position.X*10),
										math.round(localSpace.Position.Y*10),
										math.round(localSpace.Position.Z*10),

										--direction facing
										math.round(localSpace.LookVector.X*10),
										math.round(localSpace.LookVector.Y*10),
										math.round(localSpace.LookVector.Z*10),

										--up or down
										math.round(localSpace.UpVector.X*10),
										math.round(localSpace.UpVector.Y*10),
										math.round(localSpace.UpVector.Z*10)
									}

									local waiting = false

									if waiting == false then

										cubeRequest:Fire(ownedItems[i])
										waiting = true
									end

									cubeSave.Event:Connect(function(rockTable)

										if waiting == true then

											print(rockTable)

											if table.maxn(rockTable) > 0 then

												--save rock table
												for t=1, table.maxn(rockTable), 1 do

													--loop through the data that the rock has (only 3 pieces of info)
													for p=1, 3, 1 do

														--add to the end of cube table the rocks piece of information so that it can be saved.
														table.insert(cubeTable, rockTable[t][p])
													end

													--once this whole thing is complete, send this table to the datastore savetable
													if t >= table.maxn(rockTable) then

														table.insert(writeTable, cubeTable)
														print("rock table saved!")
														print(writeTable)
													end
												end
											else
												--if no rocks
												table.insert(writeTable, cubeTable)
											end
											waiting = false
										end
									end)
								else

									--find parent and keep its name
									table.insert(writeTable, {

										--where to copy the item to (0 for workspace, 1 for backpack, 2 for character)
										0,

										--name of the item, for copying from rep storage
										ownedItems[i].Parent.Name,

										--position
										math.round(localSpace.Position.X*10),
										math.round(localSpace.Position.Y*10),
										math.round(localSpace.Position.Z*10),

										--direction facing
										math.round(localSpace.LookVector.X*10),
										math.round(localSpace.LookVector.Y*10),
										math.round(localSpace.LookVector.Z*10),

										--up or down
										math.round(localSpace.UpVector.X*10),
										math.round(localSpace.UpVector.Y*10),
										math.round(localSpace.UpVector.Z*10)
									})
								end
							end
						end

					elseif ownedItems[i].Parent.Parent.Name == "Backpack" then

						--find parent and keep its name
						table.insert(writeTable, {

							--where to copy the item to (0 for workspace, 1 for backpack, 2 for character)
							1,

							--name of the item, for copying from rep storage
							ownedItems[i].Parent.Name,

							--defines owner of item
							ownedItems[i]:GetAttribute("ownerId")

						})
					else

						--find parent and keep its name
						table.insert(writeTable, {

							--where to copy the item to (0 for workspace, 1 for backpack, 2 for character)
							1,

							--name of the item, for copying from rep storage
							ownedItems[i].Parent.Name,

							--defines owner of item
							ownedItems[i]:GetAttribute("ownerId")

						})
					end
				else

					print("ignored lost item from death")
				end
			else --only for rocks

				local closeEnough = distance(relativePart, ownedItems[i])

				--check if save
				if closeEnough == true then

					--make a localspace info thingy
					local localSpace = relativePart.CFrame:ToObjectSpace(ownedItems[i].CFrame)

					--find parent and keep its name
					table.insert(writeTable, {

						0,

						--position
						math.round(localSpace.Position.X*10),
						math.round(localSpace.Position.Y*10),
						math.round(localSpace.Position.Z*10),

						--direction facing
						math.round(localSpace.LookVector.X*10),
						math.round(localSpace.LookVector.Y*10),
						math.round(localSpace.LookVector.Z*10),

						--up or down
						math.round(localSpace.UpVector.X*10),
						math.round(localSpace.UpVector.Y*10),
						math.round(localSpace.UpVector.Z*10),

						--size
						ownedItems[i].Size.X, --size of the part on all axis since cube

						--type of rock
						ownedItems[i].Name,

						--value of the rock
						ownedItems[i]:GetAttribute("value")

					})
				end
			end

			--actually set data or update datastore
			if i >= table.maxn(ownedItems) then

				--add money somewhere in the table
				table.insert(writeTable, player.Money.Value)
				
				--add the save version somewhere in the table
				table.insert(writeTable, SAVEVERSION)
				--will continue to try saving until the game is closed or until it saves

				print("trying to save")
				local success, errorMessage = pcall(function()
					print(writeTable)

					dataStore:UpdateAsync(tostring(player.UserId), function()

						return writeTable
					end)

				end)

				if not success then

					print(errorMessage)

					SaveSuccess:FireClient(player, false)

					table.remove(playerInfoQueue, 1)
					return true
				else

					print("successfully saved!")
					--fire a remote that updates players gui letting them know the save was successful
					SaveSuccess:FireClient(player, true)

					table.remove(playerInfoQueue, 1)
					return true
				end
			end
		end
	end
end


--adding players to their information
--should only partly fire after dying
game.Players.PlayerAdded:Connect(function(player)
	
	player.CharacterAdded:Connect(function(character)
		
		--makes sure not to dupe if player dies
		if table.find(playerLoadList, player) == nil then
			
			table.insert(playerLoadList, player)
			
			--add to general info tables
			playerSwingCoolDown[player] = 0
			playerHeldItems[player] = false
			playerBuilding[player] = nil
			playerOwnedItems[player] = {}
			
			--put player in queue for datastore services
			table.insert(playerInfoQueue, player)
			playerSaveLoad[player] = false -- this means load

			--add a money instance to player
			local money = Instance.new("IntValue")
			money.Name = "Money"
			money.Parent = player

			--loop through all of the bases and check for the playerId
			for i=1, 6, 1 do

				local userId = player.UserId

				--finds the base already claimed by the player
				if  workspace["PlayerBases"][tostring("Base" .. i)].RelativePart:GetAttribute("plyrId") == 0 then

					workspace["PlayerBases"][tostring("Base" .. i)].RelativePart:SetAttribute("plyrId", userId)

					playerRelativePart[player] = workspace["PlayerBases"][tostring("Base" .. i)].RelativePart

					--teleport player to relative part
					character:MoveTo(workspace["PlayerBases"][tostring("Base" .. i)].RelativePart.Position)

					BaseColor:FireClient(game:GetService("Players"):GetPlayerByUserId(userId), i)

					break
				end
			end
		else

			local userId = player.UserId
			
			--teleport player to relative part
			character:MoveTo(playerRelativePart[player].Position)
			
			task.wait(0.5)
			print("firing money")
			plyrmoney:FireClient(player, player.Money.Value)
			
		end
	end)
end)

--takes items away from world when player is gone and items have been fully saved
local function removeItems(player, itemsToDestroy)

	--destroy all items
	if itemsToDestroy[player] ~= nil then

		for i=1, table.maxn(itemsToDestroy[player]), 1 do

			if itemsToDestroy[player][i].Parent ~= nil then

				if itemsToDestroy[player][i].Parent == workspace then

					itemsToDestroy[player][i]:Destroy()
				elseif itemsToDestroy[player][i].Parent == player.Backpack then

					print("ignored backpack item")
				else

					local ModelChildren = itemsToDestroy[player][i].Parent:GetChildren()

					for i=1, table.maxn(ModelChildren), 1 do

						ModelChildren[i]:destroy()
					end
				end
			else

				print("ignored non existent item")
			end
		end

		for i=1, 6, 1 do

			if workspace["PlayerBases"][tostring("Base" .. i)].RelativePart:GetAttribute("plyrId") == player.UserId then

				workspace["PlayerBases"][tostring("Base" .. i)].LED.Color = Color3.new(0, 0, 0)
				workspace["PlayerBases"][tostring("Base" .. i)].RelativePart:SetAttribute("plyrId", 0)

			end
		end

		print("finished destroying")
	else

		print("no items to destroy")
	end
end

game.Players.PlayerRemoving:Connect(function(plyr)

	local function checkQueue()

		--check if the player is in the save queue before destroying their items
		if table.find(playerInfoQueue, plyr) then

			--only check once per second
			print("check queue repeating")
			task.wait(1)
			checkQueue()
		else

			removeItems(plyr, playerOwnedItems)
		end
	end

	checkQueue()
end)


SaveQueue.Event:Connect(function(player)
	
	if table.find(playerInfoQueue, player) == nil then
		
		table.insert(playerInfoQueue, player)
		playerSaveLoad[player] = true -- this means save
	end
end)


--removing items from the players owned table
Delete.Event:Connect(function(player, obj)
	
	if playerOwnedItems[player] ~= nil then

		--remove obj from ownedItems[player]
		for i=1, #playerOwnedItems[player] do

			--if instance is equivalent
			if obj == playerOwnedItems[player][i] then

				table.remove(playerOwnedItems[player], i)
				print("instance removed from owner table")
				break
			end
		end
	end
end)

--adding items to the player owned table
AddItem.Event:Connect(function(player, obj)

	--add the item to owned items
	print("added to owned items")
	table.insert(playerOwnedItems[player], obj)
end)



--functions
local function checkIfTool(player, instance)

	--if the item is a tool
	if instance:GetAttribute("type") == "pickaxe" then

		--send instance to player backpack
		instance.Parent.Parent = player.Character
		
	elseif instance:GetAttribute("type") == "lantern" then
		
		--send to player bag
		instance.Parent.Parent = player.Character
	else

		--bring instance to player torso, with 0.1 stud of space between
		instance.CFrame =  player.Character.Torso.CFrame * CFrame.new(0, 0, -0.5*instance.Size.Z - player.Character.Torso.Size.Z*0.5 - 0.3)

		--weld instance to player torso
		local weld = Instance.new("WeldConstraint")
		weld.Name = "HoldWeld"
		weld.Part0 = instance
		weld.Part1 = player.Character.Torso
		weld.Parent = player.Character.Torso

		--note that the player is holding the item
		playerHeldItems[player] = true

		Animate:FireAllClients(player.UserId, "pickUp")
	end
end

--function that opens boxes
local function openBox(player, outline)

	--make sure the box belongs to the player
	if outline:GetAttribute("ownerId") == player.UserId then

		--check what box it is
		if outline:GetAttribute("type") == "box" then

			--make an iron pickaxe for the player with the boxes CFrame
			local toolInBox = outline.Parent:FindFirstChildOfClass("Tool")

			if toolInBox then

				local pickaxe = game:GetService("ReplicatedStorage")["Tools"]:FindFirstChild(toolInBox.Name):Clone()

				--parent pickaxe to workspace and add ownerId
				pickaxe.Parent = workspace
				pickaxe.PrimaryPart:SetAttribute("ownerId", player.UserId)

				--set pickaxe CFrame to be the same as outline CFrame
				pickaxe:SetPrimaryPartCFrame(outline.CFrame)

				--remove the outline part (box) from the owned items table
				Delete:Fire(player, outline)

				--destroy the box
				outline.Parent:Destroy()

				--add the pickaxe to the owned items
				table.insert(playerOwnedItems[player], pickaxe.PrimaryPart)
				print(playerOwnedItems[player])

			else

				if outline:GetAttribute("cube") == true then

					local cube = game:GetService("ReplicatedStorage")["CompressionCubes"]:FindFirstChild(outline.Parent:FindFirstChildWhichIsA("Model").Name):Clone()

					--parent pickaxe to workspace and add ownerId
					cube.Parent = workspace
					cube.PrimaryPart:SetAttribute("ownerId", player.UserId)

					--set pickaxe CFrame to be the same as outline CFrame
					cube:SetPrimaryPartCFrame(outline.CFrame)

					--remove the outline part (box) from the owned items table
					Delete:Fire(player, outline)

					--destroy the box
					outline.Parent:Destroy()

					--add the cube to the owned items
					table.insert(playerOwnedItems[player], cube.PrimaryPart)
				else
				
					print("firing build!")
					--fire build event to clients
					BuildEvent:FireClient(player, outline.Parent.Name)

					--add the outline to the table to emphasize what the player is actively building
					playerBuilding[player] = outline.Parent:FindFirstChildWhichIsA("Model").Name

					--remove the outline part (box) from the owned items table
					Delete:Fire(player, outline)

					--destroy the box
					outline.Parent:Destroy()
				end
			end
		end
	end
end



--mining context fired
MineAction.OnServerEvent:Connect(function(player, mouseHit, object)
	
	local tool = player.Character:FindFirstChildOfClass("Tool")
	
	if tool.Handle:GetAttribute("type") == "flaregun" then

		if tick() - playerSwingCoolDown[player] > tool.Handle:GetAttribute("spd") then

			playerSwingCoolDown[player] = tick()
			
			local outline = object.Parent:FindFirstChild("Outline")
			
			if object.Parent:FindFirstChild("Outline") ~= nil then
				
				if outline:GetAttribute("type") == "buildable" and outline:GetAttribute("ownerId") == player.UserId then
					
					tool.Handle.Flarefire:Play()
					
					local player = game.Players:GetPlayerByUserId(outline:GetAttribute("ownerId"))
					--pass outline of buildables since they are what is stored in player data.
					Delete:Fire(player, outline)
					
					--create an explosion at outlines position
					local explosion = Instance.new("Explosion", workspace)
					explosion.Position = outline.Position
					explosion.BlastPressure = 0
					explosion.BlastRadius = 3
					tool.Handle.Explosion:Play()
					
					outline.Parent:Destroy()
				end
			end
		end
	end
	
	--cheater checker
	if (player.Character.Head.Position - object.Position).Magnitude > 10 then print("too far") return end
	if playerHeldItems[player] ~= false then print("cant mine while holding") return end
	if object:GetAttribute("hp") == nil then print("not a rock") return end
	if tool == nil then print("no tool") return end
	
	if tool.PrimaryPart:GetAttribute("type") == "pickaxe" then
		
		if tick() - playerSwingCoolDown[player] > tool.PrimaryPart:GetAttribute("spd") then

			--swing the pickaxe
			playerSwingCoolDown[player] = tick()
			
			--animate the pickaxe swing
			Animate:FireAllClients(player.UserId, "pickSwing")

			task.wait(0.44)
			
			Sparks:FireClient(player, "SparkEffect", mouseHit, 0.2)
			
			--do dmg to rock
			object:SetAttribute("hp", object:GetAttribute("hp") - tool.PrimaryPart:GetAttribute("dmg"))
			
			--use mouse hit to get the position for the spark

			--if the rocks health is 0 or below, break it
			if object:GetAttribute("hp") <= 0 then

				--break rock, add it to a table, and when daytime comes replace all rocks, with massive water spouts
				table.insert(playerOwnedItems[player], RockBreak:Invoke(player, object)) --RETURNS ROCK BROKEN WITH PLAYER USERID
			end
		end
	end
end)


--pressing a button
PressAction.OnServerEvent:Connect(function(player, mouseHit, object)
	
	--cheater checker
	if (player.Character.Head.Position - object.Position).Magnitude > 10 then print("too far") return end
	if object.Parent:FindFirstChild("Outline") == nil then print("no outline") return end
	
	--make sure no randoms can interact with ur machines
	if object.Parent.Outline:GetAttribute("ownerId") == player.UserId or object.Parent.Outline:GetAttribute("ownerId") == 0 then

		--change the object state
		if object:GetAttribute("state") == true then

			object:SetAttribute("state", false)
			object.Material = Enum.Material.SmoothPlastic

			print("false")

		else

			object:SetAttribute("state", true)
			object.Material = Enum.Material.Neon

			print("true")
		end
	end
end)


--picking up an item
PickUpAction.OnServerEvent:Connect(function(player, mouseHit, object)
	
	--cheater checker
	if (player.Character.Head.Position - object.Position).Magnitude > 10 then print("too far") return end
	if object:GetAttribute("pickUp") ~= true then print("cant pick that up") return end
	
	--glitch avoider
	if playerOwnedItems[player] == nil then print("unset nil") playerOwnedItems[player] = {} end
	if playerHeldItems[player] == true then print("already holding") return end
	
	--apply ownerId to the item the player picked up
	if object:GetAttribute("ownerId") == 0 then

		--sets ownerId back to the part
		object:SetAttribute("ownerId", player.UserId)

		--unanchor objects you can pickup
		object.Anchored = false

		if object:GetAttribute("buy") == true then

			ItemRefresh:Fire(object)
		else
			--add object to table if now owned by plyr
			table.insert(playerOwnedItems[player], object)
			print("inserted object into list")
		end

		checkIfTool(player, object)

	elseif object:GetAttribute("ownerId") == player.UserId then

		checkIfTool(player, object)
	end
end)



NPCAction.OnServerEvent:Connect(function(player, mouseHit, object)
	
	--cheater checker
	if (player.Character.Head.Position - object.Torso.Position).Magnitude > 10 then print("too far") return end
	
	if object:GetAttribute("NPC") == true then

		--trigger dialogue here
		Dialogue:FireClient(player, object.Name)
	end
end)


OpenAction.OnServerEvent:Connect(function(player, mouseHit, object)
	
	--cheater checker
	if (player.Character.Head.Position - object.Position).Magnitude > 10 then print("too far") return end
	
	if playerBuilding[player] ~= true then
		
		if object:GetAttribute("buy") ~= true then
			
			print("opening box")
			openBox(player, object)
		end
	end
end)


BuildAction.OnServerEvent:Connect(function(player, mouseHit, object)
	
	--cheater checker
	if (player.Character.Head.Position - object.Position).Magnitude > 10 then print("too far") return end
	if playerBuilding[player] == true then print("already building") return end
	
	if object:GetAttribute("type") == "buildable" and object:GetAttribute("ownerId") == player.UserId then
		
		--fire build event to clients
		BuildEvent:FireClient(player, object.Parent.Name)

		--add the outline to the table to emphasize what the player is actively building
		playerBuilding[player] = object.Parent.Name

		--remove the outline part (box) from the owned items table
		Delete:Fire(player, object)

		--destroy the box
		object.Parent:Destroy()
	end
end)


DropAction.OnServerEvent:Connect(function(player, mouseHit, object)
	
	--secondary check? might break something
	if playerHeldItems[player] == false then print("not holding anything") return end
	
	if mouseHit ~= nil then
		
		if (player.Character.Head.Position - mouseHit).Magnitude < 10 then

			--find if instance has weld
			local weld = player.Character.Torso:FindFirstChild("HoldWeld")

			task.wait()

			--id part
			local part = weld.Part0

			playerHeldItems[player] = part

			--destroy the weld
			weld:Destroy()
			
			if part ~= nil then
				local pos = Vector3.new(mouseHit.X, mouseHit.Y + 0.5*playerHeldItems[player].Size.Y + 0.1, mouseHit.Z)
				local rightVector = part.CFrame.RightVector
				local upVector = part.CFrame.UpVector
				local lookVector = player.Character.Torso.CFrame.LookVector
				playerHeldItems[player].CFrame = CFrame.fromMatrix(pos, rightVector, upVector, -lookVector)
			end

			--player is carrying nothing
			playerHeldItems[player] = false
		else
			
			--if too far just drop down like normal
			--find if instance has weld
			local weld = player.Character.Torso:FindFirstChild("HoldWeld")

			--destroy the weld
			weld:Destroy()

			--player is carrying nothing
			playerHeldItems[player] = false
		end
	else
		
		--if too far just drop down like normal
		--find if instance has weld
		local weld = player.Character.Torso:FindFirstChild("HoldWeld")

		--destroy the weld
		weld:Destroy()

		--player is carrying nothing
		playerHeldItems[player] = false
	end
	
	--send info back to client for VFX
	Animate:FireAllClients(player.UserId, "drop")
end)


BuildEvent.OnServerEvent:Connect(function(player, buildPos, rotCount)

	local newModel = game:GetService("ReplicatedStorage")["Buildables"]:FindFirstChild(playerBuilding[player]):Clone()

	newModel.Parent = workspace

	--find the relative part
	local relativePart

	if workspace.PlayerBases:FindFirstChild("Base1"):FindFirstChild("RelativePart"):GetAttribute("plyrId") == player.UserId then

		relativePart = workspace.PlayerBases.Base1.RelativePart

	elseif workspace.PlayerBases:FindFirstChild("Base2"):FindFirstChild("RelativePart"):GetAttribute("plyrId") == player.UserId then

		relativePart = workspace.PlayerBases.Base2.RelativePart

	elseif workspace.PlayerBases:FindFirstChild("Base3"):FindFirstChild("RelativePart"):GetAttribute("plyrId") == player.UserId then

		relativePart = workspace.PlayerBases.Base3.RelativePart
		
	elseif workspace.PlayerBases:FindFirstChild("Base4"):FindFirstChild("RelativePart"):GetAttribute("plyrId") == player.UserId then
		
		relativePart = workspace.PlayerBases.Base4.RelativePart
	elseif workspace.PlayerBases:FindFirstChild("Base5"):FindFirstChild("RelativePart"):GetAttribute("plyrId") == player.UserId then
		
		relativePart = workspace.PlayerBases.Base5.RelativePart
	elseif workspace.PlayerBases:FindFirstChild("Base6"):FindFirstChild("RelativePart"):GetAttribute("plyrId") == player.UserId then
		
		relativePart = workspace.PlayerBases.Base6.RelativePart
	end

	--position the part according to the bases relative part
	local pos = Vector3.new(0, 0, 0)
	local lookVector = Vector3.new(relativePart.CFrame.LookVector.X, relativePart.CFrame.LookVector.Y, relativePart.CFrame.LookVector.Z)
	local upVector = Vector3.new(newModel.Outline.CFrame.UpVector.X, newModel.Outline.CFrame.UpVector.Y, newModel.Outline.CFrame.UpVector.Z)
	local rightVector = lookVector:Cross(upVector)
	local relativeCFrame = CFrame.fromMatrix(pos, rightVector, upVector, -lookVector)


	local x = math.floor(buildPos.X)
	local y = buildPos.Y + newModel.PrimaryPart:GetAttribute("YOffset")
	local z = math.floor(buildPos.Z)

	local baseplateSize = relativePart.Parent.Part.Size.X

	if math.abs(x - relativePart.Position.X) < baseplateSize/2 and math.abs(z - relativePart.Position.Z) < baseplateSize/2 then

		newModel.PrimaryPart.CFrame = CFrame.new(x, y, z)*CFrame.Angles(0, math.rad(90*rotCount), 0)*relativeCFrame

		newModel.PrimaryPart:SetAttribute("ownerId", player.UserId)
		
		task.wait(0.1)
		if newModel:FindFirstChild("SpdPart") ~= nil and newModel.Name ~= "Conveyor" then
			
			local SpdPart = newModel:FindFirstChild("SpdPart")
			local Weld = SpdPart:FindFirstChild("OutlineWeld")
			SpdPart.Anchored = true
			
			
			Weld:Destroy()
			
			local CopyScript = game:GetService("ReplicatedStorage")["CopyScripts"]:FindFirstChild("ConveyorScript"):Clone()
			CopyScript.Parent = newModel
		end

		table.insert(playerOwnedItems[player], newModel.PrimaryPart)

		playerBuilding[player] = nil
	else

		print("cannot build outside of owned area")
	end
end)



--work through the queue!
while true do
	
	if playerInfoQueue[1] ~= nil then
		
		if previousDone == true then
			
			previousDone = false -- need to immediately say we are in the process of saving or loading and to hold others
			local player = playerInfoQueue[1]
			
			if playerSaveLoad[player] == true then
				
				previousDone = saveFunc(player, playerOwnedItems[player])
			elseif playerSaveLoad[player] == false then
				
				previousDone = loadItems(player, playerRelativePart[player])
			end
		end
	end
	
	task.wait(1)
end
