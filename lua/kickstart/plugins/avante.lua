return {
  -- Add avante.nvim for AI chat and Cursor-like experience
  'yetone/avante.nvim',
  build = 'make',
  event = 'VeryLazy', -- Load only when needed
  version = false, -- Never set this to "*"
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim', -- for UI components
    --- OPTIONAL dependencies:
    'nvim-treesitter/nvim-treesitter', -- recommended for context
    'nvim-telescope/telescope.nvim', -- for file_selector provider
    'nvim-tree/nvim-web-devicons', -- for icons
    { -- for viewing output in markdown format
      'MeanderingProgrammer/render-markdown.nvim',
      -- Define opts as a function to handle the list merges explicitly
      opts = function(_, prev_opts)
        -- Ensure `file_types` exists in `prev_opts` and is a list
        -- If prev_opts.default was nil the `or {}` creates an empty one.
        prev_opts.file_types = prev_opts.file_types or {}

        -- Use vim.list_extend to concatenate the lists
        -- `vim.list_extend` adds elements from the second list to the first.
        vim.list_extend(prev_opts.file_types, { 'Avante' })

        return prev_opts -- Always return the modified options table
      end,
    },
    { -- for completion using blink
      'saghen/blink.cmp',
      dependencies = { 'Kaiser-Yang/blink-cmp-avante' },
      -- Define opts as a function to handle the list merges explicitly
      opts = function(_, prev_opts)
        -- Ensure the options exist in `prev_opts`
        -- If an option was nil the `or {}` creates an empty one.
        prev_opts.sources = prev_opts.sources or {}
        prev_opts.sources.default = prev_opts.sources.default or {}
        prev_opts.sources.providers = prev_opts.sources.providers or {}

        -- Use vim.list_extend to concatenate the lists
        -- `vim.list_extend` adds elements from the second list to the first.
        vim.list_extend(prev_opts.sources.default, { 'avante' })

        -- add 'avante' as a provider
        prev_opts.sources.providers.avante = {
          module = 'blink-cmp-avante',
          name = 'Avante',
          opts = {},
        }
        return prev_opts -- Always return the modified options table
      end,
    },
    { -- for image pasting
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    'ravitemer/mcphub.nvim', -- ensure MCPHub for access to MCP servers
  },

  ---@module 'avante'
  ---@type avante.Config
  opts = { -- Make sure this 'opts' table exists and is properly formed
    -- Configure your AI provider (e.g., Claude, OpenAI, Ollama, Gemini)
    provider = 'gemini', -- or "claude", openai", "gemini", "ollama" etc.

    -- Provider-specific settings (adjust as per your chosen provider)
    providers = {
      -- Example for Claude
      claude = {
        -- Ensure you have your CLAUDE_API_KEY set in your environment
        -- e.g., in your shell config: export CLAUDE_API_KEY="sk-..."
        -- endpoint = "https://api.anthropic.com", -- Default, usually not needed
        model = 'claude-3-5-sonnet-20240620', -- or "claude-3-opus-20240229", "claude-3-haiku-20240307"
        timeout = 60000, -- Increase timeout for larger models/responses
        extra_request_body = {
          temperature = 0,
          max_tokens = 4096, -- Adjust based on model context window
        },
      },
      -- Example for Gemini https://ai.google.dev/models/gemini
      gemini = {
        api_key = os.getenv 'GEMINI_API_KEY', -- Good practice to get from env

        model = 'gemini-2.5-pro',
      },
      -- Example for OpenAI:
      openai = {
        model = 'gpt-4o',
        api_key = os.getenv 'OPENAI_API_KEY', -- Good practice to get from env
      },
      -- Example for Ollama (local LLMs):
      ollama = {
        ['local'] = true, -- Indicates a local Ollama instance
        endpoint = 'http://localhost:11434', -- Default Ollama server address
        model = 'llama3', -- Or your preferred local model
      },
    },

    windows = {
      input = {
        height = 12, -- Height of the input window in vertical layout
      },
    },

    -- === Crucial for MCPHub integration ===
    -- Dynamically inject active MCP server tools into the LLM's system prompt
    system_prompt = function()
      local base_prompt = 'You are a helpful AI coding assistant. You prioritize concise and actionable advice.'
      local hub = require('mcphub').get_hub_instance()
      -- This will include a description of all active tools from MCPHub in the prompt
      local mcp_prompt = hub and hub:get_active_servers_prompt() or ''
      return base_prompt .. '\n\n' .. mcp_prompt
    end,

    -- Define custom tools for Avante, including the MCPHub extension
    custom_tools = function()
      return {
        -- This line registers the MCPHub tool with Avante
        require('mcphub.extensions.avante').mcp_tool(),
        -- You can add other custom tools here if you define them
        -- {
        --   name = "my_local_shell_tool",
        --   description = "Execute a shell command.",
        --   parameters = { type = "object", properties = { cmd = { type = "string" } }, required = { "cmd" } },
        --   handler = function(args)
        --     -- Be extremely careful with shell execution from AI
        --     local output = vim.fn.system(args.cmd)
        --     return { role = "tool", content = output }
        --   end,
        -- },
      }
    end,

    -- Prefer neovim server tool: disable the corresponding Avante tools to prevent duplication:
    --[[
    disabled_tools = {
      'list_files', -- Built-in file operations
      'search_files',
      'read_file',
      'create_file',
      'rename_file',
      'delete_file',
      'create_dir',
      'rename_dir',
      'delete_dir',
      'bash', -- Built-in terminal access
    },
    --]]
  },
}
