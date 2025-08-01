source "%val{config}/plugins/plug.kak/rc/plug.kak"

plug "andreyorst/plug.kak" noload

plug "andreyorst/fzf.kak" config %{
    map global normal <c-p> ": fzf-mode<ret>"
} defer "fzf" %{
    set-option global fzf_use_main_selection false
} defer "fzf-file" %{
    set-option global fzf_file_command "find . \( -path './.*' -o -path './bin' -o -path './build*' -o -path './tmp' -o -path './node_modules' \) -prune -false -o -type f -print"
}

plug "andreyorst/smarttab.kak" defer smarttab %{
    # When `backspace' is pressed, 2 spaces are deleted at once.
    set-option global softtabstop 2
    set-option global indentwidth 2
} config %{
    # These languages will use `expandtab' behavior.
    hook global WinSetOption filetype=(fennel|rust|markdown|kak|lisp|scheme|janet|javascript|sh|ruby|html|eruby) expandtab

    hook global WinSetOption filetype=twig %{
      expandtab
      set-option global softtabstop 4
      set-option global indentwidth 4
    }
}

plug "catppuccin/kakoune" theme config %{
    colorscheme catppuccin_frappe
}

plug "Delapouite/kakoune-text-objects"

plug "eraserhd/parinfer-rust" do %{
    cargo install --force --path .
} config %{
    hook global WinSetOption filetype=(clojure|fennel|lisp|scheme|racket|janet) %{
        parinfer-enable-window -smart
    }
}

plug "kak-lsp/kak-lsp" do %{
    cargo install --locked --force --path .
    # optional: if you want to use specific language servers
    mkdir -p ~/.config/kak-lsp
    cp -n kak-lsp.toml ~/.config/kak-lsp/
} config %{
    # set g lsp_debug true
    map global user l %{:enter-user-mode lsp<ret>} -docstring "LSP mode"
    map global insert <tab> "<a-;>:try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <lt>tab> }<ret>" -docstring "Select next snippet placeholder"
    map global object a "<a-semicolon>lsp-object<ret>" -docstring "LSP any symbol"
    map global object <a-a> "<a-semicolon>lsp-object<ret>" -docstring "LSP any symbol"
    map global object e "<a-semicolon>lsp-object Function Method<ret>" -docstring "LSP function or method"
    map global object k "<a-semicolon>lsp-object Class Interface Struct<ret>" -docstring "LSP class interface or struct"
    map global object d "<a-semicolon>lsp-diagnostic-object --include-warnings<ret>" -docstring "LSP errors and warnings"
    map global object D "<a-semicolon>lsp-diagnostic-object<ret>" -docstring "LSP errors"
}

plug "kkga/ui.kak" config %{
    map global user -docstring "UI mode" u ": enter-user-mode ui<ret>"
    hook global WinCreate .* %{
        ui-git-diff-toggle
        ui-lint-toggle
        ui-matching-toggle
        ui-search-toggle
        ui-todos-toggle
    }
}

plug "occivink/kakoune-expand" config %{
  map global user e ": expand<ret>" -docstring "expand"

  # 'lock' mapping where pressing <space> repeatedly will expand the selection
  declare-user-mode expand
  map global expand <space> ": expand<ret>" -docstring "expand"
  map global user E ": expand; enter-user-mode -lock expand<ret>" -docstring "expand ↻"
}

plug "occivink/kakoune-vertical-selection" config %{
  map global user v     ": vertical-selection-down<ret>"        -docstring "Select down"
  map global user <a-v> ": vertical-selection-up<ret>"          -docstring "Select up"
  map global user V     ": vertical-selection-up-and-down<ret>" -docstring "Select up and down"
}

plug "TeddyDD/kakoune-wiki" config %{
  wiki-setup %sh{ echo $HOME/wiki }
}

# Highlighters
add-highlighter global/ number-lines -relative

hook global WinSetOption filetype=(ruby|javascript|markdown) %{
  add-highlighter buffer/ column 100 default,black
}

hook global WinSetOption filetype=(janet|fennel) %{
  add-highlighter buffer/ column 100 default,black
}

# Always reload files when changed externally.
set-option global autoreload true

# Always keep one line and three columns displayed around the cursor.
set-option global scrolloff 1,3

set-option global windowing_placement horizontal

# Easier navigation for Colemak keyboard layout.
map global normal <backspace> h
map global normal <c-h> h
map global normal <c-n> j
map global normal <c-e> k
map global normal <tab> l

# Case insensitive search
map global normal / /(?i)
map global normal <a-/> <a-/>(?i)

# Format selection with =
set-option global autowrap_column 100
map global normal = "|fmt -w $kak_opt_autowrap_column<ret>"

# Split horizontally
define-command -docstring "split [<commands>]: split tmux horizontally" \
split -params .. -command-completion %{
      tmux-terminal-vertical kak -c %val{session} -e "%arg{@}"
}

# Delete all unmodified buffers
map global user d ": evaluate-commands -buffer * delete-buffer<ret>" -docstring "Delete all buffers"

# Toggle comments
map global user c ": comment-line<ret>" -docstring "Toggle comments"

# Remove trailing whitespace
hook global BufWritePre .* %{ try %{ execute-keys -draft \%s\h+$<ret>d } }

# Copy to the system clipboard
hook global NormalKey y %{ nop %sh{
    if [ -n "$DISPLAY" ]; then
        printf %s "$kak_main_reg_dquote" | xsel --input --clipboard
    elif [ -n "$TMUX" ]; then
        tmux set-buffer -- "$kak_main_reg_dquote"
    fi
}}

# Paste from the system clipboard
map global user P "!xsel --output --clipboard<ret>" -docstring "Paste before"
map global user p "<a-!>xsel --output --clipboard<ret>" -docstring "Paste after"

# Skyspell
evaluate-commands %sh{
    skyspell-kak init
}

declare-user-mode skyspell
map global user s ": enter-user-mode skyspell<ret>" -docstring "Enter spell user mode"
map global skyspell d ": skyspell-disable<ret>" -docstring "Clear spelling highlighters"
map global skyspell e ": skyspell-enable en_US<ret>" -docstring "Enable spell checking in English"
map global skyspell l ": skyspell-list <ret>" -docstring "List spelling errors in a buffer"
map global skyspell h ": skyspell-help <ret>" -docstring "Show help message"
map global skyspell n ": skyspell-next<ret>" -docstring "Go to next spell error"
map global skyspell p ": skyspell-previous<ret>" -docstring "Go to previous spell error"
map global skyspell r ": skyspell-replace<ret>" -docstring "Suggest a list of replacements"

# Lint
hook global BufWritePost .+\.(js|es6|eruby) %{
    lint
}

# Tags
hook global KakBegin .* %{
    evaluate-commands %sh{
        path="$PWD"
        while [ "$path" != "$HOME" ] && [ "$path" != "/" ]; do
            if [ -e "./tags" ]; then
                printf "%s\n" "set-option -add current ctagsfiles %{$path/tags}"
                break
            else
                cd ..
                path="$PWD"
            fi
        done
    }
}

# JavaScript
hook global BufCreate .+\.(es6) %{
    set-option buffer filetype javascript
}
hook global WinSetOption filetype=javascript %{
    set-option window lintcmd 'standard'
}

# Ruby
hook global WinSetOption filetype=ruby %{
    lsp-enable-window

    set-option window lintcmd 'standardrb'
}

hook global WinSetOption filetype=eruby %{
    set-option window lintcmd 'erb_lint  --format compact'
}

# HTML and ERB
hook global WinSetOption filetype=(html|eruby) %{
    set-option buffer formatcmd "run(){ tidy -q --indent yes --indent-spaces 2 --wrap 1000 --show-body-only true 2>/dev/null || true; } && run"
}

# ChatGPT
map global user -docstring "Replace selection with ChatGPT's answer" g '<a-|>tee /tmp/chatgpt.txt<ret>| cat /tmp/chatgpt.txt | chatgpt -x<ret>'
map global user -docstring "Resample the last question with chatgpt" r '|cat /tmp/chatgpt.txt | chatgpt -x<ret>'
map global user -docstring "Ask chatgpt about the selection" q '<a-|>(tee /tmp/chatgpt.txt; echo "\nWhat is this?" >> /tmp/chatgpt.txt)<ret>:info -title "chatgpt" "%sh{cat /tmp/chatgpt.txt | chatgpt -x}"<ret>'
