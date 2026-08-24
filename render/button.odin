package render

Button :: struct {
    id : u32,
    x : f32,
    y : f32,
    w : f32,
    h : f32,
}

BUTTON_START_PLAY_PAUSE :: 0
BUTTON_START_RESET :: 1

start_page_buttons : [3] Button

