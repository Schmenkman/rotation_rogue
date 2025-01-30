local my_utility = require("my_utility/my_utility")
local smoke_grenade = require("spells/smoke_grenade")
local spell_state = require("spell_state")  -- Füge diese Zeile hinzu

local menu_elements_rain = {
    tree_tab = tree_node:new(1),
    main_boolean = checkbox:new(true, get_hash(my_utility.plugin_label .. "rain_of_arrows_base_main_bool")),
}

local function menu()
    if menu_elements_rain.tree_tab:push("Rain of Arrows") then
        menu_elements_rain.main_boolean:render("Enable Spell", "")
        menu_elements_rain.tree_tab:pop()
    end
end


local rain_of_arrows_spell_id = 400232

-- In rain_of_arrows.lua
local function logics(entity_list, target_selector_data, best_target)
    if not best_target then return false end
    
    -- Prüfe spell_state statt undefinierter Variable
    if not spell_state.barrage_cast then
        return false
    end

    local cast_position = best_target:get_position()
    
    if cast_spell.position(rain_of_arrows_spell_id, cast_position, 1.0) then
        spell_state.barrage_cast = false -- Reset Barrage Status
        smoke_grenade.set_loop_complete(true)
        console.print("Rogue Plugin, Casted Rain Of Arrows")
        return true
    end

    return false
end

return {
    menu = menu,
    logics = logics
}