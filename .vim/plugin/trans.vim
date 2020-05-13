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

if has("python3")
function! s:DefPython()
python3<<MY_PYTHONEOF
import http.client
import hashlib
import urllib
import random
import json
import textwrap

#below id and key is mine, it up to 2000000 words
MyAppid = '20200317000399860'
SecretKey = 'vfxAjxRgMbzsgdtUKGNx'
FromLang = 'auto'
ToLang = 'zh'
def trans(q):
    q = q.replace('\n', ' ').replace('\r', '')
    myurl = '/api/trans/vip/translate'
    salt = random.randint(32768, 65536)
    sign = MyAppid + q + str(salt) + SecretKey
    sign = hashlib.md5(sign.encode()).hexdigest()
    myurl = myurl + '?appid=' + MyAppid + '&q=' + urllib.parse.quote(q) + '&from=' + FromLang + '&to=' + ToLang + '&salt=' + str(
        salt) + '&sign=' + sign

    try:
        httpClient = http.client.HTTPConnection('api.fanyi.baidu.com')
        httpClient.request('GET', myurl)
        response = httpClient.getresponse()
        result_all = response.read().decode("utf-8")
        result = json.loads(result_all)
        print(textwrap.fill(result['trans_result'][0]['dst'], width=80))

    except Exception as e:
        print (e)
    finally:
        if httpClient:
            httpClient.close()

    return textwrap.fill(result['trans_result'][0]['dst'], width=80)

MY_PYTHONEOF
endfunction
else
function! s:DefPython()
python<<MY_PYTHONEOF
import httplib
import md5
import urllib
import random
import json
import textwrap

#below id and key is mine, it up to 2000000 words
MyAppid = '20200317000399860'
SecretKey = 'vfxAjxRgMbzsgdtUKGNx'
FromLang = 'auto'
ToLang = 'zh'
def trans(q):
    q = q.replace('\n', ' ').replace('\r', '')
    myurl = '/api/trans/vip/translate'
    salt = random.randint(32768, 65536)
    sign = MyAppid + q + str(salt) + SecretKey
    m1 = md5.new()
    m1.update(sign)
    sign = m1.hexdigest()
    myurl = myurl + '?appid=' + MyAppid + '&q=' + urllib.quote(q) + '&from=' + FromLang + '&to=' + ToLang + '&salt=' + str(
        salt) + '&sign=' + sign

    try:
        httpClient = httplib.HTTPConnection('api.fanyi.baidu.com')
        httpClient.request('GET', myurl)
        response = httpClient.getresponse()
        result_all = response.read().decode("utf-8")
        result = json.loads(result_all)
        print(textwrap.fill(result['trans_result'][0]['dst'], width=80))

    except Exception as e:
        print (e)
    finally:
        if httpClient:
            httpClient.close()

    return textwrap.fill(result['trans_result'][0]['dst'], width=80)

MY_PYTHONEOF
endfunction
endif

call s:DefPython()

function! s:MyDoTrans()
    let words = substitute(s:selection(), '\n', '', 'g')
    echom words
    if has("python3")
        execute "python3 trans('" . words . "')"
    else
        execute "python trans('" . words . "')"
    endif
endfunction
command -complete=custom,Dotrans Dotrans call s:MyDoTrans()

let maplocalleader="`"
vnoremap <unique> <LocalLeader>f <Esc><Esc>:Dotrans<CR>
nnoremap <unique> <LocalLeader>w vaw<Esc><Esc>:Dotrans<CR>
