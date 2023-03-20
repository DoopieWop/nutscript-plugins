--[[
    BodygroupNS - A bodygroup menu and bodygroup closet for NutScript 1.2
    
    Created by DoopieWop
--]]

local PLUGIN = PLUGIN

PLUGIN.name = "BodygroupNS"
PLUGIN.author = "DoopieWop"
PLUGIN.desc = "Adds a bodygroup menu and bodygroup closet, akin to BodygroupR on GModStore"
PLUGIN.license = [[
    Copyright 2023 DoopieWop

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

nut.util.include("cl_net.lua")
nut.util.include("sv_net.lua")
nut.util.include("sv_hooks.lua")

nut.config.add("bodygroupNSName", "Bodygroup Closet", "The name of the bodygroup closet.", nil, {
    category = PLUGIN.name
})

nut.config.add("bodygroupNSDesc", "A closet that allows you to change your bodygroups.", "The description of the bodygroup closet.", nil, {
    category = PLUGIN.name
})

nut.config.add("bodygroupNSModel", "models/props_wasteland/controlroom_storagecloset001a.mdl", "The model of the bodygroup closet.", nil, {
    category = PLUGIN.name
})

nut.config.add("bodygroupNSOpenSound", "doors/door_metal_thin_open1.wav", "The sound that plays when the bodygroup closet is opened.", nil, {
    category = PLUGIN.name
})

nut.config.add("bodygroupNSCloseSound", "doors/door_metal_thin_close2.wav", "The sound that plays when the bodygroup closet is closed.", nil, {
    category = PLUGIN.name
})

nut.config.add("bodygroupNSHealth", 100, "The health of the bodygroup closet. Set to 0, if it's indestructable.", nil, {
    data = {min = 0, max = 1000},
    category = PLUGIN.name
    
})

nut.command.add("ViewBodygroups", {
    syntax = "[string name]",
    onCheckAccess = function(client)
        return PLUGIN:CanChangeBodygroup(client)
    end,
    onRun = function(client, args)
        local target = nut.command.findPlayer(client, args[1] or "")

        net.Start("nutBodygroupMenu")
            if IsValid(target) then
                net.WriteEntity(target)
            end
        net.Send(client)
    end
})

if CAMI then
    CAMI.RegisterPrivilege({
        Name = "BodygroupNS - View Menu",
        MinAccess = "admin"
    })
else
    nut.config.add("bodygroupNSAdminOnly", true, "Whether or not only admins can access the bodygroup menu.", nil, {
        category = PLUGIN.name
    })
end

function PLUGIN:CanChangeBodygroup(client)
    if CAMI then
        return CAMI.PlayerHasAccess(client, "BodygroupNS - View Menu", nil)
    else
        if nut.config.get("bodygroupNSAdminOnly", true) then
            return client:IsAdmin()
        end
    end

    return true
end

function PLUGIN:CanAccessMenu(client)
    for k, v in pairs(ents.FindByClass("nut_bodygroup_closet")) do
        if (v:GetPos():Distance(client:GetPos()) <= 128) then
            return true
        end
    end
    
    return self:CanChangeBodygroup(client)
end

-- :(
function PLUGIN:CanProperty(client, str, ent)
    if str == "persist" and ent:GetClass() == "nut_bodygroup_closet" then
        return false
    end
end