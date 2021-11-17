source "%val{config}/plugins/plug.kak/rc/plug.kak"

plug "andreyorst/plug.kak" noload

plug "godlygeek/tabular"

plug "andreyorst/fzf.kak" config %{
    map global normal <c-p> ": fzf-mode<ret>"
} defer "fzf" %{
    set-option global fzf_use_main_selection false
} defer "fzf-file" %{
    set-option global fzf_file_command "find . \( -path './.*' -o -path './build*' \) -prune -false -o -type f -print"
}

plug "andreyorst/smarttab.kak" defer smarttab %{
    # When `backspace' is pressed, 2 spaces are deleted at once.
    set-option global softtabstop 2
    set-option global indentwidth 2
} config %{
    # These languages will use `expandtab' behavior.
    hook global WinSetOption filetype=(rust|markdown|kak|lisp|scheme|janet|sh|ruby|html|eruby) expandtab
}

plug "eraserhd/parinfer-rust" do %{
    cargo install --force --path .
} config %{
    hook global WinSetOption filetype=(clojure|lisp|scheme|racket|janet) %{
        parinfer-enable-window -smart
    }
}

plug "kkga/ui.kak" config %{
    map global user -docstring "UI mode" u ": enter-user-mode ui<ret>"
    hook global WinCreate .* %{
        ui-matching-toggle
        ui-search-toggle
    }
}

plug "TeddyDD/kakoune-wiki" config %{
  wiki-setup %sh{ echo $HOME/wiki }
}

# Highlighters
add-highlighter global/ number-lines -relative
add-highlighter global/ column 80 default,black

# Always keep one line and three columns displayed around the cursor.
set-option global scrolloff 1,3

# Easier navigation for Colemak keyboard layout.
map global normal <backspace> h
map global normal <c-h> h
map global normal <c-n> j
map global normal <c-e> k
map global normal <tab> l

# Format selection with =
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
hook global NormalKey y|d|c %{ nop %sh{
    if [ -n "$DISPLAY" ]; then
        printf %s "$kak_main_reg_dquote" | xsel --input --clipboard
    elif [ -n "$TMUX" ]; then
        tmux set-buffer -- "$kak_main_reg_dquote"
    fi
}}

# Paste from the system clipboard
map global user P "!xsel --output --clipboard<ret>" -docstring "Paste before"
map global user p "<a-!>xsel --output --clipboard<ret>" -docstring "Paste after"

# Lint
hook global BufWritePost .+\.(rb|js|es6) %{
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
    set-option window lintcmd 'run() { cat "$1" | eslint -f unix --stdin --stdin-filename "$kak_buffile";} && run '
}

# Ruby
hook global WinSetOption filetype=ruby %{
    set-option window lintcmd 'rubocop --config .rubocop.yml'
}

# HTML and ERB
hook global WinSetOption filetype=(html|eruby) %{
    set-option buffer formatcmd "run(){ tidy -q --indent yes --indent-spaces 2 --wrap 1000 --show-body-only true 2>/dev/null || true; } && run"
    set-option window autowrap_column 80
}
