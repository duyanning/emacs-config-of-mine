(defun foobar (buf-name, u)
  (let* (
         (y (split-string buf-name "[-_.]"))
         )
    (message "abc")
    (message "%d" u)
    ))

(defun barfoo (buffer-name)
  (let* (
         (y (split-string buffer-name "[-_.]"))
         )
    (message "abc")
    ))


         ;; (guard-def (concat ""
         ;;                    (mapconcat (lambda (x) (upcase x))
         ;;                               split-name  "_")
         ;;                    "")))
