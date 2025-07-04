return {
  -- Model Context Protocol (MCP) configuration for AI (LLM) integration
  {
    'ravitemer/mcphub.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim', -- Required for async operations
    },
    -- This build command installs the global 'mcp-hub' server.
    -- Ensure you have Node.js and npm/yarn installed on your system.
    build = 'npm install -g mcp-hub@latest',
    opts = {
      -- Path to your MCP servers configuration file
      -- This is where you'll define your individual MCP servers (e.g., file system, code gen)
      config = vim.fn.expand '~/.config/nvim/lua/kickstart/plugins/mcpservers.json',
    },
  },
}
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
