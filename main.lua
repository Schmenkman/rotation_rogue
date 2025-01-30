local spell_state = require("spell_state")
local local_player = get_local_player()
if local_player == nil then
    return
end

local character_id = local_player:get_character_class_id();
local is_rouge = character_id == 3;
if not is_rouge then
 return
end;

local menu = require("menu");

local spells =
{
    concealment             = require("spells/concealment"),
    caltrop                 = require("spells/caltrop"),
    puncture                = require("spells/puncture"),
    heartseeker             = require("spells/heartseeker"),
    forcefull_arrow         = require("spells/forcefull_arrow"),
    blade_shift             = require("spells/blade_shift"),
    invigorating_strike     = require("spells/invigorating_strike"),
    twisting_blade          = require("spells/twisting_blade"),
    barrage                 = require("spells/barrage"),
    rapid_fire              = require("spells/rapid_fire"),
    flurry                  = require("spells/flurry"),
    penetrating_shot        = require("spells/penetrating_shot"),
    dash                    = require("spells/dash"),
    shadow_step             = require("spells/shadow_step"),
    smoke_grenade           = require("spells/smoke_grenade"),
    poison_trap             = require("spells/poison_trap"),
    dark_shroud             = require("spells/dark_shroud"),
    shadow_imbuement        = require("spells/shadow_imbuement"),
    poison_imbuement        = require("spells/poison_imbuement"),
    cold_imbuement          = require("spells/cold_imbuement"),
    shadow_clone            = require("spells/shadow_clone"),
    death_trap              = require("spells/death_trap"),
    rain_of_arrows          = require("spells/rain_of_arrows"),
    dance_of_knives          = require("spells/dance_of_knives"),
}

on_render_menu (function ()

    if not menu.main_tree:push("Rouge: Base") then
        return;
    end;

    menu.main_boolean:render("Enable Plugin", "");

    if menu.main_boolean:get() == false then
        menu.main_tree:pop();
        return;
    end;

    local options =  {"Melee", "Ranged"};
    menu.mode:render("Mode", options, "");

    menu.dash_cooldown:render("Dash Cooldown", "");

    spells.concealment.menu();
    spells.caltrop.menu();
    spells.puncture.menu();
    spells.heartseeker.menu();
    spells.forcefull_arrow.menu();
    spells.blade_shift.menu();
    spells.invigorating_strike.menu();
    spells.twisting_blade.menu();
    spells.barrage.menu();
    spells.rapid_fire.menu();
    spells.flurry.menu();
    spells.penetrating_shot.menu();
    spells.dash.menu();
    spells.shadow_step.menu();
    spells.smoke_grenade.menu();
    spells.poison_trap.menu();
    spells.dark_shroud.menu();
    spells.shadow_imbuement.menu();
    spells.poison_imbuement.menu();
    spells.cold_imbuement.menu();
    spells.shadow_clone.menu();
    spells.death_trap.menu();
    spells.rain_of_arrows.menu();
    spells.dance_of_knives.menu();
    menu.main_tree:pop();
    
end
)

on_key_release(function(key)
    if key ~= 4 or true  then
        return
    end
    
    local spell_id_shadow_step = 355606;
    local cast_position = get_cursor_position()
    local actors = actors_manager.get_all_actors()

    local player_position = get_player_position()
    table.sort(actors, function(a, b)
        return a:get_position():squared_dist_to_ignore_z(cast_position) <
        b:get_position():squared_dist_to_ignore_z(cast_position)
    end);

    local_player = get_local_player()

    for _, actor in ipairs(actors) do
        if not actor:is_basic_particle() and actor ~= local_player and actor:get_position():squared_dist_to_ignore_z(cast_position) < (8.0 * 8.0) then
            cast_spell.target(actor, spell_id_shadow_step, 0.5, false)
        end
    end

end);

local can_move = 0.0;
local cast_end_time = 0.0;

local my_utility = require("my_utility/my_utility");
local my_target_selector = require("my_utility/my_target_selector");

local last_heartseeker_cast_time = 0

local glow_target = nil
local last_dash_cast_time = 0.0
global_poison_trap_last_cast_time = 0.0
global_poison_trap_last_cast_position = nil
on_update(function ()

    local local_player = get_local_player();
    if not local_player then
        return;
    end

    if menu.main_boolean:get() == false then
        return;
    end;

    local current_time = get_time_since_inject()
    if current_time < cast_end_time then
        return;
    end;

    if not my_utility.is_action_allowed() then
        return;
    end  

    local screen_range = 20.0;
    local player_position = get_player_position();

    local collision_table = { false, 1.0 };
    local floor_table = { true, 3.0 };
    local angle_table = { false, 90.0 };

    local entity_list = my_target_selector.get_target_list(
        player_position,
        screen_range, 
        collision_table, 
        floor_table, 
        angle_table);

    local target_selector_data = my_target_selector.get_target_selector_data(
        player_position, 
        entity_list);

    if not target_selector_data.is_valid then
        return;
    end

    local is_auto_play_active = auto_play.is_active();
    local max_range = 26.0;
    local mode_id = menu.mode:get()
    if mode_id <= 0 then
        max_range = 7.0;
    end
    local is_ranged =  mode_id >= 1

    if is_auto_play_active then
        max_range = 12.0;
    end

    local best_target = my_target_selector.get_best_weighted_target(entity_list)
    local best_target_dist_player_sqr = best_target:get_position():squared_dist_to_ignore_z(local_player:get_position())




    local spell_id_heartseeker = 363402
    local is_heartseeker_build = is_ranged and utility.is_spell_ready(spell_id_heartseeker)
    local is_best_target_exception = false
    if is_heartseeker_build then

        local is_vulnerable = best_target:is_vulnerable()
        if is_vulnerable then
            is_best_target_exception = true
        end

        if not is_best_target_exception then
            local buffs = best_target:get_buffs()
            if buffs then
                for i, debuff in ipairs(buffs) do
                    if debuff.name_hash == 39809 or debuff.name_hash == 298962 then
                        is_best_target_exception = true
                        break
                    end
                end
            end
        end        
    end

    local is_heartseeker_exception = is_heartseeker_build and is_best_target_exception

    local closest_target = target_selector_data.closest_unit;
    if is_ranged  and menu.dash_cooldown:get() > 0 and not is_heartseeker_exception then
        if current_time - global_poison_trap_last_cast_time > 1.20 and current_time - global_poison_trap_last_cast_time < 2.20 and global_poison_trap_last_cast_position:squared_dist_to_ignore_z(player_position) < (3.30 * 3.30) then
            if cast_spell.position(337031, player_position:get_extended(global_poison_trap_last_cast_position, -4.0), 0.00)then
                global_poison_trap_last_cast_time = 0.0
                global_poison_trap_last_cast_position = nil
                console.print("Rouge Plugin, Casted evade ranged EXCEPTION EXCEPTION EXCEPTION EXCEPTION ");
            end
        end

        if current_time - last_dash_cast_time > menu.dash_cooldown:get() then
            local nd = {}
            for index, value in ipairs(entity_list) do
                if value:get_position():squared_dist_to_ignore_z(player_position) < (2.5 * 2.5) then
                    table.insert(nd, value)
                end
            end

            if #nd >= 3 then
                if cast_spell.position(337031, player_position:get_extended(closest_target:get_position(), -4.0), 0.00)then
                    last_dash_cast_time = current_time
                    console.print("Rouge Plugin, Casted evade ranged on melees");
                end
            end
        end
        
    end

    if not best_target then
        return;
    end

    glow_target = best_target;

    local best_target = my_target_selector.get_best_weighted_target(entity_list)
    local best_target_dist_player_sqr = best_target:get_position():squared_dist_to_ignore_z(local_player:get_position())

    -- Hier beginnt die neue Loop-Logik
    if spell_state.loop_in_progress then
        -- Während des Loops nur Barrage und Rain of Arrows erlauben
        if spells.barrage.logics(best_target) then
            cast_end_time = current_time + 0.6;
            return;
        end;

        if spells.rain_of_arrows.logics(entity_list, target_selector_data, best_target) then
            cast_end_time = current_time + 0.6;
            spell_state.loop_in_progress = false; -- Loop beenden nach Rain of Arrows
            return;
        end;
    else
        -- Wenn kein Loop aktiv ist, normale Spell-Reihenfolge
        -- Start mit Barrage möglich
        if spells.barrage.logics(best_target) then
            cast_end_time = current_time + 0.6;
            spell_state.loop_in_progress = true; -- Loop starten
            return;
        end;

        -- Andere Skills nur wenn kein Loop läuft
        if spells.smoke_grenade.logics(entity_list, target_selector_data, best_target) then
            cast_end_time = current_time + 0.4;
            spell_state.reset_states(); -- Loop-Status zurücksetzen
            return;
        end;

        if spells.concealment.logics() then
            cast_end_time = current_time + 0.4;
            spell_state.reset_states();
            return;
        end;

        if spells.shadow_clone.logics(closest_target) then
            cast_end_time = current_time + 0.4;
            spell_state.reset_states();
            return;
        end;

        if spells.death_trap.logics(entity_list, target_selector_data, best_target) then
            cast_end_time = current_time + 0.4;
            spell_state.reset_states();
            return;
        end;

        if spells.poison_trap.logics(entity_list, target_selector_data, best_target) then
            cast_end_time = current_time + 0.4;
            spell_state.reset_states();
            return;
        end;

        if spells.shadow_imbuement.logics() then
            spell_state.reset_states();
            return;
        end;

        if spells.dance_of_knives.logics() then
            spell_state.reset_states();
            return;
        end;

        if spells.poison_imbuement.logics() then
            spell_state.reset_states();
            return;
        end;

        if spells.cold_imbuement.logics() then
            spell_state.reset_states();
            return;
        end;

        if not is_heartseeker_exception then
            if spells.shadow_step.logics(entity_list, target_selector_data, best_target, closest_target)then
                cast_end_time = current_time + 0.4;
                return;
            end
        
            if spells.dash.logics(closest_target)then
                cast_end_time = current_time + 0.4;
                return;
            end;
        
            if spells.caltrop.logics(entity_list, target_selector_data, closest_target)then
                cast_end_time = current_time + 0.4;
                return;
            end;
        
            if spells.dark_shroud.logics()then
                cast_end_time = current_time + 0.4;
                return;
            end;
        end
    
        if spells.twisting_blade.logics(best_target)then
            cast_end_time = current_time + 0.2;
            return;
        end;
    
        if spells.rapid_fire.logics(best_target)then
            cast_end_time = current_time + 0.4;
            return;
        end;
    
        if spells.flurry.logics(best_target)then
            cast_end_time = current_time + 0.4;
            return;
        end;
    
        if spells.penetrating_shot.logics(entity_list, target_selector_data, best_target)then
            cast_end_time = current_time + 0.4;
            return;
        end;
    
        if spells.invigorating_strike.logics(best_target)then
            cast_end_time = current_time + 0.4;
            return;
        end;
    
        if spells.blade_shift.logics(best_target)then
            cast_end_time = current_time + 0.4;
            return;
        end;
    
        if spells.forcefull_arrow.logics(best_target)then
            cast_end_time = current_time + 0.4;
            return;
        end;

    end

    if distance_sqr > (max_range * max_range) then            
        best_target = target_selector_data.closest_unit;
        local closer_pos = best_target:get_position();
        local distance_sqr_2 = closer_pos:squared_dist_to_ignore_z(player_position);
        if distance_sqr_2 > (max_range * max_range) then
            return;
        end
    end

    

    local heartseeker_spell_cast_delay = spells.heartseeker.menu_elements_heartseeker_base.spell_cast_delay:get()

    if spells.puncture.logics(best_target)then
        cast_end_time = current_time + 0.1;
        return;
    end;

    if is_heartseeker_exception then
        local is_boss = false
        for index, value in ipairs(entity_list) do
            if value:is_boss() then
                is_boss = true
                break
            end
        end

        if not is_boss then
            evade.set_pause(0.2)
        end
    end

    table.sort(entity_list, function(a, b)
        return my_target_selector.get_unit_weight(a) > my_target_selector.get_unit_weight(b)
    end)

    for _, unit in ipairs(entity_list) do
        if spells.heartseeker.logics(unit) then
            last_heartseeker_cast_time = current_time
            cast_end_time = current_time + heartseeker_spell_cast_delay
            console.print("Heartseeker BACKUP cast on unit with ID: " .. tostring(unit:get_id()))
            return
        end
    end

    local move_timer = get_time_since_inject()
    if move_timer < can_move then
        return;
    end;

    local is_auto_play = my_utility.is_auto_play_enabled();
    if is_auto_play then
        local player_position = local_player:get_position();
        local is_dangerous_evade_position = evade.is_dangerous_position(player_position);
        if not is_dangerous_evade_position then
            local closer_target = target_selector.get_target_closer(player_position, 15.0);
            if closer_target then
                local closer_target_position = closer_target:get_position();
                local move_pos = closer_target_position:get_extended(player_position, 4.0);
                if pathfinder.move_to_cpathfinder(move_pos) then
                    can_move = move_timer + 1.50;
                end
            end
        end
    end

end);

local draw_player_circle = false;
local draw_enemy_circles = false;

on_render(function ()

    if menu.main_boolean:get() == false then
        return;
    end;

    local local_player = get_local_player();
    if not local_player then
        return;
    end

    local player_position = local_player:get_position();
    local player_screen_position = graphics.w2s(player_position);
    if player_screen_position:is_zero() then
        return;
    end

    if draw_player_circle then
        graphics.circle_3d(player_position, 8, color_white(85), 3.5, 144)
        graphics.circle_3d(player_position, 6, color_white(85), 2.5, 144)
    end    

    if draw_enemy_circles then
        local enemies = actors_manager.get_enemy_npcs()

        for i,obj in ipairs(enemies) do
        local position = obj:get_position();
        local distance_sqr = position:squared_dist_to_ignore_z(player_position);
        local is_close = distance_sqr < (8.0 * 8.0);
            graphics.circle_3d(position, 1, color_white(100));

            local future_position = prediction.get_future_unit_position(obj, 0.4);
            graphics.circle_3d(future_position, 0.5, color_yellow(100));
        end;
    end

    if not glow_target then
        return;
    end

    if glow_target and glow_target:is_enemy() then
        local glow_target_position = glow_target:get_position();
        local glow_target_position_2d = graphics.w2s(glow_target_position);
        if not glow_target_position_2d:is_zero() then
            graphics.line(glow_target_position_2d, player_screen_position, color_red(180), 2.5)
            graphics.circle_3d(glow_target_position, 0.80, color_red(200), 2.0);
        end
    end

end);

console.print("Lua Plugin - Rouge Base - Version 1.5");