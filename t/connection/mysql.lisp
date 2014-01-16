#|
  This file is a part of integral project.
  Copyright (c) 2014 Eitarow Fukamachi (e.arrows@gmail.com)
|#

(in-package :cl-user)
(defpackage integral-test.connection.mysql
  (:use :cl
        :cl-test-more
        :dbi
        :integral
        :integral.connection.mysql))
(in-package :integral-test.connection.mysql)

(plan nil)

(let ((db (dbi:connect :mysql
                       :database-name "integral_test"
                       :username "root")))
  (dbi:do-sql db "DROP TABLE IF EXISTS tweets")
  (dbi:do-sql db "CREATE TABLE tweets (id INTEGER AUTO_INCREMENT PRIMARY KEY, status TEXT NOT NULL, user VARCHAR(64) NOT NULL, UNIQUE (id, user))")

  (ok (every
       #'equal
       (table-indices db "tweets")
       '((:unique-key t :primary-key nil :columns ("id" "user"))
         (:unique-key t :primary-key t :columns ("id")))))

  (dbi:do-sql db "DROP TABLE IF EXISTS users")
  (dbi:do-sql db "CREATE TABLE users (id INTEGER AUTO_INCREMENT PRIMARY KEY, first_name VARCHAR(64) NOT NULL, family_name VARCHAR(64) NOT NULL, UNIQUE(first_name, family_name))")

  (ok (every
       #'equal
       (table-indices db "users")
       '((:unique-key t :primary-key nil :columns ("first_name" "family_name"))
         (:unique-key t :primary-key t :columns ("id")))))

  (dbi:disconnect db))

(finalize)