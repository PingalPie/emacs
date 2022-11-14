(require 'package)
(setq package-enable-at-startup nil)

(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(defun split-and-follow-horizontally ()
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))

(defun split-and-follow-vertically ()
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))

(global-set-key (kbd "C-x 2") 'split-and-follow-horizontally)
(global-set-key (kbd "C-x 3") 'split-and-follow-vertically)

(defun window-focus-mode ()
  (interactive)
  (if (= 1 (length (window-list)))
      (jump-to-register '_)
    (progn
      (set-register '_ (list (current-window-configuration)))
      (delete-other-windows))))
(global-set-key (kbd "C-c return") 'window-focus-mode)

(global-set-key (kbd "C-x k") 'kill-buffer-and-window)

(use-package switch-window
  :ensure t
  :config
  (setq switch-window-input-style 'minibuffer)
  (setq switch-window-increase 4)
  (setq switch-window-threshold 2)
  (setq switch-window-shortcut-style 'qwerty)
  (setq switch-window-qwerty-shortcuts
	'("a" "s" "d" "f" "h" "j" "k" "l"))
  :bind
  ([remap other-window] . switch-window))

(scroll-bar-mode -1)
(tool-bar-mode -1)
(fringe-mode -1)
(menu-bar-mode -1)

(setq use-dialog-box nil)

(use-package ewal
  :init (setq ewal-use-built-in-always-p nil
	      ewal-use-built-in-on-failure-p t
	      ewal-built-in-palette "sexy-material")
  :if (not window-system)
  :config
  (setq-default mode-line-format nil))

(use-package ewal-spacemacs-themes
  :if window-system
  :init (progn
	  (show-paren-mode +1)
	  (global-hl-line-mode))
  :config (progn
	    (load-theme 'ewal-spacemacs-classic t)
	    (enable-theme 'ewal-spacemacs-classic)))

(add-to-list 'default-frame-alist
	     '(font . "JetBrains Mono-14"))

(use-package hungry-delete
  :ensure t
  :config (global-hungry-delete-mode))

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner "~/.emacs.d/avatar.png")
  (setq dashboard-banner-logo-title "I am just a coder for fun"))
(setq inhibit-startup-screen t)

(use-package mood-line
  :ensure t)
(mood-line-mode)

(use-package ido-vertical-mode
  :ensure t
  :config
  (setq ido-enable-flex-matching t)
  (setq ido-everywhere t)
  (setq ido-vertical-define-keys 'C-n-and-C-p-only)      
  :init
  (ido-mode 1)
  (ido-vertical-mode 1))

(use-package smex
  :ensure t
  :init (smex-initialize)
  :bind
  ("M-x" . smex))

(global-set-key (kbd "C-x C-b") 'ibuffer)

(setq ibuffer-expert t)

(global-set-key (kbd "C-c l n") 'flymake-goto-next-error)
(global-set-key (kbd "C-c l p") 'flymake-goto-prev-error)  
(setq make-backup-files nil)
(setq auto-save-default nil)
(defalias 'yes-or-no-p 'y-or-n-p)
(global-set-key [(C-return)] 'toggle-maximize-buffer)
(use-package projectile
  :ensure t
  :config
  (setq projectile-use-git-grep t)
  :bind
  ("C-x p f" . projectile-find-file)
  :init
  (projectile-mode 1))
(use-package company
  :ensure t
  :hook prog-mode)
(use-package treemacs-projectile
  :ensure t
  :after (treemacs projectile))

(use-package lsp-mode
  :ensure t
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (setq lsp-headerline-breadcrumb-enable nil))

(use-package lsp-ui
  :ensure t)

(use-package dap-mode
  :after lsp-mode
  :ensure t)

(use-package web-mode
  :ensure t
  :config
  (setq
   web-mode-markup-indent-offset 2
   web-mode-css-indent-offset 2
   web-mode-code-indent-offset 2
   web-mode-style-padding 2
   web-mode-script-padding 2
   web-mode-enable-auto-closing t
   web-mode-enable-auto-opening t
   web-mode-enable-auto-pairing t
   web-mode-enable-auto-indentation t)
  :mode
  (".html$" "*.php$" "*.tsx"))

(use-package emmet-mode
  :ensure t)

(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
			 (setq indent-tabs-mode t)
			 (setq tab-width 4)
			 (setq python-indent-offset 4)
			 (company-mode 1)
			 (require 'lsp-pyright)
			 (pyvenv-autoload)
			 (lsp))))

(defun move-text-internal (arg)
  (cond
   ((and mark-active transient-mark-mode)
    (if (> (point) (mark))
        (exchange-point-and-mark))
    (let ((column (current-column))
          (text (delete-and-extract-region (point) (mark))))
      (forward-line arg)
      (move-to-column column t)
      (set-mark (point))
      (insert text)
      (exchange-point-and-mark)
      (setq deactivate-mark nil)))
   (t
    (let ((column (current-column)))
      (beginning-of-line)
      (when (or (> arg 0) (not (bobp)))
        (forward-line)
        (when (or (< arg 0) (not (eobp)))
          (transpose-lines arg)
          (when (and (eval-when-compile
                       '(and (>= emacs-major-version 24)
                             (>= emacs-minor-version 3)))
                     (< arg 0))
            (forward-line -1)))
        (forward-line -1))
      (move-to-column column t)))))

(defun move-text-down (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines down."
  (interactive "*p")
  (move-text-internal arg))

(defun move-text-up (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines up."
  (interactive "*p")
  (move-text-internal (- arg)))


(global-set-key [M-up] 'move-text-up)
(global-set-key [M-down] 'move-text-down)

(defun copy-whole-line ()
  (interactive)
  (save-excursion
    (kill-new
     (buffer-substring
      (point-at-bol)
      (point-at-eol)))))
(global-set-key (kbd "C-c c") 'copy-whole-line)

(defun kill-whole-word ()
  (interactive)
  (kill-word 1))
(global-set-key (kbd "C-c w") 'kill-whole-word)

(defun open-edit-config ()
  (interactive)
  (find-file "~/.emacs.d/config.org"))
(global-set-key (kbd "C-c e") 'open-edit-config)

(defun config-reload ()
  (interactive)
  (org-babel-load-file (expand-file-name "~/.emacs.d/config.org")))
(global-set-key (kbd "C-c r") 'config-reload)

(defun log-diary()
  (interactive)
  (setq filename (concat "~/code/website/content/diary/" (format-time-string "%Y-%m-%d") ".md"))
  (find-file filename)
  (insert (concat "+++\ntitle = \"" (format-time-string "%Y-%m-%d") "\"\ndate = \"" (format-time-string "%Y-%m-%d") "\"\n+++\n\n" )))

(use-package beacon
  :ensure t
  :init
  (beacon-mode 1))

(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(setq org-src-window-setup 'current-window)
(custom-set-faces

 '(org-level-1 ((t (:inherit outline-1 :height 1.5))))
   '(org-level-2 ((t (:inherit outline-2 :height 1.2))))
   '(org-level-3 ((t (:inherit outline-3 :height 1.1))))
   '(org-level-4 ((t (:inherit outline-4 :height 1.0))))
   '(org-level-5 ((t (:inherit outline-5 :height 1.0))))
)

(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
