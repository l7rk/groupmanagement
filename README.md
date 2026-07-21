local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local pingEvent = ReplicatedStorage:WaitForChild("PlayerActivityPing")

local PING_THROTTLE_SECONDS = 10
local lastPing = 0

local function pingActivity()
	local now = os.clock()
	if now - lastPing >= PING_THROTTLE_SECONDS then
		lastPing = now
		pingEvent:FireServer()
	end
end

UserInputService.InputBegan:Connect(pingActivity)
UserInputService.InputChanged:Connect(pingActivity)

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
	if humanoid.MoveDirection.Magnitude > 0 then
		pingActivity()
	end
end)

player.CharacterAdded:Connect(function(newCharacter)
	local newHumanoid = newCharacter:WaitForChild("Humanoid")
	newHumanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		if newHumanoid.MoveDirection.Magnitude > 0 then
			pingActivity()
		end
	end)
end)
