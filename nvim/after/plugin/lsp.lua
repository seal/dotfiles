require("mason").setup {
    PATH = "append",
}
local lsp = require("lsp-zero")
local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
local lsp_format_on_save = function(bufnr)
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd('BufWritePre', {
        group = augroup,
        buffer = bufnr,
        callback = function()
            vim.lsp.buf.format()
            filter = function(client)
                return client.name == "null-ls"
            end
        end,
    })
end
lsp.preset("recommended")
require('mason').setup({})

local system_name = vim.loop.os_uname().sysname
local is_nixos = false
if system_name == "Linux" then
    local file = io.open("/etc/os-release", "r")
    if file then
        local content = file:read("*all")
        file:close()
        if string.find(content, "ID=nixos") then
            is_nixos = true
        end
    end
end

local ensure_installed = { 'tsserver', 'denols', 'gopls', 'volar' }
if not is_nixos then
    table.insert(ensure_installed, 'clangd')
    table.insert(ensure_installed, 'rust_analyzer')
    table.insert(ensure_installed, 'pyright')
    table.insert(ensure_installed, 'lua-ls')
    table.insert(ensure_installed, 'hls')
end

require('mason-lspconfig').setup({
    ensure_installed = ensure_installed,
    handlers = {
        lsp.default_setup,
    }
})
if is_nixos then
    require 'lspconfig'.clangd.setup {
        cmd = { "/run/current-system/sw/bin/clangd" },
    }
    require 'lspconfig'.pyright.setup {}
    require 'lspconfig'.rust_analyzer.setup {
        on_attach = function(client, bufnr)
            lsp.default_setup(client, bufnr)
            lsp_format_on_save(bufnr)
        end
    }
    require 'lspconfig'.lua_ls.setup {
        settings = {
            Lua = {
                diagnostics = {
                    globals = {
                        'vim',
                    },
                },
            },
        },
    }
    require 'lspconfig'.hls.setup {}
    require('lspconfig').gopls.setup({
        settings = {
            gopls = {
                gofumpt = true
            }
        }
    })
end
local prettier = require("prettier")

prettier.setup({
    bin = 'prettier', -- or `'prettierd'` (v0.23.3+)
    filetypes = {
        "css",
        "graphql",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "less",
        "markdown",
        "scss",
        "typescript",
        "typescriptreact",
        "yaml",
    },
})

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()
local nvim_lsp = require('lspconfig')
nvim_lsp.denols.setup {
    on_attach = on_attach,
    root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc"),
}
nvim_lsp.tsserver.setup {
    on_attach = on_attach,
    root_dir = nvim_lsp.util.root_pattern("package.json"),
    single_file_support = true,
}
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = {
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-i>'] = cmp.mapping.confirm({ select = true }),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
}

-- Remove Tab mappings
cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil
cmp.setup({
    mapping = cmp.mapping(cmp_mappings),
})

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }
    lsp_format_on_save(bufnr)
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "<C-o>", [[<Cmd>lua vim.cmd('normal! <C-O>')<CR>]], opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})
