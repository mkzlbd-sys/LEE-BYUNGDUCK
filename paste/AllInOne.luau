-- 별 모으기 놀이터 (붙여 넣기용 한 파일 버전)
-- 사용법: ServerScriptService 안에 Script 1개를 만들고, 기존 내용을 지운 뒤 이 전체를 붙여 넣기

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- ===== 설정값 (숫자만 바꿔도 됨) =====
local STAR_COUNT = 40 -- 별 개수
local STAR_RESPAWN = 8 -- 먹은 별이 다시 생기는 시간(초)
local MAP_RADIUS = 80 -- 놀이터 반지름
local JUMP_POWER = 60 -- 점프 힘 (기본 50)
local BOUNCE_POWER = 120 -- 트램펄린 힘
local COLORS = {
	Color3.fromRGB(255, 105, 180), -- 분홍
	Color3.fromRGB(255, 200, 60), -- 노랑
	Color3.fromRGB(100, 220, 255), -- 하늘
	Color3.fromRGB(150, 255, 150), -- 연두
	Color3.fromRGB(200, 150, 255), -- 보라
}
local SOUND_ID = "rbxassetid://9125402735" -- 효과음 (안 나오면 다른 ID로 교체)

-- ===== 놀이터 =====
local world = Instance.new("Folder")
world.Name = "World"
world.Parent = Workspace

local function makePart(name, size, pos, color)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.Position = pos
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = world
	return p
end

makePart("Ground", Vector3.new(MAP_RADIUS * 2, 2, MAP_RADIUS * 2), Vector3.new(0, -1, 0), Color3.fromRGB(120, 220, 120))

local spawn = Instance.new("SpawnLocation")
spawn.Size = Vector3.new(12, 1, 12)
spawn.Position = Vector3.new(0, 0.5, 0)
spawn.Anchored = true
spawn.Neutral = true
spawn.Parent = world

for i, color in ipairs(COLORS) do
	makePart("Rainbow" .. i, Vector3.new(14, 2, 10), Vector3.new(30, i * 4 - 1, 0), color)
end

for i = 1, 6 do
	local angle = (i / 6) * math.pi * 2
	local pad = makePart(
		"BouncePad" .. i,
		Vector3.new(8, 1, 8),
		Vector3.new(math.cos(angle) * 45, 0.5, math.sin(angle) * 45),
		COLORS[(i - 1) % #COLORS + 1]
	)
	pad.Material = Enum.Material.Neon
	local busy = {}
	pad.Touched:Connect(function(hit)
		local character = hit.Parent
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and not busy[character] then
			busy[character] = true
			local v = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(v.X, BOUNCE_POWER, v.Z)
			task.delay(0.5, function()
				busy[character] = nil
			end)
		end
	end)
end

-- ===== 점수판 =====
Players.PlayerAdded:Connect(function(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player
	local stars = Instance.new("IntValue")
	stars.Name = "Stars"
	stars.Parent = stats

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.UseJumpPower = true
		humanoid.JumpPower = JUMP_POWER
	end)
end)

-- ===== 별 =====
local folder = Instance.new("Folder")
folder.Name = "Stars"
folder.Parent = Workspace

-- 별을 먹은 자리에 "+1" 글자와 소리 띄우기
local function celebrate(position, color)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.Position = position
	anchor.Parent = Workspace

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(120, 60)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.AlwaysOnTop = true
	gui.Parent = anchor
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "+1 ⭐"
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = color
	label.TextStrokeTransparency = 0
	label.Parent = gui

	local sound = Instance.new("Sound")
	sound.SoundId = SOUND_ID
	sound.Volume = 0.6
	sound.Parent = anchor
	sound:Play()

	Debris:AddItem(anchor, 1.5)
end

local function spawnStar()
	local r = MAP_RADIUS - 6
	local star = Instance.new("Part")
	star.Name = "Star"
	star.Shape = Enum.PartType.Ball
	star.Size = Vector3.new(3, 3, 3)
	star.Anchored = true
	star.CanCollide = false
	star.Material = Enum.Material.Neon
	star.Color = COLORS[math.random(#COLORS)]
	star.Position = Vector3.new(math.random(-r, r), math.random(4, 14), math.random(-r, r))
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
		local stats = player:FindFirstChild("leaderstats")
		local stars = stats and stats:FindFirstChild("Stars")
		if stars then
			stars.Value += 1
		end
		celebrate(star.Position, star.Color)
		star:Destroy()
		task.delay(STAR_RESPAWN, spawnStar)
	end)
end

for _ = 1, STAR_COUNT do
	spawnStar()
end

-- 별이 둥실둥실 돌기
RunService.Heartbeat:Connect(function()
	local t = os.clock()
	for i, star in ipairs(folder:GetChildren()) do
		star.CFrame = star.CFrame * CFrame.Angles(0, 0.03, 0) + Vector3.new(0, math.sin(t * 2 + i) * 0.02, 0)
	end
end)
