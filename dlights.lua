--[[
    @title
        Dlights Library 
        https://fantasy.cat/forums/index.php?threads/lib_dlights.4114/
        
    @author
        typedef

    @notes
        This allows you to access functions within CVEfx. 
        https://i.imgur.com/sviqIF2.gif
        https://i.imgur.com/xEycxej.gif

    @functions
        init() boolean
            Initialize library.
        render( key, color, exp, radius, origin, die )
            key = This should be unique for every dlight created. Otherwise, you will overwrite. Consider this an ID.
            color = Table of r, g, b.
            exp = Increases the size.
            radius = Increases the fading radius.
            origin = Table of x, y, z
            die = The death time + current game time. If you want your dlight to be constantly on, just do anything above 0.
--]]

local ffi = require "ffi"

local dlights =
{
    ffi.cdef[[
        typedef struct  
        {
            float x;
            float y;
            float z;
        } vector;

        typedef struct 
        {
            unsigned char r;
            unsigned char g;
            unsigned char b;

            signed char exp;
        } color;

        typedef struct
        {
            int flags;
            vector origin;
            float radius;
            color color;
            float die;
            float decay;
            float minlight;
            int key;
            int style;

            vector direction;
            float inner_angle;
            float outer_angle;

            const void * excusive_light_receiver;
        } dlight;

        // CVEfx::CL_AllocDlight
        typedef dlight * (__thiscall *cl_allocdlight)(void*, int);
    ]],

    CVEfx = 0,
    CL_AllocDlight = nil,
}

function dlights.init( )
    -- Check if painting hook is enabled.
    if moonlight.vars.get( "hook_paint" ) == 0 then
        moonlight.error("dlights library could not be started because hook_paint is disabled!\n")
        return false
    end

    -- Create a new interface.
    local interface_effects = moonlight.game.create_interface( "engine.dll", "VEngineEffects" )
    
    -- Check if our interface was grabbed.
    if interface_effects == 0 then 
        moonlight.error("dlights library could not be started due to an interface error!\n")
        return false 
    end

    -- Cast to CVEfx.
    dlights.CVEfx = ffi.cast( ffi.typeof('void***'), interface_effects )

    -- virtual dlight_t* CL_AllocDlight(int key) = 0;
    dlights.CL_AllocDlight = ffi.cast('cl_allocdlight', dlights.CVEfx[0][4] )

    -- Check if we got the function.
    if dlights.CL_AllocDlight == nil then
        moonlight.error("dlights library could not be started due to function casting error!\n")
        return false
    end

    -- Everything is good.
    return true
end

function dlights.render( key, color, exp, radius, origin, die )
    local globals = moonlight.game.get_globals()

    local effect_entity = dlights.CL_AllocDlight( dlights.CVEfx, key )
    effect_entity.color.r = color.r
    effect_entity.color.g = color.g
    effect_entity.color.b = color.b
    effect_entity.color.exp = exp
    effect_entity.radius = radius
    effect_entity.origin.x = origin.x
    effect_entity.origin.y = origin.y
    effect_entity.origin.z = origin.z
    effect_entity.die = globals["curtime"] + die
end

return dlights