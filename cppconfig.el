;; Configure packages with use-package
(use-package lsp-mode
  :ensure t
  :hook ((c++-mode cmake-mode python-mode sh-mode) . lsp-deferred)
  :commands (lsp lsp-deferred)
  :config (setq lsp-idle-delay 0.500))

;;(setq lsp-enable-semantic-highlighting t)

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom (lsp-ui-doc-position 'at-point))

(global-set-key (kbd "C-c l") 'lsp)
(global-set-key (kbd "C-c u") 'lsp-ui-mode)
(global-set-key (kbd "C-c r") 'lsp-ui-peek-find-references)
(global-set-key (kbd "C-c t") 'lsp-find-references)
(global-set-key (kbd "C-c d") 'lsp-describe-thing-at-point)
(global-set-key (kbd "C-c e") 'list-flycheck-errors)

(use-package company
  :hook (prog-mode . company-mode)
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-capf
  :after lsp-mode company
  :custom
  (company-lsp-async t)
  (company-lsp-cache-candidates 'auto)
  (company-lsp-enable-snippet t)
  (company-lsp-enable-recompletion t)
  :config
  (push 'company-lsp company-backends))

(use-package cmake-mode)

(use-package rg
  :defer t)

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

(global-set-key (kbd "C-c s") 'counsel-projectile-rg)
(global-set-key (kbd "C-c f") 'counsel-projectile-find-file)

(use-package clang-format
  :ensure t
  :bind (:map c++-mode-map
         ("C-c i" . clang-format-region)
         ("C-c u" . clang-format-buffer))
  :config (setq clang-format-style "Google"))
