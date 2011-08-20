" # AutoSaveSetting - Persistent settings for gVim.
"
" * Maintainer: Kien N <info@designtomarkup.com>
" * Version: 1.2
" * Last Modified « Mon, 20 Jun 2011 9:34:50 PM »
"
" * Idea stolen from [Vim Tip 1569][1]
" * [Source repository][2]
"
" The goal of this script is to make the GUI version of Vim behave more like
" regular programs. Covers only the settings found in the default GVim menu.
" Restorable options includes window positions and sizes of previous GVim
" instances as well as colorscheme, guifont, guioptions, text wrapping,
" spellcheck and many more... If you need a full snapshot, however, then `:mks`
" and `:mkv` are recommended.
"
" [1]: http://vim.wikia.com/wiki/Restore_screen_size_and_position
" [2]: https://github.com/kien/autosavesetting.vim
"
"
" ## Install
"
" Put autosavesetting.vim into ~/.vim/plugin (on Linux/MacOSX)
" or $HOME\vimfiles\plugin (on Windows)
"
"
" ## Options
"
" >>    let g:setting_restore = 1
" If non-zero, AutoSaveSetting is enabled at startup. Enabled by default (1).
"
" >>    let g:setting_by_vim_instance = 1
" If non-zero, save a different set of settings for each Vim instance. Enabled
" by default (1).
"
" >>    let g:setting_ignores_vimrc = 1
" If non-zero, settings will persist after sourcing vimrc. Enabled by default (1).
"
" If you don't want to use a separate .vimsave or _vimsave file and want to
" save the setting into your vimrc instead, you can change the filename in the
" File() function from `vimsave` to `vimrc`. The save data will be appended to
" the end of your vimrc. (not recommended)


if !has("gui_running")
	finish
endif

if !exists('g:setting_restore')
	let g:setting_restore = 1
endif

if g:setting_restore == 0
	finish
endif

if !exists('g:setting_by_vim_instance')
	let g:setting_by_vim_instance = 1
endif

if !exists('g:setting_ignores_vimrc')
	let g:setting_ignores_vimrc = 1
endif

func! s:File()
	if has('amiga')
		return "s:.vimsave"
	elseif has('win32') || has('win64')
		return $HOME.'\_vimsave'
	else
		return $HOME.'/.vimsave'
	endif
endfunc

func! s:Setup()
	let s:safi = s:File()
	if g:setting_by_vim_instance != 0
		let s:vinst = v:servername
	else
		let s:vinst = 'GVIM'
	endif
	if !exists('g:colors_name')
		let g:colors_name = 'default'
	endif
endfunc

func! s:_(opt, ...)
	let optname = a:opt
	exe "let optval=&".a:opt
	if (exists('s:vimsav[optname]') && optval == s:vimsav[optname]) ||
				\ !exists('s:vimsav[optname]') | retu | endif
	if a:1 == 'bool'
		sil! exe "set ".optname."!"
	elseif a:1 == 'val'
		sil! exe "set ".optname."=".escape(s:vimsav[optname], ' ')
	endif
endfunc

func! s:Restore()
	if !filereadable(s:safi) | retu | endif
	for line in readfile(s:safi)
		if match(line, '^"|') >= 0 | continue | endif
		let s:vimsav = eval(substitute(line, '^"', '', ''))
		if s:vimsav['inst'] == s:vinst
			cal s:_('cp', 'bool')
			cal s:_('gfn', 'val')
			if g:colors_name != s:vimsav['color']
				sil! exe "colo ".s:vimsav['color']
			endif
			cal s:_('nu', 'bool')
			cal s:_('rnu', 'bool')
			cal s:_('go', 'val')
			cal s:_('shm', 'val')
			cal s:_('wrap', 'bool')
			cal s:_('hls', 'bool')
			cal s:_('ic', 'bool')
			cal s:_('sm', 'bool')
			cal s:_('so', 'bool')
			cal s:_('ve', 'bool')
			cal s:_('im', 'bool')
			cal s:_('list', 'bool')
			cal s:_('lbr', 'bool')
			cal s:_('et', 'bool')
			cal s:_('ai', 'bool')
			cal s:_('cin', 'bool')
			cal s:_('tw', 'val')
			cal s:_('ff', 'val')
			cal s:_('sw', 'val')
			cal s:_('sts', 'val')
			cal s:_('kmp', 'val')
			cal s:_('spl', 'val')
			cal s:_('spell', 'bool')
			" Restore window size (columns and lines) and position from values stored
			" in the vimsave file. Must set font first so columns and lines are based
			" on font size.
			let sizepos = s:vimsav['sizepos']
			sil! exe "set columns=".sizepos[0]." lines=".sizepos[1]
			sil! exe "winpos ".sizepos[2]." ".sizepos[3]
			" Restore maximized window on MS Windows, works with multi-monitors setup
			if (has('win32') || has('win64')) &&
						\ (sizepos[2] == -4 || sizepos[3] == -4)
				sil! exe "winpos ".sizepos[2]+4." ".sizepos[3]+4
				sil! exe "simalt ~x"
			endif
			retu
		endif
	endfor
endfunc

func! s:Save()
	let dict = {
				\ 'inst':s:vinst,
				\ 'cp':&cp,
				\ 'gfn':&gfn,
				\ 'color':g:colors_name,
				\ 'nu':&nu,
				\ 'rnu':&rnu,
				\ 'go':&go,
				\ 'shm':&shm,
				\ 'wrap':&wrap,
				\ 'hls':&hls,
				\ 'ic':&ic,
				\ 'sm':&sm,
				\ 'so':&so,
				\ 've':&ve,
				\ 'im':&im,
				\ 'list':&list,
				\ 'lbr':&lbr,
				\ 'et':&et,
				\ 'ai':&ai,
				\ 'cin':&cin,
				\ 'tw':&tw,
				\ 'ff':&ff,
				\ 'sw':&sw,
				\ 'sts':&sts,
				\ 'kmp':&kmp,
				\ 'spl':&spl,
				\ 'spell':&spell,
				\ 'sizepos':[&columns,&lines,getwinposx(),getwinposy()],
				\ }
	if filereadable(s:safi)
		let lines = readfile(s:safi)
		cal filter(lines, "v:val !~ '^\"|'")
		cal filter(lines, "v:val !~ '^\"{.*\\<inst\\>.*\\<".s:vinst."\\>'")
		cal add(lines, '"'.string(dict))
	else
		let lines = ['"'.string(dict)]
	endif
	cal writefile(lines, s:safi)
endfunc

func! s:Source()
	if g:setting_ignores_vimrc == 0 | retu | endif
	" prevent losing settings after sourcing .vimrc
	au SourceCmd [._]*vimrc cal s:Restore()
	au SourcePre [._]*vimrc cal s:Save()
endfunc

au VimEnter * cal s:Setup() | cal s:Restore() | cal s:Source()
au VimLeavePre * cal s:Save()

" vim:noet:ts=2: