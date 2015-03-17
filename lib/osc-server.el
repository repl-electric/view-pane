(require 'osc)
(require 'cl)

(defvar osc-server nil "Connection to recieve msgs")

(defun osc-connect ()
  (if (not osc-server)
      (setq osc-server
            (osc-make-server "localhost" 4558
                             (lambda (path &rest args)
                               (print path)
                               (cond
                                ((string-match "/flip" path) (flip))
                                ((string-match "/flop" path) (flop))))))))

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

(defun flip ()
  (custom-set-faces
   '(rainbow-delimiters-depth-1-face ((t (:foreground "blue"))))
   '(rainbow-delimiters-depth-2-face ((t (:foreground "blue"))))
   '(rainbow-delimiters-depth-3-face ((t (:foreground "#8b7500"))))
   '(rainbow-delimiters-depth-4-face ((t (:foreground "#8b7500"))))
   '(rainbow-delimiters-depth-5-face ((t (:foreground "#8b7500"))))
   '(rainbow-delimiters-depth-6-face ((t (:foreground "#8b7500"))))
   '(rainbow-delimiters-depth-7-face ((t (:foreground "#8b7500"))))
   '(rainbow-delimiters-depth-8-face ((t (:foreground "#8b7500"))))
   '(rainbow-delimiters-depth-9-face ((t (:foreground "#8b7500"))))
   '(rainbow-delimiters-unmatched-face ((t (:foreground "red"))))))

(defun flop ()
  (custom-set-faces
   '(rainbow-delimiters-depth-1-face ((t (:foreground "red"))))
   '(rainbow-delimiters-depth-2-face ((t (:foreground "red"))))
   '(rainbow-delimiters-depth-3-face ((t (:foreground "#8e7560"))))
   '(rainbow-delimiters-depth-4-face ((t (:foreground "#8b1540"))))
   '(rainbow-delimiters-depth-5-face ((t (:foreground "#8b7350"))))
   '(rainbow-delimiters-depth-6-face ((t (:foreground "#1f7540"))))
   '(rainbow-delimiters-depth-7-face ((t (:foreground "#8b7300"))))
   '(rainbow-delimiters-depth-8-face ((t (:foreground "#4b7200"))))
   '(rainbow-delimiters-depth-9-face ((t (:foreground "#1b7400"))))
   '(rainbow-delimiters-unmatched-face ((t (:foreground "red"))))))
