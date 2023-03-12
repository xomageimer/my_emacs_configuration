(use-package projectile
  :config
  (projectile-mode +1))

(defun compile-project (target)
  (interactive "MEnter target name: ")
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
