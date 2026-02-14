-- ~/.config/mpv/scripts/pretty-progress.lua

local mp = require 'mp'
local assdraw = require 'mp.assdraw'

-- Configuration
local bar_length = 40 -- How wide the bar is
local filled_char = "█"
local empty_char = " "
local border_left = "|"
local border_right = "|"
local show_percent = true

-- Main function to draw the bar
function draw_progress()
    local duration = mp.get_property_number("duration", 0)
    local position = mp.get_property_number("time-pos", 0)
    if duration == 0 then return end

    local percent = math.min(math.max(position / duration, 0), 1)
    local filled_blocks = math.floor(bar_length * percent)
    local empty_blocks = bar_length - filled_blocks

    local bar = border_left ..
                string.rep(filled_char, filled_blocks) ..
                string.rep(empty_char, empty_blocks) ..
                border_right

    if show_percent then
        bar = bar .. string.format(" %3d%%", percent * 100)
    end

    mp.osd_message(bar, 1) -- show for 1 second
end

-- Update every second
mp.add_periodic_timer(1, draw_progress)

-- Also update manually when seeking
mp.observe_property("time-pos", "number", function() draw_progress() end)

