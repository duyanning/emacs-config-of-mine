(defvar ime_status nil)

(defun ime_get_status ()
  ;; 执行"fcitx-remote"，解析其输出
  ;; 若输出为0，(setq ime-status nil)
  ;; 否则(setq ime-status t)
  )

(defun ime_set_status (openp)
  ;; 若openp为t，执行"fcitx-remote -o"
  ;; 若openp为nil，执行"fcitx-remote -c"
  )


(defun ime-save-and-set-status (openp)
  (setq ime_status (ime_get_status))
  (ime_set_status openp))

(defun ime-restore-status ()
  (ime_set_status ime_status))
