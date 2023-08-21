-- load and configure plugins using packer
--
-- :PackerSync to install

local packer = require('packer')

packer.startup(function(use)
    use {'wbthomason/packer.nvim'}

    -- REPL for lua plugin development
    use 'bfredl/nvim-luadev'

    use {'nvim-telescope/telescope.nvim',
         requires = {{'nvim-lua/plenary.nvim'}}
    }

    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    } 

    use 'edluffy/hologram.nvim'

    use_rocks "loop"
    use_rocks "lsqlite3"
    use_rocks "lrexlib-pcre2"
    use_rocks "base64"

--[[
    -- delete buffer while keeping window layout
    use 'famiu/bufdelete.nvim'

    -- status line
    --use 'famiu/feline.nvim'

    -- fast motions
    use 'justinmk/vim-sneak'
    use 'phaazon/hop.nvim'

    -- TODO tpope plugins
    use 'tpope/vim-repeat'
    --use 'tpope/vim-unimpaired'
    --use 'tpope/vim-surround'


    use {'johnwilmes/keyfactor.nvim',
         requires = {{'numToStr/Comment.nvim'}},
--         rocks = {'lsqlite3', 'loop'},
     }

    use {'LionC/nest.nvim'}
    ]]
end)

-- status line setup
--local feline = require('feline')
--feline.setup({preset='noicon'})

-- telescope
