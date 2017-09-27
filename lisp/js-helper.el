;; 可参考comment-region
;; 可利用M-x re-builder构造正则表达式
(defun stringify (beg end &optional arg)
  (interactive "*r\np")
  (message "%d %d %d" arg beg end)
  (if (> arg 1)
      ;; 去引号
      (progn
        ;;(replace-regexp "^\s*\\+ '\\(.*\\)'\s*$" "\\1" nil beg end)
        (replace-regexp "^\s*\\+ '\\(.*\\)'\s*$" "\\1" nil (point-min) (point-max))
        )
    ;; 加引号
    ;;(replace-regexp "^\\([^ \t\n]+.*\\)$" "+ '\\1'" nil beg end)
    (replace-regexp "^\\(.*\\)$" "+ '\\1'" nil (point-min) (point-max))
    )
  )

;; (load "js-helper.el" nil t t)



;; (defun ws-add-region-as-word (beg end)
;;   (interactive (list (point) (mark)))
;;   (ws-add-word (buffer-substring-no-properties beg end))
;;   )
