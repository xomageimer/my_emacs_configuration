(defun call-fun-on-word-at-point (function word)
  "Call FUNCTION with argument WORD, the word at point."
  (interactive 
   (list (emamux:send-command)
         (word-at-point))
   (funcall function word)))

(defun xx ()
  "print current word."
  (interactive)
  (message "%s" (thing-at-point 'word)))


;;(defun execute-send-comand (beg end)
;;  (let list)
;;  ((cl-loop for x from beg to end)
;;   funcall append-to-list list x)
;;  (message "%s" list))

(defun my-string-at-point ()
  "Save the space-delimited string at point to the kill ring."
  (interactive)
  (save-excursion
    (let ((beg (progn (skip-syntax-backward "^" (line-beginning-position))
                      (point)))
          (end (progn (skip-syntax-forward "^" (line-end-position))
                      (point))))
      (copy-region-as-kill beg end))))


;;(defun my-string-at-point ()
;;  "Save the space-delimited string at point to the kill ring."
;;  (interactive)
;;  (save-excursion
;;    (let ((beg (progn (skip-syntax-backward "^" (line-beginning-position))
;;                      (point)))
;;          (end (progn (skip-syntax-forward "^" (line-end-position))
;;                      (point))))
;;      (execute-send-comand beg end))))


(global-set-key (kbd "M-.") 'my-string-at-point)
