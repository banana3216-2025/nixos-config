{
  lib,
  config,
  ...
}: let
  cfg = config.custom-modules.editors.nvf;
in {
  options.custom-modules.editors.nvf = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the nvf editor and settings for users.";
    };

    theme = lib.mkOption {
      type = lib.types.str;
      default = "onedark";
      description = "Set the color scheme for nvf.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nvf = {
      enable = true;
      # Your settings need to go into the settings attribute set
      # most settings are documented in the appendix
      settings = {
        vim = {
          # 1. Enable and configure the built-in theme
          theme = {
            enable = true;
            name = "catppuccin"; # Options: catppuccin, gruvbox, rose-pine, onedark, etc.
            style = "macchiato";
          };

          # 3. Add visual enhancements (optional)
          visuals = {
            nvim-web-devicons.enable = true;
            indent-blankline.enable = true;
          };

          # 2. Tell Status bars to match the active theme automatically
          statusline.lualine = {
            enable = true;
            theme = "auto";
          };

          lsp = {
            enable = true;
            formatOnSave = true; # Optional: auto-formats files when saving
            trouble.enable = true; # Optional: diagnostic split window
          };

          autocomplete.nvim-cmp = {
            enable = true;

            # Enables menu sources
            sources = {
              buffer = "[Buffer]"; # Suggests words from your open file
              path = "[Path]"; # Suggests file system paths as you type
              nvim_lsp = "[LSP]"; # Suggests functions/variables from your LSP
              luasnip = "[Snippet]"; # Suggests snippet templates
            };
          };

          languages = {
            enableTreesitter = true; # Manages real-time syntactic parsing and fast colors
            enableFormat = true; # If you want auto-formatting support on save

            # C and C++ (Uses clangd compiler engines)
            clang = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };

            # Python (Provisions Pyright/Ruff backends natively)
            python = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };

            # JavaScript / TypeScript (Wires up vtsls or tsserver bindings)
            typescript = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };

            # CSS (Feeds vscode-css-language-server strings)
            css = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };

            # HTML (Feeds vscode-html-language-server blocks)
            html = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };

            # Nix Language (Automatically pulls down 'nil' or 'nixd')
            nix = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };

            # Markdown (Documents parsing and render syntax layouts)
            markdown = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };

            # GLSL (OpenGL Shading Language syntax highlighting)
            glsl = {
              enable = true;
              treesitter.enable = true; # GLSL features deep treesitter structure maps
            };

            # Rust (Deploys rust-analyzer safely without rustup collision traps)
            rust = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };
          };

          # Plugins

          telescope.enable = true;
          filetree.neo-tree.enable = true;
          tabline.nvimBufferline.enable = true;
          git.enable = true;

          # Vim options
          viAlias = false;
          vimAlias = true;

          options.shiftwidth = 2;

          # keybind Remaps

          # Set leader key
          globals.mapleader = " ";

          maps = {
            normal = {
              "<leader>fg" = {
                action = ":Telescope find_files<CR>";
                silent = true;
                desc = "Telescope Find Files";
              };

              # Live grep search for text strings across all project files
              "<leader>ff" = {
                action = ":Telescope live_grep<CR>";
                silent = true;
                desc = "Telescope Live Grep";
              };

              "<C-a>" = {
                action = ":lua vim.lsp.buf.code_action()<CR>";
                silent = true;
                desc = "LSP: trigger code actions";
              };

              "<leader>aa" = {
                action = ":Neotree toggle<CR>";
                silent = true;
                desc = "Toggles Neo-Tree";
              };

              "<C-d>" = {
                action = "<C-d>zz";
                silent = true;
                desc = "Scrolls down but keeps cursor in center";
              };

              "<C-b>" = {
                action = "<C-b>zz";
                silent = true;
                desc = "Scrolls up but keeps cursor in center";
              };
            };

            terminal = {
              # Choose ONE of the common variations below:

              # Option A: Map 'jk' to escape terminal (Highly recommended)
              "<Esc>" = {
                action = "<C-\\><C-n>";
                silent = true;
                desc = "Escape terminal mode";
              };
            };
          };
        };
      };
    };
  };
}
