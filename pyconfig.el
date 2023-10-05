(require 'lsp-mode)

(use-package lsp-python-ms
  :ensure t
  :demand t  ;; Загружать пакет сразу, а не по требованию
  )

(setq lsp-python-ms-executable "pyright")

(use-package python-black
  :ensure t
  :hook (python-mode . python-black-on-save-mode)
  )

(setq python-indent-offset 4)

(with-eval-after-load 'company
  (add-hook 'python-mode-hook (lambda () (add-to-list 'company-backends 'company-capf))))
