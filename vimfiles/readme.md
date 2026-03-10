# vimrc Reference

## Global Keybindings

| Key | Action |
|-----|--------|
| `Alt+m` | Find project root (walks up dirs for build.bat / make) and build |
| `Ctrl+Right` | Move forward one word |
| `Ctrl+Left` | Move backward one word |
| `Ctrl+Up` | Jump to previous blank line |
| `Ctrl+Down` | Jump to next blank line |
| `Home` | Jump to first non-whitespace character on line |
| `End` | Jump to end of line |
| `PageUp` | Scroll forward one page |
| `PageDown` | Scroll backward one page |
| `Ctrl+PageDown` | Scroll other window down |
| `Ctrl+PageUp` | Scroll other window up |
| `ScrollWheelUp` | Scroll up 15 lines |
| `ScrollWheelDown` | Scroll down 15 lines |
| `Middle Mouse` | Disabled (no accidental paste) |

---

## C / C++ Keybindings
These are only active when editing a `.c`, `.cpp`, `.h`, `.hin`, or `.cin` file.

| Key | Action |
|-----|--------|
| `F12` | Open corresponding file (e.g. `foo.cpp` <-> `foo.h`) in same window |
| `Alt+c` | Open corresponding file in same window |
| `Alt+C` | Open corresponding file in other window |
| `Alt+F12` | Open corresponding file in other window |
| `Alt+s` | Save buffer (converts tabs to spaces first) |
| `Alt+j` | Jump to tag / symbol definition |
| `Alt+.` | Reformat / fill current paragraph |
| `Alt+/` | Select current function body |
| `Alt+a` | Paste and auto-indent pasted region |
| `Alt+z` | Delete (cut) selected text |
| `Tab` | Autocomplete word (searches open buffers) |
| `Shift+Tab` | Insert a real tab character |
| `Enter` | Newline with auto-indent |

---

## Ex Commands

| Command | Action |
|---------|--------|
| `:call LockCompilationDirectory()` | Lock the build directory so Alt+m always builds from the same place |
| `:call UnlockCompilationDirectory()` | Unlock the build directory so Alt+m hunts for build.bat on each build |

---

## Keyword Highlighting
The following words are highlighted in C, C++, and Vim files:

| Keyword | Color |
|---------|-------|
| `TODO` | Red |
| `STUDY` | Yellow |
| `IMPORTANT` | Yellow |
| `NOTE` | Dark Green |

---

## File Types
These extensions are automatically treated as C++:

`.cpp` `.h` `.c` `.cc` `.hin` `.cin` `.inl` `.rdc` `.c8`

Other associations: `.txt` (text), `.m` / `.mm` (Objective-C), `.ms` (fundamental).

---

## Build System
`Alt+m` walks up the directory tree from the current file looking for `build.bat`
(on Windows) or a `Makefile` (on Linux/Mac). Once found, it runs the build script
from that directory. The build directory can be locked/unlocked with the ex commands
above so repeated builds always target the same location.

---

## Header Guards
Opening a new `.h` file automatically inserts an include guard:
```c
#if !defined(FILENAME_H)

#define FILENAME_H
#endif
```

---

## Theme
Uses the **compline** colorscheme — a dark, desaturated theme inspired by the quiet
of compline. Place `compline.vim` in `C:\Users\<you>\vimfiles\colors\` on Windows.

Here's a readme section you can add:

---

## Adding a New Language

To add a new filetype, find this block in your vimrc:

```vim
augroup jeremy_filetypes
  autocmd!
  autocmd BufNewFile,BufRead *.cpp,*.hin,*.cin,*.inl,*.rdc,*.h,*.c,*.cc,*.c8
    \ setfiletype cpp
  autocmd BufNewFile,BufRead *.txt  setfiletype text
  autocmd BufNewFile,BufRead *.ms   setfiletype fundamental
  autocmd BufNewFile,BufRead *.m,*.mm setfiletype objc
augroup END
```

Add a new line for your language. For example, to add C#:

```vim
  autocmd BufNewFile,BufRead *.cs  setfiletype cs
```

The format is always:
```vim
  autocmd BufNewFile,BufRead *.<extension>  setfiletype <vimfiletype>
```

Common Vim filetype names you might need:

| Language | Extension | Vim filetype |
|----------|-----------|--------------|
| C# | `.cs` | `cs` |
| Python | `.py` | `python` |
| Rust | `.rs` | `rust` |
| Go | `.go` | `go` |
| JavaScript | `.js` | `javascript` |
| TypeScript | `.ts` | `typescript` |

You can find the full list of built-in Vim filetypes by running `:help filetypes` inside gVim.
