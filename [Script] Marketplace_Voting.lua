--[[
    This script handles requests from players that want to purchase an upgrade or an item from the Marketplace created
    for "The Chill Zone", which is basically a hangout for players. All votes require half the server to say "Yes".
    if the ending vote is "No", then the item will fail to purchase, and inform the initial buyer that the process was denied.
    If the ending vote is "Yes", then the model is placed inside "The Chill Zone". Any custom function that is involved with
    model is ran, then the script safely ends.
]]

-- Services --
local PlayerService = game:GetService("Players")
local DebrisService = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Variables --
local OtherEvents = ReplicatedStorage:WaitForChild("OtherEvents")
local ChillZoneMarketplacePortal = OtherEvents:WaitForChild("ChillZoneMarketplacePortal")
local MarketplaceVoting = OtherEvents:WaitForChild("MarketplaceVoting")

local MarketplaceItems_Server_Module = require(script:WaitForChild("Marketplace_Items"))
local BoughtMarketplaceModels = workspace:WaitForChild("BoughtMarketplaceModels")
local MarketplaceModels = ServerStorage:WaitForChild("MarketplaceModels")

-- Marketplace Assets --
local ComputerScreen = workspace:WaitForChild("ComputerScreen")
local Notification = ComputerScreen:WaitForChild("Notification")
local ScreenGUI = ComputerScreen:WaitForChild("ScreenGUI")

local MarketplacePing = ComputerScreen:WaitForChild("MarketplacePing")
local MarketplaceFail = ComputerScreen:WaitForChild("MarketplaceFail")
local BankOpen = ComputerScreen:WaitForChild("BankOpen")

-- Marketplace Frame Assets --
local MarketplaceFrame = ScreenGUI:WaitForChild("MarketplaceFrame")
local VotingFrame = MarketplaceFrame:WaitForChild("VotingFrame")
local VotingInformation = VotingFrame:WaitForChild("Information")
local VotingTimer = VotingFrame:WaitForChild("Timer")
local TotalVotesCounter = VotingFrame:WaitForChild("TotalVotes")

local BankFrame = ScreenGUI:WaitForChild("BankFrame")
local BankInfo = BankFrame:WaitForChild("BankInfo")

local Balance = BankInfo:WaitForChild("ServerBalance")

-- Other Assets --
local ExtraFolder = ServerStorage:WaitForChild("Extra")
local ParticleEffects = ExtraFolder:WaitForChild("ParticleEffects")
local Confetti_Particle = ParticleEffects:WaitForChild("PurchaseCompleted")

-- Voting Assets
local VotingMemory = {}
local Debug_Mode = true

local VoteInProgress = script:WaitForChild("VoteInProgress")
local Minimum_Votes = 0
local Max_Votes = 0

-- Functions --
local function onRequestMarketplaceItem(Player, SelectedItem)
	if Player then
		if MarketplaceItems_Server_Module[SelectedItem] then
			if BoughtMarketplaceModels:FindFirstChild(SelectedItem) then
				return "AlreadyPurchased"
			else
				if Balance.Value >= MarketplaceItems_Server_Module[SelectedItem].Price then
					print("✉️ | Request purchase for "..SelectedItem.." has been initiated. Beginning voting...")
					MarketplacePing:Play()
					VoteInProgress.Value = true
					Notification.Enabled = true
					VotingFrame.Visible = true
					VotingInformation.Text = Player.Name.." would like to purchase "..MarketplaceItems_Server_Module[SelectedItem].Name.." for $"..MarketplaceItems_Server_Module[SelectedItem].Price.."."
					
					-- Math Calculations --
					Max_Votes = math.round(#PlayerService:GetPlayers() / 2)
					TotalVotesCounter.Text = "0/"..Max_Votes
					warn("✉️ | Max amount of votes required to pass is "..Minimum_Votes.."/"..Max_Votes..". If this requirement is not met, the vote will fail.")
					
					-- Initiate the Timer, and wait for it to be finished to decide final results
					for Timer = 15, 0, -1 do
						VotingTimer.Text = Timer.." second(s) left."
						task.wait(1)
					end
					
					print("✉️ | Voting is now over for "..SelectedItem..".")
					
					-- Final Decision based on votes
					if Minimum_Votes >= Max_Votes then
						-- Handle purchased product --
						BankOpen:Play()
						
						local FoundModel = MarketplaceModels[SelectedItem]:Clone()
						FoundModel.PrimaryPart.CFrame = MarketplaceItems_Server_Module[SelectedItem].SpawnCFrame
						FoundModel.Parent = BoughtMarketplaceModels
						
						local SpawnSound = Instance.new("Sound")
						SpawnSound.SoundId = "rbxassetid://4481540947"
						SpawnSound.Volume = 1
						SpawnSound.Parent = FoundModel.PrimaryPart
						SpawnSound:Play()
						DebrisService:AddItem(SpawnSound, 3)
						
						local ParticleFX_Clone = Confetti_Particle:Clone()
						ParticleFX_Clone.Parent = FoundModel.PrimaryPart
						ParticleFX_Clone:Emit(300)
						DebrisService:AddItem(ParticleFX_Clone, 3)
						
						-- Run any custom function the marketplace item might have --
						MarketplaceItems_Server_Module[SelectedItem].CustomFunction()
						
						Balance.Value -= MarketplaceItems_Server_Module[SelectedItem].Price
						
						for i, PlayerInMemory in pairs(VotingMemory) do
							table.remove(VotingMemory, i)
							
							if Debug_Mode == true then
								warn("[DEBUG]: Successfully removed "..PlayerInMemory.." from Voting Memory.")
							end
						end
						
						Minimum_Votes = 0
						Max_Votes = 0
						VoteInProgress.Value = false
						Notification.Enabled = false
						VotingFrame.Visible = false
						VotingInformation.Text = ""
						return "PurchaseSuccess"
					else
						-- Ignore purchase cuz it failed
						MarketplaceFail:Play()
						
						for i, PlayerInMemory in pairs(VotingMemory) do
							table.remove(VotingMemory, i)
							
							if Debug_Mode == true then
								warn("[DEBUG]: Successfully removed "..PlayerInMemory.." from Voting Memory.")
							end
						end
						
						Minimum_Votes = 0
						Max_Votes = 0
						VoteInProgress.Value = false
						Notification.Enabled = false
						VotingFrame.Visible = false
						VotingInformation.Text = ""
						return "PurchaseFailed"
					end
					
				else
					return "InsufficientFunds"
				end
			end
		else
			return "Nonexistant"
		end
	end
end

-- This function will manage 'Yes' or 'No' votes. It will also prevent extra votes, or changing of votes.
local function VoteManager(Player, Choice)
	if Player then
		if VoteInProgress.Value == true then
			if table.find(VotingMemory, Player.Name) then
				warn("✉️ | "..Player.Name.." has already voted before!")
				return "No"
			else
				if Minimum_Votes == Max_Votes then
					warn("✉️ | "..Player.Name.." tried to vote, but the max amount of votes has been reached!")
					return "No"
				else
					if Choice == "Yes" then
						Minimum_Votes += 1
						TotalVotesCounter.Text = Minimum_Votes.."/"..Max_Votes
						table.insert(VotingMemory, Player.Name)
						warn("✉️✅ | "..Player.Name.." has successfully voted '"..Choice.."'.")
						return "Yes"
					elseif Choice == "No" then
						warn("✉️✅ | "..Player.Name.." has successfully voted '"..Choice.."'.")
						table.insert(VotingMemory, Player.Name)
						return "No"
					else
						warn("✉️❌ | No proper voting parameter given. Make sure the voting parameter is 'No' or 'Yes'.")
					end
				end
			end
		else
			Player:Kick("You cannot fire this remote if no current vote is being held. Kicked for suspicious activity.")
		end
	end
end

-- Set the callbacks --
ChillZoneMarketplacePortal.OnServerInvoke = onRequestMarketplaceItem
MarketplaceVoting.OnServerInvoke = VoteManager