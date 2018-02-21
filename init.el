(live-load-config-file "bindings.el")

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)

(load "~/.live-packs/josephwilk-pack/electric.el")

(color-theme-electric)

(defun move-region (start end n)
  "Move the current region up or down by N lines."
  (interactive "r\np")
  (let ((line-text (delete-and-extract-region start end)))
    (forward-line n)
    (let ((start (point)))
      (insert line-text)
      (setq deactivate-mark nil)
      (set-mark start))))

(defun move-region-up (start end n)
  "Move the current line up by N lines."
  (interactive "r\np")
  (move-region start end (if (null n) -1 (- n))))

(defun move-region-down (start end n)
  "Move the current line down by N lines."
  (interactive "r\np")
  (move-region start end (if (null n) 1 n)))

;;F is left side B is right side. Obey logical positioning
(global-set-key (kbd "C-f") 'backward-char)
(global-set-key (kbd "C-b") 'forward-char)
(global-set-key (kbd "M-f") 'backward-word)
(global-set-key (kbd "M-b") 'forward-word)


(global-set-key (kbd "C-c C-s") 'zone)

(global-set-key (kbd "C-x p") 'previous-buffer)
(global-set-key (kbd "C-x n") 'next-buffer)

(when (fboundp 'winner-mode) (winner-mode 0))

(require 'yasnippet)
(setq yas-snippet-dirs (append yas-snippet-dirs
  '("~/.live-packs/josephwilk-pack/snippets")))
(yas-reload-all)

;;(load "~/.live-packs/josephwilk-pack/animations/algo.el")
(load "~/.live-packs/josephwilk-pack/animations/end-of-buffer.el")
;;(load "~/.live-packs/josephwilk-pack/animations/the-stars.el")
;;(load "~/.live-packs/josephwilk-pack/animations/waves.el")
;;(load "~/.live-packs/josephwilk-pack/animations/upcase.el")

(defun clojure-set-up-key-bindings ()
  (define-key cider-mode-map (kbd "M-RET")   'cider-eval-defun-at-point)
  (define-key cider-mode-map (kbd "C-M-RET") 'cider-eval-region))

(add-hook 'cider-mode-hook 'clojure-set-up-key-bindings)

(defun zone-pgm-md5 ()
  "MD5 the buffer, then recursively checksum each hash."
  (let ((prev-md5 (buffer-substring-no-properties ;; Initialize.
                   (point-min) (point-max))))
    ;; Whitespace-fill the window.
    (zone-fill-out-screen (window-width) (window-height))
    (random t)
    (goto-char (point-min))
    (while (not (input-pending-p))
      (when (eobp)
        (goto-char (point-min)))
      (while (not (eobp))
        (delete-region (point) (line-end-position))
        (let ((next-md5 (md5 prev-md5)))
          (insert next-md5)
          (setq prev-md5 next-md5))
        (forward-line 1)
                  (zone-park/sit-for (point-min) 0.1)))))


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

(defun all-off () "All drums on"
  (interactive)
  (progn
    (save-excursion
      (replace-string " #k=_" " k=_" nil (point-min) (point-max))
      (replace-string " #s=_" " s=_" nil (point-min) (point-max))
      (replace-string " #p=_" " p=_" nil (point-min) (point-max))
      (sonic-pi-send-buffer))))

(defun all-on () "All drums off"
  (interactive)
  (progn
    (save-excursion
      (replace-string " k=_" " #k=_" nil (point-min) (point-max))
      (replace-string " s=_" " #s=_" nil (point-min) (point-max))
      (replace-string " p=_" " #p=_" nil (point-min) (point-max))
      (sonic-pi-send-buffer))))

(defun drum-off () "Drums off"
  (interactive)
  (progn
    (save-excursion
      (replace-string " #k=_" " k=_" nil (point-min) (point-max))
      (sonic-pi-send-buffer))))

(defun drum-on () "Drums on"
  (interactive)
  (progn
    (save-excursion
      (replace-string " k=_" " #k=_" nil (point-min) (point-max))
      (sonic-pi-send-buffer))))

(defun drum-toggle () "Drums off/on"
  (interactive)
  (progn
    (if (eql drum-mode 'drum-on)
        (setf drum-mode  'drum-off)
      (setf drum-mode  'drum-on))
    (funcall drum-mode)))

(defun snare-off () "Snare off"
  (interactive)
  (progn
    (save-excursion
      (replace-string " #s=_" " s=_" nil (point-min) (point-max))
      (sonic-pi-send-buffer))))

(defun snare-on () "Snare on"
  (interactive)
  (progn
    (save-excursion
      (replace-string " s=_" " #s=_" nil (point-min) (point-max))
      (sonic-pi-send-buffer))))

(defun snare-toggle () "Snare off/on"
  (interactive)
  (progn
    (if (eql snare-mode 'snare-on)
        (setf snare-mode  'snare-off)
      (setf snare-mode  'snare-on))
    (funcall snare-mode)))

(defun perc-off () "Percussion off"
  (interactive)
  (progn
    (save-excursion
      (replace-string " #p=_" " p=_" nil (point-min) (point-max))
      (sonic-pi-send-buffer))))

(defun perc-on () "Percussion on"
  (interactive)
  (progn
    (save-excursion
      (replace-string " p=_" " #p=_" nil (point-min) (point-max))
      (sonic-pi-send-buffer))))

(defun perc2-off () "Percussion2 off"
  (interactive)
  (progn
    (save-excursion
      (replace-string " #pp=_" " pp=_" nil (point-min) (point-max))
      (sonic-pi-send-buffer))))

(defun perc2-on () "Percussion on"
  (interactive)
  (progn
    (save-excursion
      (replace-string " pp=_" " #pp=_" nil (point-min) (point-max))
      (sonic-pi-send-buffer))))

(defun perc-toggle () "Perc off/on"
   (interactive)
  (progn
    (if (eql perc-mode 'perc-on)
        (setf perc-mode 'perc-off)
        (setf perc-mode 'perc-on))
    (funcall perc-mode)))

(defun perc2-toggle () "Perc2 off/on"
   (interactive)
  (progn
    (if (eql perc2-mode 'perc2-on)
        (setf perc2-mode 'perc2-off)
        (setf perc2-mode 'perc2-on))
    (funcall perc2-mode)))

(defvar perc2-mode 'perc2-off)
(defvar perc-mode  'perc-off)
(defvar drum-mode  'drum-off)
(defvar snare-mode 'snare-off)

(global-set-key (kbd "<f9>")  'perc2-off)
(global-set-key (kbd "<f10>") 'perc-off)
(global-set-key (kbd "<f11>") 'snare-off)
(global-set-key (kbd "<f12>") 'drum-off)

(add-to-list 'package-archives
             '("marmalade" .
               "http://marmalade-repo.org/packages/"))
(package-initialize)

(defun win-resize-top-or-bot ()
  "Figure out if the current window is on top, bottom or in the
middle"
  (let* ((win-edges (window-edges))
         (this-window-y-min (nth 1 win-edges))
         (this-window-y-max (nth 3 win-edges))
         (fr-height (frame-height)))
    (cond
     ((eq 0 this-window-y-min) "top")
     ((eq (- fr-height 1) this-window-y-max) "bot")
     (t "mid"))))

(defun win-resize-left-or-right ()
  "Figure out if the current window is to the left, right or in the
middle"
  (let* ((win-edges (window-edges))
         (this-window-x-min (nth 0 win-edges))
         (this-window-x-max (nth 2 win-edges))
         (fr-width (frame-width)))
    (cond
     ((eq 0 this-window-x-min) "left")
     ((eq (+ fr-width 4) this-window-x-max) "right")
     (t "mid"))))

(defun win-resize-enlarge-horiz ()
  (interactive)
  (cond
   ((equal "top" (win-resize-top-or-bot)) (enlarge-window -1))
   ((equal "bot" (win-resize-top-or-bot)) (enlarge-window 1))
   ((equal "mid" (win-resize-top-or-bot)) (enlarge-window -1))
   (t (message "nil"))))

(defun win-resize-minimize-horiz ()
  (interactive)
  (cond
   ((equal "top" (win-resize-top-or-bot)) (enlarge-window 1))
   ((equal "bot" (win-resize-top-or-bot)) (enlarge-window -1))
   ((equal "mid" (win-resize-top-or-bot)) (enlarge-window 1))
   (t (message "nil"))))

(defun win-resize-enlarge-vert ()
  (interactive)
  (cond
   ((equal "left" (win-resize-left-or-right)) (enlarge-window-horizontally -1))
   ((equal "right" (win-resize-left-or-right)) (enlarge-window-horizontally 1))
   ((equal "mid" (win-resize-left-or-right)) (enlarge-window-horizontally -1))))

(defun win-resize-minimize-vert ()
  (interactive)
  (cond
   ((equal "left" (win-resize-left-or-right)) (enlarge-window-horizontally 1))
   ((equal "right" (win-resize-left-or-right)) (enlarge-window-horizontally -1))
   ((equal "mid" (win-resize-left-or-right)) (enlarge-window-horizontally 1))))


;;Sane Navigation
(global-set-key (kbd "M-u") 'backward-word)
(global-set-key (kbd "M-o") 'forward-word)
(global-set-key (kbd "M-j") 'backward-char)
(global-set-key (kbd "M-l") 'forward-char)
(global-set-key (kbd "M-i") 'previous-line)
(global-set-key (kbd "M-k") 'next-line)

(global-hl-line-mode -1)

(add-to-list 'load-path "/Users/josephwilk/Workspace/josephwilk/emacs/sonic-pi.el/")
(require 'sonic-pi-mode)
(require 'sonic-pi)

(setq sonic-pi-path "/Users/josephwilk/Workspace/josephwilk/c++/sonic-pi/app/")
(add-to-list 'ac-modes 'sonic-pi-mode)

;;(add-to-list 'load-path "~/Workspace/repl-eletric/tidal/")
;;(require 'haskell-mode)
;;(require 'tidal)
;;(setq tidal-interpreter "/usr/local/bin/ghci")

;;cider
(setq cider-repl-display-help-banner nil)
(setq cider-repl-display-in-current-window t)
(setq cider-auto-select-error-buffer nil)

;;Sane reg-builder
(require 're-builder)
(setq reb-re-syntax 'string)

(require 'unicode-fonts)
(unicode-fonts-setup)

(setq-default show-trailing-whitespace nil)
(setq-default mode-require-final-newline nil)

(require 'emojify)
(setq emojify-set-emoji-styles 'unicode)
(setq emojify-display-style    'unicode)

(define-key function-key-map "\e[1;9A" [M-up])
(define-key function-key-map "\e[1;9B" [M-down])
(define-key function-key-map "\e[1;9C" [M-right])
(define-key function-key-map "\e[1;9D" [M-left])

;;(global-set-key [M-up] 'move-region-up)
;;(global-set-key [M-down] 'move-region-down)

(defconst MAX-LENGTH 100)

(defun vst-update-all ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((start (point)))
      (let ((inhibit-read-only t))
        (remove-text-properties (point) (point-max) '(read-only t))

      (while (re-search-forward "sop2_cc .+:\s*\\([0-9]*.[0-9]+\\)\s*\n" nil t)
        (let ((full     (round (* MAX-LENGTH (string-to-number (match-string 1))))))
          (let ((empty  (- MAX-LENGTH full)))
            (goto-char (match-beginning 0))
            (end-of-line)
            (let ((start-pnt (point))
                  (pad (if (>= empty 0)
                           (make-string empty ?╌)
                         "")))
              (insert (concat " #╟"
                              (make-string full ?▓)
                              "▒░"
                              pad
                              "╢"))
              (put-text-property start-pnt (point) 'read-only t)))))
      (align-regexp (point-min) (point-max) "\\(\\s-*\\)#")
      ))))

(defun vst-update (new-number old-number)
  (interactive)
  (if (not (= new-number old-number))
      (let ((full (round (* MAX-LENGTH number))))
        (let ((empty (- MAX-LENGTH full)))
          (save-excursion
            (re-search-forward "#╟" nil t)
            (goto-char (match-end 0))
            (let ((inhibit-read-only t)
                  (start-pnt (point)))
              (if (> new-number old-number)
                  (progn ;;forwards
                    (forward-char full)
                    (insert "▓")
                    (forward-char 2)
                    (delete-char 1)
                    )
                (progn ;;backwards
                  (forward-char (- full 1))
                  (delete-char 1)
                  (forward-char 2)
                  (insert "╌")))
              (put-text-property start-pnt (point) 'read-only t)))))))

(require 'thingatpt)
(put 'float 'end-op       (lambda () (re-search-forward "[0-9-]*\.[0-9-]*" nil t)))
(put 'float 'beginning-op (lambda () (if (re-search-backward "[^0-9-\.]" nil t) (forward-char))))

(defun change-number-at-point (func)
  (let* ((bounds (bounds-of-thing-at-point 'float))
         (number (buffer-substring (car bounds) (cdr bounds)))
         (point (point)))
    (goto-char (car bounds))
    (delete-char (length number))
    (insert (format "%.2f" (funcall func (string-to-number number))))
    (goto-char point)))

(defun inc-float-at-point ()
  (interactive)
  (change-number-at-point (lambda (number)
                            (let ((new-number (min 1.00 (+ number 0.01))))
                              (vst-update new-number number)
                              new-number))))
(defun dec-float-at-point ()
  (interactive)
  (change-number-at-point (lambda (number)
                            (let ((new-number (max 0.00 (- number 0.01))))
                              (vst-update new-number number)
                              new-number))))

(global-set-key [(meta up)]   'inc-float-at-point)
(global-set-key [(meta down)] 'dec-float-at-point)
