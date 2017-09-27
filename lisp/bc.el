(defvar bc-running-p nil)

(defun bc-output (process output)
  (insert "=")
  (insert output)
  (backward-delete-char-untabify 1))

(defun bc-eval-region (beg end)
  "evaluate region using the bc calculator"
  (interactive (list (point) (mark)))
  (unless bc-running-p
    (start-process "bc" "*bc*" "bc" "-q")
    (process-send-string "bc" "scale=4\n")
    (set-process-filter (get-process "bc") 'bc-output)
    (setq bc-running-p t))
  (process-send-string "bc"
                       (concat
                        (buffer-substring-no-properties beg end)
                        "\n")))

(provide 'bc)