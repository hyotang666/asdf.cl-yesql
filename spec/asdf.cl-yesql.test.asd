; vim: ft=lisp et
(in-package :asdf)
(defsystem "asdf.cl-yesql.test"
  :version
  "0.0.0"
  :depends-on
  (:jingoh "asdf.cl-yesql")
  :components
  ((:file "asdf.cl-yesql"))
  :perform
  (test-op (o c) (declare (special args))
   (apply #'symbol-call :jingoh :examine :asdf.cl-yesql args)))