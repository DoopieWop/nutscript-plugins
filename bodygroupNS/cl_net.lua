--[[
    BodygroupNS - A bodygroup menu and bodygroup closet for NutScript 1.2
    
    Created by DoopieWop
--]]

local PLUGIN = PLUGIN

net.Receive("nutBodygroupMenu", function()
    if IsValid(PLUGIN.Menu) then
        PLUGIN.Menu:Remove()
    end

    local ent = net.ReadEntity()

    PLUGIN.Menu = vgui.Create("nutBodygroupMenu")
    PLUGIN.Menu:SetTarget(IsValid(ent) and ent or LocalPlayer())
end)