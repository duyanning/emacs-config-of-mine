(defun just-for-debug (number)
  (interactive "p")
  (progn
    (beginning-of-line)
    (c-indent-command)
    (insert "//{{{ just for debug\n")
    (insert "\n")
    (c-indent-command)
    (insert "//}}} just for debug\n")
    (c-indent-command)
    (forward-line -2)
    (c-indent-command)))

(defun todo (number)
  (interactive "p")
  (progn
    (beginning-of-line)
    (c-indent-command)
    (insert "/* TODO */ assert(false); /* TODO */\n")
    (c-indent-command)))


;;
;; Adds command M-X make-guard
;; this function inserts the standard C header
;; guard in an .h file around any existing text
;; for example if the file
;; is foo-bar_baz.h
;; ---------------------------
;; #ifndef __FOO_BAR_BAZ_H__
;; #define __FOO_BAR_BAZ_H__
;;
;;
;; #ifdef __cplusplus
;; extern "C" {
;; #endif
;;
;; existing code
;;
;;
;; #ifdef __cplusplus
;; } /* extern "C" */
;; #endif
;; #endif /* __FOO_BAR_BAZ_H__*/
;;
;; ----------------------------------
(defun make-guard (number)
  (interactive "p")
  (message "num is %d" number)
  (let ((buffer-name (buffer-name (current-buffer))))
    (if (eq (compare-strings buffer-name
                             (- (length buffer-name) 2) nil
                             ".h" 0 nil t) t)
        (insert-header-guard buffer-name (> number 1))
      (message "File must be a header file (.h)"))))


(defun insert-header-guard (buffer-name extern-C)
  (let* ((split-name (split-string buffer-name "[-_.]"))
         (guard-def (concat ""
                            (mapconcat (lambda (x) (upcase x))
                                       split-name  "_")
                            "")))
    (save-excursion
      (progn
        (goto-char 0)
        (insert "#ifndef ")
        (insert guard-def)
        (insert "\n")
        (insert "#define ")
        (insert guard-def)
        (insert "\n\n\n")
        (if extern-C
            (insert "#ifdef __cplusplus
extern \"C\" {
#endif\n\n"))

        (goto-char (point-max))
        (if extern-C
            (insert "\n\n#ifdef __cplusplus
} /* extern \"C\" */
#endif\n\n"))
        (insert "\n\n#endif // ")
        (insert guard-def)))))


;; 参考了ebrowse.el中函数ebrowse-revert-tree-buffer-from-file的实现
(defun rebuild-and-reload-BROWSE ()
  "rebuild and reload BROWSE"
  (interactive)
  (if (get-buffer "*Tree*")
    (save-excursion

      (set-buffer "*Tree*")

      ;; ebrowse *.cpp *.h
      (call-process-shell-command  "ebrowse" nil nil nil "*.cpp *.h")

      (dolist (member-buffer (ebrowse-same-tree-member-buffer-list))
        (kill-buffer member-buffer))

      (let ((BROWSE-path (buffer-file-name)))
        (kill-buffer)
        (find-file-noselect BROWSE-path))

      (message "refreshed"))

    (message "You have NOT specified BROWSE")))

;;(rebuild-and-reload-BROWSE)


(defun indent-forward ()
  (interactive)
  (beginning-of-line)
  (insert "    ")
  (back-to-indentation)
  )

(defun indent-backword ()
  (interactive)
  (message "i am foo"))

;;(global-set-key (kbd "TAB") 'indent-forward)


;; This hack fixes indentation for C++11's "enum class" in Emacs.
;; http://stackoverflow.com/questions/6497374/emacs-cc-mode-indentation-problem-with-c0x-enum-class/6550361#6550361

(defun inside-class-enum-p (pos)
  "Checks if POS is within the braces of a C++ \"enum class\"."
  (ignore-errors
    (save-excursion
      (goto-char pos)
      (up-list -1)
      (backward-sexp 1)
      (looking-back "enum[ \t]+class[ \t]+[^}]*"))))

(defun align-enum-class (langelem)
  (if (inside-class-enum-p (c-langelem-pos langelem))
      0
    (c-lineup-topmost-intro-cont langelem)))


;; c-indent-command
;;   (funcall indent-function)
;;     indent-according-to-mode
;;       indent-line-function所指的函数，即c-indent-line
;;         (setq c-syntactic-context (c-guess-basic-syntax))得到光标处的语法上下文
;;         (setq indent (c-get-syntactic-indentation c-syntactic-context)) 此时得到的indent为0
;;         (setq shift-amt (- indent (current-indentation))) 求出的shift-amt也是0
;;         (c-shift-line-indentation shift-amt) 没有移动光标
;;         (run-hooks 'c-special-indent-hook)
;;           c-gnu-impose-minimum 就是因为这一行，enum class的}总是向右太多
;;             (c-shift-line-indentation (- c-label-minimum-indentation (current-indentation)))
;; 就是因为c-gnu-impose-minimum，enum class的}总是向右太多，但把c-default-style中C++的风格设为stroustrup就好了，默认是gnu
(defun align-enum-class-closing-brace (langelem)
  (if (inside-class-enum-p (c-langelem-pos langelem))
      '-
    '+))


(defun fix-enum-class ()
  "Setup `c++-mode' to better handle \"class enum\"."
  (add-to-list 'c-offsets-alist '(topmost-intro-cont . align-enum-class))
  (add-to-list 'c-offsets-alist
               '(statement-cont . align-enum-class-closing-brace)))

;;(add-hook 'c++-mode-hook 'fix-enum-class)

;; C-x = to show char position
;; M-x goto-char
;; C-c C-s to show anchor point
;; c-echo-syntactic-information-p
;; As you configure CC Mode, you might want to set the variable c-echo-syntactic-information-p to non-nil so that the syntactic context and calculated offset always is echoed in the minibuffer when you hit TAB. 
