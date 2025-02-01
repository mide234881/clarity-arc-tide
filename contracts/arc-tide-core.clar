;; ArcTide Core Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-invalid-goal (err u101))
(define-constant err-goal-not-found (err u102))

;; Data Variables
(define-map goals
  { goal-id: uint, user: principal }
  {
    title: (string-utf8 100),
    deadline: uint,
    completed: bool,
    verified: bool
  }
)

(define-data-var goal-counter uint u0)

;; Public Functions
(define-public (create-goal (title (string-utf8 100)) (deadline uint))
  (let ((goal-id (var-get goal-counter)))
    (map-set goals
      { goal-id: goal-id, user: tx-sender }
      {
        title: title,
        deadline: deadline,
        completed: false,
        verified: false
      }
    )
    (var-set goal-counter (+ goal-id u1))
    (ok goal-id)
  )
)

(define-public (complete-goal (goal-id uint))
  (let ((goal (map-get? goals { goal-id: goal-id, user: tx-sender })))
    (match goal
      goal-data (begin
        (map-set goals
          { goal-id: goal-id, user: tx-sender }
          (merge goal-data { completed: true })
        )
        (ok true)
      )
      (err err-goal-not-found)
    )
  )
)
