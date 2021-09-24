source "%val{config}/plugins/plug.kak/rc/plug.kak"

plug "andreyorst/plug.kak" noload

plug "godlygeek/tabular"

plug "andreyorst/fzf.kak" config %{
    map global normal <c-p> ': fzf-mode<ret>'
} defer "fzf-file" %{
    set-option global fzf_file_command "find . \( -path './.*' -o -path './build*' \) -prune -false -o -type f -print"
}

plug "andreyorst/smarttab.kak" defer smarttab %{
    # When `backspace' is pressed, 2 spaces are deleted at once.
    set-option global softtabstop 2
    set-option global indentwidth 2
} config %{
    # These languages will use `expandtab' behavior.
    hook global WinSetOption filetype=(rust|markdown|kak|lisp|scheme|sh|ruby) expandtab
}

add-highlighter global/ number-lines -relative

# Map leader to <space>
# map global normal <space> , -docstring "leader"

# Easier navigation for Colemak keyboard layout.
map global normal <c-n> h
map global normal <c-e> j
map global normal <c-u> k
map global normal <tab> l

# Remove trailing whitespace.
hook global BufWritePre .* %{ try %{ execute-keys -draft \%s\h+$<ret>d } }

# Lint
hook global BufWritePost .+\.(rb) %{
    lint
}

# JavaScript
hook global BufCreate .+\.(es6) %{
    set-option buffer filetype javascript
}

# Ruby
hook global WinSetOption filetype=ruby %{
    set-option window lintcmd 'rubocop --config .rubocop.yml'
}

# HTML and ERB
hook global WinSetOption filetype=(html|eruby) %{
    set-option buffer formatcmd "run(){ tidy -q --indent yes --indent-spaces 2 --wrap 1000 2>/dev/null || true; } && run"
}
