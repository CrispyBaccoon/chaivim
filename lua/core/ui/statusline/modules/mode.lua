local utils = require 'core.ui.statusline.utils'

return function()
  if not utils.is_activewin() then
    return
  end

  local m = utils.getmode()

  return m.label
end
