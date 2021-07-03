;;; gray-matter.el --- A minimal yet powerful Emacs config -*- lexical-binding: t -*-

;;; Commentary:
;;; This is an attempt at a minimal yet featureful Emacs configuration that can
;;; just be used as is to get some work done.

;; Author: Abraham Raji <avronr@tuta.io>
;; Version: 1.0.0
;; Keywords: Config, Minimal Lisp
;; License: GPL v3

;;; Code:

;; UTF-8 across the board
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; User Info
(defvar user-full-name "Abraham Raji")
(defvar user-email "avonr@tuta.io")

;; Backups
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))

;; autosave the undo-tree history
(defvar undo-tree-history-directory-alist '((".*" . ,temporary-file-directory)))

;; Disk space is cheap. Save lots.
(setq delete-old-versions -1)
(setq version-control t)
(setq vc-make-backup-files t)
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save-list/" t)))

;; Don’t add two spaces for sentence end.
(setq sentence-end-double-space nil)

;; Time
(display-time-mode 1)
;; Package Management
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
	("gnu" . "https://elpa.gnu.org/packages/")
	("org" . "http://orgmode.org/elpa/")))
(package-initialize)

;; lisp equivalent of a while loop
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  ;; We're using package install to install use-package
  (package-install 'use-package)
  ;; to install newer version when available
  (setq load-prefer-newer t))
;; This line is just a raincheck
(defvar use-package-verbose t)
;;Always ensure that the package is installed
(defvar use-package-always-ensure t)
(require 'use-package)


;; Set font size
(set-face-attribute 'default nil :family "Inconsolata" :height 180)
(set-face-attribute 'variable-pitch nil :family "Libre Baskerville" :height 140)

;; Column Break
(add-hook 'text-mode-hook #'auto-fill-mode)
(add-hook 'prog-mode-hook #'auto-fill-mode)
(setq-default fill-column 80)

;; Set cursor type
(setq-default cursor-type 'bar)

;; Highlight when line exceeds 80 chars
(use-package column-enforce-mode :ensure t
  :config (global-column-enforce-mode t))

;; Set key bindings for buffer navigation
(windmove-default-keybindings)
(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <down>")  'windmove-down)

;; Increase cache
(setq gc-cons-threshold 50000000)

;; Disable Emacs startup screen
(setq inhibit-startup-message t)
;; Disable toolbar
(tool-bar-mode -1)
;; y or n instead of Yes or No
(fset 'yes-or-no-p 'y-or-n-p)
;; No need for double space at the end of sentences
(setq sentence-end-double-space nil)
;; Disable visible bell
(setq visible-bell t
      ring-bell-function 'ignore)
;; Key bindings for killing buffer
(global-set-key (kbd "C-x w") 'kill-current-buffer)
;; Key binding for eshell
(global-set-key (kbd "<M-return>") 'vterm-other-window)

;; Relative line number
(use-package linum-relative :ensure t
  :config (setq linum-relative-current-symbol "")
  (add-hook 'prog-mode-hook 'linum-relative-mode))

;; Pretty symbols
(global-prettify-symbols-mode t)

;; Highlight current line
(global-hl-line-mode t)

;; Scrollbar
(when (window-system)
  (tool-bar-mode 0)
  (when (fboundp 'horizontal-scroll-bar-mode)
    (horizontal-scroll-bar-mode -1))
  (scroll-bar-mode -1))

;; Scrolling conservatively
(setq scroll-conservatively 10000
      scroll-preserve-screen-position t)

;; Menu bar
(menu-bar-mode -1)
(defun my-menu-bar-open-after ()
  "Hide menu-bar when called if menubar is open."
  (remove-hook 'pre-command-hook 'my-menu-bar-open-after)
  (when (eq menu-bar-mode 42)
    (menu-bar-mode -1)))
(defun my-menu-bar-open (&rest args)
  "View menu-bar when called if menubar is open with ARGS."
  (interactive)
  (let ((open menu-bar-mode))
    (unless open
      (menu-bar-mode 1))
    (funcall 'menu-bar-open args)
    (unless open
      (setq menu-bar-mode 42)
      (add-hook 'pre-command-hook 'my-menu-bar-open-after))))
(global-set-key [f10] 'my-menu-bar-open)

;; Magit
(use-package magit :ensure t
  :init (progn
	  (bind-key "C-x g" 'magit-status)))
(use-package with-editor)

(use-package flyspell
  :ensure t
  :diminish flyspell-mode
  :init
  (add-hook 'prog-mode-hook 'flyspell-prog-mode)

  (dolist (hook '(text-mode-hook org-mode-hook))
    (add-hook hook (lambda () (flyspell-mode 1))))

  (dolist (hook '(change-log-mode-hook log-edit-mode-hook org-agenda-mode-hook))
    (add-hook hook (lambda () (flyspell-mode -1))))

  :config
  (setq ispell-program-name "/usr/bin/aspell"
        ispell-local-dictionary "en_US"
        ispell-dictionary "american" ; better for aspell
        ispell-extra-args '("--sug-mode=ultra" "--lang=en_US")
        ispell-list-command "--list"
        ispell-local-dictionary-alist '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "['‘’]"
                                      t ; Many other characters
                                      ("-d" "en_US") nil utf-8))))

;; Company mode
(use-package company :ensure t
  :bind (:map company-active-map ("<tab>" . company-complete-selection)))
(add-hook 'after-init-hook 'global-company-mode)
;; Org Mode code blocks completition
(use-package company-org-block :ensure t
  :custom (company-org-block-edit-style 'auto)
  :hook ((org-mode . (lambda ()
		       (setq-local company-backends '(company-org-block))
		       (company-mode +1)))))
(setq company-idle-delay 0.1
      company-minimum-prefix-length 1)
(setq company-show-numbers t)

;; Quickhelp
(use-package company-quickhelp :ensure t
  :config (company-quickhelp-mode 1))

;; Ivy
(use-package ivy :ensure t)
(use-package counsel :ensure t)
(use-package swiper :ensure t)
(ivy-mode)
(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)
;; enable this if you want `swiper' to use it
(setq search-default-mode #'char-fold-to-regexp)
(global-set-key "\C-s" 'swiper)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> o") 'counsel-describe-symbol)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c k") 'counsel-ag)
(global-set-key (kbd "C-x l") 'counsel-locate)
(global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
(define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)

;; LSP mode
(use-package lsp-mode
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  :init (setq lsp-keymap-prefix "C-c l")
  :hook ((python-mode . lsp)
	 (ruby-mode . lsp)
	 (js-mode . lsp)
	 (sh-mode . lsp)
	 (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

;; LSP UI
(use-package lsp-ui :commands lsp-ui-mode)
;; Ivy support for LSP
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
;; Treemacs
(use-package treemacs :ensure t
  :config (lsp-treemacs-sync-mode 1))
(global-set-key (kbd "C-c t")  'treemacs)
(global-set-key (kbd "C-c h")  'treemacs-toggle-show-dotfiles)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)
(use-package treemacs-all-the-icons :ensure t)


;; Debugger
(use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

;; Which Key
(use-package which-key :config (which-key-mode))

(use-package lsp-pyright :ensure t
  :hook (python-mode . (lambda ()
			 (require 'lsp-pyright)
			 (lsp))))  ; or lsp-deferred
;;Flycheck
(use-package flycheck :ensure t
  :init (global-flycheck-mode))

;; Vterm
(use-package vterm :ensure t)
(add-hook 'vterm-mode-hook
	  (lambda ()
	    "Switch the current buffer to a terminal friendly font."
	    (face-remap-add-relative 'default '(:family "MesloLGS NF"
						:height 120))))

;; yasnippet
(use-package yasnippet :ensure t)
(use-package yasnippet-snippets :ensure t)

;; emmet-mode
(use-package emmet-mode :ensure t)
(add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
(add-hook 'css-mode-hook  'emmet-mode) ;; enable Emmet's css abbreviation.

;; Fancy font for orgmode
(add-hook 'org-mode-hook
	  (lambda ()
	    "Switch the current buffer to a terminal friendly font."
	    (face-remap-add-relative 'default '(:family "Quicksand"))))

(add-hook 'prog-mode-hook #'yas-minor-mode)

;; Add yasnippet support for all company backends
;; https://github.com/syl20bnr/spacemacs/pull/179
(defvar company-mode/enable-yas t
  "Enable yasnippet for all backends.")

(defun company-mode/backend-with-yas (backend)
  "Add :with company-yasnippet to company BACKEND.
Taken from https://github.com/syl20bnr/spacemacs/pull/179."
  (if (or (not company-mode/enable-yas)
	  (and (listp backend)
	       (member 'company-yasnippet backend)))
      backend
    (append (if (consp backend) backend (list backend))
            '(:with company-yasnippet))))

(setq company-backends (mapcar #'company-mode/backend-with-yas
			       company-backends))

(defvar electric-pair-pairs '(
                           (?\{ . ?\})
                           (?\( . ?\))
                           (?\[ . ?\])
                           (?\" . ?\")
                           ))
(electric-pair-mode t)

;; keeping parentheses balanced.
(use-package smartparens :diminish smartparens-mode
  :config (add-hook 'prog-mode-hook 'smartparens-mode))

;; Highlight parens etc. for improved readability.
(use-package rainbow-delimiters
  :config (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

;; Smart Select
(use-package expand-region :bind ("C-=" . er/expand-region))

;; Multiple Cursors
(use-package multiple-cursors :ensure t)
(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;; Quickly visit Emacs configuration
(defun gray-matter/visit-emacs-config ()
  "Quickly visit Emacs configuration."
  (interactive)
  (find-file "~/.emacs.d/init.el"))

(defun gray-matter/visit-gray-matter ()
  "Quickly visit Emacs configuration."
  (interactive)
  (find-file "~/.emacs.d/gray-matter.el"))

(global-set-key (kbd "C-c e") 'gray-matter/visit-emacs-config)
(global-set-key (kbd "C-c m") 'gray-matter/visit-gray-matter)

;; Projectile
(use-package projectile :ensure t
  :init (projectile-mode 1))

(use-package powerline :ensure t
  :init
  (setq powerline-default-separator-dir (quote (left . right))
        powerline-height 28
        powerline-display-buffer-size nil
        powerline-display-hud nil
        powerline-display-mule-info nil
        powerline-gui-use-vcs-glyph t
	))
(powerline-default-theme)

(use-package diminish :ensure t
  :init
  (diminish 'company-mode) (diminish 'flycheck-mode)
  (diminish 'linum-relative-mode) (diminish 'projectile-mode)
  (diminish 'which-key-mode) (diminish 'eldoc-mode)
  (diminish 'auto-fill-function) (diminish 'ivy-mode)
  (diminish 'yas-minor-mode) (diminish 'column-enforce-mode))

(use-package org-superstar :ensure t)
(add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))

(provide 'grey-matter)
;;; gray-matter.el ends here
