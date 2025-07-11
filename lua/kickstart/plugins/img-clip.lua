return {
  -- embed images into any markup language
  'HakonHarnes/img-clip.nvim',
  event = 'VeryLazy',
  opts = {},
  keys = {
    -- suggested keymap
    { '<leader>p', '<cmd>PasteImage<cr>', desc = 'Paste image from system clipboard' },
  },
}
