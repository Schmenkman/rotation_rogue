local my_utility = require("my_utility/my_utility")
local barrage = require("spells/barrage")

-- Timing und Status Variablen
local next_time_allowed_cast = 0.0
local smoke_grenade_cooldown = 4.0
local last_smoke_grenade_cast = 0.0
local barrage_rain_loop_complete = true

-- Bestehende Menu-Elemente bleiben unverändert
local menu_elements = {
    tree_tab = tree_node:new(1),
    main_boolean = checkbox:new(true, get_hash(my_utility.plugin_label .. "smoke_grenade_base_main_bool")),
    filter_mode = combo_box:new(1, get_hash(my_utility.plugin_label .. "smoke_grenade_filter_mode")),
    trap_mode = combo_box:new(0, get_hash(my_utility.plugin_label .. "smoke_grenade_base_mode")),
    keybind = keybind:new(0x01, false, get_hash(my_utility.plugin_label .. "smoke_grenade_base_keybind_pos")),
    keybind_ignore_hits = checkbox:new(true, get_hash(my_utility.plugin_label .. "smoke_grenade_base_keybind_ignore_min_hitstrap_base_pos")),
    min_hits = slider_int:new(1, 20, 4, get_hash(my_utility.plugin_label .. "smoke_grenade_base_min_hits_to_casttrap_base_pos")),
    allow_percentage_hits = checkbox:new(true, get_hash(my_utility.plugin_label .. "allow_percentage_hits_smoke_grenade_base_pos")),
    min_percentage_hits = slider_float:new(0.1, 1.0, 0.50, get_hash(my_utility.plugin_label .. "min_percentage_hits_smoke_grenade_base_pos")),
    soft_score = slider_float:new(2.0, 15.0, 5.0, get_hash(my_utility.plugin_label .. "min_percentage_hits_smoke_grenade_base_soft_core_pos")),
    spell_range = slider_float:new(1.0, 12.0, 7.50, get_hash(my_utility.plugin_label .. "smoke_grenade_spell_range")),
    spell_radius = slider_float:new(0.50, 5.0, 2.50, get_hash(my_utility.plugin_label .. "smoke_grenade_spell_radius")),
}

-- Menu-Funktion bleibt unverändert
local function menu()
    if menu_elements.tree_tab:push("Smoke Grenade") then
        menu_elements.main_boolean:render("Enable Spell", "")
        local dropbox_options = {"No filter", "Elite & Boss Only", "Boss Only"}
        menu_elements.filter_mode:render("Filter Modes", dropbox_options, "")
        local options = {"Auto", "Keybind"}
        menu_elements.trap_mode:render("Mode", options, "")
        menu_elements.keybind:render("Keybind", "")
        menu_elements.keybind_ignore_hits:render("Keybind Ignores Min Hits", "")
        menu_elements.min_hits:render("Min Hits", "")
        menu_elements.allow_percentage_hits:render("Allow Percentage Hits", "")
        if menu_elements.allow_percentage_hits:get() then
            menu_elements.min_percentage_hits:render("Min Percentage Hits", "", 1)
            menu_elements.soft_score:render("Soft Score", "", 1)
        end       
        menu_elements.spell_range:render("Spell Range", "", 1)
        menu_elements.spell_radius:render("Spell Radius", "", 1)
        menu_elements.tree_tab:pop()
    end
end

local spell_id_smoke_grenade = 356162
local my_target_selector = require("my_utility/my_target_selector")

local function is_smoke_grenade_ready()
    local current_time = get_time_since_inject()
    return current_time >= (last_smoke_grenade_cast + smoke_grenade_cooldown)
end

local function logics(entity_list, target_selector_data, best_target)
    -- Basis-Checks
    local menu_boolean = menu_elements.main_boolean:get()
    if not my_utility.is_spell_allowed(menu_boolean, next_time_allowed_cast, spell_id_smoke_grenade) then
        return false
    end

    -- Prüfe Smoke Grenade Cooldown und Loop-Status
    if not is_smoke_grenade_ready() or not barrage_rain_loop_complete then
        return false
    end

    -- Bestehende Logik bleibt größtenteils unverändert
    local player_position = get_player_position()
    local keybind_used = menu_elements.keybind:get_state()
    local trap_mode = menu_elements.trap_mode:get()
    if trap_mode == 1 and keybind_used == 0 then
        return false
    end

    -- Rest der bestehenden Logik...
    -- [Bestehender Code für Zielauswahl und Filterung]

    if cast_spell.position(spell_id_smoke_grenade, cast_position, 0.4) then
        last_smoke_grenade_cast = get_time_since_inject()
        next_time_allowed_cast = last_smoke_grenade_cast + 0.4
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