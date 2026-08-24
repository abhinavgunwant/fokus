# fokus

Focus and productivity tool.

**Note:** Work in progress!

## Running

### Windows Intel/AMD 64-bit
Visit releases page or [click here](https://github.com/abhinavgunwant/fokus/releases/download/v0.1.1/fokus-windows-x64.exe) to download the executable.

Just double click the executable to run.

## Building and running

If your OS is not supported or you want to play with this code, you can easily
build this app.

Make sure you have [odin](https://odin-lang.org/docs/install/) installed.

Execute the following commands:
```bash
odin build .
```

This creates an executable which you can execute.

Alternatively you can build and execute with this single command:
```bash
odin run .
```

## Command-line arguments

You can set the timer duration using command line arguments.

- Passing a single number sets minutes:
    ```powershell
    .\fokus.exe 25
    ```
- You can set hour and minute as:
    ```powershell
    .\focus.exe 1:15
    ```
- Passing argument in `##:##:##` format also sets seconds:
    ```powershell
    .\focus.exe 00:29:30
    ```
    Or:
    ```powershell
    .\focus.exe 01:05:45
    ```
    Or:
    ```powershell
    .\focus.exe 00:00:55
    ```
- Any other type of argument input is invalid except:
  - `-h`, `--help`: shows the help menu.
  - `-v`, `--version`: shows the app version.

