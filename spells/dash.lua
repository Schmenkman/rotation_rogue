local my_utility = require("my_utility/my_utility")

-- Menu Elemente bleiben unverändert
local menu_elements_dash_base = {
    tree_tab = tree_node:new(1),
    main_boolean = checkbox:new(true, get_hash(my_utility.plugin_label .. "dash_base_main_bool")),
    allow_elite_single_target = checkbox:new(true, get_hash(my_utility.plugin_label .. "allow_elite_single_target_base_dash")),
    min_hits_slider = slider_int:new(0, 30, 4, get_hash(my_utility.plugin_label .. "min_max_number_of_targets_for_cast_dash_base")),
    spell_range = slider_float:new(1.0, 15.0, 3.10, get_hash(my_utility.plugin_label .. "dash_base_spell_range_2")),
    trap_mode = combo_box:new(0, get_hash(my_utility.plugin_label .. "dash_base_base_pos")),
    keybind = keybind:new(0x01, false, get_hash(my_utility.plugin_label .. "dash_base_keybind_pos")),
    keybind_ignore_hits = checkbox:new(true, get_hash(my_utility.plugin_label .. "keybind_ignore_min_hit_dash_base_pos")),
}

-- Menu Funktion bleibt unverändert
local function menu()
    -- ... (bisheriger Menu-Code bleibt gleich)
end

local spell_id_dash = 358761
local next_time_allowed_cast = 0.0
local is_auto_play_active = auto_play.is_active()

-- Hauptlogik für Dash
local function logics(target)
    -- Basis-Checks
    local menu_boolean = menu_elements_dash_base.main_boolean:get()
    if not my_utility.is_spell_allowed(menu_boolean, next_time_allowed_cast, spell_id_dash) then
        return false
    end

    -- Keybind Modus Check
    local keybind_used = menu_elements_dash_base.keybind:get_state()
    local trap_mode = menu_elements_dash_base.trap_mode:get()
    if trap_mode == 1 and keybind_used == 0 then
        return false
    end

    local keybind_ignore_hits = menu_elements_dash_base.keybind_ignore_hits:get()
    local keybind_can_skip = keybind_ignore_hits and keybind_used > 0

    -- Position Checks
    local local_player = get_local_player()
    local player_position = get_player_position()
    local cursor_position = get_cursor_position()

    -- Mindestabstand zum Cursor Check
    if not keybind_can_skip then
        local player_dist_cursor_sqr = cursor_position:squared_dist_to_ignore_z(player_position)
        if player_dist_cursor_sqr < (1.22 * 1.22) then
            return false
        end
    end
    
    -- Reichweiten Check
    local spell_range = menu_elements_dash_base.spell_range:get()
    local target_position = target:get_position()
    local distance_sqr = player_position:squared_dist_to_ignore_z(target_position)
    if distance_sqr > (spell_range * spell_range) and not keybind_can_skip then
        return false
    end

    -- Zielbereich Berechnung
    local rectangle_radius = 1.50
    local destination_dash = 7.50
    local area_data = target_selector.get_most_hits_target_rectangle_area_heavy(player_position, destination_dash, rectangle_radius)
    local best_target = area_data.main_target

    if not best_target then
        return false
    end

    -- Beste Position berechnen
    local best_target_position = best_target:get_position()
    local best_cast_data = my_utility.get_best_point_rec(best_target_position, destination_dash, rectangle_radius, area_data.victim_list)
    local best_hit_list = best_cast_data.victim_list
    
    -- Elite/Boss Priorisierung
    local is_single_target_allowed = false
    if menu_elements_dash_base.allow_elite_single_target:get() then
        for _, unit in ipairs(best_hit_list) do
            if (unit:is_boss() and unit:get_current_health() / unit:get_max_health() > 0.15) or
               (unit:is_elite() and unit:get_current_health() / unit:get_max_health() > 0.35) then
                is_single_target_allowed = true
                break
            end
        end
    end

    -- Treffer Check
    local best_cast_hits = best_cast_data.hits
    if best_cast_hits < menu_elements_dash_base.min_hits_slider:get() and 
       not is_single_target_allowed and 
       not keybind_can_skip then
        return false
    end

    local best_cast_position = best_cast_data.point

    -- Winkel Check für manuelles Spiel
    if not is_auto_play_active then
        local angle = best_cast_position:get_angle(cursor_position, player_position)
        if angle > 100.0 then
            return false
        end
    end

    -- Cast Optionen prüfen und ausführen
    local function try_cast_at_position(position, max_enemies, extension)
        local enemies_near = target_selector.get_near_target_list(position, 2.50)
        if not evade.is_dangerous_position(position) and #enemies_near <= max_enemies then
            if cast_spell.position(spell_id_dash, position, 0.5) then
                next_time_allowed_cast = get_time_since_inject() + 0.2
                console.print(string.format("Rogue, Casted Dash (extension: %.2f)", extension))
                return true
            end
        end
        return false
    end

    -- Versuche erst Option 1 (weiter weg), dann Option 2 (näher)
    local option_1 = best_cast_position:get_extended(player_position, -3.50)
    if try_cast_at_position(option_1, 2, -3.50) then
        return true
    end

    local option_2 = best_cast_position:get_extended(player_position, -2.00)
    if try_cast_at_position(option_2, 1, -2.00) then
        return true
    end

    return false
end

return {
    menu = menu,
    logics = logics,
}