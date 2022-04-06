--[[
    This script performs a loop which checks through multiple different conditions and scenarios to ensure a smooth
    local-based sprint system, with some contact with the server (secured ofc). This loop will check for specific HumanoidStateTypes
    and ensure the sprint phase ends when one of those conditions are met. Included with a Sprint Animation and Stamina Bar.
]]

-- Wait until game loads --
if not game:IsLoaded() then
	game.Loaded:Wait()
end

-- Services --
local TweenService = game:GetService("TweenService")
local TweenInformation = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayersService = game:GetService("Players")
local Player = PlayersService.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- RemoteEvent --
local Remote = ReplicatedStorage:WaitForChild("OtherEvents"):WaitForChild("SprintPortal")

-- Sprint Mobile UI assets --
local SprintMobileUI = PlayerGui:WaitForChild("SprintPrompts")

local Frame = SprintMobileUI:WaitForChild("Frame")
local SprintButton = Frame:WaitForChild("SprintButton")

local StaminaFrame = SprintMobileUI:WaitForChild("StaminaFrame")
local StaminaBar = StaminaFrame:WaitForChild("StaminaBar")
local SprintSettings = StaminaFrame:WaitForChild("Settings")

-- Sprint Settings --
local CanRun = SprintSettings:WaitForChild("CanRun")
local IsRunning = SprintSettings:WaitForChild("IsRunning")
local StaminaInteger = SprintSettings:WaitForChild("StaminaInteger")

-- Other Variables
local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")

local AvatarSaves = Character:WaitForChild("AvatarSaves")
local CurrentlyEmoting = AvatarSaves:WaitForChild("CurrentlyEmoting")

local WalkSpeed_Config = script:GetAttribute("WalkSpeed")

local OriginalWalkSpeed = Humanoid.WalkSpeed
local OriginalJumpPower = Humanoid.JumpPower

local AnimationId = "rbxassetid://8108292455" -- Replace with the ID of the running animation.
local SprintAnimation = Instance.new("Animation")
SprintAnimation.Parent = Character:WaitForChild("Humanoid")
SprintAnimation.AnimationId = AnimationId

local LoadedSprintAnim = Humanoid:WaitForChild("Animator"):LoadAnimation(SprintAnimation)
local SprintDelay = false

local IsSprinting = false
local LoopShouldEnd = false

-- Check if the user is on Mobile --
if UserInputService.TouchEnabled == true then
	script:Destroy()
else
	-- Let them keep the script
end

-- Function that starts the sprinting process
local function onLeftControl(KeyPressed, gameProcessedEvent)
	if KeyPressed.KeyCode == Enum.KeyCode.LeftShift then
		if Player and Character then
			if CurrentlyEmoting.Value ~= true then
				if not SprintDelay then
					SprintDelay = true

					if CanRun.Value == false then
						-- do nothing
					else
						if Humanoid:GetState() == Enum.HumanoidStateType.Jumping or Humanoid:GetState() == Enum.HumanoidStateType.Freefall or Humanoid:GetState() == Enum.HumanoidStateType.None or StaminaInteger.Value <= 0 then
							-- do nothing
						elseif Humanoid.MoveDirection ~= Vector3.new(0, 0, 0) then
							
							local TweenInStamFrame = TweenService:Create(StaminaFrame, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.5})
							local TweenInStamBar = TweenService:Create(StaminaBar, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 0})
							StaminaFrame:WaitForChild("UIStroke").Enabled = true
							TweenInStamFrame:Play()
							TweenInStamBar:Play()

							Humanoid.JumpPower = 0
							Humanoid.WalkSpeed = WalkSpeed_Config
							IsRunning.Value = true

							Remote:FireServer("Shift_Pressed", WalkSpeed_Config)
							LoopShouldEnd = false

							repeat
								task.wait()

								-- Check if Sprint is already being played
								if IsSprinting == true then
									-- do nothing
								else
									IsSprinting = true
									LoadedSprintAnim:Play()
								end

								-- Check if the player is even moving
								if Humanoid.MoveDirection == Vector3.new(0, 0, 0) then
									Humanoid.WalkSpeed = OriginalWalkSpeed
									Humanoid.JumpPower = OriginalJumpPower
									
									Remote:FireServer("Shift_Lifted", OriginalWalkSpeed)

									LoadedSprintAnim:Stop()
									--CanRun.Value = true
									IsSprinting = false
								elseif Humanoid:GetState() == Enum.HumanoidStateType.Jumping or Humanoid:GetState() == Enum.HumanoidStateType.Freefall or Humanoid:GetState() == Enum.HumanoidStateType.None or Humanoid:GetState() == Enum.HumanoidStateType.Seated or CanRun.Value == false then
									Humanoid.WalkSpeed = OriginalWalkSpeed
									Humanoid.JumpPower = OriginalJumpPower
									
									Remote:FireServer("Shift_Lifted", OriginalWalkSpeed)

									LoadedSprintAnim:Stop()
									--CanRun.Value = true
									IsSprinting = false
								end

								-- Check if the LeftShift is no longer being held
								if LoopShouldEnd == true then
									LoadedSprintAnim:Stop()

									Humanoid.WalkSpeed = OriginalWalkSpeed
									Humanoid.JumpPower = OriginalJumpPower
									
									Remote:FireServer("Shift_Lifted", OriginalWalkSpeed)
									
									--CanRun.Value = true
									IsSprinting = false
									break
								end

								-- Run until one of these parameters are met
							until Humanoid.MoveDirection == Vector3.new(0, 0, 0) or Humanoid:GetState() == Enum.HumanoidStateType.Jumping or Humanoid:GetState() == Enum.HumanoidStateType.Freefall or Humanoid:GetState() == Enum.HumanoidStateType.Seated or CanRun.Value == false
							
							LoadedSprintAnim:Stop()
							Remote:FireServer("Shift_Lifted", OriginalWalkSpeed)
							
							CanRun.Value = true
							IsRunning.Value = false
						end
					end

					task.wait(0.5)
					SprintDelay = false
				end
			end
		end
	end
end

-- Function that stops the sprinting if shift is no longer held. This function no longer handles walkspeed due to Animation issues
local function onLeftControlRelease(KeyPressed, gameProcessedEvent)
	if KeyPressed.KeyCode == Enum.KeyCode.LeftShift then
		if Player and Character then
			if CurrentlyEmoting.Value ~= true then
				LoopShouldEnd = true
				Remote:FireServer("Shift_Lifted", OriginalWalkSpeed)
			end
		end
	end
end

-- Connect the events
UserInputService.InputBegan:Connect(onLeftControl)
UserInputService.InputEnded:Connect(onLeftControlRelease)

-- Constantly check if the CanRun value is false and give energy if it's not --
while true do
	if StaminaInteger.Value <= 0 then
		CanRun.Value = false
		LoadedSprintAnim:Stop()
		task.wait(5)
	elseif StaminaInteger.Value == 1 then
		if IsRunning.Value == false then
			task.wait(1)
			local TweenOutFrame = TweenService:Create(StaminaFrame, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1})
			local TweenOutStamBar = TweenService:Create(StaminaBar, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1})
			StaminaFrame:WaitForChild("UIStroke").Enabled = false
			TweenOutFrame:Play()
			TweenOutStamBar:Play()
			TweenOutStamBar.Completed:Wait()
			CanRun.Value = true
		end
	end
	
	if IsRunning.Value == false then
		if StaminaInteger.Value < 1 then
			StaminaInteger.Value += .01
			TweenService:Create(StaminaBar, TweenInformation, {Size = UDim2.new(StaminaInteger.Value, 0, 1, 0)}):Play()
			
			task.wait(0.1)
		else
			task.wait(0.5)
		end
	elseif IsRunning.Value == true then
		if StaminaInteger.Value > 0 then
			StaminaInteger.Value -= .01
			TweenService:Create(StaminaBar, TweenInformation, {Size = UDim2.new(StaminaInteger.Value, 0, 1, 0)}):Play()
			
			task.wait(0.05)
		else
			task.wait(0.5)
		end
	end
end