package timer

import "core:time"
import "core:thread"
import "core:fmt"

Timer :: struct {
    initial_time: time.Time,
    time_remaining: time.Duration,
    last_updated: time.Time,
}

TimerMessage :: enum {
    Stop,
    Run,
}

timer_message := TimerMessage.Stop

init :: proc () -> ^thread.Thread {
    worker := thread.create(time_work)
    worker.init_context = context
    worker.user_index = 1

    thread.start(worker)

    return worker
}

time_work :: proc (t: ^thread.Thread) {
    tick : u64 = 0

    for true {
        tick += 1
        // fmt.println("tick:", tick)
        time.sleep(250 * time.Millisecond)
    }
}

