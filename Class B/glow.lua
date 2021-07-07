--[[
    @title
        Glow for Moonlight CSGO
    @author
        typedef
    @notes
        There is a WAY better method of doing this using FFI.

        This is the lazy, slower version. Rather, this is how external cheats do it.
        Except the difference/benefit here is that this doesn't flicker due to the "OnPostScreenEffects" callback.

        OnPostScreenEffects is the ideal place to allow glow. External cheats aren't timed with CS:GO's threading, therefore they flicker.
        Despite this being a slower version of what this could really be, there are no frame drops.
--]] 
local glow =
{
    -- FantasyVars
    name = "settings_glow",
    team = "settings_glow_team",
    occluded = "settings_glow_occluded",
    unoccluded = "settings_glow_unoccluded",
    full_bloom = "settings_glow_full_bloom",

    r = "settings_glow_r",
    g = "settings_glow_g",
    b = "settings_glow_b",
    a = "settings_glow_a",
    
    tr = "settings_glow_team_r",
    tg = "settings_glow_team_g",
    tb = "settings_glow_team_b",
    ta = "settings_glow_team_a",

    -- Signature
    pattern = "A1 ? ? ? ? A8 01 75 4B", -- https://github.com/frk1/hazedumper/blob/master/config.json#L257
    signature = 0,

    -- Netvars
    m_iGlowIndex = 0, -- https://github.com/frk1/hazedumper/blob/master/config.json#L753

    -- Functions
    render = function( glow_object_manager, glow_index, r, g, b, a, render_occluded, render_unoccluded, full_bloom )
        --[[
            typedef struct 
            {
                float r; /// 0x4
                float g; /// 0x8
                float b; /// 0x0C
                float a; /// 0x10
            } color_rgba;

            typedef struct
            {
                color_rgba color; /// 0x4 -> 0x10
                unsigned char unused_data[ 0x10 ];
                bool render_occluded; /// 0x24
                bool render_unoccluded; /// 0x25
                bool full_bloom; /// 0x26;
            } glow_entity;
        ]]
        moonlight.memory.set_float( glow_object_manager + glow_index + 0x4, r / 255 )
        moonlight.memory.set_float( glow_object_manager + glow_index + 0x8, g / 255 )
        moonlight.memory.set_float( glow_object_manager + glow_index + 0x0C, b / 255 )
        moonlight.memory.set_float( glow_object_manager + glow_index + 0x10, a / 255 )
        moonlight.memory.set_integer( glow_object_manager + glow_index + 0x24, render_occluded )
        moonlight.memory.set_integer( glow_object_manager + glow_index + 0x25, render_unoccluded )  
        moonlight.memory.set_integer( glow_object_manager + glow_index + 0x26, full_bloom )  
    end
}

function glow.PostInitialize( )
    -- CS:GO Only.
    if game == "TF2" then return end

    -- Don't run script unless hook_post_screen_effects is active.
    if moonlight.vars.get( "hook_post_screen_effects" ) == 0 then
        moonlight.error("You do not have \"hook_post_screen_effects\" enabled...\n")
        return
    end

    -- Find signature.
    glow.signature = moonlight.memory.get_integer( moonlight.memory.pattern( "client.dll", glow.pattern ) + 1 ) + 4
    glow.m_iGlowIndex = moonlight.memory.netvar( "DT_CSPlayer->m_flFlashDuration" ) + 24 

    if glow.signature == 0 or glow.m_iGlowIndex == 0 then 
        moonlight.error("Signature or Netvar is outdated!\n")
        return
    end

    -- Add FantasyVars
    moonlight.vars.add( glow.name, 1 )
    moonlight.vars.add( glow.team, 1 )
    moonlight.vars.add( glow.occluded, 1 )
    moonlight.vars.add( glow.unoccluded, 0 )
    moonlight.vars.add( glow.full_bloom, 0 )

    moonlight.vars.add( glow.r, 93, true )
    moonlight.vars.add( glow.g, 38, true )
    moonlight.vars.add( glow.b, 219, true )
    moonlight.vars.add( glow.a, 255, true )

    moonlight.vars.add( glow.tr, 67, true )
    moonlight.vars.add( glow.tg, 128, true )
    moonlight.vars.add( glow.tb, 240, true )
    moonlight.vars.add( glow.ta, 255, true )

    -- Add menu FantasyVars
    moonlight.imgui.add( "Glow", glow.name, "checkbox" )
    moonlight.imgui.add( "Glow Team", glow.team, "checkbox" )
    moonlight.imgui.add( "Glow Occluded", glow.occluded, "checkbox" )
    moonlight.imgui.add( "Glow Unoccluded", glow.unoccluded, "checkbox" )
    moonlight.imgui.add( "Glow Full Bloom", glow.full_bloom, "checkbox" )

    moonlight.imgui.add( "Glow Color", "", "color", glow.r, glow.g, glow.b, glow.a )
    moonlight.imgui.add( "Glow Team Color", "", "color", glow.tr, glow.tg, glow.tb, glow.ta )
end

function glow.OnPostScreenEffects( )

    -- Check server status.
    if moonlight.game.is_connected() == false or moonlight.game.is_ingame() == false then return end

    -- Get glow FantasyVars.
    local glow_enabled = moonlight.vars.get( glow.name )
    local glow_team = moonlight.vars.get( glow.team )

    -- Check if any glow enabled.
    if glow_enabled == 0 and glow_team == 0 then return end

    -- Get the rest of the FantasyVars (we didn't do this above because optimizations)
    local glow_occluded = moonlight.vars.get( glow.occluded )
    local glow_unoccluded = moonlight.vars.get( glow.unoccluded )
    local glow_full_bloom = moonlight.vars.get( glow.full_bloom )

    local color = 
    {
        r = moonlight.vars.get( glow.r ),
        g = moonlight.vars.get( glow.g ),
        b = moonlight.vars.get( glow.b ),
        a = moonlight.vars.get( glow.a ),
    }

    local color_team = 
    {
        r = moonlight.vars.get( glow.tr ),
        g = moonlight.vars.get( glow.tg ),
        b = moonlight.vars.get( glow.tb ),
        a = moonlight.vars.get( glow.ta ),
    }

    -- In case Moonlight says the localplayer doesn't exist yet.
    local player_information = moonlight.game.get_player( moonlight.game.localplayer( ) )
    if player_information == nil then return end

    -- Get manager object pointer.
    local glow_object_manager = moonlight.memory.get_integer( glow.signature )

    -- Loop through all players.
    for _, player in pairs( moonlight.game.get_players() ) do

        -- Ignore localplayer.
        if player["address"] ~= player_information["address"] then

            -- Only glow alive targets.
            if player["is_alive"] == true then
        
                -- Get their glow index.
                local glow_index = moonlight.memory.get_integer( player["address"] + glow.m_iGlowIndex ) * 0x38

                -- Team check and render.
                if player["team"] ~= player_information["team"] then
                    glow.render( glow_object_manager, glow_index, color.r, color.g, color.b, color.a, glow_occluded, glow_unoccluded, glow_full_bloom )
                else
                    glow.render( glow_object_manager, glow_index, color.tr, color.tg, color.tb, color.ta, glow_occluded, glow_unoccluded, glow_full_bloom )
                end
            end
        end
    end
end

return glow