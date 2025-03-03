if SERVER then AddCSLuaFile() end

ENT.Base = "mvm_bot"
ENT.PZClass = "scout"
ENT.Spawnable = false
ENT.AdminOnly = true 
ENT.IsBoss = true
ENT.Difficulty = 3
ENT.PrintName		= "Giant Bonk! Scout"
ENT.PreferredName	= "Scout"
ENT.Category		= "TFBots: MVM"
ENT.PreferredIcon = "hud/leaderboard_class_scout_bonk_giant"
ENT.Items = {"Bonk! Atomic Punch","Atomizer","Bonk Helm"}

function ENT:CustomOnInitialize(bot)
	timer.Create("SetModel"..bot:EntIndex(),0.1,10,function() 
		bot:SetModel("models/bots/scout_boss/bot_scout_boss.mdl")
		bot:SetNWBool("IsBoss",true)
		bot:SetModelScale(1.75)
		bot:SetHealth(1600)
		bot:SetMaxHealth(1600)
	end)
end

list.Set( "NPC", "mvm_bot_giant_bonk_scout", {
	Name = ENT.PrintName,
	Class = "mvm_bot_giant_bonk_scout",
	Category = ENT.Category,
	AdminOnly = true
} )