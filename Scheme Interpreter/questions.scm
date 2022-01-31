(define (caar x) (car (car x)))

(define (cadr x) (car (cdr x)))

(define (cdar x) (cdr (car x)))

(define (cddr x) (cdr (cdr x)))

; Some utility functions that you may find useful to implement
(define (zip pairs)
  (define (helper p lst1 lst2)
    (if (equal? p nil)
        (list lst1 lst2)
        (helper (cdr p)
                (append lst1 (list (caar p)))
                (append lst2 (cdar p))
        )
    )
  )
  (helper pairs '() '())
)

; ; Problem 15
; ; Returns a list of two-element lists
(define (enumerate s)
  ; BEGIN PROBLEM 15
  (define (helper num input lst)
    (if (equal? input nil)
        lst
        (helper (+ num 1)
                (cdr input)
                (append lst (list (list num (car input))))
        )
    )
  )
  (helper 0 s '())
)

; END PROBLEM 15
; ; Problem 16
; ; Merge two lists LIST1 and LIST2 according to COMP and return
; ; the merged lists.
(define (merge comp list1 list2)
  ; BEGIN PROBLEM 16
  (define (helper op rest1 rest2 lst)
    (cond 
      ((equal? rest1 nil)
       (append lst rest2)
      )
      ((equal? rest2 nil)
       (append lst rest1)
      )
      (else
       (helper op
               (cdr rest1)
               (cdr rest2)
               (if (op (car rest1) (car rest2))
                   (append lst (list (car rest1) (car rest2)))
                   (append lst (list (car rest2) (car rest1)))
               )
       )
      )
    )
  )
  (helper comp list1 list2 '())
)

; END PROBLEM 16
; ; Problem 17
; ; Returns a function that checks if an expression is the special form FORM
(define (check-special form)
  (lambda (expr) (equal? form (car expr)))
)

(define lambda? (check-special 'lambda))

(define define? (check-special 'define))

(define quoted? (check-special 'quote))

(define let? (check-special 'let))

; ; Converts all let special forms in EXPR into equivalent forms using lambda
(define (let-to-lambda expr)
  (cond 
    ((atom? expr)
     ; BEGIN PROBLEM 17
     expr
     ; END PROBLEM 17
    )
    ((quoted? expr)
     ; BEGIN PROBLEM 17
     expr
     ; END PROBLEM 17
    )
    ((or (lambda? expr) (define? expr))
     (let ((form (car expr))
           (params (cadr expr))
           (body (cddr expr))
          )
       ; BEGIN PROBLEM 17
       (append
        (quasiquote ((unquote form) (unquote params)))
        (map let-to-lambda body)
       )
       ; END PROBLEM 17
     )
    )
    ((let? expr)
     (let ((values (cadr expr))
           (body (cddr expr))
          )
       ; BEGIN PROBLEM 17
       (define vars (car (zip values)))
       (define vals (cdr (zip values)))
       (append (quasiquote ((lambda (unquote vars)
                              (unquote (car (map let-to-lambda body)))
                            )
                           )
               )
               (car (map let-to-lambda vals))
       )
       ; END PROBLEM 17
     )
    )
    (else
     ; BEGIN PROBLEM 17
     (map let-to-lambda expr)
     ; END PROBLEM 17
    )
  )
)
