;; while pmh-mode enabled, point movement will cause pmh-hook invoked.

;; Warning: do not use make-local-variable for a hook variable. The
;; hook variables are automatically made buffer-local as needed if you
;; use the local argument to add-hook or remove-hook.
;; (Emacs 24.1 manual: 11.10.2 Creating and Deleting Buffer-Local Bindings)
(defvar pmh-hook nil)
;; (make-local-variable 'pmh-hook)

;;(defvar current-buffer-change-hook nil)



;; todo:���޿���ִ����ĳЩ����ı��˹���µ����֣���û�иı���λ�ã�
;; �����������������Ͳ�Ӧ���Թ��λ�÷����仯Ϊ���ݡ��������᲻�Ὺ��
;; ��������������󣬻�����������׼ȷ�ԡ�
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
        ;; ע�⣬add-hook���Ĳ���t����buffer-local��������pmh-mode��buffer��pre/post-command-hook�ϲŹ��Ŵ�����
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

