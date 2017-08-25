
(in-package :math)


; TYPES

(defun int (x)
  (the integer (coerce x 'integer)))


(defun int* (xx)
  (mapcar (lambda (x) (int x)) xx))


(defun dfloat (x)
  (the double-float (coerce x 'double-float)))


(defun dfloat* (xx)
  (mapcar (lambda (x) (dfloat x)) xx))


; RANGES


(defmacro rep ((i itt) &body body)
  `(loop for ,i in ,itt collect (progn ,@body)))


(defmacro nrep (n &body body)
  (with-gensyms (i nname)
    `(let ((,nname ,n))
      (loop for ,i integer from 1 to ,nname collect (progn ,@body)))))


(defun range (a &optional (b nil))
  (if (not b)
    (loop for x integer from 0 below a collect x)
    (loop for x integer from a below b collect x)))


(defun lget (l ii)
  "
  avoid using this; it is slow if l is large.
  "
  (declare (list l ii))
  (loop for i in ii collect (nth i l)))


(defun inc (x stp)
  (mod (+ x stp) 1.0d0))


(defun linspace (a b n &key (end t))
  (if (> n 1)
    (let ((nn (if end (1- n) n)))
      (loop for i from 0 below n
        collect (dfloat (+ a (* i (/ (- b a) nn))))))
    (list (dfloat a))))


(defun add (a b)
  (declare (list a b))
  (mapcar #'+ a b))


(defun sub (a b)
  (declare (list a b))
  (mapcar #'- a b))


(defun mult (a b)
  (declare (list a b))
  (mapcar #'* a b))


(defun div (a b)
  (declare (list a b))
  (mapcar #'/ a b))


(defun scale (a s)
  (declare (list a))
  (declare (double-float s))
  (mapcar (lambda (i) (* i s)) a))


(defun iscale (a s)
  (declare (list a))
  (declare (double-float s))
  (mapcar (lambda (i) (/ i s)) a))


(defun sum (a)
  (declare (list a))
  (reduce #'+ a))


; SHAPES


(defun on-circ (p rad &key (xy (list 0.0d0 0.0d0)))
  (declare (double-float p))
  (vec:add xy (vec:scale (vec:cos-sin (* p PI 2.0d0)) rad)))


(defun on-line (p a b)
  (declare (vec:vec a b))
  (declare (double-float p))
  (vec:add a (vec:scale (vec:sub b a) p)))


(defun polygon (n rad &key (xy (list 0.0d0 0.0d0)) (rot 0.0d0))
  (declare (integer n))
  (declare (double-float rad))
  (loop for i from 0 below n collect (vec:add xy
    (vec:scale
      (vec:cos-sin (+ rot (* (/ i n) 2.0d0 PI)))
      rad))))


; THREE POINT
; todo: move

(defun -make-front-path (aa bb cc as bs)
  (let ((p1 (vec:add cc (vec:scale (vec:sub aa cc) as)))
        (p2 (vec:add cc (vec:scale (vec:sub bb cc) bs))))
    (list p1 cc p2)))


(defun -make-full-path (aa bb cc as bs)
  (let ((p1 (vec:add cc (vec:scale (vec:sub aa cc) as)))
        (p2 (vec:add cc (vec:scale (vec:sub bb cc) bs))))
    (list p1 cc p2 (vec:add p2 (vec:scale (vec:sub aa p2) as)) p1)))


(defun make-perspective-transform (a b c)
  (lambda (p a* b* u* d*)
    (let ((pc (vec:sub c p)))
      (let ((u (vec:sub p (vec:scale pc u*)))
            (d (vec:add p (vec:scale pc d*))))
        (append (-make-full-path a b u a* b*) (-make-full-path a b d a* b*))))))

