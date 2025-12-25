return {
  -- Mason core
  { "williamboman/mason.nvim", config = true },

  -- Mason LSP installer
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls",
          "eslint",
          "html",
          "cssls",
          "jsonls",
          "tailwindcss",
        },
      })
    end,
  },

  -- Completion + snippets
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      vim.opt.completeopt = { "menu", "menuone", "noselect" }

      cmp.setup({
        preselect = "item",
        completion = { completeopt = "menu,menuone,noinsert" },
        window = { documentation = cmp.config.window.bordered() },
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        sources = {
          { name = "path" },
          { name = "nvim_lsp" },
          { name = "buffer", keyword_length = 3 },
          { name = "luasnip", keyword_length = 2 },
        },
        formatting = {
          fields = { "abbr", "kind", "menu" },
          format = function(entry, item)
            item.menu = "[" .. entry.source.name .. "]"
            return item
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fb)
            if cmp.visible() then cmp.select_next_item() 
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fb() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fb)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fb() end
          end, { "i", "s" }),
          ["<C-f>"] = cmp.mapping.scroll_docs(5),
          ["<C-u>"] = cmp.mapping.scroll_docs(-5),
          ["<C-e>"] = cmp.mapping(function(fb)
            if cmp.visible() then cmp.abort() else cmp.complete() end
          end),
        }),
      })
    end,
  },

  -- Modern Neovim 0.11+ LSP registration (NO lspconfig usage)
  {
    "native-lsp-servers",
    dir = vim.fn.stdpath("config"), -- dummy holder
    config = function()
      local servers = {
        tsserver = {},
        eslint = {
          settings = {
            workingDirectory = { mode = "auto" },
          },
        },
        html = {},
        cssls = {},
        jsonls = {},
        tailwindcss = {},
      }

      -- Register servers using the new API
      for name, opts in pairs(servers) do
        vim.lsp.config(name, {
          root_markers = { "package.json", ".git", "tsconfig.json", "jsconfig.json", "tailwind.config.js" },
          settings = opts.settings,
          filetypes = opts.filetypes,
          init_options = opts.init_options,
        })
      end

      -- Auto enable when opening web dev files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "html", "css", "json" },
        callback = function(ev)
          for server, _ in pairs(servers) do
            if not vim.lsp.get_clients({ bufnr = ev.buf, name = server })[1] then
              vim.lsp.enable(server, { bufnr = ev.buf })
            end
          end
        end,
      })

      -- UI tweaks
      vim.lsp.handlers["textDocument/hover"] =
        vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = "rounded" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "✘",
            [vim.diagnostic.severity.WARN]  = "▲",
            [vim.diagnostic.severity.INFO]  = "»",
            [vim.diagnostic.severity.HINT]  = "⚑",
          },
        },
      })

      -- Keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(e)
          local o = { buffer = e.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, o)
          vim.keymap.set("n", "K",  vim.lsp.buf.hover, o)
          vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, o)
          vim.keymap.set("n", "<F4>", vim.lsp.buf.code_action, o)
          vim.keymap.set("n", "gl", vim.diagnostic.open_float, o)
        end,
      })

      -- Auto-format on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.js,*.ts,*.jsx,*.tsx,*.html,*.css,*.json",
        callback = function(ev)
          vim.lsp.format({ bufnr = ev.buf })
        end,
      })
    end,
  },
}
