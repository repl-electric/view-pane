(require 'osc)
(require 'cl)

(defvar osc-server nil "Connection to recieve msgs")
(defvar flip-state t)

(defun osc-connect ()
  (if (not osc-server)
      (setq osc-server
            (osc-make-server "localhost" 4558
                             (lambda (path &rest args)
                               ;; (print path)
                               (cond
                                ((string-match "/beat" path)  (progn (if flip-state
                                                                         (highlight)
                                                                       (default))
                                                                     (setq flip-state (not flip-state))))
                                ((string-match "/crazy" path) (crazy))))))))

(defun osc-make-server (host port default-handler)
  (make-network-process
   :name "emacs live OSC server"
   :host host
   :server t
   :service port
   :filter #'osc-filter
   :type 'datagram
   :family 'ipv4
   :plist (list :generic default-handler)))

(defun osc-cleanup ()
  "Remove osc server and client"
  (when osc-server
    (delete-process osc-server))
  (setq osc-server nil))


(osc-connect)
;;(osc-cleanup)

(provide 'osc-server)

(defun highlight ()
  (custom-set-faces
   '(rainbow-delimiters-depth-1-face ((t (:foreground "#545600"))))
   '(rainbow-delimiters-depth-2-face ((t (:foreground "#FC5609"))))
;;   '(window-number-face ((t (:foreground "#545611"))))
   '(mode-line-buffer-id ((t (:foreground "#545611"))))
   ))

;;(highlight)
;;(default)

(defun default ()
  (custom-set-faces
   '(rainbow-delimiters-depth-1-face ((t (:foreground "#FDDD0C"))))
   '(rainbow-delimiters-depth-2-face ((t (:foreground "#FC5609"))))
;;   '(window-number-face ((t (:foreground "#FDDD0C"))))
   '(mode-line-buffer-id ((t (:foreground "#FDDD0C"))))
   ))

(defun crazy ()
  (custom-set-faces
   '(font-lock-builtin-face ((t (:foreground "#F34560"))))
   '(font-lock-builtin-face ((t (:foreground "#000FF0"))))
   `(mode-line ((t (:foreground "#011143" :background "#0000000"))))
   '(mode-line-highlight ((t (:foreground "#F11111"))))
   '(mode-line-emphasis ((t (:foreground "#F11111"))))
   '(mode-line-buffer-id ((t (:foreground "#F11111"))))
   '(custom-themed ((t :foreground "#F11111")))
   '(vertical-border ((t :foreground "#101010" :background "#232232")))
   ))
;;(crazy)
