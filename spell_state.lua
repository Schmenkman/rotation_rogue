local spell_state = {
    barrage_cast = false,
    rain_of_arrows_cast = false,
    loop_in_progress = false,  -- Diese Zeile wurde hinzugefügt
    last_cast_time = 0,
    
    reset_states = function(self)  -- Hier self hinzugefügt
        self.barrage_cast = false
        self.rain_of_arrows_cast = false
        self.loop_in_progress = false  -- Diese Zeile wurde hinzugefügt
    end
}

return spell_state