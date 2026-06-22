-- GameData (ModuleScript) em ReplicatedStorage
-- Catálogo de produtos e imóveis (estruturas de dados)

local GameData = {}

GameData.StartingMoney = 500

-- PRODUTOS
-- ModelName = nome EXATO do model na pasta ProdutosModelos
-- FixtureType = em que tipo de imóvel este produto pode ser colocado
GameData.Products = {
	["pao"]    = { Name = "Pão",    ModelName = "pão",    Price = 3, SellPrice = 6,  FixtureType = "prateleira" },
	["leite"]  = { Name = "Leite",  ModelName = "leite",  Price = 6, SellPrice = 10, FixtureType = "prateleira" },
	["maca"]   = { Name = "Maçã",   ModelName = "maçã",   Price = 5, SellPrice = 8,  FixtureType = "lugardefruta" },
	["banana"] = { Name = "Banana", ModelName = "Banana", Price = 4, SellPrice = 7,  FixtureType = "lugardefruta" },
}

-- IMÓVEIS
-- ModelName = nome EXATO do model na pasta ImoveisModelos
-- FixtureType = tem de bater certo com o FixtureType dos produtos
GameData.Fixtures = {
	["prateleira"]   = { Name = "Prateleira",     ModelName = "prateleira",     Price = 100, FixtureType = "prateleira" },
	["lugardefruta"] = { Name = "Lugar de Fruta", ModelName = "lugar de fruta", Price = 80,  FixtureType = "lugardefruta" },
	["caixa"]        = { Name = "Caixa",          ModelName = "caixa",          Price = 120, FixtureType = "caixa" },
}

return GameData 
