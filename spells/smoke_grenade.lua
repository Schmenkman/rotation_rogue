local my_utility = require("my_utility/my_utility")
local spell_state = require("spell_state")  -- Füge diese Zeile hinzu

local menu_elements_smoke = {
    tree_tab = tree_node:new(1),
    main_boolean = checkbox:new(true, get_hash(my_utility.plugin_label .. "smoke_grenade_base_main_bool")),
}

local function menu()
    if menu_elements_smoke.tree_tab:push("Smoke Grenade") then
        menu_elements_smoke.main_boolean:render("Enable Spell", "")
        menu_elements_smoke.tree_tab:pop()
    end
end


-- Timing und Status Variablen
local next_time_allowed_cast = 0.0
local smoke_grenade_cooldown = 4.0
local last_smoke_grenade_cast = 0.0
local barrage_rain_loop_complete = true


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