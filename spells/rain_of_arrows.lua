local my_utility = require("my_utility/my_utility")
local smoke_grenade = require("spells/smoke_grenade")

local menu_elements_rain_of_arrows = {
    tree_tab = tree_node:new(1),
    main_boolean = checkbox:new(true, get_hash(my_utility.plugin_label .. "rain_of_arrows_main_bool_base")),
    rain_of_arrows_mode = combo_box:new(0, get_hash(my_utility.plugin_label .. "rain_base_base")),
    keybind = keybind:new(0x01, false, get_hash(my_utility.plugin_label .. "rain_base_keybind")),
    keybind_ignore_hits = checkbox:new(true, get_hash(my_utility.plugin_label .. "keybind_ignore_min_hits_rain_base")),
    min_hits = slider_int:new(1, 20, 6, get_hash(my_utility.plugin_label .. "min_hits_to_cast_rain_base")),
    allow_percentage_hits = checkbox:new(true, get_hash(my_utility.plugin_label .. "allow_percentage_hits_rain_base")),
    min_percentage_hits = slider_float:new(0.1, 1.0, 0.40, get_hash(my_utility.plugin_label .. "min_percentage_hits_rain_base")),
    soft_score = slider_float:new(2.0, 15.0, 6.0, get_hash(my_utility.plugin_label .. "min_percentage_hits_rain_base_soft_core")),
}

local function menu()
    if menu_elements_rain_of_arrows.tree_tab:push("Rain Of Arrows") then
        menu_elements_rain_of_arrows.main_boolean:render("Enable Spell", "")
        
        local options = {"Auto", "Keybind"}
        menu_elements_rain_of_arrows.rain_of_arrows_mode:render("Mode", options, "")
        
        menu_elements_rain_of_arrows.keybind:render("Keybind", "")
        menu_elements_rain_of_arrows.keybind_ignore_hits:render("Keybind Ignores Min Hits", "")
        
        menu_elements_rain_of_arrows.min_hits:render("Min Hits", "")
        
        menu_elements_rain_of_arrows.allow_percentage_hits:render("Allow Percentage Hits", "")
        if menu_elements_rain_of_arrows.allow_percentage_hits:get() then
            menu_elements_rain_of_arrows.min_percentage_hits:render("Min Percentage Hits", "", 1)
            menu_elements_rain_of_arrows.soft_score:render("Soft Score", "", 1)
        end
        
        menu_elements_rain_of_arrows.tree_tab:pop()
    end
end

local rain_of_arrows_spell_id = 400232
local barrage_spell_id = 439762 -- Barrage Spell ID für Abhängigkeitsprüfung

-- Globale Variable für den Barrage-Cast-Status
local barrage_was_cast = false

-- Funktion zum Setzen des Barrage-Cast-Status (wird von barrage.lua aufgerufen)
local function set_barrage_cast_status(status)
    barrage_was_cast = status
end

local my_target_selector = require("my_utility/my_target_selector")
local next_time_allowed_cast = 0.0

local function logics(entity_list, target_selector_data, best_target)
    -- Basis-Checks
    local menu_boolean = menu_elements_rain_of_arrows.main_boolean:get()
    if not my_utility.is_spell_allowed(menu_boolean, next_time_allowed_cast, rain_of_arrows_spell_id) then
        return false
    end

    -- Prüfe ob Barrage zuvor gecastet wurde
    if not barrage_was_cast then
        return false
    end

    local player_position = get_player_position()
    local keybind_used = menu_elements_rain_of_arrows.keybind:get_state()
    local rain_mode = menu_elements_rain_of_arrows.rain_of_arrows_mode:get()
    
    if rain_mode == 1 and keybind_used == 0 then
        return false
    end

    local keybind_ignore_hits = menu_elements_rain_of_arrows.keybind_ignore_hits:get()
    local keybind_can_skip = keybind_ignore_hits and keybind_used > 0

    -- Percentage Hits Logik
    local is_percentage_hits_allowed = menu_elements_rain_of_arrows.allow_percentage_hits:get()
    local min_percentage = menu_elements_rain_of_arrows.min_percentage_hits:get()
    if not is_percentage_hits_allowed then
        min_percentage = 0.0
    end

    -- Zielbereich und Treffer berechnen
    local spell_range = 5.0
    local spell_radius = 10.0
    local area_data = my_target_selector.get_most_hits_circular(player_position, spell_range, spell_radius)
    
    if not area_data.main_target then
        return false
    end

    -- Prüfe Treffer-Validierung
    local min_hits_menu = menu_elements_rain_of_arrows.min_hits:get()
    local is_area_valid = my_target_selector.is_valid_area_spell_aio(area_data, min_hits_menu, entity_list, min_percentage)
    
    if not is_area_valid and not keybind_can_skip then
        return false
    end

    if not area_data.main_target:is_enemy() then
        return false
    end

    -- Elite/Boss Check
    local contains_relevant = false
    for _, victim in ipairs(area_data.victim_list) do
        if victim:is_elite() or victim:is_champion() or victim:is_boss() then
            contains_relevant = true
            break
        end
    end

    if not contains_relevant and area_data.score < menu_elements_rain_of_arrows.soft_score:get() and not keybind_can_skip then
        return false
    end

    -- Position und Distanz Check
    local cast_position = area_data.main_target:get_position()
    local cast_position_distance_sqr = cast_position:squared_dist_to_ignore_z(player_position)
    
    if cast_position_distance_sqr < 2.0 and not keybind_can_skip then
        return false
    end

    -- Cast ausführen
    if cast_spell.position(rain_of_arrows_spell_id, cast_position, 1.0) then
        next_time_allowed_cast = get_time_since_inject() + 0.4
        barrage_was_cast = false -- Reset Barrage Status
        smoke_grenade.set_loop_complete(true) -- Signal für Smoke Grenade
        console.print("Rogue Plugin, Casted Rain Of Arrows")
        return true
    end

    return false
end

return {
    menu = menu,
    logics = logics,
    set_barrage_cast_status = set_barrage_cast_status
}