--[[
    This script handles, and ensures the battery percentage for the Lucky Numberator (Basically a phone in case you're curious)
    is saved correctly. When the player joins, the script checks if they have received default percentage, or not.
    If the server sees that they haven't been given the default percentage, it will issue it to a Attribute attached to the player, then save it.
    When the player leaves the game, the server will safely update their datastore using a pcall.
]]

-- Services --
local TweenService = game:GetService("TweenService")
local TweenInformation = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local PlayerService = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local BatteryPercentage = DataStoreService:GetDataStore("BatteryPercentage")

-- Variables --
local DefaultBatteryLevel = 100

-- Functions --

-- Function for working with Battery Percentages on the Lucky Numberator --
PlayerService.PlayerAdded:Connect(function(Player)

	-- Do a first join check for the players attribute --
	if Player then
		local Character = Player.Character
		local RetrievedData

		local success, failure = pcall(function()
			RetrievedData = BatteryPercentage:GetAsync(Player.UserId)
		end)

		if success then

			if RetrievedData ~= nil then

				-- If the data is NOT nil (No number saved in Datastore) then, work with it --
				print("✅ | Found existing Battery Percentage data... Working...")

				-- Make the new attribute, and work with it --
				local NewBatteryLevel = Player:SetAttribute("BatteryPercentage", RetrievedData)
				
				-- Locate the Numberator --
				local LuckyNumberator

				if Player.Backpack:FindFirstChild("Lucky Numberator") then
					LuckyNumberator = Player.Backpack:FindFirstChild("Lucky Numberator")
				elseif Character:FindFirstChild("Lucky Numberator") then
					LuckyNumberator = Character:FindFirstChild("Lucky Numberator")
				end

				-- Then get the UI elements on the screen --
				print("✅ | "..Player.Name.."'s Lucky Numberator has been located. Working with Percentage...")
				local BatteryFrame = LuckyNumberator:WaitForChild("Screen"):WaitForChild("PhoneScreen"):WaitForChild("Display"):WaitForChild("BatteryFrame")
				local ProgressBar = BatteryFrame:WaitForChild("ProgressBar")
				local ProgressLabel = BatteryFrame:WaitForChild("ProgressLabel")

				local CurrentBatteryPercentage = Player:GetAttribute("BatteryPercentage")

				local CalculatedBattery = CurrentBatteryPercentage / 100
				local Tween = TweenService:Create(ProgressBar, TweenInformation, {Size = UDim2.new(CalculatedBattery, 0, 1, 0)})
				Tween:Play()

				ProgressLabel.Text = CurrentBatteryPercentage.."/100"

				if CurrentBatteryPercentage <= 30 then
					local ColorTween = TweenService:Create(ProgressBar, TweenInformation, {BackgroundColor3 = Color3.fromRGB(255, 0, 0)})
					ColorTween:Play()
				end

			else
				print("💾⚠️ | "..Player.Name.." doesn't have any past BatteryPercentage data... Storing default value.")
				local NewBatteryLevel = Player:SetAttribute("BatteryPercentage", DefaultBatteryLevel)
			end

		elseif failure then
			warn("❌ | Retrieving data for Battery Percentage failed... Exception: "..failure)
		end
	end

	-- Set the BatteryLevel for when the player joins/respawns --
	Player.CharacterAdded:Connect(function(Character)

		task.wait(2)

		-- Locate the Numberator --
		local LuckyNumberator

		if Player.Backpack:FindFirstChild("Lucky Numberator") then
			LuckyNumberator = Player.Backpack:FindFirstChild("Lucky Numberator")
		elseif Character:FindFirstChild("Lucky Numberator") then
			LuckyNumberator = Character:FindFirstChild("Lucky Numberator")
		end

		-- Then get the UI elements on the screen --
		print("✅ | "..Player.Name.."'s Lucky Numberator has been located. Working with Percentage...")
		local BatteryFrame = LuckyNumberator:WaitForChild("Screen"):WaitForChild("PhoneScreen"):WaitForChild("Display"):WaitForChild("BatteryFrame")
		local ProgressBar = BatteryFrame:WaitForChild("ProgressBar")
		local ProgressLabel = BatteryFrame:WaitForChild("ProgressLabel")

		local CurrentBatteryPercentage = Player:GetAttribute("BatteryPercentage")

		local CalculatedBattery = CurrentBatteryPercentage / 100
		local Tween = TweenService:Create(ProgressBar, TweenInformation, {Size = UDim2.new(CalculatedBattery, 0, 1, 0)})
		Tween:Play()

		ProgressLabel.Text = CurrentBatteryPercentage.."/100"

		if CurrentBatteryPercentage <= 30 then
			local ColorTween = TweenService:Create(ProgressBar, TweenInformation, {BackgroundColor3 = Color3.fromRGB(255, 0, 0)})
			ColorTween:Play()
		end

	end)
end)

-- Function that saves BatteryLevel when the player begins to leave the game --
PlayerService.PlayerRemoving:Connect(function(Player)
	if Player then
		local CurrentBatteryLevel = Player:GetAttribute("BatteryPercentage")

		local success, failure = pcall(function()
			BatteryPercentage:SetAsync(Player.UserId, CurrentBatteryLevel)
		end)

		if success then
			print("💾✅ | "..Player.Name.." saved current BatteryPercentage successfully.")
		elseif failure then
			warn("💾❌ | "..Player.Name.." did NOT save current BatteryPercentage correctly. Exception: "..failure)
		end

	end
end)