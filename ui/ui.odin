package ui

Screen :: enum {
    Start,
    Settings,
}

UiState :: struct {
    screen: Screen,
    menu_open: bool,
    updated: bool,
}

state : UiState = {
    Screen.Start,
    false,
    true,
}

update :: proc () { state.updated = true }

