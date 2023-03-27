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

(defun my/run-cmake ()
  "Run CMake."
  (interactive)
    (let ((cmake-build-dir (my/create-build-dir)))
    (if (file-exists-p cmake-build-dir)
        (progn
          (cd cmake-build-dir)
          (compile "cmake .."))
      (message "CMake build directory not found, please create one first."))))

(defun compile-project (target)
  (interactive "MEnter target name: ")
  (cmake-ide-run-cmake)
  (let ((build-dir (concat (projectile-project-root) "build/"))
        (compile-command (concat "cd " (projectile-project-root) " && cmake --build build --target " target)))
    (compile compile-command)))

(defun build-and-run-project (target)
  (interactive "MEnter target name: ")
  (compile-project target)
  (let ((build-dir (concat (projectile-project-root) "build/"))
        (compile-command (concat "cd " (projectile-project-root) " && cmake --build build --target " target " && " (projectile-project-root) "build/" target)))
    (compile compile-command)
    (async-shell-command (concat (projectile-project-root) "build/" target))))

(defun build-and-debug-project (target)
  (interactive "MEnter target name: ")
  (compile-project target)
  (let ((build-dir (concat (projectile-project-root) "build/"))
        (compile-command (concat "cd " (projectile-project-root) " && cmake --build build --target " target)))
    (compile compile-command)
    (gdb (concat "gdb -i=mi " (concat (projectile-project-root) "build/" target)))))

;;(global-set-key (kbd "<f5>") 'build-and-run-project)
;;(global-set-key (kbd "<f6>") 'build-and-debug-project)
;;(global-set-key (kbd "<f7>") 'compile-project)
;;(global-set-key (kbd "<f8>") 'my/run-cmake)
