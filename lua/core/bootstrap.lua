local Util = require 'core.utils'

---@type { [string]: { load: function, update: function } }
local fn = {
  keymaps = {
    load = function()
      local keymapspath = core.path.keymaps

      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/crispybaccoon/keymaps.nvim.git",
        keymapspath,
      })

      local ok, keymaps_nvim = pcall(R, 'keymaps')
      if not ok then
        return false
      end
      return keymaps_nvim
    end,
    update = function()
      local keymapspath = core.path.keymaps

      vim.system({
        "git",
        "pull",
      }, { cwd = keymapspath }, function(obj)
        if obj.code > 0 then
          Util.log('error while updating keymaps at ' .. keymapspath ..
            '\n\t' .. obj.stdout .. '\n\t' .. obj.stderr, 'error')
          return
        end
        Util.log('succesfully updated keymaps', 'info')
      end)
    end,
  },
}

---@param name string
---@param props string
---@return function|nil
local function _get(name, props)
  local _fn = fn[name]
  if not _fn or not _fn[props] then
    Util.log('no bootstrap functions found for: ' .. name, 'error')
    return
  end
  return _fn[props]
end

return {
  load = function(props)
    local _fn = _get(props, 'load')
    if _fn then
      _fn()
    end
  end,
  update = function(props)
    local _fn = _get(props, 'update')
    if _fn then
      _fn()
    end
  end,
}
