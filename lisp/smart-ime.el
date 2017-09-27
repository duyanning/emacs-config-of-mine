;;;; 想要解决的问题：
;; *) 避免输入法干扰按键序列的完成
;; 如果输入法处于开启状态，会干扰emacs的使用。
;; 例如C-x b和C-h t，如果输入法处于开启状态，b和t都会让输入法以为你键入了拼音，从而出现组字窗口。
;; 如果能在输入按键序列之前自动关闭输入法就好了。
;; *) 输入命令名之前自动进入英文状态
;; 如果你想执行M-x version，为了输入version，你就不得不关闭输入法。如果能在按下M-x后自动关闭输入法就好了。
;; *) 在某些特定的buffer中禁用输入法
;; 如*Org Agenda*这种buffer，其中很多命令都是单字符形式，而单字符会导致组字窗口出现。如果能在这类buffer中禁用输入法就好了。


;;;; 解决方案：
;; *) 避免输入法干扰按键序列的完成
;; 启用smart-ime-mode时，前缀键被绑定到我们提供的“前缀键处理函数”上
;; 所以按下前缀键后，会唤起“前缀键处理函数”
;; 该函数做下面几件事：
;;   1) 关闭输入法编辑器
;;   2) 取消前缀键与“前缀键处理函数”的绑定，让前缀键重新绑定到keymap上
;;   3) 将前缀键重新送回事件队列，就好像我们没处理过前缀键一样
;; 然后，包括前缀键在内的按键序列像往常一样被处理
;; 命令执行完毕后，再次将前缀键绑定到我们的“前缀键处理函数”上
;; *) 输入命令名之前自动进入英文状态
;; M-x即执行execute-extended-command前后，因为要输入命令名，也应临时关闭输入法
;; *) 在某些特定的buffer中禁用输入法
;; 在每个命令结束后都检测当前处于哪个buffer中，如果处在禁用IME的buffer中，就关闭输入法。
;; 如果之前IME处于开启状态，就再次打开IME。如果之前IME处于关闭状态，什么也不做。


;;;; 一些实现细节:
;; (ime-set-status arg) t打开IME；nil关闭IME
;; (ime-get-status) 确定IME是打开的还是关闭的，t表示打开，nil表示关闭
;; 这两个函数的实现在.c代码中。
;; 这是因为GNU Emacs不支持Foreign Function Interface (FFI)，为了实现这两个函数需要修改emacs的源码。
;; 特别说明：通过(ime-set-status nil)关闭IME，其效果跟按Shift键切换到英文状态差不多，不同的是那个输入法的小条条会藏起来。
;; 也就是说，如果后边不用(ime-set-status t)来让它重新显形，你就得按两次Ctrl-Space才能让这个小条条重新出现。
;; 第一次是真正关闭IME，第二次是再次激活IME。
;; 这都是windows的机制，与俺无关。


;;;; 已知的问题：
;; 启用本模式后，Help菜单中的C-h都变成了<f1>。Org菜单中以C-c打头的提示都没了。
;; 这是因为C-h和C-c被绑定到了一个函数上。
;; cua-mode也有同样的问题，当高亮选中一片区域后，Org菜单也会发生一样的问题。
;; 但因为cua-mode并没有绑定C-h，所以Help菜单是好的。


;;;; 与各种输入法相关的问题：
;; 我们用的输入法其实有很多bug，这些bug只有你通过程序操作输入法时才能暴露出来。
;; *) 搜狗输入法
;; 版本：6.5
;; 由于搜狗拼音输入法中的一个bug，第一次关闭输入法将没有任何效果。
;; 此时按退格删除组字窗口中的字母，然后按C-g即可，以后就正常了。
;; *) QQ拼音
;; 版本：4.5
;; 每次自动关闭开启输入法都会导致标点符号状态恢复到基本设置中的初始状态。
;; 解决办法：高级设置>自定义功能，清除“所有程序保持一致的中英文、全半角及标点符号状态”前的复选框。再选中，似乎从此就好了。
;; *) 拼音加加
;; 版本：5.2
;; 当关闭IME时，输入法的小条条并不会消失。但没有任何不良影响。


;;;; 实现


(defvar ime-status nil)


(defun ime-save-and-set-status (arg)
  ;; 在禁用IME的buffer中按下前缀键时，不要保存IME状态。
  (when (not (is-no-IME-buffer-p))
    (setq ime-status (ime-get-status))
    )
  (ime-set-status arg)
  )


(defun ime-restore-status (tag)
  (ime-set-status ime-status)
  (when smart-ime--debug
    (message tag))
  )



(defvar smart-ime--state 'normal)
(defvar smart-ime--debug nil)
;; 是否启用prefix-override-keymap，若启用，前缀键将与“前缀键处理函数”绑定
(defvar smart-ime--ena-prefix-override-keymap nil)
;; prefix-override-keymap，其中将前缀键绑定到“前缀键处理函数”
(defvar smart-ime--prefix-override-keymap (make-sparse-keymap))

;; 所用keymap是否已初始化
(defvar smart-ime--keymaps-initialized nil)

;; 指明某个keymap由哪个ena变量使能
(defvar smart-ime--keymap-alist
  `(
    (smart-ime--ena-prefix-override-keymap . ,smart-ime--prefix-override-keymap)
    )
  )


;; 初始化keymap
(defun smart-ime--init-keymaps ()
  ;; 按下后需要关闭输入法的前缀键：C-x、C-c、C-h
  (define-key smart-ime--prefix-override-keymap [(control x)] 'smart-ime--prefix-override-handler)
  (define-key smart-ime--prefix-override-keymap [(control c)] 'smart-ime--prefix-override-handler)
  (define-key smart-ime--prefix-override-keymap [(control h)] 'smart-ime--prefix-override-handler)
  )


;; 前缀键处理函数
(defun smart-ime--prefix-override-handler (arg)
  "前缀键处理函数"
  (interactive "P")
  (smart-ime--prefix-override-replay arg))

(defun smart-ime--prefix-override-replay (arg)
  (let* ((keys (this-command-keys))
         (i (length keys))
         (key (aref keys (1- i))))

    ;; 暂时关闭输入法（将在命令执行完毕后恢复）
    (ime-save-and-set-status nil)

    ;; 命令执行完毕时执行钩子函数smart-ime--post-command-handler
    ;; 注意，该钩子函数一旦被挂上，“前缀键处理函数”完毕后就会被唤起
    (add-hook 'post-command-hook 'smart-ime--post-command-handler)
    (setq smart-ime--state 'prefix)

    ;; 取消前缀键与“前缀键处理函数”的绑定，恢复默认状态
    (setq smart-ime--ena-prefix-override-keymap nil)

    ;; 将前缀键送回事件队列
    ;; Don't record this command
    (setq this-command last-command)
    ;; Restore the prefix arg
    (setq prefix-arg arg)
    (reset-this-command-lengths)
    ;; Push the key back on the event queue
    (setq unread-command-events (cons key unread-command-events))))


;; (defun smart-ime--pre-command-handler-1 ()
;;   )

;; (defun smart-ime--pre-command-handler ()
;;   (when smart-ime-mode
;;     (condition-case nil
;;         (smart-ime--pre-command-handler-1)

;;         ;; (progn (add-log-entry "pre command %d\n" pre-count)
;;         ;;        (setq pre-count (1+ pre-count)))

;;       (error nil))))


;; 命令执行结束后执行的动作
(defun smart-ime--post-command-handler-1 ()
  (cond ((eq smart-ime--state 'prefix)
         (setq smart-ime--state 'sequence))


        ((eq smart-ime--state 'sequence)
         ;; 恢复输入法状态
         (ime-restore-status "1")
         ;; 恢复前缀键与“前缀键处理函数”的绑定
         (setq smart-ime--ena-prefix-override-keymap t)
         (setq smart-ime--state 'normal)

         (remove-hook 'post-command-hook 'smart-ime--post-command-handler)
         ;;(setq ime-status)
         )

        (t
         (error "error state"))))


(defun smart-ime--post-command-handler ()
  (when smart-ime-mode
    (condition-case nil
        (smart-ime--post-command-handler-1)
      ;; (progn (add-log-entry "post command %d\n" post-count)
      ;;        (setq post-count (1+ post-count)))
      (error nil))))


;; ;; 或许可用minibuffer-setup-hook、minibuffer-exit-hook代替
;; (defadvice execute-extended-command (around manage-ime
;;                                             (prefixarg &optional COMMAND-NAME))
;;   "Ignore case in `foo'."
;;   ;; 暂时关闭输入法（将在命令执行完毕后恢复）
;;   (ime-save-and-set-status nil)

;;   ad-do-it

;;   ;; 恢复输入法状态
;;   (ime-restore-status "2")
;; )


(defvar no-IME-buffer-list '("*Org Agenda*"
                             "*Buffer List*"
                             "*Backtrace*"
                             "Douban Music")
  "把buffer的名字放在这个list就表明在这个buffer中禁用IME")


(defun is-no-IME-buffer-p ()
  ;;(message ">>>%s" (buffer-name))
  (member (buffer-name) no-IME-buffer-list)
  )


;; 在某些特定的buffer中，要关闭IME。这些buffer称为no-IME-buffer，即禁用IME的buffer。
;; 为了能按预期正常工作，必须确保smart-ime--post-command-no-IME-buffer-handler在smart-ime--post-command-handler之后被唤起。
;; 所以add-hook的顺序很重要。
(defun smart-ime--post-command-no-IME-buffer-handler ()
  (when (eq smart-ime--state 'normal)
    (if (is-no-IME-buffer-p)
        (ime-set-status nil)
      (when (not (minibufferp)) 
        (when ime-status
          (ime-set-status t))
        )
      )
    )
  )


(define-minor-mode smart-ime-mode
  "Toggle Smart IME mode."
  :init-value nil
  :lighter " SmartIME"
  :global t

  (unless smart-ime--keymaps-initialized
    (smart-ime--init-keymaps)
    (setq smart-ime--keymaps-initialized t))

  ;; (if smart-ime-mode
  ;;     (progn
  ;;       (add-hook 'pre-command-hook 'smart-ime--pre-command-handler)
  ;;       (add-hook 'post-command-hook 'smart-ime--post-command-handler))
  ;;   (remove-hook 'pre-command-hook 'smart-ime--pre-command-handler)
  ;;   (remove-hook 'post-command-hook 'smart-ime--post-command-handler))

  (when smart-ime-mode
    (add-hook 'post-command-hook 'smart-ime--post-command-no-IME-buffer-handler)
    )

  (unless smart-ime-mode
    (remove-hook 'post-command-hook 'smart-ime--post-command-handler)
    (remove-hook 'post-command-hook 'smart-ime--post-command-no-IME-buffer-handler)
    )


  (if (not smart-ime-mode)
      (setq emulation-mode-map-alists (delq 'smart-ime--keymap-alist emulation-mode-map-alists))
    (add-to-ordered-list 'emulation-mode-map-alists 'smart-ime--keymap-alist 400)
    (setq smart-ime--ena-prefix-override-keymap t))

  (if smart-ime-mode
      (progn
        ;;(ad-enable-advice 'execute-extended-command 'around 'manage-ime)
        (add-hook 'minibuffer-setup-hook '(lambda ()
                                        (ime-save-and-set-status nil)))
        (add-hook 'minibuffer-exit-hook '(lambda ()
                                        (ime-restore-status "2")))
        )
    ;;(ad-disable-advice 'execute-extended-command 'around 'manage-ime)

    )
  ;;(ad-activate 'execute-extended-command) ; 无论enable还是disable，都需要调用一次activate
  ;;;;(ad-deactivate 'execute-extended-command)


  )

;; 或许可用minibuffer-setup-hook、minibuffer-exit-hook代替
  ;; ;; 暂时关闭输入法（将在命令执行完毕后恢复）
  ;; (ime-save-and-set-status nil)

  ;; ad-do-it

  ;; ;; 恢复输入法状态
  ;; (ime-restore-status "2")



;;;; 备忘：
;; 按键序列结束后，才会触发一次post-command-hook



;;; Announce

(provide 'smart-ime)



(defun smart-ime-debug ()
  "Toggle SMART-IME debugging."
  (interactive)
  (setq smart-ime--debug (not smart-ime--debug)))
