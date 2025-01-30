local my_utility = require("my_utility/my_utility")

local function menu()
    -- Menu kann bleiben wie es ist
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
    
    -- Cast Barrage wenn es noch nicht gecastet wurde
    if cast_spell.target(target, spell_data_barrage, false) then
        spell_state.barrage_cast = true
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