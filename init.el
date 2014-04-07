(live-load-config-file "bindings.el")

(load "~/.live-packs/josephwilk-pack/electric.el")

(color-theme-electric)

(live-use-dev-packs)

(global-set-key (kbd "C-c <left>") 'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>") 'windmove-up)
(global-set-key (kbd "C-c <down>") 'windmove-down)

(global-set-key (kbd "C-c C-s") 'zone)

(when (fboundp 'winner-mode) (winner-mode 0))

(require 'yasnippet)
(setq yas-snippet-dirs (append yas-snippet-dirs
  '("~/.live-packs/josephwilk-pack/snippets")))
(yas-reload-all)

(defun zone-fall-through-ws-re (c col wend)
  (let ((fall-p nil)                    ; todo: move outward
        (o (point))                     ; for terminals w/o cursor hiding
        (p (point)))
    (while (progn
             (forward-line 1)
             (move-to-column col)
             (looking-at " "))
      (setq fall-p t)
      (delete-char 1)
      (insert (if (< (point) wend) c " "))
      (save-excursion
        (goto-char p)
        (delete-char 1)
        (insert " ")
        (goto-char o)
        (sit-for 0))
      (setq p (- (point) 1)))
    fall-p))

(defun zone-fret-re (pos)
  (let* ((case-fold-search nil)
         (c-string (zone-cpos pos))
         (hmm (cond
               ((string-match "[a-z]" c-string) (upcase c-string))
               ((string-match "[A-Z]" c-string) (downcase c-string))
               (t " "))))
    (do ((i 0 (1+ i)))
        ((= i 20))
      (goto-char pos)
      (delete-char 1)
      (insert (if (= 0 (% i 2)) hmm c-string))
      )
    (delete-char -1) (insert c-string)))

(defun zone-cpos (pos)
  (buffer-substring pos (+ 1 pos)))

(defun zone-pgm-repl-electric (&optional fret-p pancake-p)
  (let* ((ww (1- (window-width)))
         (wh (window-height))
         (mc 0)                         ; miss count
         (total (* ww wh))
         (fall-p nil))
    (goto-char (point-min))
    ;; fill out rectangular ws block
    (while (not (eobp))
      (end-of-line)
      (let ((cc (current-column)))
        (if (< cc ww)
            (insert (make-string (- ww cc) ? ))
          (delete-char (- ww cc))))
      (unless (eobp)
        (forward-char 1)))
    ;; what the hell is going on here?
    (let ((nl (- wh (count-lines (point-min) (point)))))
      (when (> nl 0)
        (let ((line (concat (make-string (1- ww) ? ) "\n")))
          (do ((i 0 (1+ i)))
              ((= i nl))
            (insert line)))))
    ;;
    (catch 'done; ugh
      (while (not (input-pending-p))
        (goto-char (point-min))
        (let ((wbeg (window-start))
              (wend (window-end)))
          (setq mc 0)
          ;; select non-ws character, but don't miss too much
          (goto-char (+ wbeg (random (- wend wbeg))))
          (while (looking-at "[ \n\f]")
            (if (= total (setq mc (1+ mc)))
                (throw 'done 'sel)
              (goto-char (+ wbeg (random (- wend wbeg))))))
          ;; character animation sequence
          (let ((p (point)))
            (when fret-p (zone-fret-re p))
            (goto-char p)
            (setq fall-p (zone-fall-through-ws-re
                          (zone-cpos p) (current-column) wend))))
        ;; assuming current-column has not changed...
        (when (and pancake-p
                   fall-p
                   (< (count-lines (point-min) (point))
                      wh))
          (previous-line 1)
          (forward-char 1)
          (sit-for 0.37)
          (delete-char -1)
          (insert "@")
          (sit-for 0.37)
          (delete-char -1)
          (insert "*")
          (sit-for 0.37)
          (delete-char -1)
          (insert "_"))))))

(eval-after-load "zone"
  '(unless (memq 'zone-pgm-repl-electric (append zone-programs nil))
     (setq zone-programs [zone-pgm-repl-electric])))

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

(add-to-list 'package-archives
             '("marmalade" .
               "http://marmalade-repo.org/packages/"))
(package-initialize)
(setq load-path (cons "~/tidal/" load-path))
(require 'tidal)
(setq tidal-interpreter "/usr/local/bin/ghci")

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
