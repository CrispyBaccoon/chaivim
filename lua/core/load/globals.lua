---@type string
CR = CR or "~/.config"

---@type fun(v: string): string
ENV = function(v)
    if not vim.fn.has_key(vim.fn.environ(), v) then
        return ""
    end
    return vim.fn.environ()[v]
end

---@type fun(v: string): string
CR_PATH = function (v)
    return CR .. "/" .. v
end

---@generic T : any
---@param v T
---@return T
P = function (v)
 print(vim.inspect(v))
 return v
end

--- Secure reload module
---@param module_name string
---@param starts_with_only? boolean
---@return boolean
---@return any|nil|string
SR = function(module_name, starts_with_only)
  -- Default to starts with only
  if starts_with_only == nil then
    starts_with_only = true
  end

  -- TODO: Might need to handle cpath / compiled lua packages? Not sure.
  local matcher
  if not starts_with_only then
    matcher = function(pack)
      return string.find(pack, module_name, 1, true)
    end
  else
    local module_name_pattern = vim.pesc(module_name)
    matcher = function(pack)
      return string.find(pack, "^" .. module_name_pattern)
    end
  end

  -- Handle impatient.nvim automatically.
  local luacache = (_G.__luacache or {}).cache

  for pack, _ in pairs(package.loaded) do
    if matcher(pack) then
      package.loaded[pack] = nil

      if luacache then
        luacache[pack] = nil
      end
    end
  end

  return pcall(require, module_name)
end

--- secure reload and log if module is not found
---@param ... unknown
---@return boolean
---@return any
SR_L = function (...)
  local ok, result = SR(...)
  if not ok then
    vim.notify('error while loading module\n\t' .. result, vim.log.levels.ERROR)
  end
  return ok, result
end


--- wrapper fn for plenary reload
---@param module string
---@param name_only boolean|nil
RELOAD = function(module, name_only)
 return require("plenary.reload").reload_module(module, name_only)
end

--- wrapper fn for module reload and require
---@param name string
---@return any
R = function (name)
 RELOAD(name)
 return require(name)
end

MT = function (t1, t2)
  local tnew = {}
  for k,v in pairs(t1) do
    tnew[k] = v
  end
  for k,v in pairs(t2) do
    if type(v) == "table" then
      if type(tnew[k] or false) == "table" then
        MT(tnew[k] or {}, t2[k] or {})
      else
        tnew[k] = v
      end
    else
      tnew[k] = v
    end
  end
  return tnew
end

---@type {}
CUTIL = {}

---@param _ any
---@return string|string[]
CUTIL.PATH_DIR = function (_)
  local _dir = vim.fn.expand('%:.:h')
  local name
  if _dir == '.' then
    name = ''
  else
    name = _dir
  end
  return name
end

--- if in visual mode, returns number of visually selected words
---@param _ any
---@return string
CUTIL.WORD_COUNT = function (_)
  local w_count = vim.fn.wordcount()
  local count = 0
  if w_count['visual_words'] then
    count = w_count['visual_words']
  else
    count = w_count['words']
  end
  if count == 0 then
    return ""
  end
  return count
end

--- if in visual mode, returns number of visually selected lines,
--- else return line count in file
---@param _ any
---@return integer
CUTIL.LINE_COUNT = function (_)
  local _vstart = vim.fn.line('v')
  local _vend = vim.fn.line('.')

  local diff = _vend - _vstart
  if diff == 0 then
    return vim.api.nvim_buf_line_count(0)
  end

  if diff < 0 then
    diff = -diff
  end

  return diff
end

--- return file info based on filetype
--- default: LINE_COUNT
--- markdown: WORD_COUNT
---@param _ any
---@return string|integer
CUTIL.FILE_INFO = function (_)
  local type_info = {
    markdown = CUTIL.WORD_COUNT,
  }
  local bufnr = vim.fn.bufnr()
  local t = vim.filetype.match { buf = bufnr }
  local fn = type_info[t] or CUTIL.LINE_COUNT
  return fn()
end
