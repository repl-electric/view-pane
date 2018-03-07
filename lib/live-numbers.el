(defconst MAX-LENGTH 100)

(require 'osc)
(require 'cl-lib)

(defvar re-osc-client nil "Connection to send OSC->Midi")
(defvar rk-osc-client nil "Connection to send Midi->Reaktor")

(defun osc-make-client (host port)
  (make-network-process
   :name "OSC client"
   :host host
   :service port
   :type 'datagram
   :family 'ipv4))

(defun re-osc-connect ()
  (if re-osc-client   (delete-process re-osc-client))
  (setq re-osc-client (osc-make-client "localhost" 4561)))

(defun rk-osc-connect ()
  (if rk-osc-client   (delete-process rk-osc-client))
  (setq rk-osc-client (osc-make-client "localhost" 10000)))

(defun vst-connect ()
  (interactive)
  (re-osc-connect)
  (rk-osc-connect))

(defun push-msg (param-name num)
  (when param-name
    (let ((vel (round (* 127.0 num)))
          (host "/IAC Bus 1/control_change"))
      (cond
       ((string-match param-name "zero_cc/pulse") (osc-send-message re-osc-client host 9 100 vel))
       ((string-match param-name "zero_cc/wet")   (osc-send-message re-osc-client host 9 101 vel))
       ((string-match param-name "zero_cc/more")  (osc-send-message re-osc-client host 9 102 vel))
       ((string-match param-name "zero_cc/noise") (osc-send-message re-osc-client host 9 103 vel))
       ((string-match param-name "eq/lo")         (osc-send-message re-osc-client host 1 7 vel))
       ((string-match param-name "eq/mi")         (osc-send-message re-osc-client host 1 8 vel))
       ((string-match param-name "eq/hi")         (osc-send-message re-osc-client host 1 9 vel))
       ((string-match param-name "bitsea/lo")     (osc-send-message re-osc-client host 10 103 vel))
       ((string-match param-name "bitsea/mi")     (osc-send-message re-osc-client host 10 104 vel))
       ((string-match param-name "bitsea/hi")     (osc-send-message re-osc-client host 10 105 vel))
       ((string-match param-name "bitsea_cc/motion") (osc-send-message re-osc-client host 10 1 vel))
       ((string-match param-name "bitsea_cc/octave") (osc-send-message re-osc-client host 10 106 vel))
       ((string-match param-name "bitsea_cc/formant") (osc-send-message re-osc-client host 10 98 vel))
       ((string-match param-name "qbitsea/hi")    (osc-send-message re-osc-client host 4 114 vel))
       ((string-match param-name "qbitsea/lo")    (osc-send-message re-osc-client host 4 113 vel))
       ((string-match param-name "qbitsea/mi")    (osc-send-message re-osc-client host 4 115 vel))

       (t (osc-send-message rk-osc-client         (format "/%s" param-name) num))))))

(defun code->pots (beg end)
  (interactive "r")
  (save-excursion
    (let ((inhibit-read-only t))
      (remove-text-properties beg end '(read-only t))
      (goto-char end)
      (setq i 0)
      (while (re-search-backward "_cc .+:\s*\\([0-9]*.[0-9]+\\)\s*\n" beg t)
        (setq i (+ 1 i))
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
              (hlt-highlight-regexp-region (+ 3 start-pnt) (point) ".+" 'eval-sonic-pi-flash nil)
              (put-text-property start-pnt (point) 'read-only t)

              ))))
      (align-regexp beg (+ (* i 106) end) "\\(\\s-*\\)#"))))

(defun pots-update (new-number old-number)
  (interactive)
  (if (not (= new-number old-number))
      (let ((old-full (round (* 100.0 old-number)))
            (full     (round (* 100.0 new-number))))
        (let ((empty  (- MAX-LENGTH full))
              (movement (- full old-full))
              (bmovement (- old-full full)))
          (save-excursion
            (when (re-search-forward "#╟" (line-end-position) t)
              (goto-char (match-end 0))
              (let ((inhibit-read-only t)
                    (start-pnt (point)))
                (if (> new-number old-number)
                    (progn ;;forwards
                      (forward-char old-full)
                      (insert (make-string movement ?▓))
                      (forward-char 2)
                      (delete-char movement)
                      )
                  (progn ;;backwards
                    (forward-char (- old-full bmovement))
                    (delete-char bmovement)
                    (forward-char 2)
                    (insert (make-string bmovement ?╌))))
                (put-text-property start-pnt (point) 'read-only t))))))))



(require 'thingatpt)
(put 'float 'end-op       (lambda () (re-search-forward "[0-9-]*\.[0-9-]*" nil t)))
(put 'float 'beginning-op (lambda () (if (re-search-backward "[^0-9-\.]" nil t) (forward-char))))

(defun change-number-at-point (func)
  (let* ((bounds (bounds-of-thing-at-point 'float))
         (number (buffer-substring (car bounds) (cdr bounds)))
         (point (point)))
    (goto-char (car bounds))
    (re-search-backward "^\\([^\n]+\\): " (line-beginning-position)  t)
    (let ((m (match-string 1 nil)))
      (if m
          (let* ((parts (split-string (string-trim m) " "))
                 (caller (concat (replace-regexp-in-string "^#" "" (first parts)) "/" (first (reverse parts)))))
            (goto-char (car bounds))
            (delete-char (length number))
            (insert (format "%.2f" (funcall func (string-to-number number) caller)))
            (hlt-highlight-regexp-region (car bounds) (point) ".+" 'eval-sonic-pi-flash nil))
        (progn
            (goto-char (car bounds))
            (delete-char (length number))
            (insert (format "%.2f" (funcall func (string-to-number number) nil))))))
    (goto-char point)))

(defun inc-float-at-point ()
  (interactive)
  (change-number-at-point (lambda (number param-name)
                            (let ((new-number (min 1.00 (+ number 0.01))))
                              (pots-update new-number number)
                              (push-msg param-name new-number)
                              new-number))))

(defun dec-float-at-point ()
  (interactive)
  (change-number-at-point (lambda (number param-name)
                            (let ((new-number (max 0.00 (- number 0.01))))
                              (pots-update new-number number)
                              (push-msg param-name new-number)
                              new-number))))

(defun inc-float-at-point-big ()
  (interactive)
  (change-number-at-point (lambda (number param-name)
                            (let ((new-number (min 1.00 (+ number 0.1))))
                              (pots-update new-number number)
                              (push-msg param-name new-number)
                              new-number))))
(defun dec-float-at-point-big ()
  (interactive)
  (change-number-at-point (lambda (number param-name)
                            (let ((new-number (max 0.00 (- number 0.1))))
                              (pots-update new-number number)
                              (push-msg param-name new-number)
                              new-number))))

(global-set-key [(meta up)]    'inc-float-at-point)
(global-set-key [(meta down)]  'dec-float-at-point)
(global-set-key [M-shift-up ]  'inc-float-at-point-big)
(global-set-key [M-shift-down] 'dec-float-at-point-big)


(defun re-no-block  (BEG END)
  (interactive "r")
  (save-excursion
    (goto-char BEG)
    (if (re-search-forward "yes{" END t 1)
        (progn
          (delete-char -4)
          (insert "no{"))
      (progn
        (insert "no{\n")
        (goto-char (+ END 4))
        (insert "}")))))

(defun re-yes-block (BEG END)
  (interactive "r")
    (save-excursion
      (goto-char BEG)
      (if (re-search-forward "no{" END t 1)
          (progn
            (delete-char -3)
            (insert "yes{"))
          (progn
            (insert "yes{\n")
            (goto-char (+ END 4))
            (insert "}")))))
