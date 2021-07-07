--[[
    @title
        ICU (I /c/ee you)
        
    @author
        typedef

    @notes
        Works with both TF2 and CS:GO.
        https://fantasy.cat/forums/index.php?threads/icu.4498/ 
--]]

local icu = 
{
    -- FantasyVars
    name = "settings_icu",
    line = "settings_icu_line",
    x = "settings_icu_x",
    y = "settings_icu_y",
    tolerance = "settings_icu_tolerance",

    r = "settings_icu_r",
    g = "settings_icu_g",
    b = "settings_icu_b",
    a = "settings_icu_a",

    tr = "settings_icu_tr",
    tg = "settings_icu_tg",
    tb = "settings_icu_tb",
    ta = "settings_icu_ta",

    -- (D)ata(b)ase of people who see us.
    db = { },

    -- Netvars
    m_angEyeAngles = 0,
    m_szLastPlaceName = 0,

    -- Functions
    get_fov = function( x, y, z, x2, y2, z2 ) -- https://fantasy.cat/forums/index.php?threads/soundesp-determining-whether-enemy-is-within-fov.3981/#post-28057
        -- Angle both.
        x, y, z = moonlight.game.angle( x, y, z )
        x2, y2, z2 = moonlight.game.angle( x2, y2, z2 )

        --[[
            Multiply both angles by each other, divide our first vector length, then arccosine our result.
            Convert to degrees because math.acos calculates in radians.
        --]]
        return math.deg( math.acos( (x * x2 + y * y2 + z * z2) / moonlight.math.vector_length( x, y, z ) ) )
    end,
 
    get_class_name = function( id ) -- Convert class ID to name.
        if id == TF2_SCOUT then
            return "Scout"
        elseif id == TF2_SOLDIER then
            return "Soldier"
        elseif id == TF2_PYRO then
            return "Pyro"
        elseif id == TF2_DEMOMAN then
            return "Demoman"
        elseif id == TF2_HEAVY then
            return "Heavy"
        elseif id == TF2_ENGINEER then
            return "Engineer"
        elseif id == TF2_MEDIC then
            return "Medic"
        elseif id == TF2_SNIPER then
            return "Sniper"
        elseif id == TF2_SPY then
            return "Spy"
        end
    end
}

function icu.PostInitialize( )

    -- FantasyVars
    moonlight.vars.add( icu.name, 1 )
    moonlight.vars.add( icu.line, 1 )
    moonlight.vars.add( icu.x, 350 )
    moonlight.vars.add( icu.y, 350 )
    moonlight.vars.add( icu.tolerance, 50 )

    moonlight.vars.add( icu.r, 255, true )
    moonlight.vars.add( icu.g, 255, true )
    moonlight.vars.add( icu.b, 255, true )
    moonlight.vars.add( icu.a, 255, true )

    moonlight.vars.add( icu.tr, 255, true )
    moonlight.vars.add( icu.tg, 123, true )
    moonlight.vars.add( icu.tb, 243, true )
    moonlight.vars.add( icu.ta, 20, true )

    -- Menu Options
    moonlight.imgui.add( "ICU ESP", icu.name, "checkbox" )
    moonlight.imgui.add( "ICU ESP X", icu.x, "slider", 0, moonlight.vars.get( "screen_width" ) )
    moonlight.imgui.add( "ICU ESP Y", icu.y, "slider", 0, moonlight.vars.get( "screen_height" ) )
    moonlight.imgui.add( "ICU ESP Tolerance", icu.tolerance, "slider", 10, 90 )
    moonlight.imgui.add( "ICU ESP Color", "", "color", icu.r, icu.g, icu.b, icu.a )
    moonlight.imgui.add( "ICU ESP Line Color", "", "color", icu.tr, icu.tg, icu.tb, icu.ta )

    -- Netvar
    if game == "CS:GO" then
        icu.m_angEyeAngles = moonlight.memory.netvar( "DT_CSPlayer->m_angEyeAngles[0]" )
        icu.m_szLastPlaceName = moonlight.memory.netvar( "DT_BasePlayer->m_szLastPlaceName" )
    elseif game == "TF2" then
        icu.m_angEyeAngles = moonlight.memory.netvar( "DT_TFPlayer->m_angEyeAngles[0]" )
    end
end

function icu.OnCreateMove( localplayer, cmd )

    -- Reset our database every move.
    icu.db = { }

    -- ICU on?
    if moonlight.vars.get( icu.name ) == 0 then return end

    -- Get our player information.
    local player_information = moonlight.game.get_player( localplayer )
    if player_information == nil then return end

    -- Get the bone position of our head.
    local bx, by, bz = moonlight.game.get_bone_position( localplayer, 8 )

    -- Get our FOV tolerance so we don't have to keep calling this function throughout our loop (performance)
    local fov_tolerance = moonlight.vars.get( icu.tolerance )

    -- Loop through all enemies.
    for _, enemy in pairs( moonlight.game.get_enemies( ) ) do

        if enemy["is_alive"] == true then 
            -- Get the enemy eye position.
            local eye_x, eye_y, eye_z = moonlight.game.get_eye_position( enemy )
            
            -- Get our eye angles.
            local eye_angles = moonlight.memory.get_vector( enemy["address"] + icu.m_angEyeAngles )

            -- Get the angle between our eye position and our target bone position.
            local distance_x, distance_y, distance_z = moonlight.math.angle_between( eye_x, eye_y, eye_z, bx, by, bz )

            -- Calculate an FOV based on these numbers.
            local fov = icu.get_fov( eye_angles.x, eye_angles.y, eye_angles.z, distance_x, distance_y, distance_z )

            -- Is the enemy's FOV less than our tolerance level?
            if fov < fov_tolerance then

                -- TraceRay
                local result = moonlight.game.trace_ray( eye_x, eye_y, eye_z, bx, by, bz, MASK_SHOT, enemy["address"] )

                -- Convert our findings to W2S.            
                local wx, wy, wz = moonlight.game.world_to_screen( eye_x, eye_y, eye_z )
                local ewx, ewy, ewz = moonlight.game.world_to_screen( player_information.origin.x, player_information.origin.y, player_information.origin.z ) -- Using origin here for better visual representation.
                
                -- Our current "enemy" table, we're going to add another table inside of it with our W2S results.
                enemy[ "base" ] = 
                {
                    x = wx,
                    y = wy,
                    z = wz
                }
                
                enemy[ "end" ] = 
                {
                    x = ewx,
                    y = ewy,
                    z = ewz
                }

                enemy[ "last_location"] = ""

                -- If we're using this script in CS:GO, include last location.
                if game == "CS:GO" then
                    enemy[ "last_location"] = "[" .. moonlight.memory.get_string( enemy["address"] + icu.m_szLastPlaceName ) .. "]"
                elseif game == "TF2" then
                    enemy[ "last_location"] = "[" .. icu.get_class_name( enemy["class"] ) .. "]" 
                end

                -- Check if the returned entity is an actual player and it is indeed us. Consider fraction.
                if result["player"] == localplayer or result["fraction"] > 0.97 then

                    -- Add to our database.
                    table.insert( icu.db, enemy )

                end
            end
        end
    end 
end

function icu.OnEndScene( )

    -- Ingame?
    if moonlight.game.is_connected() == false or moonlight.game.is_ingame() == false then return end

    -- ICU on?
    if moonlight.vars.get( icu.name ) == 0 then return end

    -- Line FantasyVars into variables so we don't have to keep calling this function (performance).
    local is_lines_enabled = moonlight.vars.get( icu.name )

    local lines_color =
    {
        r = moonlight.vars.get( icu.tr ),
        g = moonlight.vars.get( icu.tg ),
        b = moonlight.vars.get( icu.tb ),
        a = moonlight.vars.get( icu.ta ),
    }

    -- Create output string for moonlight.visuals.draw_string.
    local output_string = ""

    -- Loop through our database.
    for _, enemy in pairs( icu.db ) do
        -- Concat string.
        output_string = output_string .. enemy[ "last_location" ] .. " " .. enemy[ "name" ] .. " sees you.\n"

        -- Are we drawing lines?
        if is_lines_enabled == 1 then

            -- Check if our base or end is nil. So we don't get glitched drawings.

            if enemy[ "base" ][ "x" ] ~= nil and enemy[ "base" ][ "y" ] ~= nil and enemy[ "end" ][ "x" ] ~= nil and enemy[ "end" ][ "y" ] ~= nil then 
                -- Draw our line.
                moonlight.visuals.draw_line(
                    enemy[ "base" ][ "x" ],
                    enemy[ "base" ][ "y" ],
                    enemy[ "end" ][ "x" ],
                    enemy[ "end" ][ "y" ],
                    lines_color,
                    2
                )
            end
        end
    end

    -- Draw string.
    moonlight.visuals.draw_string( 
        moonlight.vars.get( icu.x ), 
        moonlight.vars.get( icu.y ),  
        1,
        { 
            r = moonlight.vars.get( icu.r ),
            g = moonlight.vars.get( icu.g ),
            b = moonlight.vars.get( icu.b ),
            a = moonlight.vars.get( icu.a ),
        },
        output_string
    )
end

return icu