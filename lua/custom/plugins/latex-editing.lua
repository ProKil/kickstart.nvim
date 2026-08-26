-- LaTeX snippets. Kickstart already installs luasnip and wires it into
-- blink.cmp; this only adds the snippet collection and its loader, which gives
-- `tex` expansions for \begin{}, figure, table, itemize, and friends.
--
-- Filetype behaviour for .tex buffers lives in `latex.lua`, alongside the
-- VimTeX configuration it belongs with.
return {
  'rafamadriz/friendly-snippets',
  config = function()
    require('luasnip.loaders.from_vscode').lazy_load()
  end,
}
