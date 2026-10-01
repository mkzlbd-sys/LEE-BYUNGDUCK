-- 놀이터 만들기: 바닥, 무지개 계단, 트램펄린 발판
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local world = Instance.new("Folder")
world.Name = "World"
world.Parent = Workspace

local function makePart(name: string, size: Vector3, pos: Vector3, color: Color3): Part
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

-- 바닥(잔디)
makePart("Ground", Vector3.new(Config.MapRadius * 2, 2, Config.MapRadius * 2), Vector3.new(0, -1, 0), Color3.fromRGB(120, 220, 120))

-- 시작 위치
local spawn = Instance.new("SpawnLocation")
spawn.Name = "Spawn"
spawn.Size = Vector3.new(12, 1, 12)
spawn.Position = Vector3.new(0, 0.5, 0)
spawn.Anchored = true
spawn.Neutral = true
spawn.Color = Color3.fromRGB(255, 255, 255)
spawn.Parent = world

-- 무지개 계단
for i, color in ipairs(Config.Colors) do
	makePart("Rainbow" .. i, Vector3.new(14, 2, 10), Vector3.new(30, i * 4 - 1, 0), color)
end

-- 트램펄린 발판: 밟으면 높이 튀어 오름
for i = 1, 6 do
	local angle = (i / 6) * math.pi * 2
	local pad = makePart(
		"BouncePad" .. i,
		Vector3.new(8, 1, 8),
		Vector3.new(math.cos(angle) * 45, 0.5, math.sin(angle) * 45),
		Config.Colors[(i - 1) % #Config.Colors + 1]
	)
	pad.Material = Enum.Material.Neon
	local debounce: { [Model]: boolean } = {}
	pad.Touched:Connect(function(hit)
		local character = hit.Parent
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if humanoid and root and not debounce[character] then
			debounce[character] = true
			root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, Config.BouncePadPower, root.AssemblyLinearVelocity.Z)
			task.delay(0.5, function()
				debounce[character] = nil
			end)
		end
	end)
end
