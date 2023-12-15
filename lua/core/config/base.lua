local M = {}

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    vim.cmd('startinsert')
  end,
  desc = 'start insert mode on TermOpen',
})

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    vim.opt_local.number = false
  end,
  desc = 'remove line numbers',
})

-- mkdir path

vim.cmd [[
function s:Mkdir()
  let dir = expand('%:p:h')

  if dir =~ '://'
    return
  endif

  if !isdirectory(dir)
    call mkdir(dir, 'p')
    echo 'Created non-existing directory: '.dir
  endif
endfunction

autocmd BufWritePre * call s:Mkdir()]]

-- white space
vim.cmd [[
function! StripTrailingWhitespace()
  if !&binary && &filetype != 'diff'
    normal mz
    normal Hmy
    %s/\s\+$//e
    normal 'yz<CR>
    normal `z
  endif
endfunction
]]

-- statusline
vim.api.nvim_create_user_command('ToggleStatusLine', function(_)
  if vim.o.laststatus == 0 then
    vim.opt.laststatus = 3
    vim.opt.cmdheight = 1
  else
    vim.opt.laststatus = 0
    vim.opt.cmdheight = 0
  end
end, {})

---@class BaseConfig
---@field file_associations { [1]: string[], [2]: string, [3]: function }[]

--- Setup options
---@param opts BaseConfig
function M.setup(opts)
  -- { { patterns... }, description, callback }
  for _, item in ipairs(opts.file_associations) do
    if not type(item[1]) == 'table' then
      goto continue
    end
    if not type(item[2]) == 'string' then
      goto continue
    end
    if not type(item[3]) == 'function' then
      goto continue
    end
    vim.api.nvim_create_autocmd('BufEnter', {
      pattern = item[1],
      callback = item[3],
      group = core.group_id,
      desc = item[2],
    })
    ::continue::
  end
end

return M