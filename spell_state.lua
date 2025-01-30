local spell_state = {
    barrage_cast = false,
    rain_of_arrows_cast = false,
    last_cast_time = 0,
    
    reset_states = function()
        spell_state.barrage_cast = false
        spell_state.rain_of_arrows_cast = false
    end
}

return spell_state