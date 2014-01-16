#|
  This file is a part of integral project.
  Copyright (c) 2014 Eitarow Fukamachi (e.arrows@gmail.com)
|#

(in-package :cl-user)
(defpackage integral.util
  (:use :cl)
  (:import-from :closer-mop
                :class-finalized-p
                :finalize-inheritance
                :slot-definition-name
                :class-direct-slots
                :class-direct-superclasses)
  (:import-from :group-by
                :group-by)
  (:import-from :alexandria
                :remove-from-plist))
(in-package :integral.util)

(cl-syntax:use-syntax :annot)

@export
(defun finalize-class-if-necessary (class)
  (unless (c2mop:class-finalized-p class)
    (c2mop:finalize-inheritance class)))

@export
(defun class-slot-names (class)
  (finalize-class-if-necessary class)
  (mapcar
   #'c2mop:slot-definition-name
   (c2mop:class-direct-slots class)))

@export
(defun escaped-symbol-p (symbol)
  (declare (optimize speed)
           (type symbol symbol))
  (not (string= symbol (string-upcase symbol))))

@export
(defun symbol-name-literally (symbol)
  (if (escaped-symbol-p symbol)
      (symbol-name symbol)
      (string-downcase symbol)))

@export
(defun class-inherit-p (target parent)
  (not (null
        (member parent
                (c2mop:class-direct-superclasses target)
                :test #'eq))))

@export
(defun group-by-plist-key (plist &key key (test #'eq))
  (group-by plist :key (lambda (column)
                         (getf column key))
                  :test test
                  :value (lambda (column)
                           (remove-from-plist column key))))

(defun %list-diff (a b &key (test #'string=))
  (cond
    ((null a)
     (values nil nil b))
    ((null b)
     (values nil a nil))
    ((funcall test (car a) (car b))
     (multiple-value-bind (intersection sub-a sub-b)
         (%list-diff (cdr a) (cdr b) :test test)
       (values (cons (car a) intersection)
               sub-a
               sub-b)))
    (T (let ((pos (position (car a) (cdr b) :test test)))
         (if pos
             (multiple-value-bind (intersection sub-a sub-b)
                 (%list-diff (cdr a) (nthcdr (+ 2 pos) b)
                             :test test)
               (values (cons (car a) intersection)
                       sub-a
                       (append (subseq b 0 (1+ pos)) sub-b)))
             (multiple-value-bind (intersection sub-a sub-b)
                 (%list-diff (cdr a) b :test test)
                 (values intersection
                         (cons (car a) sub-a)
                         sub-b)))))))

@export
(defun list-diff (a b &key (test #'string=))
  "Compute differences two lists.
Note this can be applied for a list of strings."
  (%list-diff (sort (copy-list a) #'string= )
              (sort (copy-list b) #'string=)
              :test test))
