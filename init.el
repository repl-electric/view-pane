(live-load-config-file "bindings.el")

(color-theme-gandalf)

(global-set-key (kbd "C-c <left>") 'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>") 'windmove-up)
(global-set-key (kbd "C-c <down>") 'windmove-down)

(global-set-key (kbd "C-c C-s") 'zone)

(when (fboundp 'winner-mode) (winner-mode 0))

(setq zone-programs [zone-pgm-drip])
