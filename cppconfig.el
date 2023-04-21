(use-package lsp-mode
  :ensure t
  :hook ((c++-mode python-mode sh-mode) . lsp-deferred)
  :commands (lsp lsp-deferred)
  :config (setq lsp-idle-delay 0.500))

;;(setq lsp-enable-semantic-highlighting t)

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom (lsp-ui-doc-position 'at-point))

(setq lsp-ui-sideline-enable t)
(setq lsp-ui-sideline-show-diagnostics t)
(setq lsp-ui-doc-glance-mode t)
(setq lsp-enable-macro-expansion t)
(setq lsp-ui-peek-always-show t)
(setq lsp-ui-sidline-show-hover t)
(setq lsp-ui-sideline-show-code-actions t)

(setq lsp-headerline-breadcrumb-enable nil)

(add-hook 'lsp-mode-hook (lambda ()
   (setq-local lsp-xref-keep-region-history t)))

(global-set-key (kbd "C-c l") 'lsp)
(global-set-key (kbd "C-c u") 'lsp-ui-mode)
(global-set-key (kbd "C-c r") 'lsp-ui-peek-find-references)
(global-set-key (kbd "C-c q") 'lsp-find-references)
(global-set-key (kbd "C-c d") 'lsp-describe-thing-at-point)
(global-set-key (kbd "C-c e") 'list-flycheck-errors)

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

(setq enable-local-variables :all)
