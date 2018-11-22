;;; flycheck-urn --- Urn support for flycheck. -*- lexical-binding: t; -*-

;; Copyright (C) 2019 Al McElrath <hello@yrns.org>

;;; Commentary:

;;; Code:

(require 'flycheck)
(require 'rx)

(defgroup flycheck-urn nil
  "Urn support for flycheck."
  :prefix "flycheck-urn"
  :group 'flycheck
:link '(url-link :tag "Github" "https://github.com/yrns/flycheck-urn"))

(flycheck-def-option-var flycheck-urn-path "urn/bin/urn.lua" lisp-urn
  "Path to Urn."
  :type 'string
  :risky t)

(flycheck-def-option-var flycheck-urn-include-path nil lisp-urn
  "A list of include directories for Urn."
  :type '(repeat (directory :tag "Include directory"))
  :safe #'flycheck-string-list-p)

(flycheck-define-checker lisp-urn
  "A checker for Urn."
  :command ("lua"
	    (eval flycheck-urn-path)
	    (option-list "--include" flycheck-urn-include-path)
	    "-O0" 			; no optimization
	    "--exec"			; use stdin
	    )
  :standard-input t
  :error-patterns
  ((error line-start "[ERROR] "
	  (message (one-or-more not-newline) "\n"
		   (optional (one-or-more (optional (or "  •" (not space)) (one-or-more not-newline) "\n"))))
	  "  => "
	  (or (seq (or "<stdin>" (file-name)) ":[" line ":" column)
	      (seq "macro expansion" (one-or-more not-newline) "\n  in "
		   (or "<stdin>" (file-name)) ":[" line ":" column))))
  :modes urn-mode)

(defun flycheck-urn-setup ()
  "Setup Flycheck for Urn."
  (interactive)
  (add-to-list 'flycheck-checkers 'lisp-urn t))

(provide 'flycheck-urn)
;;; flycheck-urn.el ends here
