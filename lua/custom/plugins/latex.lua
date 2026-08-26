-- LaTeX authoring: VimTeX + latexmk + Skim (SyncTeX both directions).
--
-- VimTeX is configured through `vim.g.vimtex_*` globals, which must be set
-- *before* the plugin loads -- hence `init` rather than `config`/`opts`.
--
-- With `maplocalleader = ' '`, VimTeX's `\l` prefix means the maps below are
-- typed as <space>l... . The most used ones:
--    <space>ll   toggle continuous compilation (latexmk -pvc)
--    <space>lv   forward search: jump Skim to the cursor's line
--    <space>lk   stop compilation
--    <space>lc   clean aux files (.aux/.log/.out/...)
--    <space>le   open the quickfix list of errors/warnings
--    <space>lt   table of contents
--    <space>li   info about the current document
-- Backward search (Skim -> here) is shift-cmd-click in Skim.
return {
  'lervag/vimtex',
  -- VimTeX sets up its own filetype handling; lazy-loading it is not supported.
  lazy = false,
  init = function()
    -- Compile with latexmk, which handles reruns and biber/bibtex on its own.
    vim.g.vimtex_compiler_method = 'latexmk'
    vim.g.vimtex_compiler_latexmk = {
      -- Build in place. Set `out_dir = 'build'` here to keep aux files out of
      -- the repo, but note Skim then opens build/<name>.pdf.
      aux_dir = '',
      out_dir = '',
      callback = 1,
      continuous = 1,
      options = {
        '-verbose',
        '-file-line-error',
        '-synctex=1',
        '-interaction=nonstopmode',
      },
    }

    -- Skim is already installed and has auto-reload on, so a rebuilt PDF
    -- refreshes in place instead of stealing focus.
    vim.g.vimtex_view_method = 'skim'
    vim.g.vimtex_view_skim_sync = 1 -- forward search after each compile
    vim.g.vimtex_view_skim_activate = 1 -- raise Skim on forward search
    vim.g.vimtex_view_skim_reading_bar = 1 -- highlight the synced line

    -- Warnings are noisy in a real paper (overfull boxes, undefined refs on a
    -- first pass), so only surface the quickfix window for actual errors.
    vim.g.vimtex_quickfix_open_on_warning = 0
    vim.g.vimtex_quickfix_mode = 2 -- open quickfix, but keep the cursor here

    -- Conceal math/symbols in normal mode, reveal on the line being edited.
    vim.g.vimtex_syntax_conceal = {
      accents = 1,
      ligatures = 1,
      cites = 1,
      fancy = 1,
      greek = 1,
      math_bounds = 1,
      math_delimiters = 1,
      math_fracs = 1,
      math_super_sub = 1,
      math_symbols = 1,
      sections = 0,
      styles = 1,
    }

    -- The default index/toc split is wider than it needs to be.
    vim.g.vimtex_toc_config = {
      split_pos = 'vert topleft',
      split_width = 40,
      show_help = 0,
    }

    -- Prose-friendly options for LaTeX buffers. This lives here rather than in
    -- its own spec because lazy.nvim merges specs that name the same plugin and
    -- keeps only the last `init`, which would silently drop the settings above.
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('custom-latex-prose', { clear = true }),
      pattern = { 'tex', 'plaintex', 'bib' },
      desc = 'Prose-friendly options for LaTeX buffers',
      callback = function()
        -- Wrap on word boundaries and move by screen line, so a long paragraph
        -- behaves the way it looks.
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.breakindent = true
        vim.keymap.set({ 'n', 'x' }, 'j', 'gj', { buffer = true, desc = 'Down by screen line' })
        vim.keymap.set({ 'n', 'x' }, 'k', 'gk', { buffer = true, desc = 'Up by screen line' })

        -- Spell checking, with <C-s> in insert mode to fix the last typo.
        vim.opt_local.spell = true
        vim.opt_local.spelllang = 'en_us'
        vim.keymap.set('i', '<C-s>', '<c-g>u<Esc>[s1z=`]a<c-g>u', { buffer = true, desc = 'Fix last spelling error' })

        -- Reveal concealed math on the line being edited (see vimtex_syntax_conceal).
        vim.opt_local.conceallevel = 2
        vim.opt_local.concealcursor = ''

        -- Don't treat a wrapped paragraph as over-long code.
        vim.opt_local.textwidth = 0
        vim.opt_local.colorcolumn = ''
      end,
    })
  end,
}
