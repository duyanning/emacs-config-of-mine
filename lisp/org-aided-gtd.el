;; (defun tag-as-action ()
;;   (interactive "p"))

(defun new-sub-project (arg)
  "Ϊ��ǰ�ڵ�����һ���µ�������Ϊ����Ŀ"
  (interactive "P")
  (org-insert-subheading arg))


;; ����outline.el/outline-up-heading�޸Ķ���
(defun move-up-to-topmost-heading (&optional invisible-ok)
  "�ƶ�������ı��⴦��������"
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


;; ��ȡ���ò��֣����Թ�����������ƶ��������䡢�ƶ���������
(defun move-to-projects (arg)
  "���������ƶ�����Ŀ�б�����Ϊһ���µ���Ŀ"
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
