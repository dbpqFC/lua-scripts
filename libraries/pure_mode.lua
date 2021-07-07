--[[
    @title
        Pure Mode Library 
        
    @author
        typedef

    @notes
        Allows you to read and use the values inside of pure_mode.txt.

    @functions
        get( )
            Returns the "Pure Mode" JSON as a table.
        set( string, boolean )
            Sets a Pure Mode setting.
        is_enabled( string )
            Returns a boolean depending on the value found in pure_mode.txt
        is_scripts_allowed()
            Returns a boolean based on allow_non_default_scripts
        is_viewangles_allowed()
            Returns a boolean based on allow_humanizer_#2
        is_silent()
            Returns a boolean based on silence
        is_always_update()
            Returns a boolean based on always_update

--]]
local json = require "json"

local pure_mode =
{
    -- Pure Mode file.
    file = "pure_mode.txt"
}

function pure_mode.get( )
    -- Read Pure Mode file.
    local content = moonlight.windows.file.read( pure_mode.file )

    -- Does this file exist or does the content exist?
    if content == nil then
        moonlight.error( pure_mode.file .. " does not exist.\n")
        return
    end

    -- Return the array.
    return json.decode( content )["Pure Mode"]
end

function pure_mode.set( name, value )
    -- Read Pure Mode file.
    local content = moonlight.windows.file.read( pure_mode.file )

    -- Does this file exist or does the content exist?
    if content == nil then
        moonlight.error( pure_mode.file .. " does not exist.\n")
        return
    end

    -- Get our JSON table and assign to variable.
    local json_content = json.decode( content )

    -- Set new value.
    json_content["Pure Mode"][name] = value

    -- Lua Table -> JSON string.
    moonlight.windows.file.write( pure_mode.file, json.encode( json_content ) )
    moonlight.reload_pure_mode( )
end

function pure_mode.is_enabled( name )
    return pure_mode.get()[name]
end

function pure_mode.is_scripts_allowed( )
    return pure_mode.get()["allow_non_default_scripts"]
end

function pure_mode.is_viewangles_allowed( )
    return pure_mode.get()["allow_humanizer_#2"]
end

function pure_mode.is_silent( )
    return pure_mode.get()["silence"]
end

function pure_mode.is_always_update( )
    return pure_mode.get()["always_update"]
end

return pure_mode