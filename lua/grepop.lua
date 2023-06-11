-- main module file
local M = {}
M.config = {
  perform_keymaps = true,
  grep_op = "gs",
  grep_all_op = "gS",
}

-- Custom grep operator
local function grep_operator(t, searh_all, ...)
  local regsave = vim.fn.getreg("@")
  local selsave = vim.o.selection
  local selvalid = true

  vim.o.selection = "inclusive"

  if t == "v" or t == "V" then
    vim.api.nvim_command('silent execute "normal! gvy"')
  elseif t == "line" then
    vim.api.nvim_command("silent execute \"normal! '[V']y\"")
  elseif t == "char" then
    vim.api.nvim_command('silent execute "normal! `[v`]y"')
  else
    require("lib.log").error("Unsupported selection mode!")
    selvalid = false
  end

  vim.o.selection = selsave
  if selvalid then
    local query = vim.fn.getreg("@")
    local opts = { search = query }
    if searh_all == true then
      opts = { search = query, additional_args = { "--no-ignore-vcs", "--hidden" } }
    end
    require("telescope.builtin").grep_string(opts)
  end

  vim.fn.setreg("@", regsave)
end

-- setup is the public method to setup your plugin
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})

  if _G.telescope_grep_op == nil then
    _G.telescope_grep_op = function(t, ...)
      grep_operator(t, false, ...)
    end
  end

  if _G.telescope_grep_all_op == nil then
    _G.telescope_grep_all_op = function(t, ...)
      grep_operator(t, true, ...)
    end
  end

  if M.config.perform_keymaps then
    local mappings = {
      n = {
        [M.config.grep_op] = {
          function()
            vim.go.operatorfunc = "v:lua.telescope_grep_op"
            vim.api.nvim_feedkeys("g@", "n", false)
          end,
          "Grep Operator",
        },
        [M.config.grep_all_op] = {
          function()
            vim.go.operatorfunc = "v:lua.telescope_grep_all_op"
            vim.api.nvim_feedkeys("g@", "n", false)
          end,
          "Grep Operator (incl. ignored)",
        },
      },

      x = {
        [M.config.grep_op] = {
          ":<c-u>call v:lua.telescope_grep_op(visualmode())<CR>",
          "Grep Operator",
        },
        [M.config.grep_all_op] = {
          ":<c-u>call v:lua.telescope_grep_all_op(visualmode())<CR>",
          "Grep Operator (incl. ignored)",
        },
      },
    }

    for mode, mode_maps in pairs(mappings) do
      for lhs, rhs in pairs(mode_maps) do
        vim.keymap.set(mode, lhs, rhs[1], { desc = rhs[2] })
      end
    end
  end
end

return M
