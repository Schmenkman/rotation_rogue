local my_utility = require("my_utility/my_utility")
local smoke_grenade = require("spells/smoke_grenade")

local function menu()
    -- Menu kann bleiben wie es ist
end

local rain_of_arrows_spell_id = 400232

local function logics(entity_list, target_selector_data, best_target)
    if not best_target then return false end
    
    -- Prüfe ob Barrage zuvor gecastet wurde
    if not barrage_was_cast then
        return false
    end

    local cast_position = best_target:get_position()
    
    -- Cast ausführen
    if cast_spell.position(rain_of_arrows_spell_id, cast_position, 1.0) then
        barrage_was_cast = false -- Reset Barrage Status
        smoke_grenade.set_loop_complete(true) -- Signal für Smoke Grenade
        console.print("Rogue Plugin, Casted Rain Of Arrows")
        return true
    end

    return false
end

return {
    menu = menu,
    logics = logics
}