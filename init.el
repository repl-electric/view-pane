(live-load-config-file "bindings.el")

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

(load "~/.live-packs/josephwilk-pack/electric.el")

(color-theme-electric)

(live-use-dev-packs)

(global-set-key (kbd "C-c <left>") 'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>") 'windmove-up)
(global-set-key (kbd "C-c <down>") 'windmove-down)

(global-set-key (kbd "C-c C-s") 'zone)

(global-set-key (kbd "C-c p") 'previous-buffer)
(global-set-key (kbd "C-c n") 'next-buffer)

(when (fboundp 'winner-mode) (winner-mode 0))

(require 'yasnippet)
(setq yas-snippet-dirs (append yas-snippet-dirs
  '("~/.live-packs/josephwilk-pack/snippets")))
(yas-reload-all)

(defun zone-fall-through-ws-re (c col wend)
  (let ((fall-p nil)                    ; todo: move outward
        (o (point))                     ; for terminals w/o cursor hiding
        (p (point))
        (insert-char " ")
        (halt-char " "))
    (while (progn (forward-line 1) (move-to-column col) (looking-at halt-char))
      (setq fall-p t)
      (delete-char 1)
      (insert (if (< (point) wend) c " "))
      (save-excursion
        (goto-char p)
        (delete-char 1)
        (insert insert-char)
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

(defvar total-count 0)

(defun zone-circle-animate (c col wend)
  (let ((fall-p nil)                    ; todo: move outward
        (o (point))                     ; for terminals w/o cursor hiding
        (p (point))
        (insert-char " ")
        (halt-char " ")
        (counter 0))

    (while (< counter 10)
      (let ((next-char     (char-after p))
            (previous-char (char-after (- p 1))))

        ;;(progn (forward-line 1) (move-to-column col) (looking-at halt-char))
        ;;          (when (< counter 50)    (move-to-column (mod counter 150)))

        (when (< (random 100) 50)  (move-to-column counter))

        (setq counter (+ 1 counter))
        (setq total-count (+ 1 total-count))

        (when (< (random 100) 80)  (insert (if (< (point) wend)  "." "\n")))

        (if (and (not (looking-at ")"))
                 (not (looking-at "(")))
            (progn
              (save-excursion
                (when (= 0 (mod counter 1)) (dotimes (_ (random counter)) (insert insert-char)))
                (when (= 0 (mod counter 4))
                  (when (< (random 100) 10) (insert "(:music => :code)"))
                  (when (< (random 100) 12) (insert "(:code => :art)"))
                  (when (< (random 100) 1) (insert "(   )"))
                  (when (< (random 100) 1) (insert "(    )"))

                  ;;(goto-char (+ p 1))
                  (delete-char (random counter))
                  )
                ;;(goto-char o)


                (sit-for 0))
              (if (<= 5 (mod counter 10))
                  (setq p (- (point) 1))
                (setq p (+ (point) 1))
                ))

          ))
      )
    fall-p))


(defun zone-circles ()
  (set 'truncate-lines nil)
  (setq total-count 0)
  (let* ((ww (1- (window-width)))
         (wh (window-height))
         (mc 0)                         ; miss count
         (total (* ww wh))
         (fall-p nil)
         (wend 100)
         (wbeg 1))
    (goto-char (point-min))
    (while (not (eobp))
      (end-of-line)
      (let ((cc (current-column)))
        (if (< cc ww)
            (insert (make-string (- ww cc) ? ))
        ;;    (delete-char (- ww cc))
          ))
      (unless (eobp) (forward-char 1)))

    (catch 'done; ugh
      (while (not (input-pending-p))
        (goto-char (point-min))
        (let ((wbeg (window-start))
              (wend (window-end)))
          (setq mc 0)

          (goto-char (+ wbeg (random (- wend wbeg))))
          (while (looking-at "[\t\n ]") (goto-char (+ wbeg (random (- wend wbeg)))))
          ;; character animation sequence
          (let ((p (point)))
            (goto-char p)
            (zone-circle-animate (zone-cpos p) (current-column) wend)))
        ;; assuming current-column has not changed...
        ))))


(defvar start-total-count 0)

(defun zone-stars-animate (c col wend)
  (let ((fall-p nil)                    ; todo: move outward
        (o (point))                     ; for terminals w/o cursor hiding
        (p (point))
        (insert-char " ")
        (halt-char " ")
        (counter 0))

    (while (< counter 10)
      (let ((next-char     (char-after p))
            (previous-char (char-after (- p 1))))

        ;;(progn (forward-line 1) (move-to-column col) (looking-at halt-char))
        ;;          (when (< counter 50)    (move-to-column (mod counter 150)))

        (when (< (random 100) 50)  (move-to-column counter))

        (setq counter (+ 1 counter))
        (setq total-count (+ 1 total-count))

        (if (and (not (looking-at ")"))
                 (not (looking-at "("))
                 (not (looking-at "\s+"))
                 (not (looking-at "\n+")))
            (progn
              (save-excursion
                (dotimes (_ (random counter))
                  ;;(delete-char 1)
                  (insert insert-char)
                )
                ;;(goto-char o)
                (sit-for 0))
              (if (<= 5 (mod counter 10))
                  (setq p (- (point) 1))
                (setq p (+ (point) 1)))))))
    fall-p))

(defun zone-stars ()
  (set 'truncate-lines nil)
  (setq total-count 0)
  (let* ((ww (1- (window-width)))
         (wh (window-height))
         (mc 0)                         ; miss count
         (total (* ww wh))
         (fall-p nil)
         (wend 100)
         (wbeg 1)
         (counter 0))
    (goto-char (point-min))


    (let ((nl (- wh (count-lines (point-min) (point)))))
      (when (> nl 0)
        (let ((line (concat (make-string (1- ww) ? ) "\n")))
          (do ((i 0 (1+ i)))
              ((= i nl))
          ;;  (insert line)
            ))))

    (catch 'done; ugh
      (while (not (input-pending-p))
        (goto-char (point-min))
        (let ((wbeg (window-start))
              (wend (window-end)))
          (setq mc 0)

          (goto-char (+ wbeg (random (- wend wbeg))))
          (while (looking-at "[\t\n ]") (goto-char (+ wbeg (random (- wend wbeg)))))
          ;; character animation sequence

          (setq counter (+ 1 counter))

          (let ((p (point)))
            (goto-char p)
            (when (<  counter 10000) (zone-stars-animate (zone-cpos p) (current-column) wend))
            (when (and (> counter 4500) (< counter 10000))
              (while (re-search-forward "\\(\s+\\)" nil t 1)
                (when (< (random 100) 50) (replace-match "\\1 "))))

            (when (and (< counter -100)) (dotimes (i 1)
                                       (goto-char (+ wbeg (random (- wend wbeg))))
                                ;;       (zone-stars-animate (zone-cpos p) (current-column) wend)
                                     ;;(goto-char wbeg)
                                       (insert "\n\n")
                                       (insert "(orepl  oo    e   csm      l o l  tsound    ibbbb   s  m  code  code  lcode  rrrr   \n")
                                       (insert "(v      v n   r   o  u     i   e  i         x   b   o  u  t     t     i      r  r   \n")
                                       (insert "(elec   e  u  d   s   v    e   d  dmusic    i b     u  s  enot  enot  vive   rr r   \n")
                                       (insert "(r      r   c j   e  i     e   d  a         l   b   n  i  x     x     e      r r    \n")
                                       (insert "(tone   t    lo   iac      codes  l         angbb   dcoc  t     t     code   r   r  \n")
                                       (insert "\n\n")

                                       (sit-for 1)


                                       (goto-char (+ wbeg (- wend wbeg)))
                                       (setq fall-p (zone-fall-through-ws-re  (zone-cpos p) (current-column) wend))
                                       ))

            (when (> counter  11000) (dotimes (i 100)
                                      (goto-char (+ wbeg (random (- wend wbeg))))
                                      (while (looking-at "[\t\n ]") (goto-char (+ wbeg (random (- wend wbeg)))))
                                      (setq fall-p (zone-fall-through-ws-re  (zone-cpos p) (current-column) wend))))
            ))
        ;; assuming current-column has not changed...
        ))))


(eval-after-load "zone"
  '(unless (memq 'zone-stars (append zone-programs nil))
     (setq zone-programs [zone-stars])))

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
