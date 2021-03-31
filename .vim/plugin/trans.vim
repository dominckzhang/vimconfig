"this is a sample script for fanyi with baidu api you can change it to
"jinshan? youdao?
"leaf WD

set fileformat=unix
if exists("g:loaded_fanyi")
    finish
endif
let g:loaded_fanyi = 1

function! s:selection() abort
  try
    let a_save = @a
    silent! normal! gv"ay
    return @a
  finally
    let @a = a_save
  endtry
endfunction

function! s:DefPython()
python<<MY_PYTHONEOF
import requests
import random
import json
from hashlib import md5
import textwrap

myappid = '20200317000399860'
secretkey = 'vfxAjxRgMbzsgdtUKGNx'
#FromLang = 'auto'
#ToLang = 'zh'
#
def trans(query, to_lang='zh', from_lang='auto'):
    query = query.replace('\n', ' ').replace('\r', '')
    salt = random.randint(32768, 65536)
    #sign = make_md5(appid + query + str(salt) + appkey)
    #sign = md5((appid + query + str(salt) + appkey).encode('utf-8')).hexdigest()
    sign = md5(myappid + query + str(salt) + secretkey).hexdigest()
    
    # Build request
    endpoint = 'http://api.fanyi.baidu.com'
    path = '/api/trans/vip/translate'
    url = endpoint + path
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    payload = {'appid': myappid, 'q': query, 'from': from_lang, 'to': to_lang, 'salt': salt, 'sign': sign}
    
    # Send request
    r = requests.post(url, params=payload, headers=headers)
    result = r.json()
    
    # Show response
    #print(json.dumps(result, indent=4, ensure_ascii=False))
    
    print(textwrap.fill(result['trans_result'][0]['dst'], width=80))
    return textwrap.fill(result['trans_result'][0]['dst'], width=80)

MY_PYTHONEOF
endfunction

call s:DefPython()

function! s:MyDoTrans()
    let words = substitute(s:selection(), '\n', '', 'g')
    echom words
    execute "python trans('''". words. "''')"
endfunction
command -complete=custom,Dotrans Dotrans call s:MyDoTrans()

function! s:MyDoTransToEn()
    let words = substitute(s:selection(), '\n', '', 'g')
    echom words
    execute "python trans('''". words. "''', 'en', 'auto')"
endfunction
command -complete=custom,DotransToEn DotransToEn call s:MyDoTransToEn()

let maplocalleader="`"
vnoremap <unique> <LocalLeader>f <Esc><Esc>:Dotrans<CR>
nnoremap <unique> <LocalLeader>w vaw<Esc><Esc>:Dotrans<CR>

vnoremap <unique> <LocalLeader>fz <Esc><Esc>:Dotrans<CR>
nnoremap <unique> <LocalLeader>wz vaw<Esc><Esc>:Dotrans<CR>

vnoremap <unique> <LocalLeader>fe <Esc><Esc>:DotransToEn<CR>
nnoremap <unique> <LocalLeader>we vaw<Esc><Esc>:DotransToEn<CR>
