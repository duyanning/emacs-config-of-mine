(setq struct-frame nil)
(setq struct-frame-name "文档结构图")
(setq struct-buffer nil)
(setq struct-buffer-name "*文档结构图*")


;; 打开文档的结构图
(defun doc-struct-open ()
  (catch 'return
    (let (
          temp
          )

      ;; 如果还没有结构图frame，就产生出来
      (unless (frame-live-p struct-frame)
        (setq struct-frame (make-frame))
        (set-frame-parameter struct-frame 'name struct-frame-name)
        )

      ;; 如果还没有结构图buffer，就产生出来
      (unless (buffer-live-p struct-buffer)
        (setq struct-buffer
              (clone-indirect-buffer struct-buffer-name nil))

        (setq doc-buffer (current-buffer))
        )

      ;; 如果结构图buffer反映的不是当前buffer，则重新创建结构图buffer
      (when (not (eq doc-buffer (current-buffer)))
        (kill-buffer struct-buffer)
        (setq struct-buffer
              (clone-indirect-buffer struct-buffer-name nil))

        (setq doc-buffer (current-buffer))
        )

      ;; 让结构图frame成为当前frame
      (select-frame-set-input-focus struct-frame)

      ;; 让结构图frame的当前窗口切换至结构图buffer
      (switch-to-buffer struct-buffer)



      )
    ) ;; return
  )


;; 在文档和结构图的相应位置处来回跳转
(defun doc-struct-swap ()
  (interactive)
  (let (
        pos
        target-buffer
        target-frame
        )

    (setq pos (point))

    ;; 若结构图buffer在，则文档buffer必在；反之则不然。
    (if (eq (current-buffer) struct-buffer)
        (progn
          (setq target-buffer doc-buffer)
          )
      (doc-struct-open)
      (setq target-buffer struct-buffer)
      )

    (setq target-frame
          (window-frame
           (get-buffer-window target-buffer t)))
    (select-frame-set-input-focus target-frame)
    (goto-char pos)
    )
  )

(global-set-key "\C-cs" 'doc-struct-swap)


;;; Announce

(provide 'doc-struct)
