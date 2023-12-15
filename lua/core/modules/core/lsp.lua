return {
  default = {
    opts = {
      mappings = {
        show_lsp_info = '<space>si',
        goto_declaration = 'gD',
        goto_definition = 'gd',
        hover = 'K',
        goto_implementation = 'gi',
        show_signature = '<C-k>',
        show_type_definition = 'gT',
        rename = 'gr',
        show_code_action = 'gl',
        goto_references = 'gR',
        format = ',f',
      },
      config = {
        -- options passed to `vim.diagnostic.open_float()`
        -- float = {},
        severity_sort = false,
        -- use signs for diagnostics
        signs = true,
        -- Use underline for diagnostics
        underline = true,
        -- don't update diagnostics while typing
        update_in_insert = false,
        -- Use virtual text for diagnostics
        virtual_text = {
          -- Only show virtual text for diagnostics matching the given severity
          -- severity = '',
          -- Include the diagnostic source in virtual text. Use "if_many" to
          -- only show sources if there is more than one diagnostic source in
          -- the buffer. Otherwise, any truthy value means to always show the
          -- diagnostic source.
          -- boolean|string
          source = false,
          -- Amount of empty spaces inserted at the beginning of the virtual
          -- text.
          -- number
          spacing = 4,
          -- prepend diagnostic message with prefix. If a function, it must
          -- have the signature (diagnostic, i, total) -> string, where
          -- {diagnostic} is of type |diagnostic-structure|, {i} is the index
          -- of the diagnostic being evaluated, and {total} is the total number
          -- of diagnostics for the line. This can be used to render diagnostic
          -- symbols or error codes.
          -- string|function
          prefix = function(props)
            local icons = {
              [vim.diagnostic.severity.ERROR] = core.icons.diagnostic.error,
              [vim.diagnostic.severity.WARN] = core.icons.diagnostic.warn,
              [vim.diagnostic.severity.INFO] = core.icons.diagnostic.info,
              [vim.diagnostic.severity.HINT] = core.icons.diagnostic.hint,
            }
            return icons[props.severity]
          end,
          -- Append diagnostic message with suffix. If a function, it must have
          -- the signature (diagnostic) -> string, where {diagnostic} is of
          -- type |diagnostic-structure|. This can be used to render an LSP
          -- diagnostic error code.
          -- string|function
          -- suffix = '',
          -- A function that takes a diagnostic as input and returns a string.
          -- The return value is the text used to display the diagnostic.
          -- function
          -- format = '',
        },
      },
      servers = {},
    },
  },
}