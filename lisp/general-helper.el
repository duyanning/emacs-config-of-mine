;; smart-ime-mode会干扰此函数，用前先关闭smart-ime-mode
;; (defun insert-key-sequence (key)
;;   "插入按键序列"
;;     (interactive "kInseret key sequence: ")
;;     (insert (key-description key) "\t\t\t"))

;; 直接通过interactive来读取按键序列是不行的，因为该函数执行后第一件事情就是切换到minibuffer，以至于来不及在原来的buffer中关闭smart-ime-mode
;; 所以，改用如下这个函数。

(defun insert-key-sequence ()
  "插入按键序列"
    (interactive)
    (ime-save-and-set-status 0)
    (let ((on smart-ime-mode))
      (smart-ime-mode -1)
      (insert (key-description
               (read-key-sequence "Insert key sequence: "))
              "\t\t\t")
      (when on
        (smart-ime-mode)))
    (ime-restore-status "3"))


(defun go-tail (from to)
  "把选中的region移到文档末尾"
  (interactive (list (region-beginning) (region-end)))
  (let ((a t))
    (if mark-active
        (progn
          (save-restriction
            (widen)
            (save-excursion
              (goto-char (point-max))
              (newline)
              (append-to-buffer (current-buffer) from to))) ; save-restriction
          (delete-region from to)) ; progn

      (message "region is not active!!!"))))


(defun toggle-line-spacing ()
  "开关行间距"
  (interactive)
  (if (or (not (boundp 'line-spacing))
          (equal line-spacing nil))
      (setq line-spacing 5)
    (setq line-spacing nil)))

;; (toggle-line-spacing)


;; 模仿其他编辑器，创建一个不关联任何文件的buffer。
(defun new-untitled ()
  "create a new untitled file"
  (interactive)
  (switch-to-buffer (generate-new-buffer "Untitled"))
  (setq buffer-offer-save t)            ; 关闭emacs时询问是否保存
  ;; kill-buffer时询问是否保存
  (add-hook 'kill-buffer-hook '(lambda () 
                                 (when (and (buffer-modified-p)
                                            (y-or-n-p "Buffer modified; save it?"))
                                   (save-buffer)))
            nil t)
  )


;; 复制文件路径到剪贴板
(defun cp-path (arg)
  "copy the full path of the file in current buffer to the clipboard"
  (interactive "p")
  ;; (message "%d" arg)
  (cond ((= arg 1) (kill-new (message (buffer-file-name))))
        ((= arg 4) (kill-new (message (replace-regexp-in-string "/" "\\\\" (buffer-file-name)))))
        ((= arg 16) (kill-new (message (replace-regexp-in-string "/" "\\\\\\\\" (buffer-file-name)))))
        )
  )


;; 打开.emacs文件
(defun open-init-file ()
  "Open the .emacs file"
  (interactive)
  (find-file user-init-file))

(defun no-op ()
  ""
  (interactive))


;; 删除当前region中的重复行（不要求重复行挨在一起）
(defun uniquify-all-lines-region (start end)
  "Find duplicate lines in region START to END keeping first occurrence."
  (interactive "*r")
  (save-excursion
    (let ((end (copy-marker end)))
      (while
          (progn
            (goto-char start)
            (re-search-forward "^\\(.*\\)\n\\(\\(.*\n\\)*\\)\\1\n" end t))
        (replace-match "\\1\n\\2")))))

;; 删除当前buffer中的重复行（不要求重复行挨在一起）
(defun uniquify-all-lines-buffer ()
  "Delete duplicate lines in buffer and keep first occurrence."
  (interactive "*")
  (uniquify-all-lines-region (point-min) (point-max)))

;; 将多行连在一起，其实就是用空格替代回车
;; M-x replace-string RET C-q C-j RET SPC RET

;; 将代码中的弯引号替换为直引号
(defun w2z (start end)
  ""
  (interactive "*r")
  (while (search-forward "“" nil t)
    (replace-match "\"" nil t))
  (while (search-forward "”" nil t)
    (replace-match "\"" nil t))

  )


;; 加强版的kill-buffer
;; 支持kill所有buffer
;; http://superuser.com/questions/895920/how-can-i-close-all-buffers-in-emacs
(defun custom-kill-buffer-fn (&optional arg)
  "When called with a prefix argument -- i.e., C-u -- kill all interesting
buffers -- i.e., all buffers without a leading space in the buffer-name.
When called without a prefix argument, kill just the current buffer
-- i.e., interesting or uninteresting."
  (interactive "P")
  (cond
   ((and (consp arg) (equal arg '(4)))
    (mapc
     (lambda (x)
       (let ((name (buffer-name x)))
         (unless (eq ?\s (aref name 0))
           (kill-buffer x))))
     (buffer-list)))
   (t
    (kill-buffer (current-buffer)))))

(global-set-key (kbd "C-x k") 'custom-kill-buffer-fn)


;; try (current-time-string) 

(defun now ()
  "Insert string for the current time formatted like '2:34 PM'."
  (interactive)                 ; permit invocation in minibuffer
  (insert (format-time-string "%D %-I:%M %p")))

(defun today ()
  "Insert string for today's date nicely formatted in American style,
e.g. Sunday, September 17, 2000."
  (interactive)                 ; permit invocation in minibuffer
  (insert (format-time-string "%A, %B %e, %Y")))
