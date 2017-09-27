(defun assert (v msg)
  "���ԣ�V����Ϊ�棬���������ϢMSG"
  (when (not v)
    (error msg)
    )
)

;------------------------------------------------------------------------------------
;;���s���±�beginning����ʼ�������ҵ��Ӵ�s1����s1�����±겻����last���򷵻���
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
  "�Ӻ���ǰ���ַ���S�в����Ӵ�S1�ĵ�N�γ��֣��ҵ��򷵻��Ӵ���N�γ�����ʼλ�õ��±ꣻ���򷵻�nil"
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
  "��ǰ�������ַ���S�в����Ӵ�S1�ĵ�N�γ��֣��ҵ��򷵻��Ӵ���N�γ�����ʼλ�õ��±ꣻ���򷵻�nil"
  (assert (>= n 1) "n should >= 1")
  (let (
        (over nil)                      ;��������һ�������ˣ���߲���������
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
