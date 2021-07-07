--[[
    @title
        Turns on esp after you die
    @author
        dbpq
    @notes
        Turns on ESP after death
        moolight
--]]
local espOnDeath = {
    name = "esp_on_death"
}

function is_script_loaded( esp )

    -- Loop through all scripts.
    for _, script in pairs( moonlight.scripts.get_all() ) do
        -- Match name.
        if script["name"] == esp then return true end
    end

    -- Nothing found. Return false.
    return false
   
end

function espOnDeath.PostInitialize()

    if is_script_loaded( "esp.lua" ) == false then
        moonlight.error( "esp.lua is required for this script to run!\n" )
        return
    end

    -- Create the variable.
    moonlight.vars.add( espOnDeath.name, 0 )

    -- Add checkbox.
    moonlight.imgui.add( "Esp while dead", espOnDeath.name, "checkbox" )
end

function espOnDeath.OnEndScene( device, width, height )

    -- Check if checkbox is ticked.
    if moonlight.vars.get( espOnDeath.name ) == 0 then return end

    local localplayer = moonlight.game.localplayer()
    local playerInfo = moonlight.game.get_player( localplayer )

    -- Check if localplayer exists.
    if playerInfo == nil then return end

    -- Check if localplayer is dead.
    if playerInfo["is_alive"] == false then

        -- Turn CS:GO ESP on.
        moonlight.vars.set( "settings_esp", 1 )
        moonlight.vars.set( "settings_esp_name", 1 )
        moonlight.vars.set( "settings_esp_box", 1 )
        moonlight.log("Turned ESP on because I am dead.")
        
        -- If game is TF2, turn building ESP and conditions ESP on.
        if game == "TF2" then
            moonlight.vars.set( "settings_esp_building", 1 )
            moonlight.vars.set( "settings_conditions", 1 )
            moonlight.log("Turned TF2 esp on because I am dead.")
        end

    elseif playerInfo["is_alive"] == true then

        -- Turns ESP off whenever you are alive.
        moonlight.vars.set( "settings_esp", 0 )
        moonlight.vars.set( "settings_esp_name", 0 )
        moonlight.vars.set( "settings_esp_box", 0 )
        moonlight.log("Turned ESP off because I am alive.")
        
        -- If game is TF2, turn building ESP and conditions ESP off.
        if game == "TF2" then
            moonlight.vars.set( "settings_esp_building", 0 )
            moonlight.vars.set( "settings_conditions", 0 )
            moonlight.log("Turned TF2 ESP off because I am alive.")
        end
    end
end

return espOnDeath
