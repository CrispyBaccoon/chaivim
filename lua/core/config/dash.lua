return {
  setup = function(opts)
    require 'core.plugin.command'.create {
      name = 'Dash', fn = function(_)
        require 'core.plugin.dash'.open(core.modules.core.dash.opts)
      end,
    }
    if opts.open_on_startup then
      vim.defer_fn(function()
        local buf_lines = vim.api.nvim_buf_get_lines(0, 0, 1, false)
        local no_buf_content = vim.api.nvim_buf_line_count(0) == 1 and buf_lines[1] == ""
        local bufname = vim.api.nvim_buf_get_name(0)

        if bufname == "" and no_buf_content then
          require 'core.plugin.dash'.open(opts)
        end
      end, 0)
    end
  end
}
