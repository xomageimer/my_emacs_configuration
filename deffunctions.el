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

;; (defun boost-test-case-bounds ()
;;   "Returns the boundaries of the Boost test case around the current point.
;;    If the current point is not inside a Boost test case, returns nil."
;;   (save-excursion
;;     (when (search-backward-regexp "BOOST_FIXTURE_TEST_CASE(" nil t)
;;       (let ((start (match-beginning 0))
;;             (end (progn (forward-sexp) (point))))
;;         (when (<= start (point) end)
;;           (cons start end))))))

;; (defun boost-test-case-bounds-at-point ()
;;   "Returns the boundaries of the Boost test case at the current point.
;;    If the current point is not inside a Boost test case, returns nil."
;;   (let ((bounds (boost-test-case-bounds)))
;;     (when (and bounds (<= (car bounds) (point) (cdr bounds)))
;;       bounds)))

(defun my-boost-test-case-name ()
  "Get the name of the Boost test case function at point."
  (interactive)
  (forward-line 1)
  (let ((case-start (re-search-backward "\\_<BOOST_FIXTURE_TEST_CASE( *\\([^,]+\\)" nil t)))
    (if case-start
        (let ((name (match-string 1)))
          (message "Boost test case function name: %s" name))
      (message "No Boost test case found at point"))))

(defun my-boost-test-suite-name ()
  "Get the name of the Boost test suite at point."
  (interactive)
  (forward-line 1)
  (let ((case-start (re-search-backward "\\_<BOOST_AUTO_TEST_SUITE( *\\([^,)]+\\)" nil t)))
    (if case-start
        (let ((name (match-string 1)))
          (string-trim (substring name 1))
          (message "Boost test suite name: %s" name))
      (message "No Boost test suite found at point")))) 

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


;;(global-set-key (kbd "M-t") 'insert-cmake-code)

(defun my-expand-macro ()
  "Expand macro using lsp-execute-code-action and copy result to a read-only buffer on the right window."
  (interactive)
  (let* ((result-buffer (generate-new-buffer "*Macro Expansion*"))
         (params (lsp--text-document-position-params))
         (current-uri (buffer-file-name))
         (actions (lsp--send-request (lsp--make-request "textDocument/codeAction" (lsp--make-code-action-params params)))))
    (with-current-buffer result-buffer
      (read-only-mode)
      (insert (mapconcat (lambda (a) (lsp--code-action-title a)) actions "\n"))
      (goto-char (point-min)))
    (display-buffer result-buffer '((display-buffer-in-side-window)))))


(defun create-cmake-query (build-dir query)
  "Create a cmake query for cmake api"
  (let* ((cmake-dir (concat (file-name-as-directory build-dir) ".cmake/api/v1"))
         (filepath (concat (file-name-as-directory cmake-dir) query)))
    (make-directory cmake-dir t)
    (write-region "" nil filepath)
    (message "File created: %s" filepath)))

(require 'json)

;; (defun parse-json-files-in-directory (directory)
;;   "Parse all JSON files in DIRECTORY that start with the word 'target'."
;;   (interactive "DChoose directory: ")
;;   (let ((name-path-map (make-hash-table :test 'equal)))
;;     (dolist (file (directory-files-recursively directory "^target.*\\.json$"))
;;       (with-temp-buffer
;;         (insert-file-contents file)
;;         (let ((json-object-type 'hash-table))
;;           (let* ((json (json-read))
;;                  (name (gethash "name" json))
;;                  (path-vector (mapcar (lambda (source) (gethash "path" source))
;;                                       (gethash "sources" json))))
;;             (puthash name path-vector name-path-map)))))
;;     name-path-map))

;; (defvar targets nil)
;; (defvar sources_by_targets nil)

;; (defun parse-json-files-in-directory (directory)
;;   "Parse all JSON files in DIRECTORY that start with the word 'target'.
;;    Returns a list of two items: a vector of names, and a hash table
;;    mapping names to source path vectors."
;;   (interactive "DChoose directory: ")
;;   (let ((name-vector '())
;;         (name-path-map (make-hash-table :test 'equal)))
;;     (dolist (file (directory-files-recursively directory "^target.*\\.json$"))
;;       (with-temp-buffer
;;         (insert-file-contents file)
;;         (let ((json-object-type 'hash-table))
;;           (let* ((json (json-read))
;;                  (name (gethash "name" json))
;;                  (path-vector (mapcar (lambda (source) (gethash "path" source))
;;                                       (gethash "sources" json))))
;;             (push name name-vector)
;;             (puthash name path-vector name-path-map)))))
;;     (setq targets (reverse name-vector))
;;     (setq sources_by_targets name-path-map)))

(defvar targets nil)
(defvar sources_by_targets nil)
(defvar targets_by_path nil)

(defun parse-cmake-reply (directory)
  (interactive "DEnter directory:")
  "Parse all JSON files in reply DIRECTORY that start with the word 'target'.
   Returns a list of two items: a vector of names, and a hash table
   mapping names to source path vectors. Also creates a hash table mapping paths to names."
  (let ((name-vector '())
        (name-path-map (make-hash-table :test 'equal))
        (name-by-path (make-hash-table :test 'equal)))
    (dolist (file (directory-files-recursively directory "^target.*\\.json$"))
      (with-temp-buffer
        (insert-file-contents file)
        (let ((json-object-type 'hash-table))
          (let* ((json (json-read))
                 (name (gethash "name" json))
                 (sources (gethash "sources" json))
                 (artifact-vector (mapcar (lambda (artifact) (gethash "path" artifact))
                                          (gethash "artifacts" json))))
            (push name name-vector)
            (mapc (lambda (source) (puthash (gethash "path" source) name name-path-map))
                  sources)
            (mapc (lambda (artifact-path) (puthash name artifact-path name-by-path))
                  artifact-vector)))))
    (setq targets (reverse name-vector))
    (setq sources_by_targets name-path-map)
    (setq targets_by_path name-by-path)))

(defun print-name-by-path ()
  (interactive)
  "Prints the contents of the name-by-path hash table."
  (maphash (lambda (path name)
             (message "Path: %s, Name: %s" path name))
           targets_by_path))

(defun print-path-by-name (name)
    (interactive
   (list (completing-read "Enter target name: "
                          (or targets
                              (progn (my/run-cmake)
                                     targets)))))
  "Prints the path associated with NAME in the name-path-map hash table."
  (let ((path-vector (gethash name targets_by_path)))
    (if path-vector
        (dolist (path path-vector)
          (message "Name: %s, Path: %s" name path))
      (message "Name %s not found." name))))

;; (defun initialize-my-json-map ()
;;   (setq my-json-map (parse-json-files-in-directory "/path/to/directory")))

;; (initialize-my-json-map) ; Вызов функции один раз для инициализации переменной

;; Далее вы можете обращаться к my-json-map в любом месте вашей программы

;;"~/main/cmake-build-debug/.cmake/api/v1/reply"
(parse-cmake-reply "~/main/cmake-build-debug/.cmake/api/v1/reply")

(defun print-targets-by-path-to-buffer ()
  (interactive)
  "Prints the contents of the targets_by_path hash table to a new buffer."
  (let ((buffer (generate-new-buffer "*Targets by Path*")))
    (with-current-buffer buffer
      (maphash (lambda (path name)
                 (insert (format "Path: %s, Name: %s\n" path name)))
               targets_by_path))
    (switch-to-buffer buffer)))

(defun print-all-targets-for-source (json-hash source)
  "Print all targets for the given source file."
  (maphash
   (lambda (name path-vector)
     (when (member source path-vector)
       (message "%s" name)))
   json-hash))

(defun print-all-target-names (json-result)
  "Print all target names in the given JSON result."
  (with-output-to-temp-buffer "*All Target Names*"
    (let ((name-vector json-result))
      (dolist (name name-vector)
        (princ (concat name "\n"))))))

(defun find-path-by-name (name)
  (interactive "MEnter target name: ")
  (let ((path (gethash name targets_by_path)))
    (if path
        (message "Path for %s: %s" name path)
      (message "Name %s not found" name))))

;;(print-all-targets-for-source sources_by_targets "Sources/Connectors/test/Incrementalfilejournaltests.cpp")
;;(print-all-target-names targets)

;; (defun display-args-hash ()
;;   "Display contents of `my-args-hash' in a separate buffer."
;;   (interactive)
;;   (with-current-buffer (get-buffer-create "*args-hash*")
;;     (erase-buffer)
;;     (maphash (lambda (key value)
;;                (insert (format "%s: %s\n\n" key value)))
;;              targets_by_path)
;;     (pop-to-buffer (current-buffer))))

;; (display-args-hash)

(defun copy-all-bookmarks-to-array ()
  "Функция, которая копирует все закладки в массив и выводит их в сообщении."
  (interactive)
  (let ((bookmarks (bookmark-all-names)))
    (if bookmarks
        (progn
          (message "Все закладки:\n%s" (mapconcat 'identity bookmarks "\n"))
          bookmarks)
      (message "Закладок не найдено."))))

;; (setq json-result (parse-json-files-in-directory "~/Downloads/Mython-master/build/.cmake/api/v1/reply"))
;; (print-target-for-source json-result "lexer.cpp")
