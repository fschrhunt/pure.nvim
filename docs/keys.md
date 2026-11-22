# Keys

pure.nvim keeps very few keys of its own. Everyday actions are on Space, everything else is in the
command palette, and the rest are Neovim's own keys, which work the same as in any tutorial.

Lost? Press `Space p` and type what you want to do, or press Space and pause to see every Space
key. Everyday actions are also [commands](commands.md), like `:back` and `:find`.

## Space keys

| Key | Action |
| --- | --- |
| `Space p` | Command palette: every action, with its key |
| `Space f` | Find a file |
| `Space /` | Search text in the project, exactly as typed; capitals make it match case |
| `Space r` | Recent files: open files first, then the ones you had open before |
| `Space d` | Show problems |
| `Space w` | Save |
| `Space q` | Close what you're looking at: the split if the screen is split, otherwise the file (asking before discarding changes) |
| `Space -` | Split below |
| `Space +` | Split right |
| `Space ?` | Search Neovim's help |
| `Space [` | Go back to the previous place: a file, or a folder in the explorer |
| `Space ]` | Go forward again |

Palette only: new file, save all, copy file path, open a terminal, format the file,
git changes, undo history, compare files, toggles for wrap, line numbers and spell check, edit the
config, update plugins, and restart or quit Neovim.

## Getting around

`Space [` and `Space ]` work like a browser's back and forward buttons. They step through the
places you've been: files, and folders in the file explorer. Open a file from the explorer, and
`Space [` takes you back to that folder with the file selected. Going somewhere new after going
back drops the forward history.

Moves inside a file, like searching or going to a definition, aren't places. Neovim's own
`Ctrl-o` and `Ctrl-i` step back and forward through those.

| Key | Does |
| --- | --- |
| `gg` / `G` | Top / bottom of the file |
| `Ctrl-d` / `Ctrl-u` | Half a page down / up |
| `%` | Jump to the matching bracket |
| `/text`, then `n` / `N` | Search, then next / previous match |
| `*` | Search for the word under the cursor |
| `Esc` | Clear the search highlight |
| `Ctrl-w` then `h` `j` `k` `l` | Move between split windows |

## Editing

| Key | Does |
| --- | --- |
| `i` / `a` / `o` | Insert before the cursor / after it / on a new line below |
| `u` / `Ctrl-r` | Undo / redo (undo survives closing the file) |
| `.` | Repeat the last change |
| `ciw` / `ci"` / `di(` | Change a word / change inside quotes / empty the parentheses |
| `gcc` / `gc` | Comment a line / a selection |
| `v` then `an` / `in` | Grow / shrink a selection by code structure |
| `zc` / `zo` | Close / open a fold |
| `:%s/old/new/gc` | Replace across the file, confirming each |

Copying (`y`) also copies to the system clipboard. Paste from the system with `Cmd-V`.

## Code

These work once a language server is running for the file; see [languages](languages.md). Press
`g` and pause to see them listed, along with comment (`gc`) and open link (`gx`).

| Key | Does |
| --- | --- |
| `Ctrl-]` | Go to definition |
| `K` | Show docs for what's under the cursor |
| `grr` | Find references |
| `grn` | Rename everywhere |
| `gra` | Code actions |
| `gO` | Outline of the file |
| `]d` / `[d` | Next / previous problem |
| `]h` / `[h` | Next / previous git change |

Suggestions appear while typing. `Tab` and `Shift-Tab` move through them (or through snippet
fields) and `Enter` accepts one, which also adds any import it needs.

## Toasts

When something asks a question, like installing a missing language server, a toast appears in
the bottom-right corner with Yes and No buttons. Press `Space y` or `Space n`, or click a button.
It doesn't take the cursor, so you can keep typing, and it stays until you answer. After Yes, the
same toast shows the progress and then the result, and closes on its own. The next question
waits until it's gone, and the toast moves up out of the way of Neovim's own messages.

## In a terminal

"Open terminal" in the palette opens a shell in a split below. `Esc` twice returns to Neovim
(a single `Esc` still reaches the program running there), and `Space q` closes it.

Panels show the Space key as the spacebar icon `󱁐` (it needs a Nerd Font).

## In a palette

Every list you pick from is a palette: the command palette (`Space p`), and the ones behind
`Space f`, `/`, `r`, `d`, `?`, and Neovim's own "pick one" menus, like code actions. The counter in
its corner reads matches - total.

| Key | Does |
| --- | --- |
| Type | Narrow the list (fuzzy) |
| `↑` `↓` | Move |
| `Enter` | Open or run |
| `Ctrl-v` / `Ctrl-s` | Open in a split right / below |
| `Esc` | Close |

## In the file explorer

The explorer (`:explore`, or "Browse folder" in the palette) opens on the current file, with its
folder on the left and a preview on the right. `Space [` from a file you opened here comes back to
it. The columns grow with the window: the current folder takes about a third of it.

| Key | Does |
| --- | --- |
| `]` / `[` | Forward into a folder / back out of it |
| `Enter` | Open the file full screen |
| `Esc` | Close |
| `=` | Apply edits: rename by editing a name, create by adding a line, delete by removing one |
| `g?` | Show every explorer key |

Deleted files go to a trash folder in Neovim's data directory, not straight to permanent deletion.
