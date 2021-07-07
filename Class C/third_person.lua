--[[
    @title
        Third Person
    @author
        typedef
    @notes
        Using "m_nForceTauntCam" to get into 3rd person with TF2.
        In CS:GO, using the input camera functions.
--]]

local third_person =
{
    -- FantasyVars
    name = "settings_third_person",
    key = "settings_third_person_key",

    -- Netvars
    m_nForceTauntCam, -- DT_TFPlayer->m_nForceTauntCam

    -- Temporary Variables
    set = false, -- Used in the case we're stuck in 3rd person after turning off the feature.
}

function third_person.PostInitialize( )
    -- Find Netvars
    if game == "TF2" then
        third_person.m_nForceTauntCam = moonlight.memory.netvar( "DT_TFPlayer->m_nForceTauntCam" )
    end

    -- Need OnOverrideView
    if game == "CS:GO" then
        if moonlight.vars.get( "hook_override_view" ) == 0 then
            moonlight.error("This script cannot run because hook_override_view is disabled.\n")
            return 
        end
    end

    -- Add FantasyVars
    moonlight.vars.add( third_person.name, 0 )
    moonlight.vars.add( third_person.key, 0 )

    -- Add Menu Options
    moonlight.imgui.add( "Third Person", third_person.name, "checkbox" )
    moonlight.imgui.add( "Third Person Key", third_person.key, "key" )
end

function third_person.OnOverrideView( fov )
    -- This only matters in CS:GO. TF2 uses something else.
    if game ~= "CS:GO" then return end

    local player_information = moonlight.game.get_player( moonlight.game.localplayer() )
    if player_information["is_alive"] == false then return end

    -- Is enabled?
    if moonlight.vars.get( third_person.name ) == 0 then 

        -- Is third person off but we had set it on at one point? 
        if moonlight.game.is_third_person() == true then

            -- Reset
            moonlight.game.set_third_person( false, 0, 0, 0 )
        end

        return fov
    end

    -- Get the third person key.
    local third_person_key = moonlight.vars.get( third_person.key )

    -- Key wasn't set OR the key was set and the player is pressing the key down.
    if third_person_key == 0 or moonlight.windows.key( third_person_key ) == true then
        local x, y, z = moonlight.game.get_view_angles()
        moonlight.game.set_third_person( true, x, y, 150 )

    else
        -- Assuming the player had let go of their Third Person key. Return to 1st person again.
        moonlight.game.set_third_person( false, 0, 0, 0 )
    end

    
    --
    return fov
end

function third_person.OnCreateMove( localplayer, cmd )

    -- This only matters in TF2. CS:GO uses something else.
    if game ~= "TF2" then return end

    -- Is enabled?
    if moonlight.vars.get( third_person.name ) == 0 then 

        -- Is third person off but we had set it on at one point? 
        if third_person.set == true then
            -- Return our camera back to first person.
            moonlight.memory.set_boolean( localplayer + third_person.m_nForceTauntCam, false )

            -- Let the script know we're reset.
            third_person.set = false
        end

        -- Don't continue since it's off.
        return 
    end

    -- Get the third person key.
    local third_person_key = moonlight.vars.get( third_person.key )

    -- Key wasn't set OR the key was set and the player is pressing the key down.
    if third_person_key == 0 or moonlight.windows.key( third_person_key ) == true then
        -- Set the value to true (Make the game think we're taunting to go into 3rd person).
        moonlight.memory.set_boolean( localplayer + third_person.m_nForceTauntCam, true )

        -- Let the script know we changed this.
        third_person.set = true
    else
        -- Assuming the player had let go of their Third Person key. Return to 1st person again.
        moonlight.memory.set_boolean( localplayer + third_person.m_nForceTauntCam, false )

        -- Let the script know we changed this back to 1st person.
        third_person.set = false
    end
end

return third_person