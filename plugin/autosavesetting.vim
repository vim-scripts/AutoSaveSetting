" # AutoSaveSetting - Persistent settings for gVim.
"
" * Maintainer: Kien N <info@designtomarkup.com>
" * Last Modified « Sun, 19 Jun 2011 1:30:58 AM »
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
" If non-zero, AutoSaveSetting is enabled at startup.
"
" >>    let g:setting_by_vim_instance = 1
" If non-zero, save a different set of settings for each Vim instance
"
" If you don't want to use a separate .vimsave or _vimsave file and want to
" save the setting into your vimrc instead, you can change the filename in the
" File() function from `vimsave` to `vimrc`. The save data will be appended to
" the end of your vimrc. (not recommended)


if has("gui_running")

	if !exists('g:setting_restore')
		let s:restore = 1
	else
		let s:restore = g:setting_restore
		unlet g:setting_restore
	endif
	
	if !exists('g:setting_by_vim_instance')
		let s:by_instance = 1
	else
		let s:by_instance = g:setting_by_vim_instance
		unlet g:setting_by_vim_instance
	endif
	
	if s:restore == 0
		finish
	else
	
		func! s:File()
			if has('amiga')
				return "s:.vimsave"
			elseif has('win32')
				return $HOME.'\_vimsave'
			else
				return $HOME.'/.vimsave'
			endif
		endfunc
		
		func! s:Setup()
			let s:safi = s:File()
			if s:by_instance != 0
				let s:vinst = v:servername
			else
				let s:vinst = 'GVIM'
			endif
			if !exists('g:colors_name')
				let g:colors_name = 'default'
			endif
		endfunc
		
		func! s:Restore()
			if filereadable(s:safi)
				for line in readfile(s:safi)
					if match(line, '^"|') >= 0 | continue | endif
					let vimsav = eval(substitute(line, '^"', '', ''))
					if vimsav['inst'] == s:vinst
						if &gfn != vimsav['gfn']
							sil! exe "set gfn=".escape(vimsav['gfn'], ' ')
						endif
						if g:colors_name != vimsav['color']
							sil! exe "colo ".vimsav['color']
						endif
						if &nu != vimsav['nu'] && vimsav['nu'] == 1
							sil! exe "set nu!"
						elseif &rnu != vimsav['rnu'] && vimsav['rnu'] == 1
							sil! exe "set rnu!"
						elseif ( &nu != vimsav['nu'] || &rnu != vimsav['rnu'] )
									\ && vimsav['nu'] == vimsav['rnu']
							sil! exe "set nonu | set nornu"
						endif
						if &go != vimsav['go']
							sil! exe "set go=".vimsav['go']
						endif
						if &shm != vimsav['shm']
							sil! exe "set shm=".vimsav['shm']
						endif
						if &wrap != vimsav['wrap']
							sil! exe "set wrap!"
						endif
						if &hls != vimsav['hls']
							sil! exe "set hls!"
						endif
						if &ic != vimsav['ic']
							sil! exe "set ic!"
						endif
						if &sm != vimsav['sm']
							sil! exe "set sm!"
						endif
						if &so != vimsav['so']
							sil! exe "set so=".vimsav['so']
						endif
						if &ve != vimsav['ve']
							sil! exe "set ve=".vimsav['ve']
						endif
						if &im != vimsav['im']
							sil! exe "set im!"
						endif
						if &cp != vimsav['cp']
							sil! exe "set cp!"
						endif
						if &list != vimsav['list']
							sil! exe "set list!"
						endif
						if &lbr != vimsav['lbr']
							sil! exe "set lbr!"
						endif
						if &et != vimsav['et']
							sil! exe "set et!"
						endif
						if &ai != vimsav['ai']
							sil! exe "set ai!"
						endif
						if &cin != vimsav['cin']
							sil! exe "set cin!"
						endif
						if &tw != vimsav['tw']
							sil! exe "set tw=".vimsav['tw']
						endif
						if &ff != vimsav['ff']
							sil! exe "set ff=".vimsav['ff']
						endif
						if &sw != vimsav['sw']
							sil! exe "set sw=".vimsav['sw']
						endif
						if &sts != vimsav['sts']
							sil! exe "set sts=".vimsav['sts']
						endif
						if &kmp != vimsav['kmp']
							sil! exe "set kmp=".vimsav['kmp']
						endif
						if &spell != vimsav['spell']
							sil! exe "set spell!"
						endif
						" Restore window size (columns and lines) and position from values
						" stored in the vimsave file. Must set font first so columns and
						" lines are based on font size.
						sil! exe "set columns=".vimsav['sizepos'][0]." lines=".vimsav['sizepos'][1]
						sil! exe "winpos ".vimsav['sizepos'][2]." ".vimsav['sizepos'][3]
						
						" Restore maximized window on MS Windows, works with
						" multi-monitors setup
						if has('win32') && ( vimsav['sizepos'][2] == -4 || vimsav['sizepos'][3] == -4 )
							let sizeposx = vimsav['sizepos'][2]+4
							let sizeposy = vimsav['sizepos'][3]+4
							sil! exe "winpos ".sizeposx." ".sizeposy
							sil! exe "simalt ~x"
						endif
						return
					endif
				endfor
			endif
		endfunc
		
		func! s:Save()
			let dict = {
						\ 'inst':s:vinst,
						\ 'sizepos':[&columns,&lines,getwinposx(),getwinposy()],
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
						\ 'cp':&cp,
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
						\ 'spell':&spell,
						\ }
			if filereadable(s:safi)
				let lines = readfile(s:safi)
				cal filter(lines, "v:val !~ '^\"|'")
				cal filter(lines, "v:val !~ '\\<".s:vinst."\\>'")
				cal add(lines, '"'.string(dict))
			else
				let lines = ['"'.string(dict)]
			endif
			cal writefile(lines, s:safi)
		endfunc
		
		au VimEnter * cal s:Setup() | cal s:Restore()
		au VimLeavePre * cal s:Save()
	endif
endif

" vim:noet:ts=2: