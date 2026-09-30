-- Substitute operator
local function sub(fn)
    return function()
        require('substitute')[fn]()
    end
end

return {
    {
        'gbprod/substitute.nvim',
        keys = {
            { 's', sub('operator'), desc = 'Substitute with register' },
            { 'ss', sub('line'), desc = 'Substitute line' },
            { 'S', sub('eol'), desc = 'Substitute to end of line' },
            { 's', sub('visual'), mode = 'x', desc = 'Substitute selection' },
        },
        opts = {},
    },
}
