if SERVER then AddCSLuaFile() end

ENT.Base = "tf_red_bot"
ENT.PZClass = "engineer"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.IsBoss = false
ENT.PrintName		= "Red Engineer"
ENT.Category		= "TFBots"

list.Set( "NPC", "tf_red_bot_engineer", {
	Name = ENT.PrintName,
	Class = "tf_red_bot_engineer",
	Category = ENT.Category,
	AdminOnly = true
} ) 