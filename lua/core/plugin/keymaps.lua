local Util = require 'core.utils'

_G.Keymap = _G.Keymap or {}

_G.Keymap.group = _G.Keymap.group or function(props)
  if not props.group then
    Util.log('globals.keymap', '`Keymap.group` requires `group` field', 'warn')
    return
  end
  local mappings = props[1] or {}
  if #props > 1 then
    mappings = props
  end
  for _, map in ipairs(mappings) do
    if #map < 4 then
      Util.log('globals.keymap', '`Keymap.group` requires 4 paramaters per keymap', 'warn')
      goto continue
    end
    local mode = map[1]
    local lhs = map[2]
    local rhs = map[3]
    local desc = map[4]
    keymaps[mode][lhs] = { rhs, desc, group = props.group }
    ::continue::
  end
end

---@param map string
---@return string
local function lhs_fmt(map)
  local map_str = ''

  local sp_open = 0
  local temp = ''

  local _map = vim.split(map, '')
  local i = 1
  while i <= #_map do
    temp = ''
    if sp_open > 0 then
      if _map[i] == '>' then
        temp = string.sub(map, sp_open, i)
        temp = string.lower(temp)
        for pattern, rpl in pairs(keymaps_config.repl_keys) do
          temp = string.gsub(temp, pattern, rpl)
        end
        sp_open = 0
      end
    else
      temp = _map[i]

      if temp == '<' then
        sp_open = i
        temp = ''
      end
      if i == #_map and sp_open > 0 then
        temp = string.sub(map, sp_open, i)
      end
    end

    if temp and #temp > 0 then
      if #map_str > 0 then
        map_str = map_str .. ' + '
      end
      map_str = map_str .. temp
    end

    i = i + 1
  end

  return map_str
end

return {
  fmt = lhs_fmt,
}
