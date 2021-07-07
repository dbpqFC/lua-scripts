local chams = {
    name = "settings_chams",
    team = "settings_chams_team",
    xqz = "settings_chams_xqz",
    weapon = "settings_chams_weapons",

    color_visible_r = "settings_chams_color_visible_r",
    color_visible_g = "settings_chams_color_visible_g",
    color_visible_b = "settings_chams_color_visible_b",
    color_visible_a = "settings_chams_color_visible_a",

    color_hidden_r = "settings_chams_color_hidden_r",
    color_hidden_g = "settings_chams_color_hidden_g",
    color_hidden_b = "settings_chams_color_hidden_b",
    color_hidden_a = "settings_chams_color_hidden_a",

    color_weapon_visible_r = "settings_chams_color_weapon_visible_r",
    color_weapon_visible_g = "settings_chams_color_weapon_visible_g",
    color_weapon_visible_b = "settings_chams_color_weapon_visible_b",
    color_weapon_visible_a = "settings_chams_color_weapon_visible_a",

    color_weapon_hidden_r = "settings_chams_color_weapon_hidden_r",
    color_weapon_hidden_g = "settings_chams_color_weapon_hidden_g",
    color_weapon_hidden_b = "settings_chams_color_weapon_hidden_b",
    color_weapon_hidden_a = "settings_chams_color_weapon_hidden_a",

    material = "chams_material",
    material_weapons = "chams_material_weapons",
}

function chams.PostInitialize()

    if moonlight.get_game() ~= "CS:GO" then
        moonlight.error("This script can only run for CS:GO. Use chamstf.lua for TF2 chams.\n")
        return
    end


    if moonlight.vars.get("hook_draw_model") == 0 then
        moonlight.error("hook_draw_model is not enabled!\n")
        return
    end

    -- Make default chams materials
    moonlight.vars.add( chams.material, moonlight.visuals.create_material( "custom", "VertexLitGeneric", "vgui/white", "env_cubemap", false ), false, true )
    moonlight.vars.add( chams.material_weapons, moonlight.visuals.create_material( "custom", "VertexLitGeneric", "vgui/white", "env_cubemap", false ), false, true )

    -- Init variables.
    moonlight.vars.add( chams.name, 1 )
    moonlight.vars.add( chams.team, 0 )
    moonlight.vars.add( chams.xqz, 1 )
    moonlight.vars.add( chams.weapon, 1 )

    -- Regular Chams
    moonlight.vars.add( chams.color_visible_r, 255.0, true )
    moonlight.vars.add( chams.color_visible_g, 0.0, true )
    moonlight.vars.add( chams.color_visible_b, 0.0, true )
    moonlight.vars.add( chams.color_visible_a, 255.0, true )

    moonlight.vars.add( chams.color_weapon_visible_r, 0.0, true )
    moonlight.vars.add( chams.color_weapon_visible_g, 0.0, true )
    moonlight.vars.add( chams.color_weapon_visible_b, 255.0, true )
    moonlight.vars.add( chams.color_weapon_visible_a, 255.0, true )

    -- XQZ
    moonlight.vars.add( chams.color_hidden_r, 0.0, true )
    moonlight.vars.add( chams.color_hidden_g, 255.0, true )
    moonlight.vars.add( chams.color_hidden_b, 0.0, true )
    moonlight.vars.add( chams.color_hidden_a, 255.0, true )

    moonlight.vars.add( chams.color_weapon_hidden_r, 255.0, true )
    moonlight.vars.add( chams.color_weapon_hidden_g, 0.0, true )
    moonlight.vars.add( chams.color_weapon_hidden_b, 0.0, true )
    moonlight.vars.add( chams.color_weapon_hidden_a, 255.0, true )

    -- Ignore the X axis. This is so the model can be seen through objects. (Non-XQZ)
    moonlight.visuals.add_material_flag(MATERIAL_VAR_IGNOREZ, false)

    -- Wireframe Style
    moonlight.visuals.add_material_flag(MATERIAL_VAR_WIREFRAME, true)

    -- Glow-Like Material
    moonlight.visuals.add_material_flag(MATERIAL_VAR_ADDITIVE, false)

    -- Menu
    moonlight.imgui.add( "Chams", chams.name, "checkbox" )
    moonlight.imgui.add( "Chams Team", chams.team, "checkbox" )
    moonlight.imgui.add( "Chams XQZ", chams.xqz, "checkbox" )

    moonlight.imgui.add( "Chams Visible", "", "color", chams.color_visible_r, chams.color_visible_g, chams.color_visible_b, chams.color_visible_a)
    moonlight.imgui.add( "Chams XQZ", "", "color", chams.color_hidden_r, chams.color_hidden_g, chams.color_hidden_b, chams.color_hidden_a)
end

return chams