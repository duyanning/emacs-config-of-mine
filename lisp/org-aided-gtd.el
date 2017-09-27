;; (defun tag-as-action ()
;;   (interactive "p"))

(defun new-sub-project (arg)
  "为当前节点生成一棵新的子树作为子项目"
  (interactive "P")
  (org-insert-subheading arg))


;; 根据outline.el/outline-up-heading修改而来
(defun move-up-to-topmost-heading (&optional invisible-ok)
  "移动到最顶级的标题处，即树根"
  (interactive "p")
  (outline-back-to-heading invisible-ok)
  (let ((start-level (funcall outline-level)))
    (while (and (> start-level 1) (not (bobp)))
      (let ((level start-level))
        (while (not (or (< level start-level) (bobp)))
          (if invisible-ok
              (outline-previous-heading)
            (outline-previous-visible-heading 1))
          (setq level (funcall outline-level)))
        (setq start-level level))
      ))
  )


;; 提取公用部分，可以构造其他命令：移动到垃圾箱、移动到孵化器
(defun move-to-projects (arg)
  "将整棵树移动到项目列表中作为一个新的项目"
  (interactive "p")
  (move-up-to-topmost-heading)
  (org-cut-subtree) 
  (save-excursion
    (find-file "~/gtd/actionable/multi-steps/projects.txt")
    (goto-char (point-max))
    (newline)
    (yank))
  (switch-to-buffer (current-buffer))
  )


(provide 'org-aided-gtd)
