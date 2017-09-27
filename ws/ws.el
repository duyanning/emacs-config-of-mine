;;; ws.el ---

;; Authors:
;; Ye Wenbin <wenbinye@gmail.com>
;; Du Yanning <duyanning@gmail.com>


;;

;; Put this file into your load-path and the following into your ~/.emacs:
;;   (require 'ws)
;;
;; Use M-x ws-mode to enable M-f (forward-word) and M-b (backward-word).

;;; Code:

(eval-when-compile
  (require 'cl))

(defvar ws-initialized nil)
(defvar ws-words-buffer nil)
(defvar ws-reverse-words-buffer nil)

(defvar ws-words-file "~/emacs-config-of-mine/ws/words.txt")
(defvar ws-reverse-words-file "~/emacs-config-of-mine/ws/rwords.txt")

(defun ws-init ()
  (unless ws-initialized
    (save-excursion
      (set-buffer (generate-new-buffer " ws-words")) ; buffer名字前加空格，避免在emacs中编辑这两个文件，因为要在buffer中移动光标，会干扰
      (insert-file-contents ws-words-file)
      (setq ws-words-buffer (current-buffer))
      (set-buffer (generate-new-buffer " ws-rwords"))
      (insert-file-contents ws-reverse-words-file)
      (setq ws-reverse-words-buffer (current-buffer))
      (setq ws-initialized t))))


;; 折半查找（递归实现）
;; prefix 待找字符串，为一个汉字
;; start end 界定查找范围，为字符在buffer中的位置，而非行号
;; 找到（只匹配某行的前缀也算），返回该行
;; 没找到，返回nil
;; 会在两个字库中移动光标
;; 找到，光标位于命中行
;; 没找到，光标位于最后查找行
(defun ws-bisearch-word (prefix start end)
  (let ((mid (/ (+ start end) 2))
        (len (length prefix))           ; len必然为1
        line)
    (goto-char mid)
    (beginning-of-line)
    (setq line (buffer-substring-no-properties (point) (+ (point) len)))
    (if (string= line prefix)
        (buffer-substring-no-properties (point) (line-end-position))
      (if (> mid start)
          (if (string< line prefix)
              (ws-bisearch-word prefix mid end)
            (ws-bisearch-word prefix start mid))))))


;; 循环实现，速度竟然比不上递归实现
(defun new-ws-bisearch-word (prefix start end)
  (let (
        mid
        (len (length prefix))
        line
        (found nil)
        )
    (while (and (not found)
                (<= start end))
      (setq mid (/ (+ start end) 2))
      (goto-char mid)
      (beginning-of-line)
      (setq line (buffer-substring-no-properties (point) (+ (point) len)))
      (if (string= prefix line)
          (setq found t)
        (if (string< prefix line)
            (setq end (1- mid))
          (setq start (1+ mid)))
        )
      ) ; while

    (if found
        line
      nil)
    )
  )




(defun benchmark-bisearch ()
  (ws-init)
  (let (
        begin-time
        )
    (setq begin-time (float-time))
    (with-current-buffer ws-words-buffer
      (dotimes (i 50000)
        (ws-bisearch-word "我" (point-min) (point-max))))
    (insert (format "%f" (- (float-time) begin-time)))

    (insert ?\n)

    (setq begin-time (float-time))
    (with-current-buffer ws-words-buffer
      (dotimes (ii 50000)
        (new-ws-bisearch-word "我" (point-min) (point-max))))
    (insert (format "%f" (- (float-time) begin-time)))

    )

)


;; prefix为一个汉字
;; 若reverse为t，在words.txt中查；否则，在rwords.txt中查
;; 返回一个列表，列表中搜集了词库中所有以该字打头的词
(defun ws-get-words (prefix &optional reverse)
  ;;(ws-init)
  (with-current-buffer (if reverse ws-reverse-words-buffer ws-words-buffer)
    (when (ws-bisearch-word prefix (point-min) (point-max))
      (let ((len (length prefix))
            words pos)
        (save-excursion
          (while (and (not (bobp))      ; 向上搜集
                      (progn
                        (setq pos (point))
                        (forward-line -1)
                        (string= (buffer-substring-no-properties (point) (+ (point) len))
                                 prefix)))
            (push (buffer-substring-no-properties (point) (- pos 1)) words)))
        (while (and (not (eobp))        ; 向下搜集
                    (string= (buffer-substring-no-properties (point) (+ (point) len))
                             prefix))
          (push (buffer-substring-no-properties (point) (progn (forward-line 1) (- (point) 1))) words))
        words))))

;; (ws-get-words "我")


;; 传给ws-get-words的参数为光标所在处的那个汉字，ws-get-words返回词库中所有以该字打头的词
;; 只要光标下的词是这些词之一，就掠过这些词；否则，只前进一个字。
(defun ws-forward-word ()
  (interactive)
  (if (looking-at "\\cc")               ; 若光标下是个汉字.  \cc代表汉字. 参考: 34.3.1.3 Backslash Constructs in Regular Expressions
      (let ((words (ws-get-words (buffer-substring-no-properties (point) (+ (point) 1)))))
        (or (and words (re-search-forward (concat "\\=" (regexp-opt words)) nil t)) ; \=代表光标下的空串, regexp-opt构造可代表words的regexp
            (forward-char 1)))
    (let (pos)                          ; 若光标下不是个汉字
      (save-excursion
        (if (re-search-forward "\\cc" nil t) ; 找到一个汉字(此时光标会被置于该汉字之后)
            (setq pos (- (point) 1))))       ; 让pos指向该汉字
      (if pos
          (goto-char (min pos (save-excursion (forward-word) (point)))) ; 用来处理这种情况: "-!-,来这里" 即光标停在那个英文逗号上, forward-word会导致光标移动到最后一个汉字之后
        (forward-word)))))





(defun ws-reverse-string (str)
  (concat (reverse (append str nil))))

(defun ws-backward-word ()
  (interactive)
  (if (looking-back "\\cc")
      (let ((words (ws-get-words (buffer-substring-no-properties (- (point) 1) (point)) t)))
        (or (and words (re-search-backward (concat (regexp-opt (mapcar 'ws-reverse-string words)) "\\=") nil t))
            (backward-char 1)))
    (let (pos)
      (save-excursion
        (if (re-search-backward "\\cc" nil t)
            (setq pos (+ (point) 1))))
      (if pos
          (goto-char (max pos (save-excursion (backward-word) (point))))
        (backward-word)))))


;;;; word lib maintainance

;; 严格匹配
;; 为ws-add-string确定新词的插入位置
(defun ws-bisearch-word-strict (prefix start end)
  (let ((mid (/ (+ start end) 2))
        ;;(len (length prefix))
        line)
    (goto-char mid)
    (beginning-of-line)
    ;;(setq line (buffer-substring-no-properties (point) (+ (point) len)))
    (setq line (buffer-substring-no-properties (point) (line-end-position)))
    (if (string= line prefix)
        (buffer-substring-no-properties (point) (line-end-position))
      (if (> mid start)
          (if (string< line prefix)
              (ws-bisearch-word-strict prefix mid end)
            (ws-bisearch-word-strict prefix start mid))))))



(defun ws-add-string (buf s)
  (with-current-buffer buf
    (let (
          (found (ws-bisearch-word-strict s (point-min) (point-max)))
          )
      (unless found
        (unless (string< s (buffer-substring-no-properties (point) (line-end-position)))
          (forward-line 1)
          )

        (insert s)
        (insert ?\n)
        )

      )
    )
  )


;; 在词库中添加新词w
(defun ws-add-word (w)
  (interactive
   (list
    (read-from-minibuffer "word to add: ")
    ))
  (ws-add-string ws-words-buffer w)
  (ws-add-string ws-reverse-words-buffer (ws-reverse-string w))
  (ws-save-lib)
)


;; 将选中区域作为新词添加到词库
(defun ws-add-region-as-word (beg end)
  (interactive (list (point) (mark)))
  (ws-add-word (buffer-substring-no-properties beg end))
  )


;; 根据ws-words-buffer更新ws-reverse-words-buffer
(defun ws-sync-rword ()
  (interactive)
  (ws-init)
  (with-current-buffer ws-reverse-words-buffer
	(delete-region (point-min) (point-max)))
  (with-current-buffer ws-words-buffer
	(goto-char (point-min))
	(let (line)
	  (while (not (eobp))
		(setq line (buffer-substring-no-properties (point) (line-end-position)))
		(with-current-buffer ws-reverse-words-buffer
		  (insert (ws-reverse-string line))
		  (insert ?\n)
		  )
		(forward-line 1))
	  ))
  (with-current-buffer ws-reverse-words-buffer
	(sort-lines nil (point-min) (point-max)))
)


;; 保存ws-words-buffer和ws-reverse-words-buffer到各自的文件中
(defun ws-save-lib ()
  (interactive)
  (with-current-buffer ws-words-buffer
	(write-region (point-min) (point-max) ws-words-file))
  (with-current-buffer ws-reverse-words-buffer
	(write-region (point-min) (point-max) ws-reverse-words-file))
  )

;;;; kill
(defun ws-kill-word (arg)
  (interactive "p")
  (kill-region (point) (progn (ws-forward-word) (point))))

(defun ws-backward-kill-word (arg)
  (interactive "p")
  (kill-region (point) (progn (ws-backward-word) (point))))


(define-minor-mode ws-mode
  "Buffer-local minor mode to move word by chinese word."
  :group 'ws
  ;; :global t
  :lighter " WS"
  :keymap
  `((,(kbd "M-f") . ws-forward-word)
    (,(kbd "M-b") . ws-backward-word)
    (,(kbd "M-d") . ws-kill-word)
    (,(kbd "<C-f9>") . ws-add-region-as-word)
    (,(kbd "<M-backspace>") . ws-backward-kill-word))

  (ws-init))

(provide 'ws)
;;; ws.el ends here
