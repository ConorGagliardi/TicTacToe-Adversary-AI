(setf depthvar 2)
(setf no-tracing T)


(defun buildboard ()
  (setf tmpboard '())
  (dotimes (i 9)
    (setf tmpboard (append tmpboard (cons (+ 1 i) '())))
    )
  tmpboard
)

(defun copyboard (board)
  (let ((copiedboard board))
     (return-from copyboard copiedboard)
     )
)

(defun reset-board (board)
  (dotimes (i 9)
    (inserthelp board i)
    )
)

(defun inserthelp (board sym)
  (setf num (+ 1 sym))
  (rotatef (nth sym board) num)
)

(defun print-board (board)
  (setf counter 0)
  (print '>)
  (dotimes (x 3)
    (princ (nth counter board))
    (setf counter (+ counter 1))
    )
  (print '>)
  (dotimes (x 3)
    (princ (nth counter board))
    (setf counter (+ counter 1))
    )
  (print '>)
  (dotimes (x 3)
    (princ (nth counter board))
    (setf counter (+ counter 1))
    )
  )

(defun insert-board (sym pos)
  (setf p (- pos 1))
  (cond
   ((equal (nth p board) pos)
    (rotatef (nth p board) sym)
    T
    )
   ((not (equal (nth p board) pos))
    (print '(This spot is occupied choose another))
    NIL
    )
   )
 )

(defun game-play ()
  (setf board (buildboard))
  (reset-board board)
  (setf validmv T)
  (print '>)
  (princ "Lets play a game of tic-tac-toe!")
  (print '>)
  (princ "Choose your symbol (x/o): ")
  (setf usersym (read))
  (setf aisym NIL)
  (cond
   ((equal usersym 'x)
    (setf aisym 'o))
   ((equal usersym 'o)
    (setf aisym 'x))
   )
  (setf startf NIL)
  (print '>)
  (princ "Do you want to start? (y/n): ")
  (setf startf (read))
  (cond
   ((equal startf 'y)
    (princ "Current state:")
    (print-board board)
    (print '>)
    (princ "Enter move 1-9 to place your symbol on desired place, not already taken.")
    (print '>)
    (princ "Enter move: ")
    (setf space (read))
    (insert-board usersym space)
    )
   )
  (dotimes (z 999)
    (cond
     ((equal validmv T)
      (print '(ENEMY TURN))
      (enemy-input board)
      (print '>)
      (princ "Current state:")
      (print-board board)
      (when (victory board aisym)
        (print (cons aisym '(wins)))
        (return-from game-play T))
      (when (checkstalemate board)
        (print '(STALEMATE))
        (return-from game-play T))
      )
     )
    (print '>)
    (princ "Enter move 1-9 to place your symbol on desired place, not already taken.")
    (print '>)
    (princ "Enter move: ")
    (setf space (read))
    (setf validmv (insert-board usersym space))
    (print '>)
    (princ "Current state:")
    (print-board board)
    (when (victory board usersym)
      (print (cons usersym '(wins)))
      (return-from game-play T))
    (when (checkstalemate board)
      (print '(STALEMATE))
      (return-from game-play T))
    )
  )

(defun enemy-input (board)
  (setf bestmove (findbestmove board))
  (dotimes (i 9)
    (when (not (equal (nth i board) (nth i bestmove)))
      (rotatef (nth i board) (nth i bestmove))
      )
    )
)

(defun findbestmove (board)
  (setf movectr 0)
  (setf bestmove 0)
  (setf topheuristic -999)
  (setf alpha -9999)
  (dolist (suc (getsuccessors board aisym))
    (when (equal no-tracing NIL)
    (print "successor")
    (princ suc)
    )
    (setf tempheur (value suc (- depthvar 1) NIL usersym alpha 9999))
    (when (equal no-tracing NIL)
    (print "top heur")
    (princ topheuristic)
    (print "temp heur")
    (princ tempheur)
    )
    (when (not (equal tempheur NIL))
      (when (> tempheur topheuristic)
        (setf topheuristic tempheur) 
        (setf bestmove movectr)
        (setf alpha tempheur)
        )
      )
    (setf movectr (+ movectr 1))
    )
  (nth bestmove (getsuccessors board aisym))
)

(defun value (board depth ismax sym alpha beta)
  (cond
   ((equal (victory board aisym) T)
    (setf depth 0)
    1000)
   ((equal (victory board usersym) T)
    (setf depth 0)
    -1000)
   ((equal (checkstalemate board) T)
    (setf depth 0)
    0)
   ((< depth 1)
    (boardvalue board (notsym sym))
    )
   ((equal ismax T)
    (setf bestv -999)
    (dolist (suc (getsuccessors board aisym))
      (when (equal no-tracing NIL)
      (print '(MaxIMIZING))
      (princ suc)
      (princ " ")
      )
      (setf tmpbv (value suc (- depth 1) NIL usersym alpha beta))
      (when (equal no-tracing NIL)
      (princ tmpbv)
      )
      (when (not (equal tmpbv NIL))
        (when (> tmpbv bestv)
          (setf bestv tmpbv)
          )
        )
      (when (or (> bestv beta) (equal bestv beta))
        (when (equal no-tracing NIL)
        (print '(PRUNING IN MAX TREE))
        )
        (return-from value bestv)
        )
      (cond
       ((< alpha bestv)
        (when (equal no-tracing NIL)
        (print '(NEW ALPHA))
        ;(princ ": " bestv)
        )
        (setf alpha bestv)
        )
       )
      )
    (when (equal no-tracing NIL)
    (print '(best v))
    ;(princ bestv)
    )
    bestv
    )
  ((equal ismax NIL)
    (setf worstv 999)
    (dolist (suc (getsuccessors board usersym))
      (when (equal no-tracing NIL)
      (print '(MINIMIZING))
      (princ suc)
      (princ " ")
      )
      (setf tmpwv (value suc (- depth 1) T usersym alpha beta))
      (when (equal no-tracing NIL)
      (princ tmpwv)
      )
      (when (not (equal tmpwv NIL))
        (when (< tmpwv worstv)
          (setf worstv tmpwv)
          )
        )
      (when (or (< worstv alpha) (equal worstv alpha))
        (when (equal no-tracing NIL)
        (print '(PRUNING IN MIN TREE))
        )
        (return-from value worstv)
        )
      (cond
       ((> beta worstv)
        (when (equal no-tracing NIL)
        (print '(NEW BETA))
        ;(princ ": " worstv)
        )
        (setf beta worstv)
        )
       )
      )
    (when (equal no-tracing NIL)
    (print '(worst v))
    (princ worstv)
    )
     worstv
    )
  )
)

(defun victory (board sign)
  (when (checkvertical board sign)
    (return-from victory T)
    )
  (when (checkhorizontal board sign)
    (return-from victory T)
    )
  (when (checkdiagonal board sign)
    (return-from victory T)
    )
  NIL
)

(defun checkvertical (board sign)
  (dotimes (i 3)
    (setf victorycount 0)
    (when (equal (nth i board) sign)
      (setf victorycount (+ victorycount 1)))
    (when (equal (nth ( + i 3) board) sign)
      (setf victorycount (+ victorycount 1)))
    (when (equal (nth ( + i 6) board) sign)
      (setf victorycount (+ victorycount 1)))
    (cond
     ((equal victorycount 3)
      ;(print (cons sign '(wins)))
      (return-from checkvertical T)
      )
     )
    )
  )

(defun checkhorizontal (board sign)
  (dotimes (i 3)
    (setf victorycount 0)
    (setf horizon (* 3 i) )
    (when (equal (nth horizon board) sign)
      (setf victorycount (+ victorycount 1)))
    (when (equal (nth ( + horizon 1) board) sign)
      (setf victorycount (+ victorycount 1)))
    (when (equal (nth ( + horizon 2) board) sign)
      (setf victorycount (+ victorycount 1)))
    (cond
     ((equal victorycount 3)
      ;(print (cons sign '(wins)))
      (return-from checkhorizontal T)
      )
     )
    )
)

(defun checkdiagonal (board sign)
    (setf victorycount 0)
    (when (equal (nth 0  board) sign)
      (setf victorycount (+ victorycount 1)))
    (when (equal (nth 4 board) sign)
      (setf victorycount (+ victorycount 1)))
    (when (equal (nth 8 board) sign)
      (setf victorycount (+ victorycount 1)))
    (cond
     ((equal victorycount 3)
      ;(print (cons sign '(wins)))
      (return-from checkdiagonal T)
      )
     )
    (setf victorycount 0)
    (when (equal (nth 2  board) sign)
      (setf victorycount (+ victorycount 1)))
    (when (equal (nth 4 board) sign)
      (setf victorycount (+ victorycount 1)))
    (when (equal (nth 6 board) sign)
      (setf victorycount (+ victorycount 1)))
    (cond
     ((equal victorycount 3)
      ;(print (cons sign '(wins)))
      (return-from checkdiagonal T)
      )
     )
)

(defun checkstalemate (board)
  (dolist (place board)
    (when (numberp place)
      (return-from checkstalemate NIL)
      )
    )
  ;(print '(STALEMATE))
  T
)

(defun getsuccessors (board sym)
  (let ((boardcopy board) (symcopy sym))
    (setf moves '())
    (setf successors '())
    (dolist (plce boardcopy)
      (when (numberp plce)
        (setf moves (append moves (cons (- plce 1) '())))
        )
      )
    (dolist (mov moves)
      (let ((tmpboard boardcopy))
        (setf tmpboard1 (copy-list tmpboard))
        (setf tmpsym symcopy)
        (rotatef (nth mov tmpboard1) tmpsym)
        (setf successors (append successors (cons tmpboard1 '())))
        )
      )
    successors
    )
  )

(defun boardvalue (board sym)
  (setf winvalue 0)
  (setf winvalue (+ winvalue (+ (verticalvalue board sym)(+ (horizontalvalue board sym) (diagonalvalue board sym)))))
  (cond
   ((equal sym 'o)
    (setf oppositesym 'x)
    )
   ((equal sym 'x)
    (setf oppositesym 'o)
    )
   )
  (setf winvalue (- winvalue (+ (verticalvalue board oppositesym)(+ (horizontalvalue board oppositesym) (diagonalvalue board oppositesym)))))
  winvalue
)

(defun verticalvalue (board sign)
  (setf vertval 0)
  (dotimes (i 3)
    (setf victorycount 0)
    (setf losingcount 0)

    (when (equal (nth i board) sign)
      (setf victorycount (+ victorycount 1)))
    (when (not (equal (nth i board) sign))
      (when (not (numberp (nth i board)))
        (setf losingcount (+ losingcount 1))))

    (when (equal (nth ( + i 3) board) sign)
      (setf victorycount (+ victorycount 1)))
    (when (not (equal (nth ( + i 3) board) sign))
      (when (not (numberp (nth ( + i 3) board)))
        (setf losingcount (+ losingcount 1))))

    (when (equal (nth ( + i 6) board) sign)
      (setf victorycount (+ victorycount 1)))
    (when (not (equal (nth ( + i 6) board) sign))
      (when (not (numberp (nth ( + i 6) board)))
        (setf losingcount (+ losingcount 1))))

    (cond
     ((equal victorycount 3)
      (setf vertval (+ vertval 100))
      )
     ((equal victorycount 2)
      (when (equal losingcount 0)
        (setf vertval (+ vertval 10))
        )
      )
     ((equal victorycount 1)
      (when (equal losingcount 0)
        (setf vertval (+ vertval 1))
        )
      )
     )
    )
  vertval
)

(defun horizontalvalue (board sign)
  (setf horval 0)
  (dotimes (i 3)
    (setf victorycount 0)
    (setf losingcount 0)
    (setf horizon (* 3 i) )

    (when (equal (nth horizon board) sign)
      (setf victorycount (+ victorycount 1)))
    (when (not (equal (nth horizon board) sign))
      (when (not (numberp (nth horizon board)))
        (setf losingcount (+ losingcount 1))))

    (when (equal (nth ( + horizon 1) board) sign)
      (setf victorycount (+ victorycount 1)))
    (when (not (equal (nth ( + horizon 1) board) sign))
      (when (not (numberp (nth ( + horizon 1) board)))
        (setf losingcount (+ losingcount 1))))

    (when (equal (nth ( + horizon 2) board) sign)
      (setf victorycount (+ victorycount 1)))
    (when (not (equal (nth ( + horizon 2) board) sign))
      (when (not (numberp (nth ( + horizon 2) board)))
        (setf losingcount (+ losingcount 1))))

    (cond
     ((equal victorycount 3)
      (setf horval (+ horval 100))
      )
     ((equal victorycount 2)
      (when (equal losingcount 0)
        (setf horval(+ horval 10))
        )
      )
     ((equal victorycount 1)
      (when (equal losingcount 0)
        (setf horval(+ horval 1))
        )
      )
     )
    )
  horval
)

(defun diagonalvalue (board sign)
  (setf vertval 0)
  (setf victorycount 0)
  (setf losingcount 0)

  (when (equal (nth 0  board) sign)
    (setf victorycount (+ victorycount 1)))
  (when (not (equal (nth 0 board) sign))
    (when (not (numberp (nth 0 board)))
      (setf losingcount (+ losingcount 1))))

  (when (equal (nth 4 board) sign)
    (setf victorycount (+ victorycount 1)))
  (when (not (equal (nth 4 board) sign))
    (when (not (numberp (nth 4 board)))
      (setf losingcount (+ losingcount 1))))

  (when (equal (nth 8 board) sign)
    (setf victorycount (+ victorycount 1)))
  (when (not (equal (nth 0 board) sign))
    (when (not (numberp (nth 0 board)))
      (setf losingcount (+ losingcount 1))))

  (cond
   ((equal victorycount 3)
    (setf vertval (+ vertval 100))
    )
   ((equal victorycount 2)
    (when (equal losingcount 0)
      (setf vertval (+ vertval 10))
      )
    )
   ((equal victorycount 1)
    (when (equal losingcount 0)
      (setf vertval (+ vertval 1))
      )
    )
   )

  (setf victorycount 0)
  (setf losingcount 0)

  (when (equal (nth 2  board) sign)
    (setf victorycount (+ victorycount 1)))
  (when (not (equal (nth 2 board) sign))
    (when (not (numberp (nth 2 board)))
      (setf losingcount (+ losingcount 1))))

  (when (equal (nth 4 board) sign)
    (setf victorycount (+ victorycount 1)))
  (when (not (equal (nth 4 board) sign))
    (when (not (numberp (nth 4 board)))
      (setf losingcount (+ losingcount 1))))

  (when (equal (nth 6 board) sign)
    (setf victorycount (+ victorycount 1)))
  (when (not (equal (nth 6 board) sign))
    (when (not (numberp (nth 6 board)))
      (setf losingcount (+ losingcount 1))))

  (cond
   ((equal victorycount 3)
    (setf vertval (+ vertval 100))
    )
   ((equal victorycount 2)
    (when (equal losingcount 0)
      (setf vertval (+ vertval 10))
      )
    )
   ((equal victorycount 1)
    (when (equal losingcount 0)
      (setf vertval (+ vertval 1))
      )
    )
   )
  vertval
)

(defun notsym (sym)
    (setf newsym 'u)
    (cond
     ((equal sym 'x)
      (setf newsym 'o)
      )
     ((equal sym 'o)
      (setf newsym 'x)
      )
     )
)