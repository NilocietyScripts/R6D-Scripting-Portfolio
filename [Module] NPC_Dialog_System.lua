--[[
    This ModuleScript allows the Client to interact with NPC's via ProximityPrompt, or by simply approaching a Region
    near them. The Region or ProximityPrompt will call the Initiate_NPC_Dialog() function from the Module, and will
    pass the appropriate arguments depending on which NPC was triggered, and how. This will carry out the dialog in the form
    of pages, and will iterate through each line to ensure all speech is said. If the NPC is talked to again,
    the next page of dialog triggers.
]]

local NPC_Dialog_System = {
	
	-- Create the function we will use to initiate all NPC dialog
	Initiate_NPC_Dialog = function(NPC, StateType)
		if NPC and StateType then
			
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local NPC_Dialog_System = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("NPC_System"):WaitForChild("NPC_Dialog_System"))
			local TypeText_Module = require(ReplicatedStorage:WaitForChild("OtherEvents"):WaitForChild("TypeText"))
			
			local Humanoid = NPC:WaitForChild("Humanoid")
			local NPC_Config = Humanoid:WaitForChild("NPC_Config")
			local IsAlreadyTalking = NPC_Config:WaitForChild("IsAlreadyTalking")
			
			-- Section Integers; These will determine how many "pages" of dialog we have--
			local Dialog_Integers = NPC_Config:WaitForChild("Dialog_Integers")
			local Current_Section = Dialog_Integers:WaitForChild("Current_Section")
			local Max_Sections = Dialog_Integers:WaitForChild("Max_Sections")
			
			if IsAlreadyTalking.Value == true then
				print("❌ | Cannot initiate NPC Dialog. One is already in progress for "..NPC.Name)
			else
				local Head = NPC:WaitForChild("Head")
				local TalkingSound = Head:WaitForChild("TalkingSound")
				
				local TalkingNPC_UI = Head:WaitForChild("TalkingNPCGUI")
				local NPC_Dialog_Box = TalkingNPC_UI:WaitForChild("Frame"):WaitForChild("TypeWriterText")

				local ProximityPrompt = Head:WaitForChild("ProximityPrompt")
				
				-- Configure NPC --
				TalkingNPC_UI.Enabled = true
				ProximityPrompt.Enabled = false
				IsAlreadyTalking.Value = true
				
				for i, TextToType in pairs(NPC_Dialog_System[NPC.Name][StateType][Current_Section.Value]) do
					TypeText_Module.TypeText(NPC_Dialog_Box, TextToType, 0.045, TalkingSound, true)
					task.wait(2)
				end
				
				task.wait(1)
				
				-- Move up the dialog by one. Stop if it reaches the max dialog sections.
				if Current_Section.Value >= Max_Sections.Value then
					-- Do nothing
				elseif Current_Section.Value < Max_Sections.Value then
					Current_Section.Value += 1
				end
				
				IsAlreadyTalking.Value = false
				TalkingNPC_UI.Enabled = false
				ProximityPrompt.Enabled = true
				
				-- Execute the Function for the NPC, if Conversation Dialog is the current Mode --
				if StateType == "Conversation Dialog" then
					NPC_Dialog_System[NPC.Name].CustomFunction()
				end
				
			end

		end
	end,
	
	-- Now for the actual NPCs --
	
	-- The Code Guy --
	["The Code Guy"] = {
		
		-- Proximity Dialog is when you get close to the NPC. A random one is selected upon approaching.
		["Proximity Dialog"] = {
            -- The numbers in this array indicate the pages of dialog to read through.
			[1] = {
				"Nice day, isn't it?",
				"Hello there!",
			},
		},
		
		-- Conversation Dialog is the normal dialog that occurs when interacting with an NPC.
		["Conversation Dialog"] = {
            -- The numbers in this array indicate the pages of dialog to read through.
			[1] = {
				"I see that the Hat Library caught your eye! I have a bit of bad news though...",
				"Unfortunately the Hat Library is closed... we're experiencing a bit of technical difficulties with it.",
				"Maybe check back up on it in the future, as we might have revamped it! You certainly won't want to miss it :)",
			},
			
			[2] = {
				"Don't worry, we'll get things working again sooner or later! Just know it'll be fixed."
			}
		},
		
		-- This function will run after the dialog is played. Only works for Conversation Dialog.
		CustomFunction = function()
			print("⚠️ | Finished dialog with NPC, however no CustomFunction is available for them.")
		end,
		
	},
}

return NPC_Dialog_System