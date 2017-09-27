(defun create-face (face-name english-font-name chinese-font-name)
  (let (english-name
        i
        face-name-symbol
        fontset-name)

    (setq fontset-name (concat "fontset-" face-name))
    (setq face-name-symbol (intern face-name))

    (setq i (reverse-search-substring english-font-name "-" 2))
    (setq english-name (substring english-font-name 0 i))

    (create-fontset-from-fontset-spec
     (concat english-name
             "-" fontset-name
             ",chinese-gb2312:"
             chinese-font-name)
     t)


    (make-face face-name-symbol)
    (set-face-attribute face-name-symbol nil :fontset fontset-name)
    (set-face-attribute face-name-symbol nil :font fontset-name)))


(defun load-default-font-setting (chinese-font-name)

  (if (and (fboundp 'daemonp) (daemonp))
      (add-hook 'after-make-frame-functions
                (lambda (frame)
                  (with-selected-frame frame
                    (set-fontset-font "fontset-default"
                                      'chinese-gbk chinese-font-name))))
    (set-fontset-font "fontset-default" 'chinese-gbk chinese-font-name)))



;; 在*scratch* buffer中输入以下表达式
;; (insert (prin1-to-string (x-list-fonts "*")))
;; 然后按C-x C-e
;; 将输出复制到另外一个buffer中
;; 为了便于查看，先去掉前后两个括号，然后M-x replace-string将 "空格 替换为 "C-q C-j（即换行），然后选中整个buffer，执行M-x sort-lines


;; iso10646 所有unicode字符
;; iso8859 所有拉丁字符
;; gb2312 所有中文简体字符
;; M-x describe-char 可以查看光标所在处字符用的是什么字体


(defun load-winxp-font-settings ()
  ;; "-outline-楷体_GB2312-normal-normal-normal-mono-*-200-*-*-c-*-gb2312.1980-0"
  ;; "-outline-隶书-normal-normal-normal-mono-*-200-*-*-c-*-gb2312.1980-0"


  ;; 字体名字之后第6项是大小，12号字就填120
  (load-default-font-setting
   "-outline-宋体-normal-normal-normal-*-*-120-*-*-p-*-gb2312.1980-0")


  ;;;; 给各种模式设置字体
  ;; Info mode
  (create-face "infomode"
   "-*-Courier New-normal-r-*-*-*-140-*-*-c-*-iso8859-1"
   "-outline-宋体-normal-normal-normal-*-*-120-*-*-p-*-gb2312.1980-0")
  (add-hook 'Info-mode-hook '(lambda ()
                               (buffer-face-set 'infomode)))

  ;; help mode
  (create-face "helpmode"
   "-*-Courier New-normal-r-*-*-*-140-*-*-c-*-iso8859-1"
   "-outline-宋体-normal-normal-normal-*-*-120-*-*-p-*-gb2312.1980-0")
  (add-hook 'help-mode-hook '(lambda ()
                               (buffer-face-set 'helpmode)))

  ;; finder mode
  (create-face "findermode"
   "-*-Courier New-normal-r-*-*-*-140-*-*-c-*-iso8859-1"
   "-outline-宋体-normal-normal-normal-*-*-120-*-*-p-*-gb2312.1980-0")
  (add-hook 'finder-mode-hook '(lambda ()
                                 (buffer-face-set 'findermode)))

  ;; org mode
  (create-face "mynotes"
   "-outline-宋体-normal-normal-normal-*-*-120-*-*-p-*-gb2312.1980-0"
   "-outline-宋体-normal-normal-normal-*-*-120-*-*-p-*-gb2312.1980-0")
  (add-hook 'org-mode-hook '(lambda ()
                              (buffer-face-set 'mynotes)))

  ;; c++ mode
  (create-face "c++mode"
   "-outline-Courier New-normal-normal-normal-mono-*-100-*-*-c-*-iso8859-1"
   "-outline-宋体-normal-normal-normal-*-*-120-*-*-p-*-gb2312.1980-0")
  (add-hook 'c++-mode-hook '(lambda ()
                              (buffer-face-set 'c++mode)))

  )

(defun load-win7-font-settings ()

  ;; 可用字体：
  ;; 字体名字之后第6项是大小，12号字就填120
  ;; "-outline-楷体-normal-normal-normal-mono-*-*-*-*-c-*-gb2312.1980-0"
  ;; "-outline-隶书-normal-normal-normal-mono-*-*-*-*-c-*-gb2312.1980-0"

  ;; 字体名称中含有中文，如果系统的locale从中文变成英文，那么这些中文字体名将无法识别。

  ;; 直接在字体中指定大小不好，应当用text-scale-set进行缩放。
  ;; 直接在字体中制定了大小，就无法通过text-scale-set进行缩放了。
  ;; 所以，指定字体的时候，大小就写*。
  ;; 但是，又得满足汉字的宽度为字母的两倍，你就不得不指定汉字的大小。
  ;; 所以，最佳的办法还是用一种既包含汉字又包含字母，且汉字宽度为字母两倍的字体。比如雅黑等宽。
  ;; 标准：
  ;; 1. 汉字的宽度为字母的两倍（如果通过组合汉字字体跟字母字体来实现这点，将破坏2）
  ;; 2. 汉字可以与字母同步缩放（这要求汉字跟字母应来自同一个字体）
  ;; 3. 好看
  ;; 所以，需要一种同时包含汉字与字母，且汉字宽度为字母两倍的字体
  ;; 宋体满足1、2，但其字母很难看。微软雅黑满足2与3，却不满足1。有网友自己的做的字体，如雅黑等宽，能满足这些要求。不过是自己做的。
  ;; 要是emacs能支持设定汉字和字母的比例就好了。16号的微软雅黑刚好是两个13号字母的宽度。
  ;; 据说(setq face-font-rescale-alist '(("Microsoft Yahei" . 1.2) ("WenQuanYi Zen Hei" . 1.2)))可以做这个。
  ;; 编程字体为什么需要等宽？因为如用printf之类直接对输出进行排版，为了能所见即所得。


  ;; 1.12
  ;; "-outline-YaHei Consolas Hybrid-normal-normal-normal-mono-*-*-*-*-c-*-iso10646-1"
  ;; "-outline-YaHei Consolas Hybrid-normal-normal-normal-mono-*-*-*-*-c-*-iso8859-5"
  ;; "-outline-YaHei Consolas Hybrid-normal-normal-normal-mono-*-*-*-*-c-*-iso8859-2"
  ;; "-outline-YaHei Consolas Hybrid-normal-normal-normal-mono-*-*-*-*-c-*-iso8859-3"
  ;; "-outline-YaHei Consolas Hybrid-normal-normal-normal-mono-*-*-*-*-c-*-iso8859-7"
  ;; "-outline-YaHei Consolas Hybrid-normal-normal-normal-mono-*-*-*-*-c-*-iso8859-1"
  ;; "-outline-YaHei Consolas Hybrid-normal-normal-normal-mono-*-*-*-*-c-*-gb2312.1980-0"

  ;; YaHei Consolas Hybrid的字母太难看，特别是e，中间那一横太粗。
  ;; 所以，字母还是用Consolas。汉字如果用微软雅黑，则无法跟字母对齐，所以汉字用YaHei Consolas Hybrid
  ;;(set-default-font "-outline-微软雅黑-normal-normal-normal-sans-*-*-*-*-p-*-iso8859-1") ; 微软雅黑的字母不是等宽
  ;;(set-default-font "-outline-YaHei Consolas Hybrid-normal-normal-normal-mono-*-*-*-*-c-*-iso8859-1") ; YaHei Consolas Hybrid的字母太难看。e中间那横太粗。
  (set-frame-font "-outline-Consolas-normal-normal-normal-mono-*-*-*-*-c-*-iso8859-1")
  ;;(set-default-font "-*-Courier New-normal-r-*-*-*-*-*-*-c-*-iso8859-1") ; Courier New跟汉字无法很好配合

  ;;(set-fontset-font "fontset-default" 'chinese-gbk "-outline-微软雅黑-normal-normal-normal-sans-*-*-*-*-p-*-gb2312.1980-0")
  (set-fontset-font "fontset-default" 'chinese-gbk "-outline-YaHei Consolas Hybrid-normal-normal-normal-mono-*-*-*-*-c-*-gb2312.1980-0")

 ;; '(default ((t (:family "Consolas" :foundry "outline" :slant normal :weight normal :height 143 :width normal))))
 ;; '(table-cell ((t (:background "pale goldenrod" :foreground "black" :inverse-video nil))) t))


  ;;(set-face-attribute 'default nil :height 120)

  ;; (load-default-font-setting
  ;;  ;;"-outline-宋体-normal-normal-normal-*-*-120-*-*-p-*-gb2312.1980-0")
  ;;  ;;"-outline-宋体-normal-normal-normal-*-*-*-*-*-p-*-gb2312.1980-0")
  ;;  "-outline-微软雅黑-normal-normal-normal-sans-*-120-*-*-p-*-gb2312.1980-0")
  ;;  ;;"-outline-微软雅黑-normal-normal-normal-sans-*-*-*-*-p-*-gb2312.1980-0")

;;;; 给各种模式设置字体
  ;; 用text-scale-set调整字体大小，会导致auto-compte补全提示参差不齐，
  ;; 所以放弃用text-scale-set调整字体大小，改用Options > Set Default Font...，然后Options > Save Options

  ;;Info mode
  ;; (create-face "infomode"
  ;;              ;; "-*-Courier New-normal-r-*-*-*-140-*-*-c-*-iso8859-1"
  ;;              "-outline-Times New Roman-normal-normal-normal-serif-*-*-*-*-p-*-iso8859-1"
  ;;              "-outline-宋体-normal-normal-normal-*-*-*-*-*-p-*-gb2312.1980-0")
  ;; (add-hook 'Info-mode-hook '(lambda ()
  ;;                              (progn
  ;;                                ;; (buffer-face-set 'infomode)
  ;;                                (text-scale-set 5)
  ;;                                )))


  ;;(message-box "hi")
  ;;(message "hi")

  ;; help mode
  ;; (create-face "helpmode"
  ;;  "-*-Courier New-normal-r-*-*-*-140-*-*-c-*-iso8859-1"
  ;;  "-outline-宋体-normal-normal-normal-*-*-120-*-*-p-*-gb2312.1980-0")
  ;; (add-hook 'help-mode-hook '(lambda ()
  ;;                              (progn
  ;;                                ;;(buffer-face-set 'helpmode)
  ;;                                (text-scale-set 3)
  ;;                                )))


  ;; custom mode
  ;; (create-face "custommode"
  ;;              "-*-Courier New-normal-r-*-*-*-140-*-*-c-*-iso8859-1"
  ;;              "-outline-宋体-normal-normal-normal-*-*-120-*-*-p-*-gb2312.1980-0")
  ;; (add-hook 'Custom-mode-hook '(lambda ()
  ;;                                (buffer-face-set 'custommode)))

  ;; finder mode
  ;; (create-face "findermode"
  ;;              "-*-Courier New-normal-r-*-*-*-140-*-*-c-*-iso8859-1"
  ;;              "-outline-宋体-normal-normal-normal-*-*-120-*-*-p-*-gb2312.1980-0")
  ;; (add-hook 'finder-mode-hook '(lambda ()
  ;;                                (buffer-face-set 'findermode)))

  ;; org mode
  ;; (create-face "mynotes"
  ;;              "-outline-宋体-normal-normal-normal-*-*-120-*-*-p-*-gb2312.1980-0"
  ;;              "-outline-宋体-normal-normal-normal-*-*-120-*-*-p-*-gb2312.1980-0")
  ;; (create-face "mynotes"
  ;;              "-outline-Consolas-normal-normal-normal-mono-*-*-*-*-c-*-iso8859-1"
  ;;              "-outline-YaHei Consolas Hybrid-normal-normal-normal-mono-*-*-*-*-c-*-gb2312.1980-0")

  ;; (add-hook 'org-mode-hook '(lambda ()
  ;;                             (progn
  ;;                               ;;(buffer-face-set 'mynotes)
  ;;                               ;;(message-box "hi")
  ;;                               (text-scale-set 2)
  ;;                               )))

  ;; c++ mode
  ;; (create-face "c++mode"
  ;;  "-outline-Courier New-normal-normal-normal-mono-*-100-*-*-c-*-iso8859-1"
  ;;  "-outline-宋体-normal-normal-normal-*-*-120-*-*-p-*-gb2312.1980-0")
  ;; (add-hook 'c++-mode-hook '(lambda ()
  ;;                             (progn
  ;;                               ;;(buffer-face-set 'c++mode)
  ;;                               (text-scale-set 1)
  ;;                               )))

  ;; (add-hook 'emacs-lisp-mode-hook '(lambda ()
  ;;                                    (progn
  ;;                                      (text-scale-set 2)
  ;;                                      )))

  ;; (add-hook 'haskell-mode-hook '(lambda ()
  ;;                                 (progn
  ;;                                   (text-scale-set 2))))

  )

(defun load-ubuntu-font-settings ()
  ;; (load-default-font-setting
  ;;  "WenQuanYi Micro Hei Mono 12")

  ;; 跟win7下不一样，即便中英文都用YaHei Consolas Hybrid，一个汉字也不等于两个英文字母的宽度
  ;;(set-default-font "-microsoft-Consolas-normal-normal-normal-*-*-*-*-*-m-0-iso10646-1")
  ;;(set-default-font "-microsoft-YaHei Consolas Hybrid-normal-normal-normal-mono-*-*-*-*-*-0-iso10646-1")
  (set-default-font "-microsoft-Yahei Mono-normal-normal-normal-*-*-*-*-*-*-0-iso10646-1")

  ;;(set-default-font "-unknown-WenQuanYi Micro Hei Mono-normal-normal-normal-*-*-*-*-*-*-0-iso10646-1")

  ;;(set-fontset-font "fontset-default" 'chinese-gbk "-microsoft-YaHei Consolas Hybrid-normal-normal-normal-mono-*-*-*-*-*-0-iso10646-1")
  (set-fontset-font "fontset-default" 'chinese-gbk "-microsoft-Yahei Mono-normal-normal-normal-*-*-*-*-*-*-0-iso10646-1")
  ;;(set-fontset-font "fontset-default" 'chinese-gbk "-unknown-WenQuanYi Micro Hei Mono-normal-normal-normal-*-*-*-*-*-*-0-iso10646-1")

  ;; 文泉驿等宽微米黑：中文并非英文两倍宽度，只是英文等宽。


  ;; ;; need to install simsun.ttc of windows
  ;; (create-face "mynotes"
  ;;              "-unknown-SimSun-normal-normal-normal-*-*-120-*-*-d-0-iso10646-1"
  ;;              "-unknown-SimSun-normal-normal-normal-*-*-120-*-*-d-0-iso10646-1")
  ;; (add-hook 'org-mode-hook '(lambda ()
  ;;                             (buffer-face-set 'mynotes)))
  (add-hook 'org-mode-hook '(lambda ()
                              (progn
                                ;;(buffer-face-set 'mynotes)
                                ;;(message-box "hi")
                                (text-scale-set 1)
                                )))

  (create-face "mytex"
               "-unknown-DejaVu Sans Mono-normal-normal-normal-*-13-*-*-*-m-0-iso10646-1"
               "-unknown-SimSun-normal-normal-normal-*-*-120-*-*-d-0-iso10646-1")
  (add-hook 'TeX-mode-hook '(lambda ()
                              (buffer-face-set 'mytex)))



  ;; (create-face "c++mode"
  ;;              "-unknown-DejaVu Sans Mono-normal-normal-normal-*-13-130-*-*-m-0-iso10646-1"
  ;;              "-WenQuanYi-WenQuanYi Bitmap Song-normal-normal-normal-*-*-120-*-*-*-*-iso10646-1")
  ;; (add-hook 'c++-mode-hook '(lambda ()
  ;;                             (buffer-face-set 'c++mode)))
  ;; (add-hook 'c++-mode-hook '(lambda ()
  ;;                             (progn
  ;;                               (text-scale-set 1)
  ;;                               )))

  )
