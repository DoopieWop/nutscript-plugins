--[[
    BodygroupNS - A bodygroup menu and bodygroup closet for NutScript 1.2
    
    Created by DoopieWop
--]]

local PLUGIN = PLUGIN

util.AddNetworkString("nutBodygroupMenu")
util.AddNetworkString("nutBodygroupMenuClose")

-- unfortunately had to use another net message, otherwise nutbodygroupmenu would have become to ugly
net.Receive("nutBodygroupMenuClose", function(l, client)
    for k, v in pairs(ents.FindByClass("nut_bodygroup_closet")) do
        if v:HasUser(client) then
            v:RemoveUser(client)
        end
    end
end)

net.Receive("nutBodygroupMenu", function(l, client)
    local target = net.ReadEntity()
    local skn = net.ReadUInt(10) -- check what the max skin number is on a model (1024) -> this is 1023, but who is gonna hit that limit
    local groups = net.ReadTable()

    local closetuser = false

    if not IsValid(target) then
        return
    end

    if target != client then
        if not PLUGIN:CanChangeBodygroup(client) then
            client:notifyLocalized("noAccess")
            return
        end
    else
        if not PLUGIN:CanAccessMenu(client) then
            client:notifyLocalized("noAccess")
            return
        end

        closetuser = true
    end

    if target:SkinCount() and skn > target:SkinCount() then
        client:notifyLocalized("invalidSkin")
        return
    end

    if target:GetNumBodyGroups() and target:GetNumBodyGroups() > 0 then
        for k, v in pairs(groups) do
            if v > target:GetBodygroupCount(k) then
                client:notifyLocalized("invalidBodygroup")
                return
            end
        end
    end

    local char = target:getChar()

    if not char then
        return
    end

    target:SetSkin(skn)
    char:setData("skin", skn)

    for k, v in pairs(groups) do
        target:SetBodygroup(k, v)
    end
    char:setData("groups", groups)

    if target == client then
        target:notifyLocalized("bodygroupNSChanged", "your")
    else
        client:notifyLocalized("bodygroupNSChanged", target:Name() .. "'s")
        target:notifyLocalized("bodygroupNSChangedBy", client:Name())
    end

    client:SendLua("nut.plugin.list.bodygroupns.Menu:Close()")

    if closetuser then
        for k, v in pairs(ents.FindByClass("nut_bodygroup_closet")) do
            if v:HasUser(target) then
                v:RemoveUser(target)
            end
        end
    end
end)