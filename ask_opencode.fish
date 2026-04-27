# Implement an `ask_opencode` function that queries OpenCode for shell commands based on a user prompt.
# by C Shen and Deepseek V4

set -q ASK_OPENCODE_MODEL; or set -g ASK_OPENCODE_MODEL "github-copilot/gpt-5-mini"
set -q ASK_OPENCODE_DEBUG; or set -g ASK_OPENCODE_DEBUG 0

function _ask_opencode_spinner --argument-names prompt
    set -l spinstr '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while true
        printf "\r%s Asking OpenCode for '$prompt'..." (string sub -l 1 $spinstr) > /dev/tty
        set spinstr (string sub -s 2 $spinstr)(string sub -l 1 $spinstr)
        sleep 0.1
    end
end

function ask_opencode
    set -l user_prompt (commandline)
    test -z "$user_prompt"; and return

    commandline -r ""
    commandline -f repaint

    _ask_opencode_spinner "$user_prompt" &
    set -l spinner_pid $last_pid

    set -l output (opencode run --model "$ASK_OPENCODE_MODEL" \
        "Generate the 3 simpliest shell commands to: $user_prompt
        Output format: command1\\0command2\\0command3
        Requirements:
        - Each command must be one line, no actual newlines
        - Separate with \\0 (backslash-zero)
        - Rank by best (speed/safety/reliability)
        - No explanations, code blocks, or markdown
        - Output only the commands" 2>&1)
    set -l exit_code $status

    kill $spinner_pid 2>/dev/null
    printf "\r\033[K" > /dev/tty

    if test $exit_code -ne 0
        echo "Error: $output" > /dev/tty
        commandline -f repaint
        return 1
    end

    if test "$ASK_OPENCODE_DEBUG" = 1
        echo "[ask_opencode] Raw output (NUL-separated):" > /dev/tty
        echo "$output" | tr '\0' '\n' | nl -ba > /dev/tty
    end

    set output (string replace -a \n '' $output)
    set output (string replace -a '\\0' \0 $output)
    set -l commands (string split \0 $output)

    if test "$ASK_OPENCODE_DEBUG" = 1
        echo "[ask_opencode] Parsed commands:" > /dev/tty
        printf '%s\n' $commands | nl -ba > /dev/tty
    end

    if test (count $commands) -eq 0
        echo "No commands generated" > /dev/tty
        commandline -f repaint
        return 1
    end

    set -l selected $commands[1]
    if type -q fzf
        set selected (printf '%s\n' $commands | \
            fzf --height=10% --reverse --prompt="$user_prompt > " --border)
        or begin
            commandline -r "$user_prompt"
            commandline -f repaint
            return 0
        end
    end

    commandline -r "$selected"
    commandline -f repaint
end

if status is-interactive
    bind \co ask_opencode
end
