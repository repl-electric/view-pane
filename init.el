(live-load-config-file "bindings.el")

(color-theme-gandalf)

(live-use-dev-packs)

(global-set-key (kbd "C-c <left>") 'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>") 'windmove-up)
(global-set-key (kbd "C-c <down>") 'windmove-down)

(global-set-key (kbd "C-c C-s") 'zone)

(when (fboundp 'winner-mode) (winner-mode 0))

(setq zone-programs [zone-pgm-drip])

(defun music-layout () "Music split"
  (interactive)
  (progn
    (split-window-horizontally)
    (win-switch-right)
    (minimize-window)
    (win-switch-left)))

(defun test-layout () "Code split"
  (interactive)
  (progn
    (split-window-horizontally)
    (win-switch-right)
    (win-switch-left)))
