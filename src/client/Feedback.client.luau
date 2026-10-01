-- 별을 먹었을 때 소리와 "+1 ⭐" 글자로 칭찬해 주기
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "Feedback"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://9125402735" -- 효과음. 마음에 안 들면 다른 ID로 교체
sound.Volume = 0.6
sound.Parent = SoundService

ReplicatedStorage:WaitForChild("StarCollected").OnClientEvent:Connect(function(_position, color)
	sound:Play()
	local label = Instance.new("TextLabel")
	label.Text = "+1 ⭐"
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = color
	label.TextStrokeTransparency = 0
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(0.2, 0.1)
	label.Position = UDim2.fromScale(0.4, 0.4)
	label.Parent = gui
	local tween = TweenService:Create(label, TweenInfo.new(0.8), {
		Position = UDim2.fromScale(0.4, 0.25),
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	})
	tween:Play()
	tween.Completed:Connect(function()
		label:Destroy()
	end)
end)
