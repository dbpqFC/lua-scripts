--[[
    @title
        Lets you know when you are aiming at an enemy. (OBS proof)
    @author
        dbpq
    @notes
        Draws a dot in the middle of your screen whenever it is on an enemy. Kind of like a more legit triggerbot.
        Took inspiration from Tsukino's Sniper Crosshair: https://fantasy.cat/forums/index.php?threads/recoil-crosshair-sniper-crosshair.3889/
        moolight
--]]
local legitTrigger = {
    name = "settings_legit_triggerbot",

    -- Colors
    r = "settings_legit_trigger_red",
    g = "settings_legit_trigger_green",
    b = "settings_legit_trigger_blue",
    a = "settings_legit_trigger_alpha"
}

function legitTrigger.PostInitialize()

    moonlight.vars.add( legitTrigger.name, 1 )

    moonlight.vars.add( legitTrigger.r, 0, true )
    moonlight.vars.add( legitTrigger.g, 255, true )
    moonlight.vars.add( legitTrigger.b, 0, true )
    moonlight.vars.add( legitTrigger.a, 255, true )

    moonlight.imgui.add( "Legit Triggerbot", legitTrigger.name, "checkbox" )
end

function legitTrigger.OnEndScene(device, width, height)

    -- Check if checkbox is ticked.
    if moonlight.vars.get( legitTrigger.name ) == 0 then return end

    -- Check if we are ingame.
    if moonlight.game.is_connected() == false or moonlight.game.is_ingame() == false then return end

    -- Get screen width and height.
    local width, height = moonlight.visuals.get_screen_size()

    local color = {
        r = moonlight.vars.get( legitTrigger.r ),
        g = moonlight.vars.get( legitTrigger.g ),
        b = moonlight.vars.get( legitTrigger.b ),
        a = moonlight.vars.get( legitTrigger.a )
    }

    local width = width / 2
    local height = height / 2
 
    moonlight.visuals.draw_box( width - 2, height - 2, width + 2, height + 2, color )
end

function legitTrigger.OnCreateMove( localplayer, cmd )
 
    -- Get localweapon and localplayer.
    local localweapon = moonlight.game.localweapon()
    local localplayer = moonlight.game.localplayer()

    -- Check if localplayer exists.
    if localplayer == nil or localweapon == nil then return end

    -- Get localplayer entity information.
    local player = moonlight.game.get_player( localplayer )

    -- Get localplayer's eye position.
    local x, y, z = moonlight.game.get_eye_position( localplayer )
    
    -- Calculate the angle in a 3D Vector using your viewangles.
    local end_x, end_y, end_z = moonlight.game.angle( cmd["x"] + (player["punch"]["x"] * 2), cmd["y"] + (player["punch"]["y"] * 2), cmd["z"] + (player["punch"]["z"] * 2) )
    
    -- Getting localplayer's weapon data. Need "range" for how far the weapon can shoot.
    local weapon_data = moonlight.game.get_weapon_data( localweapon )

    if weapon_data["range"] <= 0 then
        weapon_data["range"] = 8192.0
    end

    -- Creating the destination/How far the triggerbot will scan.
    end_x = x + (end_x * weapon_data["range"])
    end_y = y + (end_y * weapon_data["range"])
    end_z = z + (end_z * weapon_data["range"])

    local result = moonlight.game.trace_ray( x, y, z, end_x, end_y, end_z, 0x46004003, true)
    
    -- Get the target player entity information.
    local target_player = moonlight.game.get_player( result["player"] )

    -- Is the player alive and dormant (Server is ending information to you about the player)?
    if target_player.is_alive and target_player.is_dormant == false then
        moonlight.vars.set("settings_legit_trigger_green", 0)
        moonlight.vars.set("settings_legit_trigger_red", 255)
    else
        moonlight.vars.set("settings_legit_trigger_green", 255)
        moonlight.vars.set("settings_legit_trigger_red", 0)
    end
end

return legitTrigger
