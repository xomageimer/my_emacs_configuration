(use-package projectile
  :config
  (projectile-mode +1))

(use-package cmake-ide
  :config
  (cmake-ide-setup)
  (setq cmake-ide-project-dir (projectile-project-root))
  (setq cmake-ide-build-dir (or
                             (expand-file-name "build/" cmake-ide-project-dir)
                             (expand-file-name "cmake-build-debug/" cmake-ide-project-dir)
                             (expand-file-name "cmake-build-release/" cmake-ide-project-dir)))
)

