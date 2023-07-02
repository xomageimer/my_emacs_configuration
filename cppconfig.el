(use-package lsp-mode
  :ensure t
  :hook ((c++-mode python-mode sh-mode) . lsp-deferred)
  :commands (lsp lsp-deferred)
  :config (setq lsp-idle-delay 0.500))

;(setq lsp-clients-clangd-args '("--log=verbose"))

;(setq lsp-log-io t)

(setq lsp-clients-clangd-executable "clangd")
;;(setq lsp-enable-semantic-highlighting t)

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom (lsp-ui-doc-position 'at-point))

(setq lsp-ui-sideline-enable t)
;;(setq lsp-ui-sideline-show-diagnostics t)
(setq lsp-ui-doc-glance-mode t)
(setq lsp-enable-macro-expansion t)
(setq lsp-ui-peek-always-show t)
(setq lsp-ui-sidline-show-hover t)
(setq lsp-ui-sideline-show-code-actions t)

(setq lsp-headerline-breadcrumb-enable nil)

(add-hook 'lsp-mode-hook (lambda ()
                           (setq-local lsp-xref-keep-region-history t)))

;;(setq lsp-clients-clangd-args '("--clang-tidy"))

(global-set-key (kbd "C-c l") 'lsp)
(global-set-key (kbd "C-c u") 'lsp-ui-mode)
(global-set-key (kbd "C-c r") 'lsp-ui-peek-find-references)
(global-set-key (kbd "C-c q") 'lsp-find-references)
(global-set-key (kbd "C-c d") 'lsp-describe-thing-at-point)
(global-set-key (kbd "C-c e") 'list-flycheck-errors)

;;; ====> Пакет flycheck в Emacs - это плагин для автоматической проверки синтаксиса вашего кода на наличие ошибок.
;; ------ flycheck ------
(use-package flycheck
  :hook (lsp-mode . flycheck-mode))

;; ------ flycheck-clang-tidy ------
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-clang-tidy-setup))

(use-package flycheck-clang-tidy
  :after flycheck
  :hook
  (flycheck-mode . flycheck-clang-tidy-setup)
  )

(with-eval-after-load 'flycheck
  (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc)))
(add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c++17")))

(add-hook 'c++-mode-hook
          (lambda () (setq flycheck-clang-standard-library "libc++")))
(add-hook 'c++-mode-hook
          (lambda () (setq flycheck-clang-include-path
                           (list "/usr/include/c++/12"))))

;;; <==== flycheck

(use-package counsel
  :ensure t)

(use-package projectile
  :hook (prog-mode . projectile-mode)
  :custom
  (projectile-completion-system 'default)
  (projectile-enable-caching t)
  (projectile-indexing-method 'hybrid)
  (projectile-globally-ignored-directories '(".git" ".svn" ".hg" ".idea" ".vscode" ".eunit" "node_modules" "dist" "build" "target"))
  (projectile-globally-ignored-file-suffixes '(".o" ".elc" ".pyc" ".class" ".min.js" ".min.css"))
  :config
  (projectile-mode))

(use-package counsel-projectile
  :ensure t)

;;; ====> Пакет company в Emacs - это автодополнитель, который помогает вам быстрее писать код, предоставляя предложения для завершения кода, основанные на том, что вы уже написали.
(use-package company
  :ensure t
  :init (global-company-mode)
  :bind (:map company-active-map
	  ("<tab>" . company-select-next)
          ("<backtab>" . company-select-previous))
  :hook (prog-mode . company-mode)
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package yasnippet
  :ensure t)
(require 'yasnippet)
(yas-global-mode 1)

(when (package-installed-p 'company-capf)
  (use-package company-capf
    :after lsp-mode company
    :custom
    (company-lsp-async t)
    (company-lsp-cache-candidates 'auto)
    (company-lsp-enable-snippet t)
    (company-lsp-enable-recompletion t)
    :config
    (push 'company-lsp company-backends)))

(use-package rg
  :defer t)

(global-set-key (kbd "C-c s") 'counsel-projectile-rg)
(global-set-key (kbd "C-c f") 'counsel-projectile-find-file)

(use-package clang-format
  :ensure t
  :bind (:map c++-mode-map
         ("C-c i" . clang-format-region)
         ("C-c u" . clang-format-buffer)))

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)                ; tabs four spaces wide
(defvaralias 'c-basic-offset 'tab-width)  ; Set the C/C++/Java.. mode to use this tab width

(global-set-key (kbd "C-c c a") 'lsp-ui-sideline-apply-code-actions)

(use-package flycheck-clang-tidy
  :ensure t)

(defun set_permission_hook ()
  (setq enable-local-variables :all)
  )

(add-hook 'flycheck-mode-hook #'set_permission_hook)

(defun gud-break-and-save-to-gdbinit ()
  "Установить точку останова в GDB на текущей строке и сохранить ее в .gdbinit в папке cmake-build."
  (interactive)
  (let ((current-line (line-number-at-pos))
        (current-file (get-project-relative-file-name)))
    (let ((gdbinit-file (my/create-gdbinit-file)))
      (when (and (file-exists-p gdbinit-file) (file-writable-p gdbinit-file))
        (with-temp-buffer
          (insert (format "break %s:%d\n" current-file current-line))
          (append-to-file (point-min) (point-max) gdbinit-file))))))

(global-set-key (kbd "C-x g b") 'gud-break-and-save-to-gdbinit)

(defvar my-compile-commands-path nil
  "Path to the compile_commands.json file.")

(defun my/find-compile-commands ()
  "Find compile_commands.json in the project root and set the path."
  (interactive)
  (if (not my-compile-commands-path)
    (let ((compile_commands_path (process-find-compile-commands)))
      (if compile_commands_path
          (progn
            (setq my-compile-commands-path compile_commands_path)
            (setq lsp-clients-clangd-args (list (concat "--compile-commands-dir=" my-compile-commands-path)))
            (message "Found compile_commands.json in the project root: %s" my-compile-commands-path))
      (message "No compile_commands.json found in the project root.")))
  (message "compile_commands.json already seted!")))

(defun my/reset-compile-commands-path ()
  "Reset compile_commands.json in the project root and set the path."
  (interactive)
  (setq my-compile-commands-path nil)
  (my/find-compile-commands))

(defun process-find-compile-commands ()
  "Find the project root directory."
  (let ((root-file (locate-dominating-file default-directory "compile_commands.json")))
    (if root-file
        (concat (projectile-project-root "compile_commands.json")
      nil))))

(defun my-show-compile-commands-path ()
  "Show the path to the compile_commands.json file."
  (interactive)
  (if my-compile-commands-path
      (message "Current compile_commands.json path: %s" my-compile-commands-path)
    (message "No compile_commands.json path set.")))

(defun my/lsp-mode-hook ()
  "Custom hook for lsp-mode."
  (when (bound-and-true-p lsp-mode)
    (my/find-compile-commands)))

(add-hook 'lsp-mode-hook #'my/lsp-mode-hook)

<<<<<<< Updated upstream
(use-package lsp-treemacs
  :ensure t)
(lsp-treemacs-sync-mode 1)

(use-package dap-mode
  :ensure t)

(dap-mode 1)

;; The modes below are optional

(dap-ui-mode 1)
;; enables mouse hover support
(dap-tooltip-mode 1)
;; use tooltips for mouse hover
;; if it is not enabled `dap-mode' will use the minibuffer.
(tooltip-mode 1)
;; displays floating panel with debug buttons
;; requies emacs 26+
(dap-ui-controls-mode 1)
=======
;; (use-package exec-path-from-shell
;;   :ensure
;;   :init (exec-path-from-shell-initialize))

;; (use-package dap-mode
;;   :ensure
;;   :config
;;   (dap-ui-mode)
;;   (dap-ui-controls-mode 1)

;;   (require 'dap-lldb)
;;   (require 'dap-gdb-lldb)
;;   ;; installs .extension/vscode
;;   (dap-gdb-lldb-setup)
;;   (dap-register-debug-template
;;    "Rust::LLDB Run Configuration"
;;    (list :type "lldb"
;;          :request "launch"
;;          :name "LLDB::Run"
;; 	 :gdbpath "rust-lldb"
;;          :target nil
;;          :cwd nil)))
>>>>>>> Stashed changes
