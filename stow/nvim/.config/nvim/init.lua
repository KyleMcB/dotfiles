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
