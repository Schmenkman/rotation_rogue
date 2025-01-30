local my_utility = require("my_utility/my_utility")

-- Timing und Status Variablen
local next_time_allowed_cast = 0.0
local smoke_grenade_cooldown = 4.0
local last_smoke_grenade_cast = 0.0
local barrage_rain_loop_complete = true

local function menu()
    -- Menu kann bleiben wie es ist
end

local spell_id_smoke_grenade = 356162

local function logics(entity_list, target_selector_data, best_target)
    if not best_target then return false end
    
    local current_time = get_time_since_inject()
    
    -- Prüfe Cooldown
    if current_time - last_smoke_grenade_cast < smoke_grenade_cooldown then
        return false
    end
    
    -- Prüfe Loop-Status
    if not barrage_rain_loop_complete then
        return false
    end

    local cast_position = best_target:get_position()
    
    if cast_spell.position(spell_id_smoke_grenade, cast_position, 0.4) then
        last_smoke_grenade_cast = current_time
        barrage_rain_loop_complete = false
        console.print("Rogue Plugin, Casted Smoke Grenade")
        return true
    end

    return false
end

local function set_loop_complete(status)
    barrage_rain_loop_complete = status
end

return {
    menu = menu,
    logics = logics,
    set_loop_complete = set_loop_complete
}