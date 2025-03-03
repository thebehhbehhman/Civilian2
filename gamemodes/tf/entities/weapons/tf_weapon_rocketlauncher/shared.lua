if SERVER then
	AddCSLuaFile( "shared.lua" )
	
end

SWEP.Slot				= 0

if CLIENT then

SWEP.PrintName			= "Rocket Launcher"


function SWEP:ClientStartCharge()
	self.ClientCharging = true
	self.ClientChargeStart = CurTime()
end

function SWEP:ClientEndCharge()
	self.ClientCharging = false
end

end

function SWEP:OnEquipAttribute(a, owner)
	if a.attribute_class == "set_weapon_mode" then
		if a.value == 1 then
			if CLIENT then
				self.CustomHUD = {HudBowCharge = true}
			end
		end
	end
end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/c_models/c_soldier_arms.mdl"
SWEP.WorldModel			= "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Team Fortress 2"

SWEP.MuzzleEffect = "rocketbackblast"
PrecacheParticleSystem("rocketbackblast")

SWEP.ShootSound = Sound("TF_Weapon_RPG.Single")
SWEP.ShootCritSound = Sound("Weapon_RPG.SingleCrit")
SWEP.ChargeSound = Sound("Weapon_StickyBombLauncher.ChargeUp")
SWEP.ReloadSound = Sound("")

SWEP.Primary.ClipSize		= 4
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_PRIMARY

SWEP.Primary.Delay = 0.8
SWEP.ReloadTime = 0.8
SWEP.IsRapidFire = false
SWEP.ReloadSingle = true

SWEP.HoldType = "PRIMARY"
SWEP.HoldTypeHL2 = "rpg"

SWEP.ProjectileShootOffset = Vector(23.5, 12.0, -3.0)

SWEP.PunchView = Angle( 0, 0, 0 )

SWEP.Properties = {}

SWEP.ChargeTime = 2
SWEP.MinForce = 150
SWEP.MaxForce = 2800

SWEP.MinAddPitch = -1
SWEP.MaxAddPitch = -6

SWEP.MinGravity = 1
SWEP.MaxGravity = 1

SWEP.VM_DRAW = ACT_PRIMARY_VM_DRAW
SWEP.VM_IDLE = ACT_PRIMARY_VM_IDLE
SWEP.VM_PRIMARYATTACK = ACT_PRIMARY_VM_PRIMARYATTACK
SWEP.VM_RELOAD = ACT_PRIMARY_VM_RELOAD
SWEP.VM_RELOAD_START = ACT_PRIMARY_RELOAD_START
SWEP.VM_RELOAD_FINISH = ACT_PRIMARY_RELOAD_FINISH

function SWEP:DoMuzzleFlash()
	local betaeffect = self.BetaMuzzle
	local ent
	
	if self.Owner==LocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer() then
		ent = self.CModel
	else
		ent = self:GetWorldModelEntity()
	end
	
	self:ResetParticles()
	
	if betaeffect then
		local effectdata = EffectData()
			effectdata:SetEntity(self)
		util.Effect(betaeffect, effectdata)
	else
		--ent:MuzzleFlash()
		ParticleEffectAttach(self.MuzzleEffect, PATTACH_POINT_FOLLOW, ent, ent:LookupAttachment("backblast"))
	end
end


function SWEP:CreateSounds(owner)
	if not IsValid(owner) then return end
	
	self.RocketJumpLoop = CreateSound(owner, "RocketJumpLoop")
	
end
function SWEP:Deploy()
	if CLIENT then
		HudBowCharge:SetProgress(0)
	end
	self:CreateSounds(self.Owner)
	return self:CallBaseFunction("Deploy")
end

function SWEP:PrimaryAttack()
	if self.WeaponMode ~= 1 then
		return self:CallBaseFunction("PrimaryAttack")
	end
	
	if not self.IsDeployed then return false end
	if self.Reloading then return false end
	
	self.NextDeployed = nil
	
	-- Already charging
	if self.Charging or self.LockAttackKey then return end
	
	local Delay = self.Delay or -1
	local QuickDelay = self.QuickDelay or -1
	
	if (not(self.Primary.QuickDelay>=0 and self.Owner:KeyPressed(IN_ATTACK)) and Delay>=0 and CurTime()<Delay)
	or (self.Primary.QuickDelay>=0 and self.Owner:KeyPressed(IN_ATTACK) and QuickDelay>=0 and CurTime()<QuickDelay) then
		return
	end
	
	self.Delay =  CurTime() + self.Primary.Delay
	self.QuickDelay =  CurTime() + self.Primary.QuickDelay
	
	if not self:CanPrimaryAttack() then
		return
	end
	
	if self.NextReload or self.NextReloadStart then
		self.NextReload = nil
		self.NextReloadStart = nil
	end
	
	-- Start charging
	self.Charging = true
	self:SendWeaponAnim(self.VM_IDLE)
	
	if SERVER then
		self:CallOnClient("ClientStartCharge", "")
	end
	
	self.ChargeStartTime = CurTime()
end

function SWEP:Think()
	self:CallBaseFunction("Think")
	
	if self:GetItemData().model_player == "models/weapons/c_models/c_rocketjumper/c_rocketjumper.mdl" then
		self.ShootSound = Sound("weapons/rocket_jumper_shoot.wav")
		self.ShootCritSound = Sound("weapons/rocket_jumper_shoot.wav")
	end
	if self:GetItemData().model_player == "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl" then
		if (IsValid(self.Owner) and string.find(self.Owner:GetModel(),"_boss.mdl")) then
			self.ShootSound = Sound("MVM.GiantSoldierRocketShoot")
			self.ShootCritSound = Sound("MVM.GiantSoldierRocketShootCrit")
		end
	end
	if self.WeaponMode ~= 1 then return end
	if CLIENT then
		if self.ClientCharging and self.ClientChargeStart then
			HudBowCharge:SetProgress((CurTime()-self.ClientChargeStart) / self.ChargeTime)
		else
			HudBowCharge:SetProgress(0)
		end
	end

	
	if self.LockAttackKey and not self.Owner:KeyDown(IN_ATTACK) then
		self.LockAttackKey = nil
	end
	
	if self.Charging then
		if (not self.Owner:KeyDown(IN_ATTACK) or CurTime() - self.ChargeStartTime > self.ChargeTime) then
			self.Charging = false
			
			self:SendWeaponAnim(self.VM_PRIMARYATTACK)
			self.Owner:DoAttackEvent()
			
			self.NextIdle = CurTime() + self:SequenceDuration() - 0.2
			
			self:ShootProjectile()
			self:TakePrimaryAmmo(1)
			
			self.Delay =  CurTime() + self.Primary.Delay
			self.QuickDelay =  CurTime() + self.Primary.QuickDelay
			
			if SERVER then
				self:CallOnClient("ClientEndCharge", "")
			end
			
			if self:Clip1() <= 0 then
				self:Reload()
			end
			
			if SERVER and not self.Primary.NoFiringScene then
				self.Owner:Speak("TLK_FIREWEAPON")
			end
			
			self:RollCritical() -- Roll and check for criticals first
			
			if (game.SinglePlayer() or CLIENT) and self.ChargeUpSound then
				self.ChargeUpSound:Stop()
				self.ChargeUpSound = nil
			end
			
			self.LockAttackKey = true
		else
			if (game.SinglePlayer() or CLIENT) and not self.ChargeUpSound then
				self.ChargeUpSound = CreateSound(self, self.ChargeSound)
				self.ChargeUpSound:PlayEx(1, 400 / self.ChargeTime)
			end
		end
	end
	self:Inspect()
end

function SWEP:ShootProjectile()
	if SERVER then

		local rocket = ents.Create("tf_projectile_rocket")
		rocket:SetPos(self:ProjectileShootPos())
		local ang = self.Owner:EyeAngles()
		if self.WeaponMode == 1 then
			local charge = (CurTime() - self.ChargeStartTime) / self.ChargeTime
			rocket.Gravity = Lerp(1 - charge, self.MinGravity, self.MaxGravity)
			rocket.BaseSpeed = Lerp(charge, self.MinForce, self.MaxForce)
			ang.p = ang.p + Lerp(1 - charge, self.MinAddPitch, self.MaxAddPitch)
		end
		
		rocket:SetAngles(ang)
		
		if self:Critical() then
			rocket.critical = true
		end
		
		for k,v in pairs(self.Properties) do
			rocket[k] = v
		end
		
		if self:GetItemData().model_player == "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl" then
			if (IsValid(self.Owner) and string.find(self.Owner:GetModel(),"_boss.mdl")) then

				--rocket.ExplosionSound = "MVM.GiantSoldierRocketExplode"
				
			end
		end
		if (self:GetVisuals() != nil and self:GetVisuals().sound_special1) then
			rocket.ExplosionSound = self:GetVisuals().sound_special1
		end
		if (self.ProjectileDamageMultiplier) then
			rocket.OldBaseDamage = rocket.BaseDamage
			rocket.BaseDamage = rocket.OldBaseDamage * self.ProjectileDamageMultiplier
		end
		rocket:SetOwner(self.Owner)
		self:InitProjectileAttributes(rocket)
		
		rocket.NameOverride = self:GetItemData().item_iconname or self.NameOverride
		rocket:Spawn()
		rocket:Activate()
	end
	
	if CLIENT then
		self:ShootEffects()
	end
end

function SWEP:OnRemove()
	if (game.SinglePlayer() or CLIENT) and self.ChargeUpSound then
		self.ChargeUpSound:Stop()
		self.ChargeUpSound = nil
	end
end
