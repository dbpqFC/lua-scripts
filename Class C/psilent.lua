--[[
    @title
        pSilent for Moonlight.
    @author
        typedef
    @notes
        
--]] 

local psilent =
{
    name = "settings_psilent",
    fov = "settings_psilent_fov",
    key = "settings_psilent_key",
    bone = "settings_psilent_bone",
}

function psilent.PostInitialize()

    -- Only TF2
    if moonlight.get_game() ~= "TF2" then return end

    -- FantasyVars
    moonlight.vars.add( psilent.name, 1 )
    moonlight.vars.add( psilent.fov, 10.0, true )
    moonlight.vars.add( psilent.key, 0 )
    moonlight.vars.add( psilent.bone, 8 )

    -- Menu
    moonlight.imgui.add( "pSilent", psilent.name, "checkbox")
    moonlight.imgui.add( "pSilent FOV", psilent.fov, "slider_float", 0.0, 20.0)
    moonlight.imgui.add( "pSilent Bone", psilent.bone, "slider", 0, 27)
    moonlight.imgui.add( "pSilent Key", psilent.key, "key")
end

function get_closest_target( localplayer, fov, bone )
    --[[
        Gets the closest target in your FOV range.
        Returns the table shown below.
    ]]

    local fov_information =
    {
        highest = 9999999,
        target = nil,
        x,
        y,
        z
    }

    -- Get localplayer's eye position.
    local x, y, z = moonlight.game.get_eye_position( localplayer )

    -- Loop through everyone.
    for _, target_player in pairs( moonlight.game.get_enemies() ) do 

        -- Get their bone position based on our settings.
        local h_x, h_y, h_z = moonlight.game.get_bone_position( target_player, bone )

        -- Calculate the angle between our eye position and their bones.
        local angle_x, angle_y, angle_z = moonlight.math.angle_between( x, y, z, h_x, h_y, h_z )
     
        -- Get the FOV value based on the angle we calculated.
        local calculated_fov = moonlight.game.get_fov( angle_x, angle_y, angle_z )
        
        -- Start comparing player FOVs.
        if calculated_fov < fov then -- Is the FOV less than our settings?
            if fov < fov_information.highest then -- We found someone. But let's start breaking down who is the closest.

                -- We found someone who is the best target... but are they even visible?
                local trace_ray_result = moonlight.game.trace_ray( x, y, z, h_x, h_y, h_z, MASK_SHOT_HULL, true)

                -- We see them. No wall in the way or anything!
                if moonlight.game.is_valid_player( trace_ray_result["player"] ) then 
                    -- Closest target we can find. Store their information.
                    fov_information.highest = calculated_fov
                    fov_information.target = target_player
                    fov_information.x = angle_x
                    fov_information.y = angle_y
                    fov_information.z = angle_z
                end

                -- Don't break loop. Let's keep looping in case there is someone closer.
            end
        end
    end

    return fov_information
end

function psilent.OnCreateMove( localplayer, cmd )


    -- FOV
    local fov_information = get_closest_target( localplayer, moonlight.vars.get( psilent.fov ), moonlight.vars.get( psilent.bone ) )

    -- We couldn't find anyone.
    if fov_information.target == nil then return end

    local key = moonlight.vars.get( psilent.key )
    local apply_psilent = false

    if key == 0 then
        apply_psilent = true
    else
        if moonlight.windows.key( key ) == true then
            apply_psilent = true
        end
    end
    
    -- Apply pSilent.
    if apply_psilent == true then

        -- No ban.
        fov_information.x, fov_information.y, fov_information.z = moonlight.math.normalize( fov_information.x, fov_information.y, fov_information.z )

        cmd["x"] = fov_information.x
        cmd["y"] = fov_information.y
        cmd["z"] = fov_information.z
        moonlight.game.push_cmd( cmd )

        -- Turn off the humanizer.
        moonlight.vars.set( "settings_humanizer_active", 0 )
    end
end

return psilent