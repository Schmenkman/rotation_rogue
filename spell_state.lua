local spell_state = {
    loop_in_progress = false,
    last_loop_end_time = 0,
    barrage_cast = false,
    rain_of_arrows_cast = false
}

function spell_state.reset_states()
    spell_state.loop_in_progress = false
    spell_state.barrage_cast = false
    spell_state.rain_of_arrows_cast = false
    spell_state.last_loop_end_time = get_time_since_inject()
end

return spell_state