(use-package projectile
  :config
  (projectile-mode +1))

(require 'cmake-ide)
(cmake-ide-setup)

(setq cmake-ide-flags-c++ (append '("-E" "tags") cmake-ide-flags-c++))
(setq cmake-ide-flags-c (append '("-E" "tags") cmake-ide-flags-c))

(add-hook 'cmake-ide-after-switch-project-hook 'my-cmake-ide-hook)
(defun my-cmake-ide-hook ()
  (setq-local tags-file-name (concat cmake-ide-build-dir "TAGS")))

;; (use-package cmake-ide			
  ;; :ensure t
  ;; :config
  ;; ;; Задайте имя исполняемого файла CMake (если необходимо)
  ;; (setq cmake-ide-cmake-command "cmake")
  
  ;; ;; Задайте имя исполняемого файла make (если необходимо)
  ;; (setq cmake-ide-make-command "make")
  
  ;; ;; Настройте флаги компилятора (если необходимо)
  ;; (setq cmake-ide-flags-c++ (append '("-std=c++17")))
  
  ;; ;; Настройте ключи CMake (если необходимо)
  ;; (setq cmake-ide-cmake-args (append '("-DCMAKE_BUILD_TYPE=Debug")))
  
  ;; ;; Задайте команду для запуска сборки
  ;; (setq cmake-ide-build-dir (concat (file-name-as-directory (projectile-project-root)) "build")))

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
