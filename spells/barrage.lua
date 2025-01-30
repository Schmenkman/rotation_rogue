local my_utility = require("my_utility/my_utility")
local spell_state = require("spell_state")

local menu_elements_barrage = {
    tree_tab = tree_node:new(1),
    main_boolean = checkbox:new(true, get_hash(my_utility.plugin_label .. "barrage_base_main_bool")),
}

local function menu()
    if menu_elements_barrage.tree_tab:push("Barrage") then
        menu_elements_barrage.main_boolean:render("Enable Spell", "")
        menu_elements_barrage.tree_tab:pop()
    end
end

local spell_id_barrage = 439762

local spell_data_barrage = spell_data:new(
    3.0,                        -- radius
    9.0,                        -- range
    1.5,                        -- cast_delay
    3.0,                        -- projectile_speed
    true,                       -- has_collision
    spell_id_barrage,           -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    -- targeting_type
)

local function logics(target)
    if not target then return false end
    
    -- Barrage nur casten wenn Rain of Arrows NICHT aktiv ist und Barrage auch nicht aktiv ist
    if spell_state.rain_of_arrows_cast or spell_state.barrage_cast then
        return false
    end
    
    if cast_spell.target(target, spell_data_barrage, false) then
        spell_state.barrage_cast = true
        spell_state.rain_of_arrows_cast = false
        spell_state.loop_in_progress = true -- Loop-Status setzen
        spell_state.last_cast_time = get_time_since_inject()
        console.print("Rogue, Casted Barrage")
        return true
    end
    
    return false
end

return {
    menu = menu,
    logics = logics
}