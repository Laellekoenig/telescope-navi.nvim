local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local function get_session_lst()
    local handle = io.popen("navi --list")
    if handle == nil then
      return {}
    end
    local result = handle:read("*a")
    handle:close()

    local sessions = {}
    for session in result:gmatch("[^\r\n]+") do
        table.insert(sessions, session)
    end

    return sessions
end

local select_session = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Open TMUX Session",
    finder = finders.new_table {
      results = get_session_lst()
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        local handle = io.popen("navi --select " .. selection[1])
        if handle == nil then
          return {}
        end
        handle:close()
      end)
      return true
    end,
  }):find()
end

return require("telescope").register_extension {
  setup = function(ext_config, config)
  end,
	exports = {
    select_session = select_session,
	},
}
