rem �޸�ע����Ա�˫���ļ�ʱ��emacs�� 
rem ���������ļ�����Run as administrator

ftype emacsfile=f:\emacs\bin\emacsclientw.exe -n -a F:\emacs\bin\runemacs.exe "%%1"

rem assoc .emacs=emacsfile
assoc .el=emacsfile
assoc .py=emacsfile
assoc .hs=emacsfile
rem assoc .org=emacsfile
assoc .md=emacsfile
rem .txt�ļ���Ҫ������ã�����ᵼ��New�Ӳ˵��е�Text Documentһ����ʧ
rem Ϊ��˫��txtʱ����emacs�򿪣��ȵ���orgmode.reg��Ȼ���Ҽ�����һ��txt�ļ���ѡ��Open with > Choose default program... > GNU EmacsClient
rem assoc .txt=emacsfile
rem assoc .txt=txtfile


