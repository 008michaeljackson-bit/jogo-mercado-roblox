-- ClientMain (LocalScript) em StarterPlayer > StarterPlayerScripts
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
local ImoveisModelos = ReplicatedStorage:WaitForChild("ImoveisModelos")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BuyProduct = Remotes:WaitForChild("BuyProduct")
local PlaceFixture = Remotes:WaitForChild("PlaceFixture")
local PlaceProduct = Remotes:WaitForChild("PlaceProduct")

local leaderstats = player:WaitForChild("leaderstats")
local money = leaderstats:WaitForChild("Money")
local stock = player:WaitForChild("Stock")

-- =========================================================
-- INTERFACE
-- =========================================================
local gui = Instance.new("ScreenGui")
gui.Name = "MercadoGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- ----- Dinheiro -----
local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(0, 200, 0, 50)
moneyLabel.Position = UDim2.new(0, 20, 0, 20)
moneyLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
moneyLabel.BackgroundTransparency = 0.2
moneyLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
moneyLabel.Font = Enum.Font.GothamBold
moneyLabel.TextSize = 22
moneyLabel.Text = "$ " .. money.Value
moneyLabel.Parent = gui
Instance.new("UICorner", moneyLabel).CornerRadius = UDim.new(0, 10)

money.Changed:Connect(function()
	moneyLabel.Text = "$ " .. money.Value
end)

-- ----- Botão LOJA -----
local shopButton = Instance.new("TextButton")
shopButton.Size = UDim2.new(0, 120, 0, 50)
shopButton.Position = UDim2.new(0, 20, 1, -70)
shopButton.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
shopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shopButton.Font = Enum.Font.GothamBold
shopButton.TextSize = 20
shopButton.Text = "LOJA"
shopButton.Parent = gui
Instance.new("UICorner", shopButton).CornerRadius = UDim.new(0, 10)

-- ----- Botão STOCK -----
local stockButton = Instance.new("TextButton")
stockButton.Size = UDim2.new(0, 120, 0, 50)
stockButton.Position = UDim2.new(0, 150, 1, -70)
stockButton.BackgroundColor3 = Color3.fromRGB(220, 150, 50)
stockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stockButton.Font = Enum.Font.GothamBold
stockButton.TextSize = 20
stockButton.Text = "STOCK"
stockButton.Parent = gui
Instance.new("UICorner", stockButton).CornerRadius = UDim.new(0, 10)

-- ----- Aviso de rotação (aparece só ao colocar imóvel) -----
local rotateHint = Instance.new("TextLabel")
rotateHint.Size = UDim2.new(0, 380, 0, 50)
rotateHint.Position = UDim2.new(0.5, -190, 0, 90)
rotateHint.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
rotateHint.BackgroundTransparency = 0.2
rotateHint.TextColor3 = Color3.fromRGB(255, 255, 255)
rotateHint.Font = Enum.Font.GothamBold
rotateHint.TextSize = 18
rotateHint.Text = "Pressione E para girar 45°  |  X para cancelar"
rotateHint.Visible = false
rotateHint.Parent = gui
Instance.new("UICorner", rotateHint).CornerRadius = UDim.new(0, 10)

-- ----- Painel da LOJA -----
local shopFrame = Instance.new("Frame")
shopFrame.Size = UDim2.new(0, 400, 0, 350)
shopFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
shopFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
shopFrame.Visible = false
shopFrame.Parent = gui
Instance.new("UICorner", shopFrame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.Text = "LOJA"
title.Parent = shopFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Text = "X"
closeBtn.Parent = shopFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local tabProdutos = Instance.new("TextButton")
tabProdutos.Size = UDim2.new(0.5, -10, 0, 35)
tabProdutos.Position = UDim2.new(0, 10, 0, 45)
tabProdutos.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
tabProdutos.TextColor3 = Color3.fromRGB(255, 255, 255)
tabProdutos.Font = Enum.Font.GothamBold
tabProdutos.TextSize = 16
tabProdutos.Text = "Produtos"
tabProdutos.Parent = shopFrame
Instance.new("UICorner", tabProdutos).CornerRadius = UDim.new(0, 8)

local tabImoveis = Instance.new("TextButton")
tabImoveis.Size = UDim2.new(0.5, -10, 0, 35)
tabImoveis.Position = UDim2.new(0.5, 0, 0, 45)
tabImoveis.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
tabImoveis.TextColor3 = Color3.fromRGB(255, 255, 255)
tabImoveis.Font = Enum.Font.GothamBold
tabImoveis.TextSize = 16
tabImoveis.Text = "Imóveis"
tabImoveis.Parent = shopFrame
Instance.new("UICorner", tabImoveis).CornerRadius = UDim.new(0, 8)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -20, 1, -95)
list.Position = UDim2.new(0, 10, 0, 85)
list.BackgroundTransparency = 1
list.ScrollBarThickness = 6
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = shopFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = list

-- ----- Painel do STOCK -----
local stockFrame = Instance.new("Frame")
stockFrame.Size = UDim2.new(0, 400, 0, 350)
stockFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
stockFrame.BackgroundColor3 = Color3.fromRGB(45, 38, 30)
stockFrame.Visible = false
stockFrame.Parent = gui
Instance.new("UICorner", stockFrame).CornerRadius = UDim.new(0, 12)

local stockTitle = Instance.new("TextLabel")
stockTitle.Size = UDim2.new(1, 0, 0, 40)
stockTitle.BackgroundTransparency = 1
stockTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
stockTitle.Font = Enum.Font.GothamBold
stockTitle.TextSize = 24
stockTitle.Text = "STOCK"
stockTitle.Parent = stockFrame

local stockClose = Instance.new("TextButton")
stockClose.Size = UDim2.new(0, 30, 0, 30)
stockClose.Position = UDim2.new(1, -35, 0, 5)
stockClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
stockClose.TextColor3 = Color3.fromRGB(255, 255, 255)
stockClose.Font = Enum.Font.GothamBold
stockClose.TextSize = 18
stockClose.Text = "X"
stockClose.Parent = stockFrame
Instance.new("UICorner", stockClose).CornerRadius = UDim.new(0, 8)

local stockHint = Instance.new("TextLabel")
stockHint.Size = UDim2.new(1, -20, 0, 30)
stockHint.Position = UDim2.new(0, 10, 0, 45)
stockHint.BackgroundTransparency = 1
stockHint.TextColor3 = Color3.fromRGB(200, 200, 200)
stockHint.Font = Enum.Font.Gotham
stockHint.TextSize = 13
stockHint.Text = "Clica num produto, depois clica no imóvel para o colocar"
stockHint.TextWrapped = true
stockHint.Parent = stockFrame

local stockList = Instance.new("ScrollingFrame")
stockList.Size = UDim2.new(1, -20, 1, -95)
stockList.Position = UDim2.new(0, 10, 0, 85)
stockList.BackgroundTransparency = 1
stockList.ScrollBarThickness = 6
stockList.CanvasSize = UDim2.new(0, 0, 0, 0)
stockList.AutomaticCanvasSize = Enum.AutomaticSize.Y
stockList.Parent = stockFrame

local stockLayout = Instance.new("UIListLayout")
stockLayout.Padding = UDim.new(0, 8)
stockLayout.Parent = stockList

-- =========================================================
-- FUNÇÕES DE LISTA
-- =========================================================
local function clearFrame(frame)
	for _, child in ipairs(frame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

local function makeRow(parent, leftText, btnText, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 50)
	row.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
	row.Parent = parent
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
	nameLabel.Position = UDim2.new(0, 10, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextSize = 16
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = leftText
	nameLabel.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 100, 0, 36)
	btn.Position = UDim2.new(1, -110, 0.5, -18)
	btn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Text = btnText
	btn.Parent = row
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	btn.MouseButton1Click:Connect(callback)
	return row
end

-- =========================================================
-- COLOCAÇÃO DE IMÓVEIS
-- =========================================================
local placing = false
local placementReady = false
local previewModel = nil
local currentFixtureId = nil
local placementRotation = 0 -- rotação atual em graus

local camera = workspace.CurrentCamera

local function startFixturePlacement(fixtureId)
	local data = GameData.Fixtures[fixtureId]
	if not data or placing then return end
	local modelo = ImoveisModelos:FindFirstChild(data.ModelName)
	if not modelo then return end

	placing = true
	placementReady = false
	currentFixtureId = fixtureId
	placementRotation = 0
	shopFrame.Visible = false
	rotateHint.Visible = true

	previewModel = modelo:Clone()
	for _, part in ipairs(previewModel:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 0.5
			part.CanCollide = false
		end
	end
	previewModel.Parent = workspace

	task.delay(0.15, function()
		placementReady = true
	end)
end

local function stopFixturePlacement()
	placing = false
	placementReady = false
	currentFixtureId = nil
	rotateHint.Visible = false
	if previewModel then
		previewModel:Destroy()
		previewModel = nil
	end
end

RunService.RenderStepped:Connect(function()
	if not (placing and previewModel) then return end

	-- Raycast a partir da câmara, ignorando o preview e o personagem
	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignoreList = { previewModel }
	if player.Character then
		table.insert(ignoreList, player.Character)
	end
	params.FilterDescendantsInstances = ignoreList

	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
	if result then
		-- aplica a posição do rato + a rotação escolhida
		previewModel:PivotTo(CFrame.new(result.Position) * CFrame.Angles(0, math.rad(placementRotation), 0))
	end
end)

-- =========================================================
-- COLOCAÇÃO DE PRODUTOS
-- =========================================================
local selectedProduct = nil

local function selectProductForPlacing(productId)
	selectedProduct = productId
	stockFrame.Visible = false
end

-- =========================================================
-- CLIQUES NO MUNDO (colocar imóvel OU produto)
-- =========================================================
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end

	-- a colocar imóvel
	if placing then
		if input.UserInputType == Enum.UserInputType.MouseButton1 and placementReady then
			PlaceFixture:FireServer(currentFixtureId, previewModel:GetPivot())
			stopFixturePlacement()
		elseif input.KeyCode == Enum.KeyCode.E then
			-- rodar 45 graus
			placementRotation = placementRotation + 45
		elseif input.KeyCode == Enum.KeyCode.X then
			stopFixturePlacement()
		end
		return
	end

	-- a colocar produto (clicar num imóvel)
	if selectedProduct then
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local target = mouse.Target
			if target then
				local model = target:FindFirstAncestorOfClass("Model")
				if model and model:GetAttribute("FixtureType") then
					PlaceProduct:FireServer(selectedProduct, model)
					selectedProduct = nil
				end
			end
		elseif input.KeyCode == Enum.KeyCode.X then
			selectedProduct = nil
		end
	end
end)

-- =========================================================
-- MOSTRAR LISTAS
-- =========================================================
local function showProdutos()
	tabProdutos.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
	tabImoveis.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
	clearFrame(list)
	for id, data in pairs(GameData.Products) do
		makeRow(list, data.Name .. "  ($" .. data.Price .. ")", "Comprar", function()
			BuyProduct:FireServer(id)
		end)
	end
end

local function showImoveis()
	tabImoveis.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
	tabProdutos.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
	clearFrame(list)
	for id, data in pairs(GameData.Fixtures) do
		makeRow(list, data.Name .. "  ($" .. data.Price .. ")", "Colocar", function()
			startFixturePlacement(id)
		end)
	end
end

local function showStock()
	clearFrame(stockList)
	for id, data in pairs(GameData.Products) do
		local stockItem = stock:FindFirstChild(id)
		local qty = stockItem and stockItem.Value or 0
		makeRow(stockList, data.Name .. "  (tens " .. qty .. ")", "Colocar", function()
			if qty > 0 then
				selectProductForPlacing(id)
			end
		end)
	end
end

-- =========================================================
-- LIGAR BOTÕES
-- =========================================================
tabProdutos.MouseButton1Click:Connect(showProdutos)
tabImoveis.MouseButton1Click:Connect(showImoveis)

shopButton.MouseButton1Click:Connect(function()
	stockFrame.Visible = false
	shopFrame.Visible = not shopFrame.Visible
	if shopFrame.Visible then
		showProdutos()
	end
end)

stockButton.MouseButton1Click:Connect(function()
	shopFrame.Visible = false
	stockFrame.Visible = not stockFrame.Visible
	if stockFrame.Visible then
		showStock()
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	shopFrame.Visible = false
end)

stockClose.MouseButton1Click:Connect(function()
	stockFrame.Visible = false
end)

-- =========================================================
-- TECLAS DE ATALHO: Q = Loja, R = Stock
-- =========================================================
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	-- não usar as teclas enquanto estamos a colocar um imóvel
	if placing then return end

	if input.KeyCode == Enum.KeyCode.Q then
		stockFrame.Visible = false
		shopFrame.Visible = not shopFrame.Visible
		if shopFrame.Visible then
			showProdutos()
		end
	elseif input.KeyCode == Enum.KeyCode.R then
		shopFrame.Visible = false
		stockFrame.Visible = not stockFrame.Visible
		if stockFrame.Visible then
			showStock()
		end
	end
end) 
