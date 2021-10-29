# Buch Buchungsformat

### Standard-Form

```
Datum

[<redmine>]#<ticketnr> <zeit> <activity> <text>
```

#### Beispiel

```
2019-01-01

#1234    1.5 Daily  Maint Daily
s#25888  0.5 Orga   Buchungsdext
```

### Zeitangaben

Es sind Stunden-Angaben (`1.25`, `1:15`) verwendbar.

```
#1234   1.25  Orga  Meeting
#1234   1:15  Orga  Meeting
```

### Zeitgranularitaet

Zeiten werden aufgerundet. Die mindestens zu buchende Zeit kann über die
Konfiguration `minimum_time` konfiguriert werden. Ist beispielsweise eine
Viertelstunde konfiguriert

```
minimum_time: 0.25
``` 

wird

```
#1234   1:10  Orga  Meeting
```

gebucht als

```
#1234   1.25  Orga  Meeting
```

## Vim Highlighting

`~/.vim/syntax/buchungen.vim`

```viml
" Vim syntax file
" Language: Redmine Buchungen
" Maintainer: Jonathan Buch <jonathan.buch@gmail.com>
" Latest Revision: 2016

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn match redDate /\d\d\d\d-\d\d-\d\d/
syn keyword redTag GEBUCHT TODO XXX
syn match redDate /KW\s*\d\d*/

" Rest is more fuzzy
syn case ignore

syn keyword redActivity contained admin analyse daily weekly desing doku einarb einarbeitung schulung enwicklung dev solo pair entw supp maint maintenance support orga planning plan retro review workshop
syn match redTicket /#\d\d*/ contained nextgroup=redHours skipwhite
syn match redTicket /[a-z]#\d\d*/ contained nextgroup=redHours skipwhite
syn match redHours /\s\@<=\d\d*\.\@!/ contained
syn match redHours /\d\d*\.\(25\|50\|5\|75\|0\)/ contained
syn match redHours /\d\d*\:\(15\|30\|45\|0\)/ contained

syn match redId /\[\d\d*\]/ contained

syn match redError /\d\d*\.\(25\|50\|5\|75\|0\)\@!/

syn match redComment /%.*/ contains=redDate,redTag

syn region redLine start=/^\(#\|[a-zA-Z]#\)/ end='$' oneline transparent contains=ALLBUT,redDate,redLine

let b:current_syntax = "buchungen"

hi def link redTicket Constant
hi def link redHours Number
hi def link redText Todo
hi def link redComment Comment
hi def link redDate Type
hi def link redTag Tag
hi def link redId Constant
hi def link redActivity Directory
hi def link redError Error
```

`~/.vim/ftdetect/buchungen.vim`

```viml
au BufRead,BufNewFile *.B set filetype=buchungen
autocmd FileType buchungen set noet|set ts=8|set sw=8|set sts=8
```
