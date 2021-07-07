--[[
    @title
        WIN32 Keys Library 
        
    @author
        typedef

    @notes
        These are simple key functions for whatever purpose you may desire as an SDK developer.
        See key_test.lua in the thread for an example.

    @functions
        get_name( key ) string
            - Converts the virtual key to a name.
        get_key( key ) number
            - Converts the name to a virtual key.
        is_mouse_button( key ) boolean
            - Returns true/false depending on if the virtual key is a mouse button.
        is_keyboard_button( key ) boolean
            - Returns true/false depending on if the virtual key is a keyboard button.
        monitor( ) number
            - Returns the current key being pressed as a virtual key ID.
--]]

local keys =
{
    virtual_keys = 
    {
        "MOUSE 1","MOUSE 2","BRK","MOUSE 3","MOUSE 4","MOUSE 5",
        "","BSPC","TAB","","","","ENTER","","","SHIFT",
        "CTRL","ALT","PAUSE","CAPS","","","","","","",
        "ESC","","","","","SPACE","PGUP","PGDOWN","END","HOME","Left",
        "UP","RIGHT","DOWN","","PRNT","","PRTSCR","INS","DEL","","0","1",
        "2","3","4","5","6","7","8","9","","","","","","",
        "","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U",
        "V","W","X","Y","Z","LFTWIN","RGHTWIN","","","","NUM0","NUM1",
        "NUM2","NUM3","NUM4","NUM5","NUM6","NUM7","NUM8","NUM9","*","+","","-",".","/","F1","F2","F3",
        "F4","F5","F6","F7","F8","F9","F10","F11","F12","F13","F14","F15","F16","F17","F18","F19","F20","F21",
        "F22","F23","F24","","","","","","","","",
        "NUMLOCK","SCROLLLOCK","","","","","","","",
        "","","","","","","","LSHFT","RSHFT","LCTRL",
        "RCTRL","LMENU","RMENU","","","","","","","",
        "","","","NTRK","PTRK","STOP","PLAY","","",
        "","","","",";","+",",","-",".","/?","~","","",
        "","","","","","","","","",
        "","","","","","","","","",
        "","","","","","","{","\\|","}","'\"",
    }
}

function keys.get_name( key )
    return keys.virtual_keys[ key ]
end

function keys.get_key( key )
    -- Loop through all the keys.
    for i = 0, #keys.virtual_keys do

        -- Does the key match?
        if keys.virtual_keys[ i ] == key then

            -- Return the index.
            return i
        end
    end

    -- No key found. Return nil.
    return nil
end

function keys.is_mouse_button( key )
    return key >= 1 and key <= 6
end

function keys.is_keyboard_button( key )
    return key > 7
end

function keys.monitor( )
    -- Loop through all the keys.
    for i = 0, #keys.virtual_keys do
        
        -- Check if a key is pressed.
        if moonlight.windows.key( i ) then
            return i
        end
    end

    -- No key is being pressed right now.
    return nil
end

return keys