return {
	{
		'https://gitlab.com/itaranto/preview.nvim',
		version = '*',
		opts = {
			plantuml = {
				name = 'plantuml_text',
				renderer = { type = 'buffer', opts = { split_cmd = 'split' } },
			}
		}
	}
}
