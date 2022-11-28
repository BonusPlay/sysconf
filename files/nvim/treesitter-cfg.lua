require('nvim-treesitter.configs').setup {
    ensure_installed = "maintained",
    -- Install languages synchronously (only applied to `ensure_installed`)
    sync_install = false,
    ignore_install = { "beancount", "clojure", "comment", "commonlisp", "dart", "devicetree", "elixir", "elm", "erlang", "fennel", "fish", "fortran", "gdscript", "glimmer", "haskell", "hcl", "julia", "ledger", "lua", "nix", "ocaml", "ocaml_interface", "ocamllex", "php", "ql", "r", "rst", "ruby", "scala", "sparql", "supercollider", "svelte", "swift", "teal", "turtle", "yang", "zig" },
    highlight = {
        enable = true,
        disable = {},
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
    ident = {
        enable = true
    }
}
