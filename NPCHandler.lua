-- NPCHandler (Script) em ServerScriptService
-- Controla os NPCs clientes: aparecem, vão às prateleiras, pagam na caixa e saem.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local PhysicsService = game:GetService("PhysicsService")

local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
local NPCsModelos = ReplicatedStorage:WaitForChild("NPCsModelos")
local LadraoModelo = ReplicatedStorage:WaitForChild("LadraoModelo")

local NOME_GRUPO = "NPCs"
pcall(function()
	PhysicsService:RegisterCollisionGroup(NOME_GRUPO)
	PhysicsService:CollisionGroupSetCollidable(NOME_GRUPO, NOME_GRUPO, false)
end)

local pontos = workspace:WaitForChild("PontoNPC")
local pontoSpawn = pontos:WaitForChild("SpawnNPC")
local pontoEntrada = pontos:WaitForChild("EntradaLoja")
local pontoSaida = pontos:WaitForChild("saidaaloja")

local INTERVALO_SPAWN = 8
local MAX_NPCS = 5
local TEMPO_MINIMO = 15
local TEMPO_MAXIMO = 17
local ANTES_DE_PAGAR = 5
local CHANCE_LADRAO = 6  
local PERCENT_ROUBO = 0.5

local npcsAtivos = 0
local rng = Random.new()

local function encontrarImoveis(fixtureType)
	local lista = {}
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj:GetAttribute("FixtureType") == fixtureType then
			table.insert(lista, obj)
		end
	end
	return lista
end

local function escolherAleatorio(lista)
	if #lista == 0 then return nil end
	return lista[math.random(1, #lista)]
end

local function moverPara(npc, destino)
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local path = PathfindingService:CreatePath()
	local sucesso = pcall(function()
		path:ComputeAsync(npc.PrimaryPart.Position, destino)
	end)
	if sucesso and path.Status == Enum.PathStatus.Success then
		for _, waypoint in ipairs(path:GetWaypoints()) do
			humanoid:MoveTo(waypoint.Position)
			humanoid.MoveToFinished:Wait()
		end
	else
		humanoid:MoveTo(destino)
		humanoid.MoveToFinished:Wait()
	end
end

local function encontrarProdutos(imovel)
	local lista = {}
	for _, obj in ipairs(imovel:GetChildren()) do
		if obj:IsA("Model") and obj:GetAttribute("ProductId") then
			table.insert(lista, obj)
		end
	end
	return lista
end

local function posicaoEmFrente(imovel, npc)
	local _, tamanho = imovel:GetBoundingBox()
	local posImovel = imovel:GetPivot().Position
	local posNPC = npc.PrimaryPart.Position
	local direcao = (posNPC - posImovel)
	direcao = Vector3.new(direcao.X, 0, direcao.Z)
	if direcao.Magnitude < 0.1 then
		direcao = Vector3.new(0, 0, 1)
	end
	direcao = direcao.Unit
	local raio = math.max(tamanho.X, tamanho.Z) / 2 + 0.5
	return Vector3.new(posImovel.X, posNPC.Y, posImovel.Z) + direcao * raio
end

local function comportamentoCliente(npc)
	moverPara(npc, pontoEntrada.Position)
	local tempoNaLoja = math.random(TEMPO_MINIMO, TEMPO_MAXIMO)
	local tempoAteComprar = tempoNaLoja - ANTES_DE_PAGAR
	local totalAPagar = 0
	local prateleiras = encontrarImoveis("prateleira")
	local frutas = encontrarImoveis("lugardefruta")
	local todosImoveis = {}
	for _, p in ipairs(prateleiras) do table.insert(todosImoveis, p) end
	for _, f in ipairs(frutas) do table.insert(todosImoveis, f) end
	local tempoInicio = tick()
	while (tick() - tempoInicio) < tempoAteComprar do
		local alvo = escolherAleatorio(todosImoveis)
		if alvo and alvo.PrimaryPart then
			moverPara(npc, posicaoEmFrente(alvo, npc))
			local produtos = encontrarProdutos(alvo)
			local produto = escolherAleatorio(produtos)
			if produto then
				local productId = produto:GetAttribute("ProductId")
				local dados = GameData.Products[productId]
				if dados then
					totalAPagar = totalAPagar + (dados.Price * 2)
				end
				local unidades = produto:GetAttribute("Unidades") or 1
				unidades = unidades - 1
				produto:SetAttribute("Unidades", unidades)
				local primaryPart = produto.PrimaryPart or produto:FindFirstChildWhichIsA("BasePart")
				if primaryPart then
					local billboard = primaryPart:FindFirstChild("ContadorStock")
					if billboard then
						local label = billboard:FindFirstChildWhichIsA("TextLabel")
						if label then
							label.Text = "x" .. unidades
						end
					end
				end
				if unidades <= 0 then
					produto:Destroy()
				end
			end
		end
		task.wait(1)
	end
	if totalAPagar > 0 then
		local caixas = encontrarImoveis("caixa")
		local caixa = escolherAleatorio(caixas)
		if caixa and caixa.PrimaryPart then
			moverPara(npc, posicaoEmFrente(caixa, npc))
			task.wait(3)
			local players = game:GetService("Players"):GetPlayers()
			local dono = players[1]
			if dono and dono:FindFirstChild("leaderstats") then
				local money = dono.leaderstats:FindFirstChild("Money")
				if money then
					money.Value += totalAPagar
				end
			end
		end
	end
	moverPara(npc, pontoSaida.Position)
	npc:Destroy()
end

local function comportamentoLadrao(npc)
	moverPara(npc, pontoEntrada.Position)
	local prateleiras = encontrarImoveis("prateleira")
	local frutas = encontrarImoveis("lugardefruta")
	local todosImoveis = {}
	for _, p in ipairs(prateleiras) do table.insert(todosImoveis, p) end
	for _, f in ipairs(frutas) do table.insert(todosImoveis, f) end
	local alvo = escolherAleatorio(todosImoveis)
	if alvo and alvo.PrimaryPart then
		moverPara(npc, posicaoEmFrente(alvo, npc))
		local produtos = encontrarProdutos(alvo)
		local quantosRoubar = math.floor(#produtos * PERCENT_ROUBO)
		for i = 1, quantosRoubar do
			if produtos[i] then
				produtos[i]:Destroy()
			end
		end
	end
	moverPara(npc, pontoSaida.Position)
	npc:Destroy()
end

local function criarNPC()
	local temPrateleira = #encontrarImoveis("prateleira") > 0
	local temFruta = #encontrarImoveis("lugardefruta") > 0
	if not (temPrateleira or temFruta) then return end

	local ehLadrao = rng:NextInteger(1, 100) <= CHANCE_LADRAO

	local modelo
	if ehLadrao then
		modelo = LadraoModelo:FindFirstChildWhichIsA("Model")
		if not modelo then return end
	else
		local modelos = NPCsModelos:GetChildren()
		if #modelos == 0 then return end

		-- bebe aparece só 10% das vezes
		local chanceBebe = rng:NextInteger(1, 100)
		if chanceBebe <= 10 then
			modelo = NPCsModelos:FindFirstChild("bebe")
		else
			local normais = {}
			for _, m in ipairs(modelos) do
				if m.Name ~= "bebe" then
					table.insert(normais, m)
				end
			end
			modelo = normais[math.random(1, #normais)]
		end
	end

	local npc = modelo:Clone()
	npc:SetAttribute("ClienteNPC", true)
	npc:PivotTo(CFrame.new(pontoSpawn.Position + Vector3.new(0, 3, 0)))
	npc.Parent = workspace

	for _, part in ipairs(npc:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = NOME_GRUPO
		end
	end

	task.spawn(function()
		if ehLadrao then
			comportamentoLadrao(npc)
		else
			comportamentoCliente(npc)
		end
	end)
end

local function contarNPCs()
	local total = 0
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:GetAttribute("ClienteNPC") then
			total = total + 1
		end
	end
	return total
end

while true do
	task.wait(INTERVALO_SPAWN)
	if contarNPCs() < MAX_NPCS then
		criarNPC()
	end
end 
