(add-to-list 'exec-path "~/.local/bin")
(require 'lsp-mode)
(setq lsp-cmake-server-path "/snap/bin/cmake-server")
(add-to-list 'lsp-language-id-configuration '(cmake-mode . "cmake"))
(add-hook 'cmake-mode-hook #'lsp-deferred)

(use-package projectile
  :config
  (projectile-mode +1))

(require 'ansi-color)
(defun my/colorize-compilation-buffer ()
  "Colorize compilation buffer."
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region (point-min) (point-max))))

(add-hook 'compilation-filter-hook #'my/colorize-compilation-buffer)

(defun my/create-build-dir ()
  "Create a build directory in the project root directory, or find one if it exists."
  (interactive)
  (let* ((build-dirs '("build" "cmake-build" "cmake-build-debug" "cmake-build-release"))
         (project-root (projectile-project-root))
         (build-dir (seq-find #'file-directory-p
                              (mapcar (lambda (dir) (concat project-root dir)) build-dirs))))
    (if build-dir
        (message "Build directory found: %s" build-dir)
      (setq build-dir (concat project-root "build"))
      (make-directory build-dir)
      (message "Build directory created: %s" build-dir))
    build-dir))

(defun my-read-cmake-flags ()
  "Read CMake flags from cmakeflags.in or return default flags."
  (let* ((cmakeflags-path (projectile-expand-root "cmakeflags.in"))
         (default-flags '("-DCMAKE_BUILD_TYPE=Debug"
                          "-DCMAKE_C_COMPILER=/usr/bin/clang"
                          "-DCMAKE_CXX_COMPILER=/usr/bin/clang++"
                          "-DCMAKE_EXPORT_COMPILE_COMMANDS=1")))
    (if (file-exists-p cmakeflags-path)
        (with-temp-buffer
          (insert-file-contents cmakeflags-path)
          (mapcar (lambda (flag)
                    (replace-regexp-in-string "\\s-+" "" flag))
                  (split-string (buffer-string) "\n" t)))
      default-flags)))

(defun create-cmake-query (build-dir query)
  "Create a cmake query for cmake api"
  (let* ((cmake-dir (concat (file-name-as-directory build-dir) ".cmake/api/v1/query"))
         (filepath (concat (file-name-as-directory cmake-dir) query)))
    (make-directory cmake-dir t)
    (write-region "" nil filepath)
    (message "File created: %s" filepath)))

(defvar targets nil)
(defvar sources_by_targets nil)

(defun parse-cmake-reply (directory)
  "Parse all JSON files in reply DIRECTORY that start with the word 'target'.
   Returns a list of two items: a vector of names, and a hash table
   mapping names to source path vectors."
  (let ((name-vector '())
        (name-path-map (make-hash-table :test 'equal)))
    (dolist (file (directory-files-recursively directory "^target.*\\.json$"))
      (with-temp-buffer
        (insert-file-contents file)
        (let ((json-object-type 'hash-table))
          (let* ((json (json-read))
                 (name (gethash "name" json))
                 (path-vector (mapcar (lambda (source) (gethash "path" source))
                                      (gethash "sources" json))))
            (push name name-vector)
            (puthash name path-vector name-path-map)))))
    (setq targets (reverse name-vector))
    (setq sources_by_targets name-path-map)))

(defun print-all-target-names (json-result)
  "Print all target names in the given JSON result."
  (with-output-to-temp-buffer "*All Target Names*"
    (let ((name-vector json-result))
      (dolist (name name-vector)
        (princ (concat name "\n"))))))

(defun my/run-cmake ()
  "Run CMake."
  (interactive)
      (let ((cmake-build-dir (my/create-build-dir))
	    (cmake-flags (my-read-cmake-flags)))
    (if (file-exists-p cmake-build-dir)
        (progn
          (create-cmake-query cmake-build-dir "codemodel-v2")
          (cd cmake-build-dir)
          (compile (concat "cmake .. " (mapconcat 'identity cmake-flags " ")))
          (cd "..")
          (parse-cmake-reply (concat cmake-build-dir "/.cmake/api/v1/reply")))
      (message "CMake build directory not found, please create one first."))))

(defun compile-project (target)
  (interactive
   (list (completing-read "Enter target name: "
                          (or targets
                              (progn (my/run-cmake)
                                     targets)))))
  (let ((build-dir (my/create-build-dir))
        (compile-command (concat "cd " (projectile-project-root) " && cmake --build " build-dir " --target " target)))
    (compile compile-command)))

;; (defun compile-project (target)
;;    (when (null targets)
;;       (parse-cmake-reply (concat (my/create-build-dir) "/.cmake/api/v1/reply")))
;;   (interactive (list (completing-read "Enter target name: " targets)))
;;   (my/with-cmake  
;;   (let* ((build-dir (concat (projectile-project-root) "build/"))
;;          (compile-command (concat "cd " (projectile-project-root) " && cmake --build build --target " target)))
;;     (compilation-start compile-command 'compilation-mode (lambda (proc) (when (eq (process-status proc) 'exit) (message "Compilation finished")) :sync t)))))

(defun build-and-run-project (target)
   (when (null targets)
      (parse-cmake-reply (concat (my/create-build-dir) "/.cmake/api/v1/reply")))
  (interactive (list (completing-read "Enter target name: " targets)))
  (my/with-cmake
  (let ((build-dir (concat (projectile-project-root) "build/"))
        (compile-command (concat "cd " (projectile-project-root) " && cmake --build build --target " target " && " (projectile-project-root) "build/" target)))
    (compilation-start compile-command 'compilation-mode (lambda (proc) (when (eq (process-status proc) 'exit) (async-shell-command (concat (projectile-project-root) "build/" target))) :sync t)))))

(defun build-and-debug-project (target)
   (when (null targets)
      (parse-cmake-reply (concat (my/create-build-dir) "/.cmake/api/v1/reply")))
  (interactive (list (completing-read "Enter target name: " targets)))
  (my/with-cmake
  (let ((build-dir (concat (projectile-project-root) "build/"))
        (compile-command (concat "cd " (projectile-project-root) " && cmake --build build --target " target)))
    (compilation-start compile-command 'compilation-mode (lambda (proc) (when (eq (process-status proc) 'exit) (gdb (concat "gdb -i=mi " (concat (projectile-project-root) "build/" target))))) :sync t))))


;;(global-set-key (kbd "<f5>") 'build-and-run-project)
;;(global-set-key (kbd "<f6>") 'build-and-debug-project)
(global-set-key (kbd "<f7>") 'compile-project)
(global-set-key (kbd "<f8>") 'my/run-cmake)
