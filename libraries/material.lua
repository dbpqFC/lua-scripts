--[[
    @title
        Material Library 
        
    @author
        typedef

    @notes
        This allows you to access functions within CMaterialSystem. 
        I have only added functions that were used for no_smoke.lua and nightmode.lua.

    @functions
        init() boolean
            Initialize library.
        to_material() IMaterial
            Cast pointer to proper IMaterial

        get_texture_group_name( IMaterial ) string
        color_modulate( IMaterial, r, g, b ) 
        find_material( name ) IMaterial
        first_material() number
        next_material( index ) number
        get_material( index ) IMaterial
        invalid_material( index ) number
        set_material_var_flag( number, boolean )

--]]
local ffi = require "ffi"

-- CMaterialSystem
local material_system =
{
    -- FFI
    ffi.cdef[[
        // CMaterialSystem::FindMaterial( const char *materialName, const char *pTextureGroupName, bool complain = true, const char *pComplainPrefix = NULL );
        typedef void * (__thiscall * find_material)( void *, const char *, const char *, bool, const char * );

        // CMaterialSystem::DELEGATE_TO_OBJECT_0C( MaterialHandle_t, FirstMaterial, &m_MaterialDict );
        typedef unsigned short (__thiscall *first_material)(void*);

        // CMaterialSystem::DELEGATE_TO_OBJECT_0C( MaterialHandle_t, InvalidMaterial, &m_MaterialDict );
        typedef unsigned short (__thiscall *invalid_material)(void*);

        // CMaterialSystem::DELEGATE_TO_OBJECT_1C( MaterialHandle_t, NextMaterial, MaterialHandle_t, &m_MaterialDict );
        typedef unsigned short (__thiscall *next_material)(void*, unsigned short);

        // CMaterialSystem::DELEGATE_TO_OBJECT_1C( IMaterial *,		GetMaterial, MaterialHandle_t, &m_MaterialDict );
        typedef void * (__thiscall *get_material)(void*, unsigned short);

        // IMaterialInternal::GetTextureGroupName() const;
        typedef const char * (__thiscall *get_texture_group_name)(void*);

        // IMaterialInternal::ColorModulate( float r, float g, float b );
        typedef void (__thiscall *color_modulate)(void*, float r, float g, float b);

        // IMaterialInternal::SetMaterialVarFlag( MaterialVarFlags_t flag, bool on );
        typedef void (__thiscall *set_material_var_flag)(void*, int, bool );
    ]],

    CMaterialSystem = nil,

    -- Functions
    functions =
    {
        find_material = nil,
        first_material = nil,
        invalid_material = nil,
        next_material = nil,
        get_material = nil
    },
}

function material_system.init()
    -- Get Interface
    local material_interface = moonlight.game.create_interface( "interface_material_system" )

    -- Cast to CMaterialSystem (https://github.com/VSES/SourceEngine2007/blob/master/src_main/materialsystem/cmaterialsystem.h)
    material_system.CMaterialSystem = ffi.cast( ffi.typeof('void***'), material_interface )

    -- Get FindMaterial function.
    material_system.functions.find_material = ffi.cast('find_material', material_system.CMaterialSystem[0][84] )
    material_system.functions.first_material = ffi.cast('first_material', material_system.CMaterialSystem[0][86] )
    material_system.functions.next_material = ffi.cast('next_material', material_system.CMaterialSystem[0][87] )
    material_system.functions.invalid_material = ffi.cast('invalid_material', material_system.CMaterialSystem[0][88] )
    material_system.functions.get_material = ffi.cast('get_material', material_system.CMaterialSystem[0][89] )

    -- Check if everything was casted correctly.
    if material_system.functions.find_material == nil or
    material_system.functions.first_material == nil or
    material_system.functions.next_material == nil or
    material_system.functions.invalid_material == nil or
    material_system.functions.get_material == nil then
        return false
    end

    return true
end

function material_system.get_material( index )
    return material_system.functions.get_material( material_system.CMaterialSystem, index )
end

function material_system.invalid_material( )
    return material_system.functions.invalid_material( material_system.CMaterialSystem )
end

function material_system.next_material( index )
    return material_system.functions.next_material( material_system.CMaterialSystem, index )
end

function material_system.first_material( )
    return material_system.functions.first_material( material_system.CMaterialSystem )
end

function material_system.find_material( name )
    return material_system.functions.find_material( material_system.CMaterialSystem, name, nil, true, nil )
end

function material_system.to_material( obj )
    return ffi.cast( ffi.typeof('void***'), obj )
end

function material_system.get_texture_group_name( IMaterial )
    local fnc = ffi.cast('get_texture_group_name', IMaterial[0][1] )
    return ffi.string(fnc(IMaterial))
end

function material_system.color_modulate( IMaterial, r, g, b )
    local fnc = ffi.cast('color_modulate', IMaterial[0][28] )
    fnc( IMaterial, r, g, b )
end

function material_system.set_material_var_flag( IMaterial, flag, toggle )
    local fnc = ffi.cast('set_material_var_flag', IMaterial[0][29] )
    fnc( IMaterial, flag, toggle )
end

return material_system