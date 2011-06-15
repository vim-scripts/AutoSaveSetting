" # AutoSaveSetting - Autosave GVim settings upon exit.
"
" * Maintainer: Kien N <info+vim@designslicer.com>
" * Last Modified « Wed, 04 May 2011 10:06:44 AM »
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
" [2]: https://github.com/kien/vim/blob/master/script/autosavesetting.vim
"
"
" ### Install
"
" Put autosavesetting.vim into ~/.vim/plugin (on Linux/MacOSX)
" or $HOME\vimfiles\plugin (on Windows)
"
"
" ### Options
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


if exists("loaded_AutoSaveSetting")
	finish
endif
let loaded_AutoSaveSetting = 1

if has("gui_running")

	if !exists('g:setting_restore')
		let s:restore = 1
	else
		let s:restore = g:setting_restore
		unlet g:setting_restore
	endif
	
	if !exists('g:setting_by_vim_instance')
		let s:by_vim_instance = 1
	else
		let s:by_vim_instance = g:setting_by_vim_instance
		unlet g:setting_by_vim_instance
	endif
	
	if s:restore == 1
	
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
			let s:safi = <SID>File()
			if s:by_vim_instance == 1
				let s:vinst = v:servername
			elseif has("macunix")
				let s:vinst = 'VIM'
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
					let vimsav = split(line, '|')
					if len(vimsav) == 31 && vimsav[1] == s:vinst
						if &gfn != vimsav[6]
							if match(vimsav[6], " ") >= 0
								let vimsav6 = split(vimsav[6])
								let fontstr = "set gfn=".vimsav6[0]
								for i in range(1, len(vimsav6) - 1)
									let fontstr = fontstr."\\ ".vimsav6[i]
								endfor
							else
								let fontstr = "set gfn=".vimsav[6]
							endif
							silent! execute fontstr
						endif
						if g:colors_name != vimsav[7]
							silent! execute "colo ".vimsav[7]
						endif
						if &nu != vimsav[8] && vimsav[8] == 1
							silent! execute "set nu!"
						elseif &rnu != vimsav[9] && vimsav[9] == 1
							silent! execute "set rnu!"
						elseif ( &nu != vimsav[8] || &rnu != vimsav[9] )
									\ && vimsav[8] == vimsav[9]
							silent! execute "set nonu | set nornu"
						endif
						if &go != vimsav[10]
							silent! execute "set go=".vimsav[10]
						endif
						if &shm != vimsav[11]
							silent! execute "set shm=".vimsav[11]
						endif
						if &wrap != vimsav[12]
							silent! execute "set wrap!"
						endif
						if &hls != vimsav[13]
							silent! execute "set hls!"
						endif
						if &ic != vimsav[14]
							silent! execute "set ic!"
						endif
						if &sm != vimsav[15]
							silent! execute "set sm!"
						endif
						if &so != vimsav[16]
							silent! execute "set so=".vimsav[16]
						endif
						if &ve != vimsav[17]
							silent! execute "set ve=".vimsav[17]
						endif
						if &im != vimsav[18]
							silent! execute "set im!"
						endif
						if &cp != vimsav[19]
							silent! execute "set cp!"
						endif
						if &list != vimsav[20]
							silent! execute "set list!"
						endif
						if &lbr != vimsav[21]
							silent! execute "set lbr!"
						endif
						if &et != vimsav[22]
							silent! execute "set et!"
						endif
						if &ai != vimsav[23]
							silent! execute "set ai!"
						endif
						if &cin != vimsav[24]
							silent! execute "set cin!"
						endif
						if &tw != vimsav[25]
							silent! execute "set tw=".vimsav[25]
						endif
						if &ff != vimsav[26]
							silent! execute "set ff=".vimsav[26]
						endif
						if &sw != vimsav[27]
							silent! execute "set sw=".vimsav[27]
						endif
						if &sts != vimsav[28]
							silent! execute "set sts=".vimsav[28]
						endif
						if &kmp != vimsav[29]
							silent! execute "set kmp=".vimsav[29]
						endif
						if &spell != vimsav[30]
							silent! execute "set spell!"
						endif
						" Restore window size (columns and lines) and position from values
						" stored in the vimsave file. Must set font first so columns and
						" lines are based on font size.
						silent! execute "set columns=".vimsav[2]." lines=".vimsav[3]
						silent! execute "winpos ".vimsav[4]." ".vimsav[5]
						
						" Restore maximized window on MS Windows, works with
						" multi-monitors setup
						if has('win32') && ( vimsav[4] == -4 || vimsav[5] == -4 )
							let sizeposx = vimsav[4]+4
							let sizeposy = vimsav[5]+4
							silent! execute "winpos ".sizeposx." ".sizeposy
							silent! execute "simalt ~x"
						endif
						return
					endif
				endfor
			endif
		endfunc
		
		func! s:Save()
			let data = '"|' . s:vinst . '|' .
						\	&columns . '|' . &lines . '|' .
						\ getwinposx() . '|' . getwinposy() . '|' .
						\ &gfn . '|' .
						\ g:colors_name . '|' .
						\ &nu . '|' . &rnu . '|' .
						\ &go . '|' .
						\ &shm . '|' .
						\ &wrap . '|' .
						\ &hls . '|' .
						\ &ic . '|' .
						\ &sm . '|' .
						\ &so . '|' .
						\ &ve . '|' .
						\ &im . '|' .
						\ &cp . '|' .
						\ &list . '|' .
						\ &lbr . '|' .
						\ &et . '|' .
						\ &ai . '|' .
						\ &cin . '|' .
						\ &tw . '|' .
						\ &ff . '|' .
						\ &sw . '|' .
						\ &sts . '|' .
						\ &kmp . '|' .
						\ &spell
			if filereadable(s:safi)
				let lines = readfile(s:safi)
				call filter(lines, "v:val !~ '^\"|" . s:vinst . "\\>'")
				call add(lines, data)
			else
				let lines = [data]
			endif
			call writefile(lines, s:safi)
		endfunc
		
		au VimEnter * call <SID>Setup() | call <SID>Restore()
		au VimLeavePre * call <SID>Save()
	endif
endif

" vim:noet:ts=2:
