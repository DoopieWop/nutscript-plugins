--[[
    BodygroupNS - A bodygroup menu and bodygroup closet for NutScript 1.2
    
    Created by DoopieWop
--]]

AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Bodygroup Closet"
ENT.Category = "NutScript"
ENT.Spawnable = true
ENT.AdminOnly = true

if SERVER then
    function ENT:Initialize()
        local model = nut.config.get("bodygroupNSModel", "models/props_wasteland/controlroom_storagecloset001a.mdl")

        self:SetModel(model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local health = nut.config.get("bodygroupNSHealth", 100)
        if health > 0 then
            self:SetMaxHealth(health)
            self:SetHealth(health)
        else
            self:SetMaxHealth(-1)            
            self:SetHealth(-1)
        end
    end

    function ENT:OnTakeDamage(dmg)
        if self:Health() == -1 then return end

        self:SetHealth(self:Health() - dmg:GetDamage())

        local surfaceinfo = util.GetSurfaceData(util.GetSurfaceIndex(self:GetBoneSurfaceProp(0)))

        if self:Health() <= 0 then
            if surfaceinfo then
                self:EmitSound(surfaceinfo.breakSound != "" and surfaceinfo.breakSound or surfaceinfo.impactHardSound)
            else
                self:EmitSound("physics/metal/metal_box_break2.wav")
            end
            
            local amount = self:PrecacheGibs()
            if amount > 0 then
                self:GibBreakClient(dmg:GetDamageForce() * 0.05)
            else
                local effectdata = EffectData()
                effectdata:SetOrigin(self:GetPos())
                effectdata:SetNormal(self:GetUp())
                effectdata:SetMagnitude(4)
                effectdata:SetScale(1)
                util.Effect("Sparks", effectdata)
            end

            self:Remove()
        else
            if dmg:IsDamageType(DMG_SLASH) or dmg:IsDamageType(DMG_CLUB) then
                if surfaceinfo then
                    self:EmitSound(surfaceinfo.impactHardSound)
                else
                    self:EmitSound("physics/metal/metal_box_impact_bullet1.wav")
                end
            end
        end
    end

    function ENT:HasUser(user)
        self.users = self.users or {}

        return self.users[user] == true
    end

    function ENT:AddUser(user)
        self.users = self.users or {}

        self.users[user] = true

        hook.Run("BodygroupNSClosetAddUser", self, user)
    end

    function ENT:RemoveUser(user)
        self.users = self.users or {}

        self.users[user] = nil

        hook.Run("BodygroupNSClosetRemoveUser", self, user)
    end

    function ENT:Use(activator)
        if (activator:IsPlayer()) then
            net.Start("nutBodygroupMenu")
            net.Send(activator)

            self:AddUser(activator)
        end
    end
else
    ENT.DrawEntityInfo = true

    function ENT:onDrawEntityInfo(alpha)
        local pos = self:LocalToWorld(self:OBBCenter()):ToScreen()
        local color = nut.config.get("color")
        local name = nut.config.get("bodygroupNSName", "Bodygroup Closet")
        local desc = nut.config.get("bodygroupNSDesc", "A closet that allows you to change your bodygroups.")

        nut.util.drawText(name, pos.x, pos.y, ColorAlpha(color, alpha), 1, 1, "nutMediumFont", alpha * 0.65)

        if desc and desc != "" then
            surface.SetFont("nutSmallFont")
            pos.y = pos.y + select(2, surface.GetTextSize(desc))

            nut.util.drawText(desc, pos.x, pos.y, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
        end
    end

    function ENT:Draw()
        self:DrawModel()
    end
end