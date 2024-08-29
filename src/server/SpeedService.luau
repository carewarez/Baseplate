-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Modules
local Leaderboard = require(ServerStorage.Leaderboard)
local PlayerData = require(ServerStorage.PlayerData)

-- Events
local IncreaseWalkSpeedFunction = ReplicatedStorage.Instances.IncreaseWalkSpeedFunction

local SPEED_KEY_NAME = PlayerData.SPEED_KEY_NAME
local COIN_KEY_NAME = PlayerData.COIN_KEY_NAME
local WALK_SPEED_INCREMENT = 10
local SPEED_COIN_COST = 2

local function updateWalkSpeed(player,updateFunction)
	-- Update the walk speed table
	local newWalkSpeed = PlayerData.updateValue(player,SPEED_KEY_NAME,updateFunction)
	
	-- Update the player's walk speed
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = newWalkSpeed
		
		-- Update the speed leaderboard
		Leaderboard.setStat(player, SPEED_KEY_NAME, newWalkSpeed)
	end
end

local function onPurchaseSpeedIncrease(player)
	local coinAmount = PlayerData.getValue(player, COIN_KEY_NAME)
	if coinAmount < SPEED_COIN_COST then
		return false
	end
	
	-- Increase the players's walk speed
	updateWalkSpeed(player, function(oldWalkSpeed)
		oldWalkSpeed = oldWalkSpeed or 0
		return oldWalkSpeed + WALK_SPEED_INCREMENT
	end)
	-- Update the coin table
	local newCoinAmount = PlayerData.updateValue(player, COIN_KEY_NAME, function(oldCoinAmount)
		return oldCoinAmount - SPEED_COIN_COST
	end)
	-- Update the coin leaderboard
	Leaderboard.setStat(player, COIN_KEY_NAME, newCoinAmount)
	return true
end


local function onCharacterAdded(player)
	-- Reset player's walk speed when the character is added
	updateWalkSpeed(player, function(_)
		return 15
	end)
end

-- Initialize any players added before connecting to PlayerAdded event
for _, player in Players:GetPlayers() do
	onCharacterAdded(player)
end

-- Normal initialization of players from PlayerAdded event
local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function()
		onCharacterAdded(player)
	end)
end

local function onPlayerRemoved(player)
	updateWalkSpeed(player, function(_)
		return nil
	end)
end


IncreaseWalkSpeedFunction.OnServerInvoke = onPurchaseSpeedIncrease
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoved)
