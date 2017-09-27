(defun assert (v msg)
  "断言，V必须为真，否则输出消息MSG"
  (when (not v)
    (error msg)
    )
)

;------------------------------------------------------------------------------------
;;如果s从下标beginning处开始往后能找到子串s1，且s1起点的下标不等于last，则返回真
(defun match-found (s beginning s1 last)
  (assert (and (>= beginning 0) (<= beginning (length s))) "should: 0 <= beginning <= length")
  (let (
        (i (string-match s1 s beginning))
        )
    (if (or (eq i nil) (eq i last))
        nil
      t
      )
    )
  ;;(setq i (string-match s1 s beginning))
  )

;; unit test
;; t
;;(match-found "abcd" 0 "b" 0)
;; t
;;(match-found "abcd" 1 "b" 0)
;; t
;;(match-found "abcd" 2 "b" 0)
;------------------------------------------------------------------------------------

(defun reverse-search-substring (s s1 n)
  "从后往前在字符串S中查找子串S1的第N次出现，找到则返回子串第N次出现起始位置的下标；否则返回nil"
  (assert (>= n 1) "n should >= 1")
  (let (
        (found nil)
        (at (length s))
        (i (- (length s) 1))
        )
    (while (and (>= i 0) (not found))
      (when (match-found s i s1 at)
        (setq at i)
        (setq n (1- n))
        )
      (when (= n 0)
        (setq found t)
        )

      (setq i (1- i))
      )

    (if found
        at
      nil
      )
    )


  )

;; unit test
;; 1
;;(reverse-search-substring "abcbc" "b" 2)
;; 3
;;(reverse-search-substring "abcbc" "b" 1)
;; nil
;;(reverse-search-substring "abcbc" "b" 3)
;; 2
;;(reverse-search-substring "i am a programmer" "am" 2)
;------------------------------------------------------------------------------------

(defun search-substring (s s1 n)
  "从前往后在字符串S中查找子串S1的第N次出现，找到则返回子串第N次出现起始位置的下标；否则返回nil"
  (assert (>= n 1) "n should >= 1")
  (let (
        (over nil)                      ;不用再逐一往后找了，后边不可能有了
        (at nil)
        (i 0)
        (len (length s))
        (found nil)
        )
    (while (and (< i len) (not over) (not found))

      (setq at (string-match s1 s i))

      (if at
          (progn
            (setq n (1- n))
            (setq i (+ at 1))
            )
        (setq over t)
        )

      (when (= n 0)
        (setq found t)
        )

      (setq i (1+ i))
      )

    (if found
        at
      nil
      )

    )


  )

;; unit test
;; 1
;;(search-substring "abcbc" "b" 1)
;; 3
;;(search-substring "abcbc" "b" 2)
;; nil
;;(search-substring "abcbc" "b" 3)


;; 12
;;(search-substring "i am a programmer" "am" 2)

;------------------------------------------------------------------------------------

;;; Announce

(provide 'string-operations)
