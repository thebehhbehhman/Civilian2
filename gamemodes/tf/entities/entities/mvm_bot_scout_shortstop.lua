if SERVER then AddCSLuaFile() end

ENT.Base = "mvm_bot"
ENT.PZClass = "scout_shortstop"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.PrintName		= "Shortstop Scout"
ENT.Category		= "TFBots: MVM"
ENT.PreferredIcon = "hud/leaderboard_class_scout_shortstop"

list.Set( "NPC", "mvm_bot_scout_shortstop", {
	Name = ENT.PrintName,
	Class = "mvm_bot_scout_shortstop",
	Category = ENT.Category,
	AdminOnly = true
} )