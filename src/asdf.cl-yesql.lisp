(in-package :cl-user)

(defpackage :asdf.cl-yesql
  (:use :cl)
  (:export ;;;; CLASS
           #:yesql
           ;;;; CONFIGURATION
           #:*sql-package*))

(in-package :asdf.cl-yesql)

(defclass yesql (asdf:source-file) ()
  (:default-initargs :type "sql")
  (:documentation "Class that represents SQL source file for cl-yesql."))

(defclass compile-yesql-op (asdf:compile-op)
  ;; NOTE: asdf:input-files is memoised.
  ;; We could not control return value via special symbols.
  ;; We need another object (i.e. compile-yesql-op) for another return value.
  ((op :accessor op)))

(defmethod asdf:input-files ((o compile-yesql-op) (c yesql))
  "Return universal file path."
  (list
    (make-pathname :name "universal"
                   :type "lisp"
                   :defaults (asdf:system-source-directory
                               (asdf:find-system :vernacular)))))

(defmethod asdf:output-files ((o asdf:compile-op) (c yesql))
  "Generate output fasl pathnames."
  (asdf::lisp-compilation-output-files o c))

(defmethod asdf:output-files ((o compile-yesql-op) (c yesql))
  ;; NOTE: Do not CALL-NEXT-METHOD!
  ;; asdf::lisp-compilation-output-files call input-files implicitly!
  (asdf:output-files (op o) c))

(defmethod asdf:perform :before ((o asdf:compile-op) (c yesql))
  ;; Needs to specify system.
  (overlord:set-package-base
   (make-pathname :directory (list :relative (asdf:component-name
                                               (asdf:component-parent c))))
   (asdf:primary-system-name c)))

(defvar *sql-package*)

(defmethod documentation ((symbol (eql '*sql-package*)) (type (eql 'variable)))
  "Dynamically bound by package designator.
Do not asign to it. (Sugestion: net.didierverna.asdf-flv may help you.)
This is used to specify which package is used for symbol interning of sql file.")

(defmethod asdf:perform ((o asdf:compile-op) (c yesql))
  (let ((vernacular/specials:*program-preamble* nil)
        (vernacular/specials:*program*
         `(progn
           ,@(loop :for (op name . rest)
                        :in (cdr
                              (vernacular/lang:expand-module
                                (asdf:component-pathname c)))
                   :collect `(,op ,(intern (symbol-name name) *sql-package*)
                              ,@rest))))
        ;; Intermediate operation object to control generating the input files.
        ;; SQL file path for generating fasl pathname.
        ;; universal.lisp for compiling.
        (op (asdf:make-operation 'compile-yesql-op)))
    (setf (op op) o)
    (asdf::perform-lisp-compilation op c)))

(defmethod asdf:perform ((o asdf:load-op) (c yesql))
  (asdf::perform-lisp-load-fasl o c))
