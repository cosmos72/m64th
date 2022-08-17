(declaim (optimize (speed 3) (safety 0)
		   (compilation-speed 0)
		   (space 0) (debug 0)))

(defun fib (n)
  (labels ((xfib (n)
	     (declare (type fixnum n))
	     (if (> n 2)
		 (the fixnum
		      (+ (xfib (- n 1))
			 (xfib (- n 2))))
                 1)))
    (xfib n)))

;; (eval-when (:execute)
(time (print (fib 45)))

