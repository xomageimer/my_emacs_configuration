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
(defvar targets_by_path nil)

(defvar targets-by-args (make-hash-table :test 'equal)
  "Hash table to store target arguments.")

(defun get-arg-from-target (target)
  (if (hash-table-p targets-by-args)
      (or (gethash target targets-by-args) "")
    ""))

;; TODO нужно убрать это из parse cmake и сделать чтение из файла для определенного таргета без хэш таблицы
(defun parse-args-file ()
  "Parse args.in file and store target arguments in hash table."
  (interactive)
  (let ((args-file (expand-file-name "args.in" (projectile-project-root)))
        (targets ()))
    (when (file-exists-p args-file)
      (with-temp-buffer
        (insert-file-contents args-file)
        (while (re-search-forward "^\\(.*?\\):\\s-*\\(.+\\)$" nil t)
          (puthash (match-string 1) (match-string 2) targets-by-args))))))

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
    (setq targets_by_path name-by-path))
    (parse-args-file))

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
    (let ((build-dir nil))
    (setq build-dir (my/create-build-dir))
    (let ((compile-command (concat "cd " (projectile-project-root) " && cmake --build " build-dir " --target " target)))
      (compile compile-command))))

(require 'async)

(defun build-and-run-project (target)
  (interactive
   (list (completing-read "Enter target name: "
                          (or targets
                              (progn (my/run-cmake)
                                     targets)))))
  (let ((compilation-buffer-name-function)
        (build-dir (my/create-build-dir))
        (compile-command)
        (args)
        (buffer-name nil)
        (compilation-buffer nil))
    (setq build-dir (my/create-build-dir))
    (setq compile-command (concat "cd " (projectile-project-root) " && cmake --build " build-dir " --target " target))
    (setq buffer-name (concat "*Running " target "*"))
    (compilation-buffer-name-function (lambda (mode) buffer-name))
    (setq args (get-arg-from-target target))
    (compile compile-command)
    (set-process-sentinel (get-buffer-process (compilation-find-buffer))
                          `(lambda (process event)
                             (run-sentinel process event ,target ,args ,buffer-name)))))

(defun run-sentinel (process event target args buffer-name)
  (when (eq (process-status process) 'exit)
    (let ((target-path (gethash target targets_by_path))
          (compilation-buffer nil))
      (setq compilation-buffer (get-buffer (buffer-name)))
      (with-current-buffer compilation-buffer)
          (async-shell-command (concat (my/create-build-dir) "/" target-path " " args) buffer-name))))

(defun build-and-debug-project (target)
  (interactive
   (list (completing-read "Enter target name: "
                          (or targets
                              (progn (my/run-cmake)
                                     targets)))))
  (let ((compilation-buffer-name-function (lambda (mode) (concat "*Debugging " target "*")))
        (build-dir (my/create-build-dir))
        (compile-command)
        (args))
    (setq build-dir (my/create-build-dir))
    (setq compile-command (concat "cd " (projectile-project-root) " && cmake --build " build-dir " --target " target))
    (setq args (get-arg-from-target target))
    (compile compile-command)
    (set-process-sentinel (get-buffer-process (compilation-find-buffer))
                          `(lambda (process event)
                             (debug-sentinel process event ,target ,args)))))

(setq gdb-many-windows t gdb-use-separate-io-buffer t gud-async-input t)

(defun debug-sentinel (process event target args)
  (when (eq (process-status process) 'exit)
    (let ((target-path (gethash target targets_by_path)))
      (tab-bar-new-tab-to)
      (gdb (concat "gdb -i=mi -args " (concat (my/create-build-dir) "/" target-path " " args))))))

(add-hook 'gud-mode-hook
          (lambda ()
            (setq-local company-global-modes '(not gud-mode))))

(global-set-key (kbd "<f5>") 'build-and-run-project)
(global-set-key (kbd "<f6>") 'build-and-debug-project)
(global-set-key (kbd "<f7>") 'compile-project)
(global-set-key (kbd "<f8>") 'my/run-cmake)

(defun get-project-relative-file-name ()
  (when-let ((project-root (projectile-project-root))
             (file-name (buffer-file-name)))
    (file-relative-name file-name project-root)))

(defun boost-test-case-name ()
  "Get the name of the Boost test case function at point."
  (interactive)
  (forward-line 1)
  (let ((case-start (re-search-backward "\\_<BOOST_FIXTURE_TEST_CASE( *\\([^,]+\\)" nil t)))
    (if case-start
        (match-string 1)
      (error "No Boost test case found at point"))))

(defun boost-test-suite-name ()
  "Get the name of the Boost test suite at point."
  (interactive)
  (forward-line 1)
  (let ((case-start (re-search-backward "\\_<BOOST_AUTO_TEST_SUITE( *\\([^,)]+\\)" nil t)))
    (if case-start
        (match-string 1)
      (error "No Boost test suite found at point"))))

(defun run-boost-test-case ()
  (or targets
    (progn (my/run-cmake)
             targets))
  (interactive)
  (let ((current_file (get-project-relative-file-name))
        (test_name)
        (compilation-buffer-name-function)
        (target)
        (build-dir (my/create-build-dir))
        (compile-command)
        (test_args)
        (test_case)
        (test_suite)
        (saved_position)
        (buffer-name nil))
    (setq saved_position (point))
    (setq current_file (get-project-relative-file-name))
    (setq target (gethash current_file sources_by_targets))
    (setq test_case (boost-test-case-name))
    (setq test_suite (boost-test-suite-name))
    (setq test_name (concat test_suite "/" test_case))
    (goto-char saved_position)
    (setq buffer-name (concat "*Running: " test_name "*"))
    (setq compilation-buffer-name-function (lambda (mode) buffer-name))
    (setq build-dir (my/create-build-dir))
    (setq compile-command (concat "cd " (projectile-project-root) " && cmake --build " build-dir " --target " target))
    (setq test_args (concat "--run_test=" test_name " --color_output=true --report_format=HRF --show_progress=no --log_level=warning"))
    (compile compile-command)
    (set-process-sentinel (get-buffer-process (compilation-find-buffer))
                          `(lambda (process event)
                             (run-sentinel process event ,target ,test_args ,buffer-name)))))

(defun debug-boost-test-case ()
  (or targets
    (progn (my/run-cmake)
             targets))
  (interactive)
  (let ((current_file (get-project-relative-file-name))
        (test_name)
        (compilation-buffer-name-function)
        (target)
        (build-dir (my/create-build-dir))
        (compile-command)
        (test_args)
        (test_case)
        (test_suite)
        (saved_position))
    (setq saved_position (point))
    (setq current_file (get-project-relative-file-name))
    (setq target (gethash current_file sources_by_targets))
    (setq test_case (boost-test-case-name))
    (setq test_suite (boost-test-suite-name))
    (setq test_name (concat test_suite "/" test_case))
    (goto-char saved_position)
    (setq compilation-buffer-name-function (lambda (mode) (concat "*Running: " test_name "*")))
    (setq build-dir (my/create-build-dir))
    (setq compile-command (concat "cd " (projectile-project-root) " && cmake --build " build-dir " --target " target))
    (setq test_args (concat "--run_test=" test_name " --color_output=true --report_format=HRF --show_progress=no --log_level=warning"))
    (compile compile-command)
    (set-process-sentinel (get-buffer-process (compilation-find-buffer))
                          `(lambda (process event)
                             (debug-sentinel process event ,target ,test_args)))))

(global-set-key (kbd "C-x <f5>") 'run-boost-test-case)
(global-set-key (kbd "C-x <f6>") 'debug-boost-test-case)
