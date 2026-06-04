{
  lib,
  config,
  pkgs,
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
  };

  config = lib.mkIf cfg.enable {
    environment.sessionVariables = {EDITOR = "nvim";};

    programs.nvf = {
      enable = true;

      settings = {
        vim = {
          extraLuaFiles = [
            (pkgs.writeText "dashboard-banner.lua" ''
              local status, alpha = pcall(require, "alpha")
              if status then
                local dashboard = require("alpha.themes.dashboard")

                -- 1. Create your custom blue highlight group safely
                vim.api.nvim_set_hl(0, "AlphaBlueHeader", { fg = "#8aadf4" })

                local banner_placed = false

                -- 2. Modify dashboard elements dynamically
                for _, element in ipairs(dashboard.config.layout) do
                  if element.type == "text" then
                    if not banner_placed then
                      element.opts.hl = "AlphaBlueHeader"
                      element.val = {
                        "                                                                       ",
                        "                                                                     ",
                        "       ████ ██████           █████      ██                     ",
                        "      ███████████             █████                             ",
                        "      █████████ ███████████████████ ███   ███████████   ",
                        "     █████████  ███    █████████████ █████ ██████████████   ",
                        "    █████████ ██████████ █████████ █████ █████ ████ █████   ",
                        "  ███████████ ███    ███ █████████ █████ █████ ████ █████  ",
                        " ██████  █████████████████████ ████ █████ █████ ████ ██████ ",
                        "                                                                       ",
                      }
                      banner_placed = true
                    else
                      element.val = {}
                    end
                  end

                  -- 3. Filter buttons using legacy v2 character sets
                  if element.type == "group" then
                    -- SWAPPED: Using legacy symbols to ensure absolute fallback compatibility
                    local b1 = dashboard.button("e", "  New file", "<cmd>ene <BAR> startinsert <CR>")
                    local b2 = dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>")
                    local b3 = dashboard.button("q", "  Exit", "<cmd>qa<CR>")

                    b1.opts.hl_shortcut = "Number"
                    b2.opts.hl_shortcut = "Number"
                    b3.opts.hl_shortcut = "Number"

                    element.val = { b1, b2, b3 }
                  end
                end

                alpha.setup(dashboard.config)
              end
            '')
          ];

          theme = {
            enable = true;
            name = "catppuccin";
            style = "macchiato";
          };

          visuals = {
            nvim-web-devicons.enable = true;
            indent-blankline.enable = true;
          };

          statusline.lualine = {
            enable = true;
            theme = "auto";
          };

          dashboard.alpha = {
            enable = true;
            theme = "dashboard";
          };

          lsp = {
            enable = true;
            formatOnSave = true;
            trouble.enable = true;
          };

          autocomplete.nvim-cmp = {
            enable = true;
            sources = {
              buffer = "[Buffer]";
              path = "[Path]";
              nvim_lsp = "[LSP]";
              luasnip = "[Snippet]";
            };
          };

          debugger = {
            nvim-dap = {
              enable = true;
              ui.enable = true;
            };
          };

          languages = {
            enableTreesitter = true;
            enableFormat = true;
            enableDAP = true;

            clang = {
              enable = true;

              lsp.enable = true;
              lsp.servers = ["clangd"];

              treesitter.enable = true;
              dap.enable = true;
            };

            python = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
              dap.enable = true;
            };

            typescript = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };

            css = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };

            html = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };

            nix = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };

            markdown = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };

            glsl = {
              enable = true;
              treesitter.enable = true;
            };

            rust = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
              dap.enable = true;
            };

            go = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
              dap.enable = true;
            };
          };

          extraPackages = with pkgs; [
            # C / C++ / Rust
            lldb_19
            # Python
            python3Packages.debugpy
            # JS / TS
            vscode-js-debug # JavaScript/TypeScript Debugger
            # Go
            delve # Go Debugger
          ];

          luaConfigRC.dap-custom-adapters = ''
            local dap = require('dap')

            -- 🟢 JavaScript / TypeScript Adapter Routing
            -- This explicitly hooks NVF up to the package path provided by vscode-js-debug
            if not dap.adapters["pwa-node"] then
              dap.adapters["pwa-node"] = {
                type = "server",
                host = "localhost",
                port = "''${port}",
                executable = {
                  command = "js-debug-adapter", -- Provided cleanly by pkgs.vscode-js-debug
                  args = { "''${port}" },
                }
              }
            end

            -- 🟢 Lightweight, Native Lua Environment Debugging Setup
            -- Bypasses node-based debugger binaries entirely
            dap.adapters.nlua = function(callback, config)
              callback({ type = 'server', host = config.host or "127.0.0.1", port = config.port or 8086 })
            end

            dap.configurations.lua = {
              {
                type = 'nlua',
                request = 'attach',
                name = "Attach to running Neovim instance",
                host = function()
                  return vim.fn.input('Host: ') or "127.0.0.1"
                end,
                port = function()
                  return tonumber(vim.fn.input('Port [8086]: ')) or 8086
                end,
              },
            }
          '';

          telescope.enable = true;
          filetree.neo-tree.enable = true;
          tabline.nvimBufferline.enable = true;
          git.enable = true;

          viAlias = false;
          vimAlias = true;

          options.shiftwidth = 2;
          globals.mapleader = " ";
          options.timeoutlen = 500;

          maps = {
            normal = {
              "<leader>fg" = {
                action = ":Telescope find_files<CR>";
                silent = true;
                desc = "Telescope Find Files";
              };

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

              "qs" = {
                action = ":w | bp | bd #<CR>";
                silent = true;
                desc = "Saves and cloes the buffer tab(closes tab on tob bar)";
              };

              "gt" = {
                action = ":bprev<CR>";
                silent = true;
                desc = "moves to the next buffer with tab moving keys";
              };

              "g<S-t>" = {
                # g then capital T
                action = ":bnext<CR>";
                silent = true;
                desc = "moves to the next buffer with tab moving keys";
              };
            };

            terminal = {
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
