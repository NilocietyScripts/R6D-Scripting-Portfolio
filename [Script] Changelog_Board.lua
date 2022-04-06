--[[
    This script gathers an array of changelogs, then iterates through a loop to clone and create new textlabels.
    These text labels have their text changed to the one set in the loop, then are parented to a UIListLayout
    to properly space, and show in Date-Of-Creation order. The board is then present to all Players to read at spawn.
]]

-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

-- Variables --
local CurrentChangelog = {
	[1] = "▶️ (v4.0.0) Replaced most of the experiences audio to comply with Audio Privacy changes on March 22nd.",
	[2] = "▶️ (v4.0.0) Enabled Generator ambience sound effect on all Charging Stations. This was in the game, but not enabled when they were implemented.",
	[3] = "▶️ (v4.0.0) Refined SprintHandler script to properly end the running animation when Stamina is exhausted. This feature will be expanded on in another update.",
	[4] = "▶️ (v4.0.0) Refined 'The Chill Zone Marketplace' UI because the previous edit was not super 'customer' friendly.",
	[5] = "▶️ (v4.0.0) Fixed a bug with 'Exit Focus' button on Computer in The Chill Zone. Resetting properly fixes the camera now.",
	[6] = "▶️ (v4.0.0) Redesigned DisplayTags above players' heads. All characters use a new DisplayTag by default now.",
	[7] = "▶️ (v4.0.0) All hats in the game have been updated to support multiple hats at the same time for one name. This was present in the backend, but never used until now.",
	[8] = "▶️ (v4.0.0) Implemented 'The Chill Zone Marketplace' fully into the game. Voting, timer, and items are present and working. Make sure to suggest some additions in our server!",
	[9] = "▶️ (v4.0.0) Updated this board to display recent changelogs instead of unused text. Now this actually has purpose.",
	[10] = "▶️ (v4.0.0) Adjusted DistanceBlur (Depth of Field) to be more accurate when focusing in on objects.",
	[11] = "▶️ (v4.0.0) Adjusted Night Time to look more like night with a better, and more accurate atmosphere.",
	[12] = "▶️ (v4.0.0) Adjusted ProcessReceipt script for Donor badge to compensate for new nametag system. (Watch for bugs please!)",
	[13] = "▶️ (v4.0.1) Fixed a bug that caused the inability to purchase hats due to the recent change in the way Hats work for Characters.",
	[14] = "▶️ (v4.0.1) Fixed a bug that caused The Chill Zone Marketplace to store peoples votes in memory forever, preventing further purchases of other items.",
	[15] = "▶️ (v4.0.1) Adjusted TV Light in The Chill Zone to be more accurate.",
	[16] = "▶️ (v4.0.1) Added 'Improved Lights' to The Chill Zone Marketplace. The price goes for $50.",
	[17] = "▶️ (v4.0.1) Fixed a bug on Mobile Sprint where when the Stamina Bar ran out, the player would keep running.",
}

local EventNoticePart = script.Parent
local UpdateSign = EventNoticePart:WaitForChild("UpdateSign")
local Changelog = UpdateSign:WaitForChild("Changelog")
local MainTitle = UpdateSign:WaitForChild("MainTitle")

local Resources = UpdateSign:WaitForChild("Resources")
local TemplateButton = Resources:WaitForChild("TemplateButton")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local JSONDateConverter = require(Modules:WaitForChild("JSONDateConverter"))

-- Functions --
local CurrentGameVersion

local success, failure = pcall(function()
	-- This time will be in ISO6801 format. We'll need to convert this!
	CurrentGameVersion = MarketplaceService:GetProductInfo(game.PlaceId).Updated
end)

if success then
	-- This will set CurrentGameVersion to a solid NUMBER (Example: 1945757884)
	CurrentGameVersion = JSONDateConverter:Decode_JSON_Date(CurrentGameVersion)
	MainTitle.Text = "Changelog: "..os.date("%a, %b %d, at %I:%M:%S %p", CurrentGameVersion)
	
	-- Add all changes to the changelog board --
	local success, failure = pcall(function()
		for i, Change in pairs(CurrentChangelog) do
			local CurrentChange = TemplateButton:Clone()
			CurrentChange.Name = i.."Change"
			CurrentChange.Text = Change
			CurrentChange.Visible = true
			CurrentChange.Parent = Changelog
			task.wait(0.1)
		end
	end)

	if success then
		print("▶️ ✅ | Successfully loaded all changes into changelog sign")
	elseif failure then
		warn("▶️ ❌ | Failed to load all changes into changelog sign. Exception: "..failure)
	end
end