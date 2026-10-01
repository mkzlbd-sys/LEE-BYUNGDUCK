-- 별 모으기: 별을 만지면 점수가 오르고, 잠시 뒤 다시 나타남
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Config = require(ReplicatedStorage.Shared.Config)

-- 점수판(leaderstats)
Players.PlayerAdded:Connect(function(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player
	local stars = Instance.new("IntValue")
	stars.Name = "Stars"
	stars.Value = 0
	stars.Parent = stats

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.UseJumpPower = true
		humanoid.JumpPower = Config.JumpPower
	end)
end)

-- 클라이언트에 알림을 보내는 이벤트
local collected = Instance.new("RemoteEvent")
collected.Name = "StarCollected"
collected.Parent = ReplicatedStorage

local folder = Instance.new("Folder")
folder.Name = "Stars"
folder.Parent = Workspace

local function randomPosition(): Vector3
	local r = Config.MapRadius - 6
	return Vector3.new(math.random(-r, r), math.random(4, 14), math.random(-r, r))
end

local function spawnStar()
	local star = Instance.new("Part")
	star.Name = "Star"
	star.Shape = Enum.PartType.Ball
	star.Size = Vector3.new(3, 3, 3)
	star.Anchored = true
	star.CanCollide = false
	star.Material = Enum.Material.Neon
	star.Color = Config.Colors[math.random(#Config.Colors)]
	star.Position = randomPosition()
	star.Parent = folder

	local light = Instance.new("PointLight")
	light.Color = star.Color
	light.Range = 12
	light.Parent = star

	local taken = false
	star.Touched:Connect(function(hit)
		if taken then
			return
		end
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then
			return
		end
		taken = true
		local stars = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Stars")
		if stars then
			stars.Value += 1
		end
		collected:FireClient(player, star.Position, star.Color)
		star:Destroy()
		task.delay(Config.StarRespawnSeconds, spawnStar)
	end)
end

for _ = 1, Config.StarCount do
	spawnStar()
end

-- 별이 둥실둥실 돌게 하기
game:GetService("RunService").Heartbeat:Connect(function()
	local t = os.clock()
	for i, star in ipairs(folder:GetChildren()) do
		if star:IsA("BasePart") then
			star.CFrame = star.CFrame * CFrame.Angles(0, 0.03, 0) + Vector3.new(0, math.sin(t * 2 + i) * 0.02, 0)
		end
	end
end)
