-- ServerMain (Script) em ServerScriptService
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
local ProdutosModelos = ReplicatedStorage:WaitForChild("ProdutosModelos")
local ImoveisModelos = ReplicatedStorage:WaitForChild("ImoveisModelos")

-- === Remotes ===
local Remotes = Instance.new("Folder")
Remotes.Name = "Remotes"
Remotes.Parent = ReplicatedStorage

local BuyProduct = Instance.new("RemoteEvent")
BuyProduct.Name = "BuyProduct"
BuyProduct.Parent = Remotes

local PlaceFixture = Instance.new("RemoteEvent")
PlaceFixture.Name = "PlaceFixture"
PlaceFixture.Parent = Remotes

local PlaceProduct = Instance.new("RemoteEvent")
PlaceProduct.Name = "PlaceProduct"
PlaceProduct.Parent = Remotes

local AcertouSpy = Instance.new("RemoteEvent")
AcertouSpy.Name = "AcertouSpy"
AcertouSpy.Parent = Remotes

-- === Quantas unidades cada produto tem quando é colocado ===
local UNIDADES_POR_PRODUTO = 10

-- === Preparar jogador ===
local function setupPlayer(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = GameData.StartingMoney
	money.Parent = leaderstats

	local stock = Instance.new("Folder")
	stock.Name = "Stock"
	stock.Parent = player
	for id, _ in pairs(GameData.Products) do
		local v = Instance.new("IntValue")
		v.Name = id
		v.Value = 0
		v.Parent = stock
	end
end

Players.PlayerAdded:Connect(setupPlayer)

-- === Comprar produto (vai para o stock) ===
BuyProduct.OnServerEvent:Connect(function(player, productId)
	local data = GameData.Products[productId]
	if not data then return end
	local money = player.leaderstats.Money
	if money.Value >= data.Price then
		money.Value -= data.Price
		local stockItem = player.Stock:FindFirstChild(productId)
		if stockItem then
			stockItem.Value += 1
		end
	end
end)

-- === Colocar imóvel no mapa ===
PlaceFixture.OnServerEvent:Connect(function(player, fixtureId, targetCFrame)
	local data = GameData.Fixtures[fixtureId]
	if not data then return end
	local money = player.leaderstats.Money
	if money.Value < data.Price then return end
	local modelo = ImoveisModelos:FindFirstChild(data.ModelName)
	if not modelo then
		warn("Modelo de imóvel não encontrado: " .. data.ModelName)
		return
	end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if (root.Position - targetCFrame.Position).Magnitude > 100 then return end
	money.Value -= data.Price
	local clone = modelo:Clone()
	clone:SetAttribute("FixtureType", data.FixtureType)
	clone:SetAttribute("OwnerId", player.UserId)
	clone:PivotTo(targetCFrame)
	clone.Parent = workspace
end)

-- === Colocar produto num imóvel ===
PlaceProduct.OnServerEvent:Connect(function(player, productId, fixtureModel)
	local data = GameData.Products[productId]
	if not data then return end
	if not fixtureModel or not fixtureModel:IsA("Model") then return end

	-- o produto tem de combinar com o tipo do imóvel
	if fixtureModel:GetAttribute("FixtureType") ~= data.FixtureType then return end

	-- o jogador tem de ter o produto em stock
	local stockItem = player.Stock:FindFirstChild(productId)
	if not stockItem or stockItem.Value <= 0 then return end

	local modelo = ProdutosModelos:FindFirstChild(data.ModelName)
	if not modelo then
		warn("Modelo de produto não encontrado: " .. data.ModelName)
		return
	end

	-- gastar 1 do stock do jogador
	stockItem.Value -= 1

	-- colocar o produto em cima do imóvel
	local clone = modelo:Clone()
	local fixtureCFrame = fixtureModel:GetPivot()
	local _, fixtureSize = fixtureModel:GetBoundingBox()
	clone:PivotTo(fixtureCFrame * CFrame.new(0, fixtureSize.Y / 2 + 1, 0))
	clone:SetAttribute("ProductId", productId)

	-- cada produto colocado aguenta 10 compras
	clone:SetAttribute("Unidades", UNIDADES_POR_PRODUTO)

	-- número por cima a mostrar quantas unidades restam
	local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")
	if primaryPart then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ContadorStock"
		billboard.Size = UDim2.new(0, 60, 0, 30)
		billboard.StudsOffset = Vector3.new(0, 2, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = primaryPart

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.Text = "x" .. UNIDADES_POR_PRODUTO
		label.Parent = billboard
	end

	clone.Parent = fixtureModel
end)

-- === Bastão: jogador acertou no Spy ===
AcertouSpy.OnServerEvent:Connect(function(player, spy)
	if not spy or not spy.Parent then return end
	if spy.Name ~= "Spy" then return end

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local spyRoot = spy:FindFirstChild("HumanoidRootPart")
	if not root or not spyRoot then return end
	if (root.Position - spyRoot.Position).Magnitude > 10 then return end

	for _, part in ipairs(spy:GetDescendants()) do
		if part:IsA("BasePart") then
			part.BrickColor = BrickColor.new("Bright red")
		end
	end
	task.wait(0.4)
	spy:Destroy()
end) 
