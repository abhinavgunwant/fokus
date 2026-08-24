package ui

import "core:time"

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

