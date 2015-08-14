;;End of buffeeeeeeeeeeerrrrrrrrrrrr by Joseph Wilk
(defvar start-total-count 0)

(defun zone-end-of-buffer-animate (c col wend)
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

(defun zone-end-of-buffer ()
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
            (when (<  counter 10000) (zone-end-of-buffer-animate (zone-cpos p) (current-column) wend))
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
  '(unless (memq 'zone-end-of-buffer (append zone-programs nil))
     (setq zone-programs [zone-end-of-buffer])))