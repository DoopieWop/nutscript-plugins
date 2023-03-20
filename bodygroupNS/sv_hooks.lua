--[[
    BodygroupNS - A bodygroup menu and bodygroup closet for NutScript 1.2
    
    Created by DoopieWop
--]]

function PLUGIN:BodygroupNSClosetAddUser(closet, user)
    local opensound = nut.config.get("bodygroupNSOpenSound")

    if opensound then
        closet:EmitSound(opensound)
    end
end

function PLUGIN:BodygroupNSClosetRemoveUser(closet, user)
    local closesound = nut.config.get("bodygroupNSCloseSound")

    if closesound then
        closet:EmitSound(closesound)
    end
end

function PLUGIN:SaveData()
    local data = {}

    for k, v in pairs(ents.FindByClass("nut_bodygroup_closet")) do
        data[#data + 1] = {v:GetPos(), v:GetAngles()}
    end

    self:setData(data)
end

function PLUGIN:LoadData()
    for k, v in pairs(self:getData()) do
        local closet = ents.Create("nut_bodygroup_closet")
        closet:SetPos(v[1])
        closet:SetAngles(v[2])
        closet:Spawn()

        local phys = closet:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end
    end
end