(defun add-log-entry (format-string &rest args)
  "Add a given message string to the end of a file."
  (append-to-file (apply 'format format-string args) nil "~/debug-log.txt"))

;; (add-log-entry "hi %d\n" 1)


;;; Announce

(provide 'debug-log)
;;(require 'debug-log)

