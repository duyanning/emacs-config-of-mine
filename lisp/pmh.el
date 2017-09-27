;; while pmh-mode enabled, point movement will cause pmh-hook invoked.

;; Warning: do not use make-local-variable for a hook variable. The
;; hook variables are automatically made buffer-local as needed if you
;; use the local argument to add-hook or remove-hook.
;; (Emacs 24.1 manual: 11.10.2 Creating and Deleting Buffer-Local Bindings)
(defvar pmh-hook nil)
;; (make-local-variable 'pmh-hook)

;;(defvar current-buffer-change-hook nil)



;; todo:有无可能执行了某些命令，改变了光标下的文字，但没有改变光标位置？
;; 如果存在这种情况，就不应该以光标位置发生变化为依据。但这样会不会开销
;; 过大？如果开销过大，还不如牺牲点准确性。
;; window-text-change-functions
;; after-change-functions
(defvar point-motion-last-point 0)
;; (make-local-variable 'point-motion-last-point)


;;(defvar current-buffer-change-)


(defun pmh--pre-command-handler ()
  (setq point-motion-last-point (point)))


(defun pmh--post-command-handler ()
  (when (not (equal point-motion-last-point (point)))
    (run-hooks 'pmh-hook)))


(define-minor-mode pmh-mode
  "Toggle point motion hook mode."
  :init-value nil
  :lighter " PMH"
  :global t                      

  (if pmh-mode
      (progn
        ;; 注意，add-hook最后的参数t表明buffer-local，即开启pmh-mode的buffer的pre/post-command-hook上才挂着处理函数
        (add-hook 'pre-command-hook 'pmh--pre-command-handler nil t)
        (add-hook 'post-command-hook 'pmh--post-command-handler nil t)

        (make-local-variable 'point-motion-last-point)

        )
    (remove-hook 'pre-command-hook 'pmh--pre-command-handler t)
    (remove-hook 'post-command-hook 'pmh--post-command-handler t))


  )


(provide 'pmh)


;;================================================================
;; for debug
;; (defun show-point ()
;;   (message "%d -> %d" point-motion-last-point (point)))

;; (add-hook 'pmh-hook 'show-point)

