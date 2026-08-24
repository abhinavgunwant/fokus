package ui

import "core:time"
import "core:fmt"

import "../globals"

Screen :: enum {
    Start,
    Settings,
}

UiState :: struct {
    screen: Screen,
    timer: Timer,
    message: TimerMessage,
    menu_open: bool,
    updated: bool,
    started: bool,
}

state : UiState = {
    Screen.Start,
    {
        time.tick_now(),
        { 0 },
        globals.DEFAULT_TIMER,
        time.tick_now(),
    },
    TimerMessage.Stop,
    false,
    true,
    false,
}

Timer :: struct {
    initial_time: time.Tick,
    configured_duration: time.Tick,
    remaining_duration: time.Duration,
    last_updated: time.Tick,
}

TimerMessage :: enum {
    Stop,
    Run,
    Finished,
}

update :: proc () { state.updated = true }

tick :: proc () {
    now := time.tick_now()

    if state.message == TimerMessage.Run {
        state.timer.remaining_duration -= time.tick_diff(state.timer.last_updated, now)
        state.timer.last_updated = now

        if state.timer.remaining_duration < 0 {
            state.message = TimerMessage.Finished
            state.timer.remaining_duration = 0
            state.started = false
        }
    }
}

get_time_string :: proc () -> string {
    h, m, s, n := time.precise_clock_from_duration(state.timer.remaining_duration)

    if h > 0 {
        return fmt.tprintf("%2v:%2v:%2v", h, m, s)
    }

    return fmt.tprintf("%2v:%2v", m, s)
}

