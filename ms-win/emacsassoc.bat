rem 修改注册表，以便双击文件时用emacs打开 
rem 本批处理文件必须Run as administrator

ftype emacsfile=f:\emacs\bin\emacsclientw.exe -n -a F:\emacs\bin\runemacs.exe "%%1"

rem assoc .emacs=emacsfile
assoc .el=emacsfile
assoc .py=emacsfile
assoc .hs=emacsfile
rem assoc .org=emacsfile
assoc .md=emacsfile
rem .txt文件不要如此设置，否则会导致New子菜单中的Text Document一项消失
rem 为了双击txt时能用emacs打开，先导入orgmode.reg，然后右键单击一个txt文件，选择Open with > Choose default program... > GNU EmacsClient
rem assoc .txt=emacsfile
rem assoc .txt=txtfile


