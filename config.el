;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Ethercflow"
      user-mail-address "ethercflow.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)


;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "/workspace/org/")
(setq org-superstar-headline-bullets-list '("⁖" "⁖" "⁖" "⁖" ))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

(defun c-lineup-arglist-tabs-only (ignored)
  "Line up argument lists by tabs, not spaces"
  (let* ((anchor (c-langelem-pos c-syntactic-element))
         (column (c-langelem-2nd-pos c-syntactic-element))
         (offset (- (1+ column) anchor))
         (steps (floor offset c-basic-offset)))
    (* (max steps 1)
       c-basic-offset)))

(add-hook 'c-mode-common-hook
          (lambda ()
            ;; Add kernel style
            (c-add-style
             "linux-tabs-only"
             '("linux" (c-offsets-alist
                        (arglist-cont-nonempty
                         c-lineup-gcc-asm-reg
                         c-lineup-arglist-tabs-only))))))

(add-hook 'c-mode-hook
          (lambda ()
            (let ((filename (buffer-file-name)))
              ;; Enable kernel mode for the appropriate files
              (when (and filename
                         (string-match (expand-file-name "/workspace/kernel/")
                                       filename))
                (setq tab-width 8)
                (setq indent-tabs-mode t)
                (setq show-trailing-whitespace t)
                (c-set-style "linux-tabs-only")))))

(setq rustic-lsp-server 'rust-analyzer)
(setq wakatime-api-key "1043fd7f-32c2-4017-ae05-91571781f7ba")

(setq +mu4e-mu4e-mail-path "~/.mbsync"
      mu4e-get-mail-command "mbsync -v gmail")
(set-email-account! "ethercflow@gmail.com"
  '((mu4e-sent-folder       . "/[Gmail].Sent Mail")
    (smtpmail-smtp-user     . "ethercflow@gmail.com")
    (mu4e-compose-signature . "---\nWenbo Zhang"))
  t)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
(after! ivy
  ;; I prefer search matching to be ordered; it's more precise
  (add-to-list 'ivy-re-builders-alist '(counsel-projectile-find-file . ivy--regex-plus)))

;; Switch to the new window after splitting
(setq evil-split-window-below t
      evil-vsplit-window-right t)

(map! :after ccls
    :map (c-mode-map c++-mode-map)
    :n "C-h" #'tmux-pane-omni-window-left
    :n "C-j" #'tmux-pane-omni-window-down
    :n "C-k" #'tmux-pane-omni-window-up
    :n "C-l" #'tmux-pane-omni-window-right
    :n "C-c h" (cmd! (ccls-navigate "U"))
    :n "C-c j" (cmd! (ccls-navigate "R"))
    :n "C-c k" (cmd! (ccls-navigate "L"))
    :n "C-c l" (cmd! (ccls-navigate "D")))

(after! (vterm evil-collection)
  (add-hook!
   'vterm-mode-hook
   ;; evil-collection for vterm overrided some keymaps defined by tmux-pane
   (evil-collection-define-key 'insert 'vterm-mode-map
     (kbd "C-h") (lambda () (interactive) (tmux-pane--windmove
                                           "left"
                                           "tmux select-pane -L"))
     (kbd "C-j") (lambda () (interactive) (tmux-pane--windmove
                                           "down"
                                           "tmux select-pane -D"))
     (kbd "C-k") (lambda () (interactive) (tmux-pane--windmove
                                           "up"
                                           "tmux select-pane -U"))
     (kbd "C-l") (lambda () (interactive) (tmux-pane--windmove
                                           "right"
                                           "tmux select-pane -R")))
   ;; change keymap to toggle sending escape to vterm
   (evil-collection-define-key '(normal insert) 'vterm-mode-map
     (kbd "C-c") 'vterm--self-insert
     ;; for CLI emacs
     (kbd "ESC <escape>") 'evil-collection-vterm-toggle-send-escape
     ;; for GUI emacs
     (kbd "M-<escape>") 'evil-collection-vterm-toggle-send-escape)
   ;; send escape to vterm by default
   (evil-collection-vterm-toggle-send-escape)))
