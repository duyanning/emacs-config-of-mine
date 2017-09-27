;; smart-kill-mode


;; 想要解决的问题：
;; 在编写程序时，我们往往会copy一些文本，然后粘贴到文件中好几个地方。
;; 在这个过程中，我们往往会kill另一些文本。
;; 此时就发生问题了：一旦我们在该过程中kill，它就会替换掉剪贴板中原来的内容，以至于我们再次yank时，出来的就不是我们想要的东西了。


;; 解决办法：
;; yank之后，如果不移动光标，立即M-d或C-k，这些M-d或C-k删除掉的文本就不会进入剪贴板。


;;------------------------(以下为实现部分)-----------------------------------------
;; 因为我们会临时用delete-region的定义替换kill-region的定义，所以得先保存kill-region的定义
(fset 'original-kill-region (symbol-function 'kill-region))

;; 上一次smart kill执行的是kill，还是kill (without kill ring)
(defvar smart-kill-last-operation nil)
(make-local-variable 'smart-kill-last-operation)


;; 上一次smart kill之后point的位置
(defvar smart-kill-last-point nil)
(make-local-variable 'smart-kill-last-point)


(defun smart-kill-word (arg)
  "smart kill word"
  (interactive "p")
  ;; 先关闭smart-kill小模式，然后看M-d对应那个函数
  (smart-kill-mode -1)
  (let ((original-M-d (key-binding "\M-d")))
    (if (or
         (eq last-command 'yank)
         (and
          (eq smart-kill-last-operation 'kill-without-kill-ring)
          (equal (point) smart-kill-last-point)))
        (progn
          (fset 'kill-region 'delete-region)
          (funcall original-M-d arg)
          (fset 'kill-region (symbol-function 'original-kill-region))

          (setq smart-kill-last-operation 'kill-without-kill-ring)
          (setq smart-kill-last-point (point))
          (message "kill word (without kill ring)"))

      (funcall original-M-d arg)

      (setq smart-kill-last-operation 'kill)
      (message "kill word")))
  (smart-kill-mode 1))


(defun smart-kill-line (&optional arg)
  "smart kill line"
  (interactive "P")
  ;; 先关闭smart-kill小模式，然后看C-k对应那个函数
  (smart-kill-mode -1)
  (let ((original-C-k (key-binding "\C-k")))
    (if (or
         (eq last-command 'yank)
         (and
          (eq smart-kill-last-operation 'kill-without-kill-ring)
          (equal (point) smart-kill-last-point)))
        (progn
          (fset 'kill-region 'delete-region)
          (funcall original-C-k arg)
          (fset 'kill-region (symbol-function 'original-kill-region))

          (setq smart-kill-last-operation 'kill-without-kill-ring)
          (setq smart-kill-last-point (point))
          (message "kill line (without kill ring)"))

      (funcall original-C-k arg)

      (setq smart-kill-last-operation 'kill)
      (message "kill line")))
  (smart-kill-mode 1))


;;---------------------------------------------------
(defun install-smart-kill-key-bindings ()
  (global-set-key "\M-d" 'smart-kill-word)
  (global-set-key "\C-k" 'smart-kill-line)
  )

;;(install-smart-kill-key-bindings)


(define-minor-mode smart-kill-mode
  "Toggle Smart Kill mode."
  :init-value nil
  :lighter " SmartKill"
  ;;:global t
  :keymap
  '(
    ([?\M-d] . smart-kill-word)
    ([?\C-k] . smart-kill-line)
    )
  )


(defun turn-on-smart-kill ()
  "Unconditionally turn on Smart Kill mode."
  (smart-kill-mode 1))

(defun turn-off-smart-kill ()
  "Unconditionally turn off Smart Kill mode."
  (smart-kill-mode -1))

;;(turn-on-smart-kill)
;;(turn-off-smart-kill)


;;; Announce

(provide 'smart-kill)


;; ============
