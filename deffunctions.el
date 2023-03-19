(defun call-fun-on-word-at-point (function word)
  "Call FUNCTION with argument WORD, the word at point."
  (interactive 
   (list (emamux:send-command)
         (word-at-point))
   (funcall function word)))

(defun xx ()
  "print current word."
  (interactive)
  (message "%s" (thing-at-point 'sentence)))


;;(defun execute-send-comand (beg end)
;;  (let list)
;;  ((cl-loop for x from beg to end)
;;   funcall append-to-list list x)
;;  (message "%s" list))

(defun my-string-at-point ()
  "Save the space-delimited string at point to the kill ring."
  (interactive)
  (save-excursion
    (let ((beg (progn (skip-syntax-backward "^{" (line-beginning-position))
                      (point)))
          (end (progn (skip-syntax-forward "^}" (line-end-position))
                      (point))))
      (copy-region-as-kill beg end))))

(defun my-get-boundary-and-thing ()
  "example of using `bounds-of-thing-at-point'"
  (interactive)
  (let (bounds pos1 pos2 mything)
    (setq bounds (bounds-of-thing-at-point 'line))
    (setq pos1 (car bounds))
    (setq pos2 (cdr bounds))
    (setq mything (buffer-substring-no-properties pos1 pos2))

    (message 
     "thing begin at [%s], end at [%s], thing is [%s]"
     pos1 pos2 mything)))

;; ChatGPT

(defun boost-test-case-bounds ()
  "Returns the boundaries of the Boost test case around the current point.
   If the current point is not inside a Boost test case, returns nil."
  (save-excursion
    (when (search-backward-regexp "BOOST_FIXTURE_TEST_CASE(" nil t)
      (let ((start (match-beginning 0))
            (end (progn (forward-sexp) (point))))
        (when (<= start (point) end)
          (cons start end))))))

(defun boost-test-case-bounds-at-point ()
  "Returns the boundaries of the Boost test case at the current point.
   If the current point is not inside a Boost test case, returns nil."
  (let ((bounds (boost-test-case-bounds)))
    (when (and bounds (<= (car bounds) (point) (cdr bounds)))
      bounds)))

(defun my-boost-test-case-name ()
  "Get the name of the Boost test case function at point."
  (interactive)
  (let ((case-start (re-search-backward "\\_<BOOST_FIXTURE_TEST_CASE( *\\([^,]+\\)" nil t)))
    (if case-start
        (let ((name (match-string 1)))
          (message "Boost test case function name: %s" name))
      (message "No Boost test case found at point"))))

;; (global-set-key (kbd "M-t") 'my-boost-test-case-name)

;;(defun my-string-at-point ()
;;  "Save the space-delimited string at point to the kill ring."
;;  (interactive)
;;  (save-excursion
;;    (let ((beg (progn (skip-syntax-backward "^" (line-beginning-position))
;;                      (point)))
;;          (end (progn (skip-syntax-forward "^" (line-end-position))
;;                      (point))))
;;      (execute-send-comand beg end))))

(defun insert-cmake-code ()
  (interactive)
  (let ((root-dir (locate-dominating-file default-directory "CMakeLists.txt")))
    (if root-dir
        (progn
          (setq root-dir (expand-file-name root-dir))
          (let ((cmakelists (concat root-dir "/CMakeLists.txt")))
            (if (file-exists-p cmakelists)
                (progn
                  (write-region
                   "function(get_all_targets var)\n"
                   "  set(targets)\n"
                   "  get_all_targets_recursive(targets ${CMAKE_CURRENT_SOURCE_DIR})\n"
                   "  set(${var} ${targets} PARENT_SCOPE)\n"
                   "endfunction()\n"
                   "\n"
                   "macro(get_all_targets_recursive targets dir)\n"
                   "  get_property(subdirectories DIRECTORY ${dir} PROPERTY SUBDIRECTORIES)\n"
                   "  foreach(subdir ${subdirectories})\n"
                   "    get_all_targets_recursive(${targets} ${subdir})\n"
                   "  endforeach()\n"
                   "\n"
                   "  get_property(current_targets DIRECTORY ${dir} PROPERTY BUILDSYSTEM_TARGETS)\n"
                   "  list(APPEND ${targets} ${current_targets})\n"
                   "endmacro()\n"
                   "\n"
                   "function(main)\n"
                   "  get_all_targets(all_targets)\n"
                   "  message(\"All targets: ${all_targets}\")\n"
                   "endfunction()\n"
                   "\n"
                   "main()\n"
                   "\n"
                   nil
		   (cmakelists)
		   t)
                  (message "CMake code inserted at the end of CMakeLists.txt."))
              (message "CMakeLists.txt file not found."))))
      (message "Could not find root CMakeLists.txt file."))))


(global-set-key (kbd "M-t") 'insert-cmake-code)
