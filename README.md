# ask-opencode.fish

Shell plugin that generates shell commands from natural language prompts using the `opencode` CLI.

Type a prompt, press `Ctrl+O`, and your buffer is replaced with a generated shell command.

## Author

C Shen

## Installation

### Fish

```fish
# Set the model to use for command generation (optional, defaults to "github-copilot/gpt-5-mini")
# suggestions: [ "deepseek-v4-pro", "deepseek-v4-flash" ],
set -gx ASK_OPENCODE_MODEL "deepseek/deepseek-v4-flash"
source ask_opencode.fish
```


To make it permanent, copy or symlink into your Fish config:

```fish
cp ask_opencode.fish ~/.config/fish/conf.d/ask_opencode.fish
```

## Usage

1. Type a natural language prompt at your shell prompt (e.g., `find all PDFs modified this week`)
2. Press `Ctrl+O`
3. A spinner shows while `opencode` processes the prompt
4. If multiple commands are generated:
   - With `fzf`: select from the list interactively
   - Without `fzf`: the first (best) command is used automatically
5. The selected command replaces your prompt — press Enter to run or edit further

## Configuration

| Variable | Default | Description |
|---|---|---|
| `ASK_OPENCODE_MODEL` | `github-copilot/gpt-5-mini` | Model passed to `opencode run --model` |
| `ASK_OPENCODE_DEBUG` | `0` | When `1`, dumps raw and parsed output to `/dev/tty` |

Set in Fish:

```fish
set -g ASK_OPENCODE_MODEL "your-model-here"
set -g ASK_OPENCODE_DEBUG 1
```

## Requirements

- [`opencode`](https://github.com/sst/opencode) CLI
- `fzf` (optional, for interactive command selection)

## License

MIT
