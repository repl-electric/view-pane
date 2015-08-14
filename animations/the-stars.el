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

(eval-after-load "zone"
  '(unless (memq 'zone-pgm-repl-electric (append zone-programs nil))
     (setq zone-programs [zone-pgm-repl-electric])))
