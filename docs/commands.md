# Commands

Everyday actions are also plain-word commands: type `:` and the word. They match the command
palette and the Space keys, so each action has one name everywhere. The palette shows every
action's command next to its key.

## The commands

| Command | Does | Key |
| --- | --- | --- |
| `:back` or `:b` | Go back to the previous place: a file, or a folder in the explorer | `Space [` |
| `:forward` or `:f` | Go forward again | `Space ]` |
| `:find` | Find a file | `Space f` |
| `:recent` | Recent files | `Space r` |
| `:search` | Search text in the project | `Space /` |
| `:explore` | Browse the current file's folder | |
| `:close` | Close what you're looking at: the split, or the file | `Space q` |
| `:problems` | Show problems | `Space d` |
| `:palette` | Command palette | `Space p` |
| `:format` | Format the file | |
| `:install` | Install the language server this file is missing; `:install rust` installs or updates one by name | |
| `:rename` | Rename the symbol under the cursor | `grn` |
| `:actions` | Code actions | `gra` |
| `:references` | Find references | `grr` |
| `:outline` | Outline of the file | `gO` |
| `:compare` | Compare two files or folders | |
| `:config` | Edit this config | |

Neovim's own commands still work as usual: `:w` (save), `:q` (quit), `:wq`, `:e file`,
`:%s/old/new/g`, and `:help`.

## Replaced built-ins

A few words already meant something in Neovim and now run the action above instead:

| Command | Neovim's meaning | Use instead |
| --- | --- | --- |
| `:b` | Switch to an open buffer | `:recent` lists open files first |
| `:f` | Show the file name | The tab title shows it |
| `:find` | Find a file on `'path'` | Same idea, in a palette |
| `:close` | Close the window | Same, and closes the file when there's one window |

The long forms of Neovim's commands, like `:buffer` and `:file`, are untouched.

## How it works

Neovim only allows commands of your own to start with a capital letter, so each one is defined as
`:Back`, `:Find`, and so on, and the lowercase word expands to it. It expands only when the word
is the whole command, so `b` or `f` inside a longer command is left alone.

To give an action a command, add `cmd = 'word'` (and optionally `short = 'x'`) to its line in
`lua/pure/actions.lua`. Pick a word Neovim doesn't already use, or list it under replaced
built-ins.
