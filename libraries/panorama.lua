local ffi = require("ffi")
local panorama =
{
    --[[
        @title
            Panorama HUD Library for fantasy.moonlight.
        
        @author
            typedef
    ]]

    ffi.cdef [[

        typedef void***(__thiscall* t_find_hud_element)(void*, const char*);

        // CBaseHud
        typedef void(__cdecl* t_printf)(void*, int, int, const char*, ...); // ChatPrintf

        // IUIEngine
        typedef void* (__thiscall *t_access_ui_engine)(void*); // AccessUIEngine
        
        // EventDispatcher(?)
        typedef void (__thiscall *t_dispatch_event)( void*, void *); // dispatchEvent

        // IUIPanel
        typedef int (__thiscall *t_get_child_count)( void* ); // GetChildCount
        typedef void* (__thiscall *t_get_child)( void*, int ); // GetChild
        typedef void* (__thiscall *t_get_first_child)( void* ); // GetFirstChild
        typedef void* (__thiscall *t_get_last_child)( void* ); // GetLastChild
        typedef int (__thiscall *t_get_child_index)( void*, void const * const ); // GetChildIndex
        typedef bool (__thiscall *t_has_class)( void*, const char * ); // HasClass
        typedef float (__thiscall *get_attribute)( void*, const char *, float ); // GetAttribute
        typedef float (__thiscall *set_attribute)( void*, const char *, float ); // SetAttribute
    ]],

    hud = nil,
    CHudChat = nil, 
    IUIEngine = nil,
    interface = 0,

    functions =
    {
        find_hud_element = nil,
        printf = nil,
        access_ui_engine = nil,
    },
}

function panorama.init( self )

    local signatures =
    {
        hud = 0,
        find_hud = 0
    }

    -- Find Panorama Interface
    self.interface = moonlight.game.create_interface( "panorama.dll", "PanoramaUIEngine001" )
    if self.interface == 0 then return false end

    -- Interface Casting (panorama::IUIEngine)
    self.IUIEngine = ffi.cast( ffi.typeof('void***'), self.interface )
    if self.IUIEngine == nil then return false end

    -- Find signatures.
    signatures.hud = moonlight.memory.pattern( "client.dll", "B9 ? ? ? ? E8 ? ? ? ? 8B 5D 08" )
    signatures.find_hud = moonlight.memory.pattern( "client.dll", "55 8B EC 53 8B 5D 08 56 57 8B F9 33 F6 39 77 28" )
    if signatures.hud == 0 or signatures.find_hud == 0 then return false end

    -- Type Casting
    self.hud = ffi.cast( "void**", ffi.cast("char*", signatures.hud) + 1)[ 0 ]
    self.functions.find_hud_element = ffi.cast( "t_find_hud_element", signatures.find_hud )
    if self.hud == nil or self.functions.find_hud_element == nil then return false end

    -- Finding CHudChat
    self.CHudChat = self.functions.find_hud_element( self.hud, "CHudChat" )
    if self.CHudChat == nil then return false end

    -- Assigning functions.
    self.functions.printf = ffi.cast('t_printf', self.CHudChat[ 0 ][ 27 ] )
    self.functions.access_ui_engine = ffi.cast('t_access_ui_engine', self.IUIEngine[ 0 ][ 11 ] )
    return true
end

-- GetHud().FindElement(?)
function panorama.find_hud_element( self, name )
    return self.functions.find_hud_element( self.hud, name )
end

-- CBaseHud::ChatPrintf
function panorama.printf( self, player, filter, text )
    self.functions.printf( self.hud, player, filter, text )
end

-- panorama::IUIEngine::AccessUIEngine
function panorama.access_ui_engine( self )
    return self.functions.access_ui_engine( self.IUIEngine )
end

-- EventDispatcher::dispatchEvent(?)
function panorama.dispatch_event( self, ui, event )
    local ui_ptr = ffi.cast( ffi.typeof('void***'), ui )
    local dispatch_event = ffi.cast('t_dispatch_event', ui_ptr[ 0 ][ 52 ] )
    dispatch_event( ui_ptr, event )
end

-- IUIPanel::GetChildCount
function panorama.get_child_count( self, ui )
    local ui_ptr = ffi.cast( ffi.typeof('void***'), ui )
    local fnc = ffi.cast('t_get_child_count', ui_ptr[ 0 ][ 48 ] )
    return fnc( ui_ptr )
end

-- IUIPanel::GetChild
function panorama.get_child( self, ui, num )
    local ui_ptr = ffi.cast( ffi.typeof('void***'), ui )
    local fnc = ffi.cast('t_get_child', ui_ptr[ 0 ][ 49 ] )
    return fnc( ui_ptr, num )
end

-- IUIPanel::GetFirstChild
function panorama.get_first_child( self, ui )
    local ui_ptr = ffi.cast( ffi.typeof('void***'), ui )
    local fnc = ffi.cast('t_get_first_child', ui_ptr[ 0 ][ 50 ] )
    return fnc( ui_ptr )
end

-- IUIPanel::GetLastChild
function panorama.get_last_child( self, ui )
    local ui_ptr = ffi.cast( ffi.typeof('void***'), ui )
    local fnc = ffi.cast('t_get_last_child', ui_ptr[ 0 ][ 51 ] )
    return fnc( ui_ptr )
end

-- IUIPanel::GetChildIndex
function panorama.get_child_index( self, ui )
    local ui_ptr = ffi.cast( ffi.typeof('void***'), ui )
    local fnc = ffi.cast('t_get_child_index', ui_ptr[ 0 ][ 52 ] )
    return fnc( ui_ptr )
end

-- IUIPanel::HasClass
function panorama.has_class( self, ui, class )
    local ui_ptr = ffi.cast( ffi.typeof('void***'), ui )
    local fnc = ffi.cast('t_has_class', ui_ptr[ 0 ][ 139 ] )
    return fnc( ui_ptr, class )
end

-- IUIPanel::GetAttribute
function panorama.get_attribute( self, ui, name, default )
    local ui_ptr = ffi.cast( ffi.typeof('void***'), ui )
    local fnc = ffi.cast('t_get_attribute', ui_ptr[ 0 ][ 278 ] )
    return fnc( ui_ptr, name, default )
end

-- IUIPanel::SetAttribute
function panorama.set_attribute( self, ui, name, value )
    local ui_ptr = ffi.cast( ffi.typeof('void***'), ui )
    local fnc = ffi.cast('t_set_attribute', ui_ptr[ 0 ][ 288 ] )
    fnc( ui_ptr, name, value )
end

return panorama