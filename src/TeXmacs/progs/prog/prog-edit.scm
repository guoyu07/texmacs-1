
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : prog-edit.scm
;; DESCRIPTION : editing verbatim programs
;; COPYRIGHT   : (C) 2008  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (prog prog-edit)
  (:use (utils library tree)
        (utils library cursor)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Basic routines for textual programs
;; WARNING: most of these fail for non-verbatim content!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (inside-program?)
  (:synopsis "are we inside the line of a textual document?")
  (let* ((ct (cursor-tree))
         (dt (tree-ref ct :up)))
    (and (tree-atomic? ct) (tree-is? dt 'document))))

(tm-define (program-tree)
  (:synopsis "get the entire program tree")
  (let* ((ct (cursor-tree))
         (dt (tree-ref ct :up)))
    (and (tree-atomic? ct) (tree-is? dt 'document) dt)))

(tm-define (program-row row)
  (:synopsis "get the string at a given @row")
  (and-with doc (program-tree)
    (and-with par (tree-ref doc row)
      (and (tree-atomic? par) (tree->string par)))))

(tm-define (program-row-number)
  (:synopsis "get the vertical position on the current line")
  (and (inside-program?) (cADr (cursor-path))))

(tm-define (program-column-number)
  (:synopsis "get the horizontal position on the current line")
  (and (inside-program?) (cAr (cursor-path))))

(tm-define (program-go-to row col)
  (:synopsis "go to the character at a given @row and @col")
  (and-with doc (program-tree)
    (tree-go-to doc row col)))

(tm-define (program-character path)
  (let ((s (tree->string (path->tree (cDr path))))
        (pos (cAr path)))
    (if (or (string-null? s) (>= pos (string-length s)) (< pos 0)) ""
        (char->string (string-ref s pos)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Preferences for bracket handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define prog-auto-close-brackets? #f)
(tm-define prog-highlight-brackets? #f)
(tm-define prog-select-brackets? #f)

(define (notify-auto-close-brackets var val)
  (set! prog-auto-close-brackets? (== val "on")))
(define (notify-highlight-brackets var val)
  (set! prog-highlight-brackets? (== val "on")))
(define (notify-select-brackets var val)
  (set! prog-select-brackets? (== val "on")))

(define-preferences
  ("prog:automatic brackets" "off" notify-auto-close-brackets)
  ("prog:highlight brackets" "off" notify-highlight-brackets)
  ("prog:select brackets" "off" notify-select-brackets))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bracket handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (path++ p)
  (rcons (cDr p) (+ 1 (cAr p))))

(define (path-- p)
  (rcons (cDr p) (- (cAr p) 1)))

(define (set-brackets-selection prev next)
  (if (or (null? prev) (null? next))
      (if (nnull? (get-alt-selection "alternate"))
          (cancel-alt-selection "alternate"))
      (set-alt-selection "alternate" 
                         (list prev (path++ prev) next (path++ next)))))

(tm-define (select-brackets path lb rb)
  (:synopsis "Highlights innermost matching brackets around given @path")
  (set-brackets-selection (find-left-bracket path lb rb)
                          (find-right-bracket path lb rb)))

(tm-define (select-brackets-after-movement lb rb esc)
  (:synopsis "Highlight brackets after a cursor movement")
  (let* ((p (cursor-path))
         (p* (path-- p))
         (ch (program-character p))
         (lch (program-character p*)))
    (if (and (== lch rb) (!= ch lb))
        (set-brackets-selection (find-left-bracket p* lb rb)
                                (find-right-bracket p* lb rb))
        (if (or (== ch esc) (and (!= ch lb) (!= ch rb)))
            (if (nnull? (get-alt-selection "alternate"))
                (cancel-alt-selection "alternate"))
            (set-brackets-selection (find-left-bracket p lb rb)
                                    (find-right-bracket p lb rb))))))

(tm-define (bracket-open lb rb esc)
  (if prog-auto-close-brackets?
      (if (selection-active-normal?)
          (begin
            (clipboard-cut "temp")
            (insert-go-to (string-append lb rb) '(1))
            (clipboard-paste "temp"))
          (with ch (or (before-cursor) "")
            ; Don't create right bracket if prev char is escape char
            (if (== ch esc)
                (insert lb)
                (insert-go-to (string-append lb rb) '(1)))))
      (insert lb))
  (if prog-highlight-brackets? (select-brackets (cursor-path) lb rb)))

; TODO: warn if unmatched
(tm-define (bracket-close lb rb esc)
  (with p (cursor-path)
    (insert rb)
    (if prog-highlight-brackets? (select-brackets p lb rb))))

(tm-define (program-select-enlarge lb rb)
  (let* ((start (selection-get-start))
         (end (selection-get-end))
         (start* (if (== start end) start (path-- start)))
         (prev (find-left-bracket start* lb rb))
         (next (find-right-bracket end lb rb)))
    (if (or (and (== start prev) (== end next)) (null? prev) (null? next))
        (selection-cancel)
        (selection-set prev (path++ next)))))

; Cancel any active selection when we leave a code fragment
(tm-define (notify-cursor-moved status)
  (:require prog-highlight-brackets?)
  (:require (not (in-prog?)))
  (if (nnull? (get-alt-selection "alternate"))
      (cancel-alt-selection "alternate")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Whitespace handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (char-whitespace? c)
  (== c #\space))

(define (char-non-whitespace? c)
  (!= c #\space))

(tm-define (string-whitespace? s)
  (:synopsis "does @s only contain whitespace?")
  (list-and (map char-whitespace? (string->list s))))

(tm-define (string-get-indent s)
  (:synopsis "get the indentation of @s")
  (with pos (list-find-index (string->list s) char-non-whitespace?)
    (or pos (string-length s))))

(tm-define (string-set-indent s i)
  (:synopsis "set the indentation of @s to @i spaces")
  (let* ((l (make-string i #\space))
         (r (substring s (string-get-indent s) (string-length s))))
    (string-append l r)))

(tm-define (program-get-indent)
  (:synopsis "get the indentation of the current line")
  (and (inside-program?)
       (string-get-indent (program-row (program-row-number)))))

(tm-define (program-set-indent i)
  (:synopsis "set the indentation of the current line to @i spaces")
  (when (inside-program?)
    (with t (cursor-tree)
      (tree-set t (string-set-indent (tree->string t) i)))))
      
(tm-define (get-tabstop)
  (with tabstop* (get-preference "editor:verbatim:tabstop")
    (cond ((and (string? tabstop*) (string->number tabstop*))
           (string->number tabstop*))
          ((and (number? tabstop*) (> tabstop* 0)) tabstop*)
          (else (set-message
                 `(replace "Wrong tabstop: %1" ,tabstop*) "User preferences")
                8))))

(tm-define (insert-tabstop)
  (with w (get-tabstop)
    (with fill (- w (remainder (cAr (cursor-path)) w))
      (if (> fill 0) (insert (make-string fill #\space))))))
