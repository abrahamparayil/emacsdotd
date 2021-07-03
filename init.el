;;; init.el --- Personal additions to Emacs config -*- lexical-binding: t -*-
;;; Commentary:
;;; Personal additions to the Emacs Config

;; Author: Abraham Raji <avronr@tuta.io>
;; Version: 1.0.0
;; Keywords: Config, Minimal Lisp
;; License: GPL v3

;;; Code:

(load-file "~/.emacs.d/gray-matter.el")

;; User Info
(defvar user-full-name "Abraham Raji")
(defvar user-email "avonr@tuta.io")

(setq custom-file (concat user-emacs-directory "/custom.el"))
(load-file custom-file)

;; run an emacs server
(require 'server)
(unless (server-running-p)
(server-start))

;; org treeslide for easily moving files
(use-package org-tree-slide :ensure t)

;; beamer exporting
(require 'ox-md)
(require 'ox-beamer)

(setq org-ellipsis " ▶")

;; better theming
(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-tomorrow-night t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (defvar doom-themes-treemacs-theme "doom-tomorrow-night") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package pdf-tools
   :defer t
   :config
       (pdf-tools-install)
       (setq-default pdf-view-display-size 'fit-page)
   :bind (:map pdf-view-mode-map
         ("\\" . hydra-pdftools/body)
         ("<s-spc>" .  pdf-view-scroll-down-or-next-page)
         ("g"  . pdf-view-first-page)
         ("G"  . pdf-view-last-page)
         ("l"  . image-forward-hscroll)
         ("h"  . image-backward-hscroll)
         ("j"  . pdf-view-next-page)
         ("k"  . pdf-view-previous-page)
         ("e"  . pdf-view-goto-page)
         ("u"  . pdf-view-revert-buffer)
         ("al" . pdf-annot-list-annotations)
         ("ad" . pdf-annot-delete)
         ("aa" . pdf-annot-attachment-dired)
         ("am" . pdf-annot-add-markup-annotation)
         ("at" . pdf-annot-add-text-annotation)
         ("y"  . pdf-view-kill-ring-save)
         ("i"  . pdf-misc-display-metadata)
         ("s"  . pdf-occur)
         ("b"  . pdf-view-set-slice-from-bounding-box)
         ("r"  . pdf-view-reset-slice)))

(use-package org-pdftools
  :config
  (add-to-list 'org-file-apps
               '("\\.pdf\\'" . (lambda (file link)
				 (org-pdfview-open link)))))

(add-hook 'pdf-view-mode-hook (lambda() (linum-mode -1)))

(use-package nov
  :config (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))

(setq-default indent-tabs-mode t)

;; insert date and time
(defun insert-current-date ()
  "Insert current date and time."
  (interactive)
  (insert (shell-command-to-string "echo -n $(date)")))

(global-set-key (kbd "C-c C-d") 'insert-current-date)
;;; init.el ends here
