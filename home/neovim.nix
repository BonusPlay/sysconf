{ config, pkgs, lib, ... }:
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    luaLoader.enable = true;

    globals = {
      # Disable useless providers
      loaded_ruby_provider = 0;   # Ruby
      loaded_perl_provider = 0;   # Perl
      loaded_python_provider = 0; # Python 2

      # the star of the show
      mapleader = " ";
      maplocalleader = " ";
    };

    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    keymaps = let
      keys = lib.mapAttrsToList (key: action: {
        inherit action key;
      })
      {
        "<Space>" = "<NOP>";
        "<esc>" = ":noh<CR>";

        # tab movement
        "<C-Right>"=  "<C-W>l";
        "<C-Left>" = "<C-W>h";
        "<C-Up>" = "<C-W>k";
        "<C-Down>" = "<C-W>j";

        # resize splits
        "<C-S-Left>" = ":vertical resize +1<cr>";
        "<C-S-Right>" = ":vertical resize -1<cr>";

        # clipboard
        "<leader>y" = "+y";
        "<leader>p" = "+p";
      };
    in config.lib.nixvim.keymaps.mkKeymaps
      {options.silent = true;}
      keys;

    opts = {
      # Faster completion
      updatetime = 100;

      # Relative line numbers
      relativenumber = true;

      # Display the absolute line number of the current line
      number = true;

      # A new window is put below the current one
      splitbelow = true;

      # A new window is put right of the current one
      splitright = true;

      # Disable the swap file
      swapfile = false;
      backup = false;
      wb = false;

      # undo is helpful
      undofile = true;
      undodir = "/home/bonus/.cache/nvim/undo";

      # ignore case while searching
      ignorecase = true;
      # Override the 'ignorecase' option if the search pattern contains upper
      smartcase = true;

      # show whitespace stuff
      list = true;
      listchars = "eol:↵,nbsp:_,tab:>-,trail:~,extends:>,precedes:<";

      # bottom bar height
      cmdheight = 2;

      # disable audio/visual bells
      errorbells = false;
      visualbell = false;

      # more width for fold column
      foldcolumn = "auto";

      # nicer view
      wrap = false;
      encoding = "UTF8";
      fileencoding = "utf-8"; # File-content encoding for the current buffer
      termguicolors = true; # Enables 24-bit RGB color in the |TUI|

      # Highlight spelling mistakes (local to window)
      spell = true;

      # Tab options
      tabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      autoindent = true;
      smartindent = true;
    };

    colorschemes.nightfox = {
      enable = true;
      flavor = "carbonfox";
    };

    plugins = {
      treesitter = {
        enable = true;
        # https://github.com/nix-community/nixvim/commit/97fa47376b73d774b081c8e5dd54fcfd0ad278cb
        settings = {
          # Install languages synchronously (only applied to `ensure_installed`)
          sync_install = true;

          # who does these
          ignore_install = [ "beancount" "clojure" "comment" "commonlisp" "dart" "devicetree" "elixir" "elm" "erlang" "fennel" "fish" "fortran" "glimmer" "haskell" "hcl" "julia" "ledger" "ocaml" "ocaml_interface" "ocamllex" "php" "ql" "r" "rst" "ruby" "scala" "sparql" "supercollider" "svelte" "swift" "teal" "turtle" "yang" ];

          highlight = {
            enable = true;
            additional_vim_regex_highlighting = true;
          };
        };
      };

      coq-nvim.enable = true;
      web-devicons.enable = true;

      lsp = {
        enable = true;
        servers = {
          clangd.enable = true;
          cmake.enable = true;
          gopls.enable = true;
          html.enable = true;
          pyright.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
          ts_ls.enable = true;
          volar.enable = true;
          zls.enable = true;
        };
        keymaps = {
          diagnostic = {
            "<leader>b" = "goto_prev";
            "<leader>n" = "goto_next";
          };
          lspBuf = {
            gd = "definition";
            gD = "references";
            gt = "type_definition";
            gi = "implementation";
            "<C-Space>" = "hover";
            "<F2>" = "rename";
          };
        };
      };

      telescope = {
        enable = true;
        keymaps = {
          "<C-F><C-F>" = "find_files";
          "<C-F><C-G>" = "live_grep";
          "<C-F><C-D>" = "diagnostics";
        };
      };

      lualine.enable = true;

      indent-blankline.enable = true;

      comment.enable = true;

      zig.enable = true;
    };
  };
}
