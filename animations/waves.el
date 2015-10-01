;;Waves by Joseph Wilk

(defvar total-count 0)

(defun zone-waves-animate (c col wend)
  (let ((fall-p nil)                   
        (o (point))                    
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


(defun zone-waves ()
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
            (zone-waves-animate (zone-cpos p) (current-column) wend)))
        ;; assuming current-column has not changed...
        ))))

(eval-after-load "zone"
  '(unless (memq 'zone-waves (append zone-programs nil))
     (setq zone-programs [zone-waves])))
