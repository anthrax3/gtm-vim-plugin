" Git Time Metric Vim plugin
" Author: Michael Schenk
" License: MIT

if exists('g:gtm_plugin_loaded') || &cp
  finish
endif

let s:no_gtm_err = 'GTM exe not found, install GTM or update path, see https://www.github.com/git-time-metric/gtm'

if executable('gtm') == 0
  echomsg s:no_gtm_err
  finish
endif

let g:gtm_plugin_loaded = 1

let g:gtm_plugin_status_enabled = get(g:, 'gtm_plugin_status_enabled', 0)

let s:last_update = 0
let s:last_file = ''
let s:update_interval = 30
let s:gtm_plugin_status = ''

function! s:record()
  let fpath = expand('%:p')
  " record if file path has changed or last update is greater than update_interval
  if s:last_file != fpath || localtime() - s:last_update > s:update_interval
    let s:cmd = (g:gtm_plugin_status_enabled == 1 ? 'gtm record --status' : 'gtm record')
    let output=system(s:cmd . ' ' . shellescape(fpath))
    if v:shell_error
      echomsg s:no_gtm_err
    else
      let s:gtm_plugin_status = (g:gtm_plugin_status_enabled ? join(split(substitute(output, '\s*\d*s\s*$', '', 'g')), ' ')  : '')
    endif
    let s:last_update = localtime()
    let s:last_file = fpath
  endif
endfunction

function! GTMStatusline()
  return s:gtm_plugin_status
endfunction

augroup gtm_plugin
  autocmd!
  autocmd BufReadPost,BufWritePost,CursorMoved,CursorMovedI * call s:record()
augroup END
