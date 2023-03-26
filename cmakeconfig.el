(use-package projectile
  :config
  (projectile-mode +1))

(defun my-cmake-build ()
  "Compile CMake project using LSP."
  (interactive)
  (let ((default-directory (projectile-project-root))
        (compilation-scroll-output t)
        (compilation-finish-function (lambda (buf str)
                                        (let ((ansi-color-apply t))
                                          (ansi-color-buffer))))
        (buf-name "*CMake Compile*"))
    (if (not (file-exists-p (concat default-directory "build")))
        (message "CMake build directory does not exist, please run 'CMake Configure' first")
      (progn
        (cd (concat default-directory "build"))
        (async-shell-command (concat "cmake --build . "
                                     (if (eq system-type 'windows-nt) "/m" "-j8")
                                     " && ctest") buf-name)))))

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

(global-set-key (kbd "<f5>") 'build-and-run-project)
(global-set-key (kbd "<f6>") 'build-and-debug-project)
(global-set-key (kbd "<f7>") 'compile-project)
(global-set-key (kbd "<f8>") 'my-cmake-build)
