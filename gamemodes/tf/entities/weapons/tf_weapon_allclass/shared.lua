if SERVER then
	AddCSLuaFile( "shared.lua" )
end
	SWEP.Slot				= 2
if CLIENT then
	SWEP.PrintName			= "All Class"


	function SWEP:ResetBackstabState()
		self.NextBackstabIdle = nil
		self.BackstabState = false
		self.NextAllowBackstabAnim = CurTime() + 0.8
	end
	

function SWEP:InitializeCModel()
	self:CallBaseFunction("InitializeCModel")
	
	if IsValid(self.CModel) then
		self.CModel:SetBodygroup(1, 1)
	end
	
	for _,v in pairs(self.Owner:GetTFItems()) do
		if IsValid(v) && v:GetClass() == "tf_wearable_item_demoshield" then
			self.ShieldEntity = v
			v:InitializeCModel(self)
		end
	end	
	
	for _,v in pairs(self.Owner:GetTFItems()) do
		if IsValid(v) && v:GetClass() == "tf_wearable_item_tideturnr" then
			self.ShieldEntity = v
			v:InitializeCModel(self)
		end
	end
end


function SWEP:ViewModelDrawn()
	self:CallBaseFunction("ViewModelDrawn")
	
	if IsValid(self.ShieldEntity) and IsValid(self.ShieldEntity.CModel) then
		self.ShieldEntity:StartVisualOverrides()
		self.ShieldEntity.CModel:DrawModel()
		self.ShieldEntity:EndVisualOverrides()
	end
end

end

SWEP.Base				= "tf_weapon_melee_base"

SWEP.ViewModel			= "models/weapons/c_models/c_soldier_arms.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_wrench.mdl" 
SWEP.Crosshair = "tf_crosshair3"

SWEP.Swing = Sound("Weapon_Bat.Miss")
SWEP.SwingCrit = Sound("Weapon_Bat.MissCrit")
SWEP.HitFlesh = Sound("Weapon_Wrench.HitFlesh")
SWEP.HitWorld = Sound("Weapon_Shovel.HitWorld")
SWEP.HoldTypeHL2 = "melee"
local SpeedTable = {
{40, 1.6},
{80, 1.4},
{120, 1.2},
{160, 1.1},
}

SWEP.HitBuildingSuccess = Sound("Weapon_Wrench.HitBuilding_Success")
SWEP.HitBuildingFailure = Sound("Weapon_Wrench.HitBuilding_Failure")

SWEP.MinDamage = 0.5
SWEP.MaxDamage = 1.75

SWEP.BaseDamage = 65
SWEP.DamageRandomize = 0.1
SWEP.MaxDamageRampUp = 0
SWEP.MaxDamageFalloff = 0

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay = 0.8
SWEP.ReloadTime = 0.8

SWEP.CriticalChance = 11
SWEP.NoCModelOnStockWeapon = false

SWEP.HoldType = "MELEE_ALLCLASS"
SWEP.BackstabAngle = 180
SWEP.ShouldOccurFists = true
SWEP.DamageType = DMG_CLUB


function SWEP:InspectAnimCheck()
	if (IsValid(self.Owner)) then
		self.Owner:SetPoseParameter("r_hand_grip",0.0)
		self.Owner:SetPoseParameter("r_arm",1.5)
	end

	self:CallBaseFunction("InspectAnimCheck")
end
function SWEP:ShouldBackstab(ent)
	if self.Owner:GetPlayerClass() == "spy" then
		self.BaseDamage = 40
		self.CriticalChance = 0
		if not ent then
			local tr = self:MeleeAttack(true)
			ent = tr.Entity
		end
		
		if not IsValid(ent) or not self.Owner:CanDamage(ent) or ent:Health()<=0 or not ent:CanReceiveCrits() or inspecting == true or inspecting_post == true then
			return false
		end
		
		if not self.BackstabCos then
			self.BackstabCos = math.cos(math.rad(self.BackstabAngle * 0.5))
		end
		
		local v1 = ent:GetPos() - self.Owner:GetPos()
		local v2 = ent:GetAngles():Forward()
		
		v1.z = 0
		v2.z = 0
		v1:Normalize()
		v2:Normalize()
		
		return v1:Dot(v2) > self.BackstabCos
	end
end

function SWEP:Think()
	if (IsValid(self.Owner)) then
		self.Owner:SetPoseParameter("r_arm",1.5)
		self.Owner:SetPoseParameter("r_hand_grip",0)
	end
	if self.Owner:GetPlayerClass() == "scout" then
		self.BaseDamage = 35
		self.Primary.Delay = 0.5
	elseif self.Owner:GetPlayerClass() == "spy" then
		self.BaseDamage = 40
		self.MeleeAttackDelay = 0
	else 
		if (!self.Owner:IsHL2() and self.Owner:GetPlayerClass() != "mercenary") then
			self.HoldType = "MELEE_ALLCLASS"
			self:SetWeaponHoldType("MELEE_ALLCLASS")
		else
			self.HoldType = "MELEE"
			self:SetWeaponHoldType("MELEE")
		end
		if self.Owner:GetPlayerClass() == "spy" then
			self.MeleeAttackDelay = 0
		else
			self.MeleeAttackDelay = 0.25
		end
	end
		
	if self.Owner:GetPlayerClass() == "engineer" then
		self.NoHitSound = true
		self.UpgradeSpeed = 25
		self.GlobalCustomHUD = {HudAccountPanel = true}
	end
	self.BaseClass.Think(self)
end


function SWEP:Critical(ent,dmginfo)
	if self.Owner:GetPlayerClass() == "spy" then
	if self:ShouldBackstab(ent) then
		return true
	end
	end
	
	return self:CallBaseFunction("Critical", ent, dmginfo)
end

function SWEP:PredictCriticalHit()
	if self:ShouldBackstab() then
		return true
	end
end


function SWEP:OnMeleeHit(tr)
	if self.Owner:GetPlayerClass() == "engineer" then
		if tr.Entity and tr.Entity:IsValid() then
			if tr.Entity:IsBuilding() then
				local ent = tr.Entity
				
				if ent.IsTFBuilding and ent:IsFriendly(self.Owner) then
					if ent.Sapped == true then
						self.Owner:EmitSoundEx("Weapon_Sapper.Removed")
						ent.Sapped = false
					end
					if SERVER then
	
						local m = ent:AddMetal(self.Owner, self.Owner:GetAmmoCount(TF_METAL))
						if m > 0 then
							self.Owner:EmitSoundEx(self.HitBuildingSuccess)
							self.Owner:RemoveAmmo(m, TF_METAL)
							umsg.Start("PlayerMetalBonus", self.Owner)
								umsg.Short(-m)
							umsg.End()
						elseif ent:GetState() == 1 then
							self.Owner:EmitSoundEx(self.HitBuildingSuccess)
						else
							self.Owner:EmitSoundEx(self.HitBuildingFailure)
						end
					end
				end
			end
		elseif tr.HitWorld then
			self:EmitSound(self.HitWorld)
		end
	end
	
	if self.Owner:GetPlayerClass() == "spy" then
		if self:Critical() then
			self.Owner:DoAnimationEvent(ACT_MP_ATTACK_STAND_MELEE_SECONDARY)
		end
	end
end


function SWEP:SecondaryAttack()
	if self.Owner:GetPlayerClass() == "engineer" then
		self:SetNextSecondaryFire(CurTime() + 0.5)
		for k,v in pairs(ents.FindInSphere(self.Owner:GetPos(), 75)) do
			if v:IsBuilding() and v:GetOwner() == self.Owner then
				if v:GetClass() == "obj_sentrygun" then
					if SERVER then
						local builder = self.Owner:GetWeapon("tf_weapon_builder")
						--print(builder.MovedBuildingLevel)
						if v:GetLevel()==2 then
							builder.MovedBuildingLevel = 2
						elseif v:GetLevel()==1 then
							builder.MovedBuildingLevel = 1
						elseif v:GetLevel() == 3 then 
							builder.MovedBuildingLevel = 3
						end
						v:Fire("Kill", "", 0.1)
						self.Owner:ConCommand("move 2 0")
					end
				elseif v:GetClass() == "obj_dispenser" then
					if SERVER then
						local builder = self.Owner:GetWeapon("tf_weapon_builder")
						if v:GetLevel()==2 then
							builder.MovedBuildingLevel = 2
						elseif v:GetLevel()==1 then
							builder.MovedBuildingLevel = 1
						elseif v:GetLevel() == 3 then 
							builder.MovedBuildingLevel = 3
						end
						v:Fire("Kill", "", 0.1)
						self.Owner:ConCommand("move 0 0")
					end
				elseif v:GetClass() == "obj_teleporter" and v:IsExit() != true then
					if SERVER then
						local builder = self.Owner:GetWeapon("tf_weapon_builder")
						if v:GetLevel()==2 then
							builder.MovedBuildingLevel = 2
						elseif v:GetLevel()==1 then
							builder.MovedBuildingLevel = 1
						elseif v:GetLevel() == 3 then 
							builder.MovedBuildingLevel = 3
						end
						v:Fire("Kill", "", 0.1)
						self.Owner:ConCommand("move 1 0")
					end
				elseif v:GetClass() == "obj_teleporter" and v:IsExit() != false then
					if SERVER then
						local builder = self.Owner:GetWeapon("tf_weapon_builder")
						if v:GetLevel()==2 then
							builder.MovedBuildingLevel = 2
						elseif v:GetLevel()==1 then
							builder.MovedBuildingLevel = 1
						elseif v:GetLevel() == 3 then 
							builder.MovedBuildingLevel = 3
						end
						v:Fire("Kill", "", 0.1)
						self.Owner:ConCommand("move 1 1")
					end
				end
			end
		end
	end
end 	


function SWEP:PrimaryAttack()
	if not self:CallBaseFunction("PrimaryAttack") then return false end
	
	if self:GetItemData().model_player == "models/weapons/c_models/c_frying_pan/c_frying_pan.mdl" then
		self.HitRobot = Sound("MVM_FryingPan.HitFlesh")
		self.HitFlesh = Sound("FryingPan.HitFlesh")
		self.HitWorld = Sound("FryingPan.HitWorld")
	end
	if self:GetItemData().model_player == "models/workshop/weapons/c_models/c_ham/c_ham.mdl" then
		self.HitFlesh = Sound("Weapon_HolyMackerel.HitFlesh")
		self.HitWorld = Sound("Weapon_HolyMackerel.HitWorld")
	end
	if self:GetItemData().model_player == "models/weapons/c_models/c_saxxy/c_saxxy.mdl" then
		self.HitWorld = Sound("Saxxy.HitWorld")
	end
	self.NameOverride = nil
	
	if game.SinglePlayer() then
		self:CallOnClient("ResetBackstabState", "")
	elseif CLIENT then
		self:ResetBackstabState()
	end
	if SERVER then
		self.Owner:Speak("TLK_FIREWEAPON")
	end
	if self.Owner:GetPlayerClass() == "spy" then
		if self:Critical() then
			self.Owner:DoAnimationEvent(ACT_MP_ATTACK_STAND_MELEE_SECONDARY)
		end
	end
end
