--[[
    This script handles requests from Players that wish to equip hats that are specific to certain Badge IDs.
    The player must own this said Badge in their Roblox Inventory in order to fully utilize this event.
    If a player tries to fake information using this event, the remote function will kick the player, and exit the function.
]]

-- Services --
local BadgeService = game:GetService("BadgeService")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules --
local HatBadgeIds = require(script.Parent:WaitForChild("HatBadgeIds"))

-- Variables
local HatStorage = ServerStorage:WaitForChild("HatStorage")
local HatModule = ServerScriptService:WaitForChild("AvatarSavesSystem"):WaitForChild("HatHandlerScript"):WaitForChild("HatInformationModule")
local RequestHat = ReplicatedStorage:WaitForChild("OtherEvents"):WaitForChild("RequestHat")

-- Tables --
local Blacklist = {}

-- Functions
local function onRequestHat(Player, HatName, HatType)
	if table.find(Blacklist, Player.UserId) then
		warn(Player.Name.." is using this RemoteEvent too fast... The request was rejected.")
	else
		-- Get the character, and their body parts
		local Character = Player.Character
		local Humanoid = Character:WaitForChild("Humanoid")
		local HatValue = Player:WaitForChild("leaderstats"):WaitForChild("Hat")

		local LeftArm = Character:WaitForChild("Left Arm")
		local RightArm = Character:WaitForChild("Right Arm")
		local LeftLeg = Character:WaitForChild("Left Leg")
		local RightLeg = Character:WaitForChild("Right Leg")
		local Torso = Character:WaitForChild("Torso")
		local Head = Character:WaitForChild("Head")
		
		-- Blacklist the User; Prevent them from using this remote function until the script finishes --
		local NewValue = table.insert(Blacklist, Player.UserId)

		if HatModule[HatName] then
			
			local FoundHat = HatModule[HatName]

			if FoundHat.Type == HatType then
				
				if HatType == "BadgeHat" then
					
					local ActualHat = HatStorage:WaitForChild("BadgeHats")[HatName]
					
					-- Sanity Check; Ensure they actually have the badge hat they're requesting --
					for i, v in pairs(HatBadgeIds) do
						if v.HatName == HatName then
							if BadgeService:UserHasBadgeAsync(Player.UserId, v.BadgeId) then
								-- let them go
							else
								Player:Kick("\nYou aren't allowed to access the hat ["..HatName.."] because you don't have the required BadgeId\n")
								return -- Exit function; Don't issue hat.
							end
						end
					end
					
					if Character:FindFirstChild(HatName) then
						-- do nothing
					else
						Humanoid:RemoveAccessories()
						Humanoid:UnequipTools()

						for i, v in pairs(Player.Backpack:GetChildren()) do
							if v:IsA("Tool") then
								if v.Name == "Lucky Numberator" then
									-- do nothing
								else
									v:Destroy()
								end
							end
						end

						ActualHat:Clone().Parent = Character
						Character:FindFirstChild(HatName):WaitForChild("Handle").Spawn:Play()

						LeftArm.BrickColor = BrickColor.new(HatModule[HatName].LeftArm)
						RightArm.BrickColor = BrickColor.new(HatModule[HatName].RightArm)
						LeftLeg.BrickColor = BrickColor.new(HatModule[HatName].LeftLeg)
						RightLeg.BrickColor = BrickColor.new(HatModule[HatName].RightLeg)
						Torso.BrickColor = BrickColor.new(HatModule[HatName].Torso)
						Head.BrickColor = BrickColor.new(HatModule[HatName].Head)

						HatValue.Value = HatName
						print("Received... ["..HatName.."], ["..HatType.."]. Completed...")
					end

				end

				
			end
		end
		
		-- Whitelist the User by removing their UserId from the table; Allow them to fire the remote function again --
		task.wait(1)
		table.remove(Blacklist, NewValue)
	end
	
end

-- Hook the event! --
RequestHat.OnServerEvent:Connect(onRequestHat)