;;; snakehump.el --- Convert between compound word conventions

;; Copyright (C) 2013 Anders Eurenius <aes@spotify.com>

;; Author: Anders Eurenius <aes@spotify.com>
;; Created: 2014-07-05
;; Keywords: formatting camelcase snakecase
;; Version: 0.1.1

;; This file is not part of GNU Emacs.

;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.


(defun snakehump--split-name (compound-word)
  (split-string
   (let ((case-fold-search nil))
     (downcase
      (replace-regexp-in-string "\\([a-z]\\)\\([A-Z]\\)" "\\1 \\2"
				compound-word)))
   "[^A-Za-z0-9]+"))

(defmacro snakehump--fmt (name up sep)
  `(defun ,(intern (concat "snakehump-" (symbol-name name)))
       (compound-word)
     ,(concat "Format compound word with " (symbol-name name))
     (mapconcat
      ',(if up 'capitalize 'downcase)
      (snakehump--split-name compound-word) ,sep)))

(defmacro snakehump--fmt-p (name regexp)
  `(defun ,(intern (concat "snakehump-" (symbol-name name) "-p"))
       (compound-word)
     ,(concat "True if string is a " (symbol-name name) "-style compound word")
     (let ((case-fold-search nil))
       (and (string-match-p ,regexp compound-word) t))))

;; Because it's easier to do this separately
(defun snakehump-drom (compound-word)
  "Format compound word like CamelCase but with leading-lowercase"
  (let ((frags (snakehump--split-name compound-word)))
    (concat (downcase (car frags))
            (mapconcat 'capitalize (cdr frags) ""))))

(setq
 snakehump--wip
 '(
   ;;n makefmt up sep  regexp
   (camel t   t   ""   "^[A-Z][a-z]+\\(?:[A-Z][a-z]+\\)*[A-Z][a-z]*$")
   (snake t   nil "_"  "^[a-z]+\\(?:_[a-z]+\\)+$")
   (dash  t   nil "-"  "^[a-z]+\\(?:-[a-z]+\\)+$")
   (colon t   t   "::" "^\\(?:[A-Za-z]+::\\)+[A-Za-z]+$")
   (drom  nil nil ""   "^[a-z]+\\(?:[A-Z][a-z]+\\)*[A-Z][a-z]*$")
   ))


(dolist (def snakehump--wip)  ; define the predicates and formatters
  (apply  ; dolist-apply-lambda because I can't find destructuring dolist
   (lambda (name makefmt capitalize separator regexp)
     (eval `(snakehump--fmt-p ,name ,regexp))
     (if makefmt
	 (eval `(snakehump--fmt ,name ,capitalize ,separator)))
     )
   def))


(setq snakehump-all-formats (mapcar 'car snakehump--wip))

(defcustom snakehump-hump-cycle
  snakehump-all-formats
  "Order of formats for cycling humps"
  :group 'snakehump
  :safe t)

(defun snakehump-current-format (compound-word)
  "Return a symbol denoting current format"
  (catch 'found
    (dolist (name snakehump-all-formats found)
      (if (apply (intern (concat "snakehump-" (symbol-name name) "-p"))
		 (list compound-word))
	  (throw 'found name)))))

(defun snakehump-format (compound-word format)
  "Format a compound word according to format symbol"
  (apply (intern (concat "snakehump-" (symbol-name format)))
	 (list compound-word)))


;;; Cycle as list, for customizability.
;; Whyyyy?! It's 2014 already
(defun snakehump--list-next (key list)
  "Get item after given key in list"
  (if (and key list)
      (if (and list (equal key (car list)))
	  (if (cdr list) (cadr list) nil)
	(snakehump--list-next key (cdr list)))))

(defun snakehump--cycle-next (key list)
  "Get item after given key in list, or first"
  (or (snakehump--list-next key list) (car list)))


(defun snakehump--list-prev (key cycle &optional last)
  "Get item before given key in list"
  (if key
      (if cycle
	  (if (equal (car cycle) key)
	      last
	    (snakehump--list-prev key (cdr cycle) (car cycle)))
	nil)))

(defun snakehump--cycle-prev (key cycle)
  "Get item before given key in list, or last"
  (or (snakehump--list-prev key cycle) (car (last cycle))))


;;; Format cycling functions
(defun snakehump-next (compound-word)
  (let* ((current (snakehump-current-format compound-word))
	 (next (snakehump--cycle-next current snakehump-hump-cycle)))
    (snakehump-format compound-word next)))

(defun snakehump-prev (compound-word)
  (let* ((current (snakehump-current-format compound-word))
	 (prev (snakehump--cycle-prev current snakehump-hump-cycle)))
    (snakehump-format compound-word prev)))


;;; User functions

;;;###autoload
(defun snakehump-next-at-point ()
  "Format the compound word at point with the next in snakehump-hump-cycle"
  (interactive)
  (let* ((case-fold-search nil)
         (beg (and (skip-chars-backward "[:alnum:]:_-") (point)))
         (end (and (skip-chars-forward  "[:alnum:]:_-") (point)))
         (txt (buffer-substring-no-properties beg end))
         (cml (snakehump-next txt)) )
    (if cml (progn (delete-region beg end) (insert cml))) ))


;;;###autoload
(defun snakehump-prev-at-point ()
  "Format the compound word at point with the previous in snakehump-hump-cycle"
  (interactive)
  (message "prev")
  (let* ((case-fold-search nil)
         (beg (and (skip-chars-backward "[:alnum:]:_-") (point)))
         (end (and (skip-chars-forward  "[:alnum:]:_-") (point)))
         (txt (buffer-substring-no-properties beg end))
         (cml (snakehump-prev txt)) )
    (when cml (delete-region beg end) (insert cml)) ))

;; (global-set-key (kbd "s-s") 'snakehump-next-at-point)
;; (global-set-key (kbd "C-s-s") 'snakehump-prev-at-point)

(provide 'snakehump)

;;; snakehump.el ends here
