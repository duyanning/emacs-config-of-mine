(defvar ime_status nil)

(defun ime_get_status ()
  ;; ִ��"fcitx-remote"�����������
  ;; �����Ϊ0��(setq ime-status nil)
  ;; ����(setq ime-status t)
  )

(defun ime_set_status (openp)
  ;; ��openpΪt��ִ��"fcitx-remote -o"
  ;; ��openpΪnil��ִ��"fcitx-remote -c"
  )


(defun ime-save-and-set-status (openp)
  (setq ime_status (ime_get_status))
  (ime_set_status openp))

(defun ime-restore-status ()
  (ime_set_status ime_status))
