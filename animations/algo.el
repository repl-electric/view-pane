;;algo by Joseph Wilk
(defvar start-total-count 0)


(defun post-zone-algo-animate (c col wend)
  (let ((fall-p nil)                    ; todo: move outward
        (o (point))                     ; for terminals w/o cursor hiding
        (p (point))
        (insert-char (nth 0 `("⟁")))
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

        (if (and
             ;;(not (looking-at ")"))
            ;;      (not (looking-at "("))
;;             (not (looking-at "\W"))
             (not (looking-at insert-char))
            ;; (not (looking-at "\s"))
           ;;  (not (looking-at "\w"))


             )
            (progn
              (save-excursion
                (dotimes (_ 1)
                  (delete-char 1)
                  (insert insert-char)
                )
                ;;(goto-char o)
                (sit-for 0))
              (if (<= 5 (mod counter 10))
                  (setq p (- (point) 1))
                (setq p (+ (point) 1)))))))
    fall-p))


(defun zone-algo-animate (c col wend)
  (let ((fall-p nil)                    ; todo: move outward
        (o (point))                     ; for terminals w/o cursor hiding
        (p (point))
        (insert-char (nth 0 `("⟁")))
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

        (if (and
             ;;(not (looking-at ")"))
            ;;      (not (looking-at "("))
;;             (not (looking-at "\W"))
             (not (looking-at insert-char))
;;             (not (looking-at "\s"))
           ;;  (not (looking-at "\w"))


             )
            (progn
              (save-excursion
                (dotimes (_ 1)
                  (delete-char 1)
                  (insert insert-char)
                )
                ;;(goto-char o)
                (sit-for 0))
              (if (<= 5 (mod counter 10))
                  (setq p (- (point) 1))
                (setq p (+ (point) 1)))))))
    fall-p))

(defun zone-algo ()
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
            ;;(insert line)
            ))))

    (catch 'done; ugh
      (while (not (input-pending-p))
        (goto-char (point-min))
        (let ((wbeg (window-start))
              (wend (window-end)))
          (setq mc 0)

          (goto-char (+ wbeg (random (- wend wbeg))))
          (while (or (looking-at "[\t\n]")) (goto-char (+ wbeg (random (- wend wbeg)))))
          ;; character animation sequence

          (setq counter (+ 1 counter))

          (let ((p (point)))
            (goto-char p)
            (when (< counter 10000) (zone-algo-animate (zone-cpos p) (current-column) wend))
            (when (and (> counter 4500) (< counter 10000))
              ;;(delete-char 1)
              (while (re-search-forward "\\(\s+\\)" nil t 1)
                (when (< (random 100) 50) (replace-match "\\1 ")))
              )

            ))
        ))))

(eval-after-load "zone"
  '(unless (memq 'zone-algo (append zone-programs nil))
     (setq zone-programs [zone-algo])))
