# ASDF.CL-YESQL 0.0.0
## What is this?
[ASDF] extension to support [cl-yesql].
ASDF.cl-yesql allows you to load SQL files via [ASDF].

## Alternatives and differences.
Please tell me if exists.

## Usage

```lisp
(defpackage :myproject.asdf (:use :cl :asdf :uiop))
(in-package :myproject.asdf)

;; Load ASDF.CL-YESQL beforehand.
(load-system :asdf.cl-yesql)

;; Inherit it.
(defclass yesql (asdf.cl-yesql:yesql) ())

(defsystem "myproject"
  :depends-on
  ("cl-yesql" "cl-yesql/sqlite")
  :components
  ((:module "src"
            :components
            ((:file "myproject")))
   (:module "sql"
            :depends-on ("src")
            :components
	    ;; Specify component class.
            ((yesql "something")))))

;; Bind ASDF.CL-YESQL:*SQL-PACKAGE*.
;; Every functions are interned to this package.
(defmethod perform ((o compile-op) (c yesql))
  (let ((asdf.cl-yesql:*sql-package* '#:my-project-package))
    (call-next-method)))
```

## From developer

### Product's goal
Integrated to [cl-yesql].

### License
MIT

### Developed with

### Tested with

## Installation

<!-- Links -->
[ASDF]:https://gitlab.common-lisp.net/asdf/asdf/
[cl-yesql]:https://github.com/ruricolist/cl-yesql
