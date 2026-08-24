package main

import "core:fmt"
import "core:os"
import "core:time"
import "core:strings"
import "core:strconv"

import "globals"
import "ui"

parse_time :: proc (text: string) {
    components := strings.split(text, ":")

    h, m, s : i64 = 0, 0, 0

    for c in components {
        if len(c) > 2 {
            fmt.eprintln("ERROR: Invalid arguments!\n")
            print_help()
            os.exit(1)
        }
    }

    ok : bool

    switch len(components) {
        case 1:
            m, ok = strconv.parse_i64(components[0])

            if !ok || m > 60 || m < 0 {
                fmt.eprintln("ERROR: Invalid arguments!\n")
                print_help()
                os.exit(1)
            }

        case 2:
            h, ok = strconv.parse_i64(components[0])

            if !ok || h > 24 || h < 0 {
                fmt.eprintln("ERROR: Invalid arguments!\n")
                print_help()
                os.exit(1)
            }

            m, ok = strconv.parse_i64(components[1])

            if !ok || m > 60 || m < 0 {
                fmt.eprintln("ERROR: Invalid arguments!\n")
                print_help()
                os.exit(1)
            }

        case 3:
            h, ok = strconv.parse_i64(components[0])

            if !ok || h > 24 || h < 0 {
                fmt.eprintln("ERROR: Invalid arguments!\n")
                print_help()
                os.exit(1)
            }

            m, ok = strconv.parse_i64(components[1])

            if !ok || m > 60 || m < 0 {
                fmt.eprintln("ERROR: Invalid arguments!\n")
                print_help()
                os.exit(1)
            }

            s, ok = strconv.parse_i64(components[2])

            if !ok || s > 60 || s < 0 {
                fmt.eprintln("ERROR: Invalid arguments!\n")
                print_help()
                os.exit(1)
            }

        case:
            fmt.eprintln("ERROR: Invalid arguments!\n")
            print_help()
            os.exit(1)
    }

    duration : time.Duration = 0

    if h != 0 {
        duration += cast(time.Duration) h * time.Hour
    }

    if m != 0 {
        duration += cast(time.Duration) m * time.Minute
    }

    if s != 0 {
        duration += cast(time.Duration) s * time.Second
    }

    globals.initial_timer = duration
    ui.state.timer.remaining_duration = duration
}

parse_args :: proc () {
    switch len(os.args) {
        case 1: return
        case 2:
            if os.args[1][0] == '-' {
                switch os.args[1] {
                    case "-h", "--help":
                        print_help()
                        os.exit(0)
                    case "-v", "--version":
                        print_version()
                        os.exit(0)
                    case:
                        fmt.eprintln("Invalid arguments!\n")
                        print_help()
                        os.exit(1)
                }
            } else {
                parse_time(os.args[1])
            }
        case: 
            fmt.eprintln("ERROR: Invalid arguments!\n")
            print_help()
            os.exit(1)
    }
}

print_help :: proc () {
    fmt.println(version_str())
    fmt.println("\nDESCRIPTION")
    fmt.println("  Minimal focus and productivity tool.")
    fmt.println("\nUSAGE")
    fmt.println("  .\\fokus.exe")
    fmt.println("                     Starts with default time (30 minutes).")
    fmt.println("  .\\fokus.exe TIME")
    fmt.println("                     Starts with TIME.")
    fmt.println("\nTIME")
    fmt.println("  Passing a single number sets minutes:")
    fmt.println("    .\\fokus.exe 25")
    fmt.println("  You can set hour and minute as:")
    fmt.println("    .\\focus.exe 1:15")
    fmt.println("  Passing argument as `##:##:##` also sets seconds:")
    fmt.println("    .\\focus.exe 00:29:30")
    fmt.println("  Or:")
    fmt.println("    .\\focus.exe 01:05:45")
    fmt.println("  Or:")
    fmt.println("    .\\focus.exe 00:00:55")
    fmt.println("\nFLAGS")
    fmt.println("  -h, --help     Shows this help menu.")
    fmt.println("  -v, --version  Shows the app version.")
}

print_version :: proc () {
    fmt.println(version_str())
}

version_str :: proc () -> string {
    return fmt.tprintf(
        "fokus v%v.%v.%v",
        globals.APP_VERSION_MAJOR,
        globals.APP_VERSION_MINOR,
        globals.APP_VERSION_PATCH,
    )
}

