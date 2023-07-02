;;; хоткеи для перехода в конец и начало буфера
(global-set-key (kbd "C-c b") 'beginning-of-buffer)
(global-set-key (kbd "C-c n") 'end-of-buffer)

;;; восстанавливать последнее состояние буфера
(desktop-save-mode 1)

;;; ====> функции для подключения других el конфигов
;;; Указываем откуда брать части настроек.
(defconst user-init-dir
  (cond ((boundp 'user-emacs-directory) user-emacs-directory)
        ((boundp 'user-init-directory) user-init-directory)
        (t "~/.emacs.d/")))

;;; Функция для загрузки настроек из указанного файла.
(defun load-user-file (file)
  (interactive "f")
  "Load a file in current user's configuration directory"
  (load-file (expand-file-name file user-init-dir)))
;;; <====  функции для подключения других el конфигураций

;;; подключение melpa репозитория
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;;; Если пакет use-package не установлен, его нужно скачать и
;;; установить
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
  (message "EMACS install use-package.el")

;;; =====> настройки для плавного скролинга и получения последних файлов
(global-set-key "\C-x\ \C-g" 'recentf-open-files)
(setq redisplay-dont-pause t
      scroll-margin 5
      scroll-step 1
      scroll-conservatively 1000
      scroll-preserve-screen-position 1)   
;;; <===== настройки для плавного скролинга и получения последних файлов

(setq use-package-always-ensure t)

;; (use-package solarized-themes
;;   :ensure t
;;   :config
;;   (load-theme 'solarized-dark t))

;;; ====> пакет для работы с git // TODO: вынести в отдельный конфиг
(use-package magit
  :ensure t)
(global-set-key (kbd "C-c g s") 'magit-status)
(global-set-key (kbd "C-c g l") 'magit-log-head)
(global-set-key (kbd "C-c g d") 'magit-diff)
(global-set-key (kbd "C-c g b") 'magit-blame)
;;; <==== magit

(use-package async
  :ensure t
  :config
  (async-bytecomp-package-mode 1))

;;; ====> пакет для работы с парными символами, упрощает работу с ними
(use-package smartparens
  :config (smartparens-global-mode 1))
;;; <==== smartparens

;;; ====> Пакет Ansi-color в Emacs предназначен для работы с текстом, содержащим ANSI-цветовые коды. 
(use-package ansi-color
  :ensure t)
;;; <==== Ansi-color. 

;;; ====> Пакет Neotree в Emacs предназначен для работы с файловой системой и навигации по файлам и директория
(use-package neotree
  :ensure t
  :init (setq neo-window-width 35)
  :config (setq neo-smart-open nil))

;;; функция чтобы открывать toggle'ить текущую директорию
(defun toggle-neotree-and-find ()
  "Toggle the NeoTree window and find the current file."
  (interactive)
  (if (neo-global--window-exists-p)
      (neotree-hide)
    (progn
      (neotree-find)
      (neotree-show))))
(global-set-key (kbd "<f9>") 'toggle-neotree-and-find)
;;; <=== Neotree

;; ==========> Пакет Consult - это набор инструментов для Emacs, который предоставляет расширенный поиск файлов, буферов, команд и многого другого.
(use-package consult
  :ensure t
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings (ctl-x-map)
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings (goto-map)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings (search-map)
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
  ;;;; 4. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;;;; 5. No project support
  ;; (setq consult-project-function nil)
  )
;; <============ Consult

;; ============> Пакет Vertico - это расширение для Emacs, которое предоставляет расширенную функциональность для работы с минибуфером.
(use-package vertico
  :ensure t
  :init
  (vertico-mode)

  ;; Different scroll margin
  ;; (setq vertico-scroll-margin 0)

  ;; Show more candidates
  ;; (setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  ;; (setq vertico-cycle t)
  )

;; ====> Пакет savehist - это расширение для Emacs, которое сохраняет историю выполненных команд и ввода в Emacs между сеансами работы.
(use-package savehist
  :ensure t
  :init
  (savehist-mode))
;; <==== savehist

;; A few more useful configurations...
(use-package emacs
  :ensure t
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :ensure t
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))
;; <================ Vertico

;;; ====> Пакет which-key - это расширение для Emacs, которое помогает пользователям отслеживать и запоминать горячие клавиши и команды, доступные в Emacs
(use-package which-key
  :ensure t
  :config
  (which-key-mode)
  (setq which-key-side-window-location 'right))
;;; <==== which-key

;; load tab and backtab keys for editing
;;(load-user-file "helmconfig.el")

;; load tab and backtab keys for editing
(load-user-file "normaltabs.el")

;; load cpp configuration
(load-user-file "cppconfig.el")

;; load cmake configuration
(load-user-file "buildconfig.el")

;; load ue configuration
(load-user-file "ue/ue.el")

;; load for marco paintin
;;(load-user-file "deffunctions.el")

(delete-selection-mode 1)   ; включаем режим удаления выделенного текста
(setq yank-undo-function 'yank-unbounded)   ; настраиваем замену выделенного текста при вставке

;;; устанавливаем шрифт
(set-face-attribute 'default nil :font "JetBrains Mono 12" :height 107)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(solarized-dark-high-contrast))
 '(custom-safe-themes
   '("833ddce3314a4e28411edf3c6efde468f6f2616fc31e17a62587d6a9255f4633" "d89e15a34261019eec9072575d8a924185c27d3da64899905f8548cbd9491a36" "00445e6f15d31e9afaa23ed0d765850e9cd5e929be5e8e63b114a3346236c44c" "285d1bf306091644fb49993341e0ad8bafe57130d9981b680c1dbd974475c5c7" "830877f4aab227556548dc0a28bf395d0abe0e3a0ab95455731c9ea5ab5fe4e1" "3e200d49451ec4b8baa068c989e7fba2a97646091fd555eca0ee5a1386d56077" "51ec7bfa54adf5fff5d466248ea6431097f5a18224788d0bd7eb1257a4f7b773" "7f1d414afda803f3244c6fb4c2c64bea44dac040ed3731ec9d75275b9e831fe5" "fee7287586b17efbfda432f05539b58e86e059e78006ce9237b8732fde991b4c" default))
 '(gdb-many-windows t)
 '(global-display-line-numbers-mode t)
 '(ispell-dictionary nil)
 '(menu-bar-mode nil)
 '(package-selected-packages
   '(exec-path-from-shell yasnippet srefactor-lisp srefactor ue embrace nerd-icons-dired nerd-icons deadgrep term-projectile projectile-codesearch consult-projectile helm projectile-ripgrep find-file-rg flycheck-clang-tidy fringe-helper realgud-lldb realgud quelpa google-translate pdf-tools solarized-themes lsp-mode lsp-focus flycheck-plantuml markdown-mode cmake-project clang-format+ google-c-style cl-lib cpputils-cmake clang-format edebug-x dap-mode fzf ag unicode-fonts default-font-presets counsel-projectile rg company-lsp projectile cmake-mode yasnippet-snippets realgud-jdb neotree which-key rtags-xref ivy-rtags ac-rtags magit smartparens company solarized-theme vertico consult use-package compat))
 '(recentf-mode t)
 '(safe-local-variable-values
   '((flycheck-mode . t)
     (flycheck-clang-tidy-checks . "*, -readability-identifier-naming")))
 '(tab-bar-mode t)
 '(tab-stop-list
   '(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120))
 '(tool-bar-mode nil)
 '(warning-suppress-types '(((dap-variables-expand-variable)))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;; размеры окна по умолчанию
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(defun my-enlarge-window-horizontally ()
  "Enlarge the window horizontally by 5 columns."
  (interactive)т
  (enlarge-window-horizontally 5))

(defun my-shrink-window-horizontally ()
  "Enlarge the window horizontally by 5 columns."
  (interactive)
  (shrink-window-horizontally 5))

(defun my-enlarge-window ()
  "Enlarge the window horizontally by 5 columns."
  (interactive)
  (enlarge-window 5))

(defun my-shrink-window ()
  "Enlarge the window horizontally by 5 columns."
  (interactive)
  (shrink-window 5))

(global-set-key (kbd "M-[") 'my-enlarge-window-horizontally)
(global-set-key (kbd "M-]") 'my-shrink-window-horizontally)
(global-set-key (kbd "M-o") 'my-enlarge-window)
(global-set-key (kbd "M-p") 'my-shrink-window)

(global-set-key (kbd "C-x t <left>") 'tab-bar-move-tab-backward)
(global-set-key (kbd "C-x t <right>") 'tab-bar-move-tab)

(setq ripgrep-arguments '("-S" "-u" "-i"))

;; Enable M-x kill-process (to kill the current buffer's process).
(put 'kill-process 'interactive-form
     '(interactive
       (let ((proc (get-buffer-process (current-buffer))))
         (if (process-live-p proc)
             (unless (yes-or-no-p (format "Kill %S? " proc))
               (error "Process not killed"))
           (error (format "Buffer %s has no process" (buffer-name))))
         nil)))

(setq comint-scroll-to-bottom-on-output t)

(setq-default message-log-max nil)

(setq savehist-file "~/.emacs.d/history")
(savehist-mode 1)
(setq history-length t)
(setq history-length 100)

(global-set-key (kbd "C-x O") 'previous-window-any-frame)

(setq-default large-file-warning-threshold (* 25 1024 1024 1024)) ;; 25 GB

(use-package pdf-tools
  :ensure t
  :config
  ;; Установка pdf-tools
  (pdf-tools-install)
  ;; Добавление ключей прокрутки
  (setq pdf-view-continuous-scroll-mode t)
  (setq pdf-view-continuous-scroll-speed-mode 0.5)
  ;; Добавление сокращений для работы с pdf-view-mode
  (define-key pdf-view-mode-map (kbd "j") 'pdf-view-next-line-or-next-page)
  (define-key pdf-view-mode-map (kbd "k") 'pdf-view-previous-line-or-previous-page)
  (define-key pdf-view-mode-map (kbd "l") 'image-forward-hscroll)
  (define-key pdf-view-mode-map (kbd "h") 'image-backward-hscroll))

(use-package google-translate
  :ensure t
  :config
  ;; Настройка Google Translate
  (require 'google-translate)
  (require 'google-translate-default-ui)
  (setq google-translate-default-source-language "en")
  (setq google-translate-default-target-language "ru")
  ;; Добавление сокращения для быстрого перевода выделенного текста
  (global-set-key (kbd "C-c t") 'google-translate-at-point))

(defun my-query-replace-regexp (text-to-replace replacement-text)
  "Обертка над `query-replace-regexp`, перемещает курсор в начало буфера перед выполнением замены."
  (interactive
   (list (read-string "Текст для замены: ")
         (read-string "Текст, на который заменить: ")))
  (save-excursion
    (goto-char (point-min))
    (query-replace-regexp text-to-replace replacement-text)))

(global-set-key (kbd "C-c C-r") ' my-query-replace-regexp)

(defvar surround-text-default-strings '("/* */")
  "Список строк для окружения текста по умолчанию.")

(defun surround-text-with-strings (strings)
  "Заменяет выделенный текст, окружая его указанными строками.
   Если указана одна строка, она будет использована для окружения с обеих сторон.
   Если указаны две строки, первая будет вставлена вначале, а вторая в конце."
  (interactive
   (list (read-string "Input strings (or press enter for default): " nil nil surround-text-default-strings)))
  (let* ((strings-list (split-string strings))
         (text (buffer-substring (region-beginning) (region-end))))
    (delete-region (region-beginning) (region-end))
    (cond ((= (length strings-list) 1)
           (insert (concat (car strings-list) text (car strings-list))))
          ((= (length strings-list) 2)
           (insert (concat (car strings-list) text (cadr strings-list))))))
  (setq surround-text-default-strings strings))

(setq-default surround-text-default-strings surround-text-default-strings)

(global-set-key (kbd "C-c C-x s") 'surround-text-with-strings)

(setq enable-local-variables t)

(use-package project
  :ensure t)

(use-package deadgrep)

(defun my/show-projectile-root ()
  "Display the current Projectile project root in the minibuffer."
  (interactive)
  (message "Projectile root directory: %s" (projectile-project-root)))

(use-package yasnippet
  :ensure t)

(use-package multiple-cursors
  :ensure t)
