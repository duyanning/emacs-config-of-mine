;;; 给iswitchb-mode添加按拼音首字母匹配的能力。就像Listary和Total Commander某插件那样。



;;; iswitchb-read-buffer C-x b之后唤起的函数
;;; iswitchb-make-buflist 构造buffer列表
;;; iswitchb-set-matches
;;; iswitchb-get-matched-buffers
;;; 此函数中最关键的一段：
;;; (setq name (if (stringp x) x (buffer-name x)))
;;; (when (and (string-match regexp name) ; 最关键的一句，它是直接跟buffer名匹配，我们想让它考虑跟buffer名的拼音形式匹配
;;;            (not (iswitchb-ignore-buffername-p name)))
;;;   (push name ret))




(defvar iswitchb-pinyin-initialized nil)
(defvar pinyin-initials-buffer nil)

;; pinyin-initials.txt中包含了20902个汉字的拼音首字母。这些字母是按对应
;; 汉字unicode码点的顺序排列的。包括了所有的“CJK统一汉字”。
(defvar pinyin-initials-file "~/emacs-config-of-mine/lisp/pinyin-initials.txt") 

(defun iswitchb-pinyin-init ()
  (unless iswitchb-pinyin-initialized
    (save-excursion
      (set-buffer (generate-new-buffer " pinyin-initials")) ; buffer名字前加空格，避免在emacs中编辑该文件
      (insert-file-contents pinyin-initials-file)
      (setq pinyin-initials-buffer (current-buffer))
      (setq iswitchb-pinyin-initialized t))))


;;; 从某个字符的码点得到拼音首字母，如果不是汉字就原样返回
(defun unicode-to-pinyin-initial (codepoint)
  (cond 
   ;; ascii，原样返回
   ((and (>= codepoint 0) (< codepoint 256))
    codepoint)
   ;; 所有的“CJK统一汉字”，查表转换为拼音首字母
   ((and (>= codepoint ?一) (<= codepoint ?龥)) 
    (let (
          (index (- codepoint 19968))
          c
          )
      (with-current-buffer pinyin-initials-buffer
        ;; 字符在buffer中的位置是从1开始，而非0
        (aref (buffer-substring-no-properties (+ index 1) (+ index 2))
              0)
        )
      ))
   ;; 从Ａ到Ｚ的全角字符，全部转换为半角
   ((and (>= codepoint ?Ａ) (<= codepoint ?Ｚ))
    (let ((offset (- ?Ａ ?A)))
      (- codepoint offset)
      ))
   ;; 从ａ到ｚ的全角字符，全部转换为半角
   ((and (>= codepoint ?ａ) (<= codepoint ?ｚ))
    (let ((offset (- ?ａ ?a)))
      (- codepoint offset)
      ))
   ;; 从０到９的全角字符，全部转换为半角
   ((and (>= codepoint ?０) (<= codepoint ?９))
    (let ((offset (- ?０ ?0)))
      (- codepoint offset)
      ))
   ;; 其他字符，原样返回
   (t codepoint)
   )
  )



;;; 将字符串str中的所有汉字转换为其首字母，其他不变
(defun str-unicode-to-pinyin-initial (str)
  (let (
        (newstr (copy-sequence str))
        (i 0)
        )
    (while (< i (length newstr))
      (aset newstr i
            (unicode-to-pinyin-initial (aref newstr i)))
      (setq i (1+ i))
      )
    newstr
    )
  )

;;; (setq iswitchb-pinyin-initialized nil)
;;; (iswitchb-pinyin-init)

;;; (unicode-to-pinyin-initial ?a)
;;; (unicode-to-pinyin-initial ?ａ)
;;; (unicode-to-pinyin-initial ?0)
;;; (unicode-to-pinyin-initial ?０)
;;; (unicode-to-pinyin-initial ?杜)

;;; (str-unicode-to-pinyin-initial "杜延宁ΔЉりㄶfxm０0ａa")


;;; 用于代替string-match。
;;; 假如name为"中国"，本函数就从"中国"构造出"中国|zg"，
;;; 该字符串不但可以跟"中国"匹配，还可以跟"zg"匹配。
(defun pinyin-initials-string-match (regexp name)
  (let (
        (pinyin-name (str-unicode-to-pinyin-initial name))
        )
    (string-match regexp (concat name "|" pinyin-name))
    )
  )

;;; (pinyin-initials-string-match "zg" "中国")
;;; (pinyin-initials-string-match "zg" "zg")


;;; 这个函数跟iswitchb.el中的同名函数完全一样，除了一点
;;; 即它不是用string-match而是我们提供的pinyin-initials-string-match来做文件名匹配
(defun iswitchb-get-matched-buffers (regexp
				     &optional string-format buffer-list)
  "Return buffers matching REGEXP.
If STRING-FORMAT is nil, consider REGEXP as just a string.
BUFFER-LIST can be list of buffers or list of strings."
  (let ((case-fold-search (iswitchb-case))
         name ret)
    (if (null string-format) (setq regexp (regexp-quote regexp)))
    (setq iswitchb-invalid-regexp nil)
    (condition-case error
        (dolist (x buffer-list (nreverse ret))
          (setq name (if (stringp x) x (buffer-name x)))
          (when (and (pinyin-initials-string-match regexp name) ; string-match被替换为pinyin-initials-string-match
                     (not (iswitchb-ignore-buffername-p name)))
            (push name ret)))
      (invalid-regexp
       (setq iswitchb-invalid-regexp t)
       (cdr error)))))


(iswitchb-pinyin-init)
