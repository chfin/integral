#|
  This file is a part of integral project.
  Copyright (c) 2014 Eitarow Fukamachi (e.arrows@gmail.com)
|#

(in-package :cl-user)
(defpackage integral-test.connection.sqlite3
  (:use :cl
        :cl-test-more
        :dbi
        :integral
        :integral.connection.sqlite3)
  (:import-from :integral.connection.sqlite3
                :table-primary-keys)
  (:import-from :integral-test.init
                :connect-to-testdb))
(in-package :integral-test.connection.sqlite3)

(plan 4)

(let ((db (connect-to-testdb)))
  (dbi:do-sql db "CREATE TABLE tweets (id INTEGER PRIMARY KEY, status TEXT NOT NULL, user VARCHAR(64) NOT NULL, UNIQUE (id, user))")

  (is (table-primary-keys db "tweets") '("id"))

  (ok (every
       #'equal
       (table-indices db "tweets")
       '((:unique-key t :primary-key t :columns ("id"))
         (:unique-key t :primary-key nil :columns ("id" "user")))))

  (dbi:do-sql db "CREATE TABLE users (id INTEGER PRIMARY KEY, first_name VARCHAR(64) NOT NULL, family_name VARCHAR(64) NOT NULL, UNIQUE(first_name, family_name))")

  (is (table-primary-keys db "users") '("id"))

  (ok (every
       #'equal
       (table-indices db "users")
       '((:unique-key t :primary-key t :columns ("id"))
         (:unique-key t :primary-key nil :columns ("first_name" "family_name"))))))

(finalize)