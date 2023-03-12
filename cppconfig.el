
(use-package company-rtags
:ensure t)
(use-package flycheck-rtags
:ensure t)

;; ensure that we use only rtags checking
;; https://github.com/Andersbakken/rtags#optional-1
(defun setup-flycheck-rtags ()
(interactive)
(flycheck-select-checker 'rtags)
;; RTags creates more accurate overlays.
(setq-local flycheck-highlighting-mode nil)
(setq-local flycheck-check-syntax-automatically nil))

(use-package rtags
:ensure t
:hook (c++-mode . rtags-start-process-unless-running)
:config
(setq rtags-completions-enabled t
    rtags-path "/home/ivan-egorov/.emacs.d/rtags/src/rtags.el"
    rtags-rc-binary-name "/home/ivan-egorov/.emacs.d/rtags/bin/rc"
    rtags-use-helm t
    rtags-rdm-binary-name "/home/ivan-egorov/.emacs.d/rtags/bin/rdm")
:bind (("C-c E" . rtags-find-symbol)
    ("C-c e" . rtags-find-symbol-at-point)
    ("C-c O" . rtags-find-references)
    ("C-c o" . rtags-find-references-at-point)
    ("C-c s" . rtags-find-file)
    ("C-c v" . rtags-find-virtuals-at-point)
    ("C-c F" . rtags-fixit)
    ("C-c f" . rtags-location-stack-forward)
    ("C-c b" . rtags-location-stack-back)
    ("C-c n" . rtags-next-match)
    ("C-c p" . rtags-previous-match)
    ("C-c P" . rtags-preprocess-file)
    ("C-c R" . rtags-rename-symbol)
    ("C-c x" . rtags-show-rtags-buffer)
    ("C-c T" . rtags-print-symbol-info)
    ("C-c t" . rtags-symbol-type)
    ("C-c I" . rtags-include-file)
    ("C-c i" . rtags-get-include-file-for-symbol)))

(use-package company
:ensure t
:config
(global-company-mode)
(push 'company-rtags company-backends)
(define-key c-mode-base-map (kbd "<C-tab>") (function company-complete)))

(use-package flycheck-rtags
:ensure t
:hook (c-mode-common-hook . setup-flycheck-rtags))

(setq rtags-display-result-backend 'helm)

(use-package yasnippet
:ensure t
:config
(yas-global-mode 1))

(defun code-compile ()
  (interactive)
  (unless (file-exists-p "Makefile")
    (set (make-local-variable 'compile-command)
     (let ((file (file-name-nondirectory buffer-file-name)))
       (format "%s -o %s %s"
           (if  (equal (file-name-extension file) "cpp") "g++" "gcc" )
           (file-name-sans-extension file)
           file)))
    (compile compile-command)))

(global-set-key [f9] 'code-compile)

(global-set-key (kbd "<left-fringe> <mouse-1>") 'gdb-toggle-breakpoint)
