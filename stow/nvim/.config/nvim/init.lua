-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
-- Function to handle auto-saving
local function auto_save()
  local opts = { silent = true, noremap = true }
  -- Check if the buffer is modifiable and not in a special filetype
  if vim.bo.modifiable and vim.bo.filetype ~= "TelescopePrompt" and vim.bo.filetype ~= "spectre_panel" then
    vim.cmd("silent! write")
    -- Optionally, display a message (commented out to reduce clutter)
    -- print("Auto-saved")
  end
end

-- Debounce timer to prevent excessive saving
local autosave_timer = vim.loop.new_timer()

-- Set up autocommands for events that should trigger auto-save
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = "*",
  callback = function()
    -- Start or reset the timer (e.g., 1000 ms delay)
    autosave_timer:start(1000, 0, vim.schedule_wrap(auto_save))
  end,
})

-- Optional: Clean up the timer on Vim exit
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    autosave_timer:stop()
    autosave_timer:close()
  end,
})
-- Ensure Comment.nvim is loaded
local comment_api = require("Comment.api")

-- Remap <leader>cc to toggle comment on the current line (normal mode) or selected lines (visual mode)
vim.keymap.set("n", "<leader>ck", function()
  comment_api.toggle.linewise.current()
end, { noremap = true, silent = true, desc = "Toggle comment on current line" })

vim.keymap.set(
  "v",
  "<leader>ck",
  "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
  { noremap = true, silent = true, desc = "Toggle comment on selected lines" }
)
local telescope = require("telescope.builtin")

-- Custom function to search only Swift files
function live_grep_swift()
  telescope.live_grep({
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "-t",
      "swift", -- Limit search to Swift files
    },
  })
end

-- Map it to a convenient keybinding
vim.api.nvim_set_keymap(
  "n",
  "<leader>fs",
  "<cmd>lua live_grep_swift()<CR>",
  { noremap = true, silent = true, desc = "search text in swift files" }
)

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- Custom function to search with a file type prompt
function live_grep_with_type_prompt()
  -- Run `rg --type-list` to get all supported file types
  local handle = io.popen("rg --type-list")
  local result = handle:read("*a")
  handle:close()

  -- Parse file types from rg output
  local types = {}
  for line in result:gmatch("[^\r\n]+") do
    local type_name = line:match("^(%w+):")
    if type_name then
      table.insert(types, type_name)
    end
  end

  -- Use Telescope picker to select a file type
  pickers
    .new({}, {
      prompt_title = "Select File Type",
      finder = finders.new_table({
        results = types,
      }),
      sorter = require("telescope.config").values.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            -- Run live_grep with the selected file type
            require("telescope.builtin").live_grep({
              vimgrep_arguments = {
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
                "-t",
                selection[1], -- Apply the selected file type filter
              },
            })
          end
        end)
        return true
      end,
    })
    :find()
end
-- Use Telescope to select a file type
vim.api.nvim_set_keymap(
  "n",
  "<leader>t",
  "<cmd>lua live_grep_with_type_prompt()<CR>",
  { noremap = true, silent = true, desc = "select type then ripgrep for on that type" }
)
