local Util = require 'core.utils'

local parts = {}

function parts.load_modules(_)
  parts.load_config {}

  for main_mod, modules in pairs(core.modules) do
    parts._modules(main_mod, modules)
  end
end

function parts.load_config(_)
  if not core.config.modules['core'] then
    Util.log('core modules are not defined.', 'error')
    return
  end

  for main_mod, modules in pairs(core.config.modules) do
    Util.log('loading ' .. main_mod .. ' modules.')
    core.modules[main_mod] = core.modules[main_mod] or {}

    for _, spec in pairs(modules) do
      if spec.opts and type(spec.opts) == 'string' then
        spec.opts = require(spec.opts)
      end
      local name = spec.name or spec[1]
      spec = require 'core.modules'.setup(main_mod, name, spec)

      core.modules[main_mod][name] = spec
    end

    core.modules[main_mod] = vim.tbl_deep_extend("keep", core.modules[main_mod],
      require 'core.modules'.get_defaults(main_mod))
  end
end

---@param module string
---@param spec ModuleSpec
function parts.load(module, spec)
  if spec.enabled == false then
    Util.log('skipping loading module: ' .. module)
    return
  end
  if spec.loaded and spec.reload == false then
    Util.log('skipping reloading module: ' .. module)
    return
  end

  ---@param source string
  ---@param opts table
  local callback = function(source, opts)
    local status, result = pcall(require, source)
    if not status then
      Util.log("failed to load " .. source .. "\n\t" .. result, 'error')
      return
    end
    if type(result) == 'table' then
      if result.setup then
        if not type(spec.opts) == 'table' then
          return
        end
        result.setup(opts)
      end
    end
  end

  if spec.event and not spec.loaded then
    vim.api.nvim_create_autocmd({ spec.event }, {
      group = core.group_id,
      once = true,
      callback = function()
        callback(module, spec.opts)
      end,
    })
  else
    callback(module, spec.opts)
  end
end

---@param modules { [ModuleName]: boolean }
function parts._modules(mod, modules)
  for _, spec in pairs(modules) do
    ---@type ModuleName
    local module = mod .. '.' .. spec.name
    if mod == 'core' then
      module = mod .. '.config.' .. spec.name
    end

    parts.load(module, spec)
    spec.loaded = true

    if spec.reload then
      require 'core.load.autocmds'.create_reload(module, spec)
    end
  end
end

function parts.colorscheme(_)
  vim.cmd.colorscheme(core.config.colorscheme)
  local ok, _ = pcall(vim.cmd.colorscheme, core.config.colorscheme)
  if not ok then
    Util.log("couldn't load colorscheme", 'error')
  end

  vim.api.nvim_create_autocmd({ 'UIEnter' }, {
    group = core.group_id,
    once = true,
    callback = function()
      vim.api.nvim_exec_autocmds('ColorScheme', {})
    end
  })
end

function parts.preload(_)
  require 'core.bootstrap'.boot 'keymaps'
  require 'core.bootstrap'.boot 'plenary'
  require 'core.bootstrap'.boot 'telescope'
  require 'core.bootstrap'.boot 'evergarden'

  if not keymaps then
    Util.log('global keymaps is not defined.', 'error')
    return
  end

  core.icons = require 'core.plugin.icons'
  require 'core.plugin.hl'.setup()
end

function parts.platform(_)
  local is_mac = Util.has 'mac'
  local is_win = Util.has 'win32'
  local is_neovide = vim.g.neovide

  if is_mac then
    require(CONFIG_MODULE .. '.macos')
  end
  if is_win then
    require(CONFIG_MODULE .. '.windows')
  end
  if is_neovide then
    require(CONFIG_MODULE .. '.neovide')
  end
end

function parts.update_core(_)
  require 'core.bootstrap'.update 'core'
  RELOAD 'core'
end

function parts.update_keymaps(_)
  require 'core.bootstrap'.update 'keymaps'
  RELOAD 'keymaps'
end

return parts
