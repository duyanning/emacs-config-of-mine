(defun use-color-theme (theme)
  "use specified color theme"
  (interactive
   (list
    (completing-read "Use color theme: " '(("blackboard" 1) ("deep-blue" 2)))
    ))
  (funcall (intern-soft (concat "color-theme-" theme))))


;;(rebuild-and-reload-BROWSE)

(provide 'color-theme-helper)