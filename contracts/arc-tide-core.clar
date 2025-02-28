;; ArcTide Core Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-invalid-goal (err u101))
(define-constant err-goal-not-found (err u102))
(define-constant err-already-completed (err u103))
(define-constant err-past-deadline (err u104))

;; Data Variables
(define-map goals
  { goal-id: uint, user: principal }
  {
    title: (string-utf8 100),
    deadline: uint,
    completed: bool,
    verified: bool,
    reward-claimed: bool
  }
)

(define-data-var goal-counter uint u0)

;; Events
(define-data-var last-event-id uint u0)

(define-map events
  { event-id: uint }
  {
    event-type: (string-ascii 20),
    goal-id: uint,
    user: principal,
    timestamp: uint
  }
)

;; Private Functions
(define-private (emit-event (event-type (string-ascii 20)) (goal-id uint))
  (let ((event-id (var-get last-event-id)))
    (map-set events
      { event-id: event-id }
      {
        event-type: event-type,
        goal-id: goal-id,
        user: tx-sender,
        timestamp: block-height
      }
    )
    (var-set last-event-id (+ event-id u1))
    (ok event-id)
  )
)

;; Public Functions
(define-public (create-goal (title (string-utf8 100)) (deadline uint))
  (let ((goal-id (var-get goal-counter)))
    (asserts! (> deadline block-height) err-invalid-goal)
    (map-set goals
      { goal-id: goal-id, user: tx-sender }
      {
        title: title,
        deadline: deadline,
        completed: false,
        verified: false,
        reward-claimed: false
      }
    )
    (var-set goal-counter (+ goal-id u1))
    (try! (emit-event "goal-created" goal-id))
    (ok goal-id)
  )
)

(define-public (complete-goal (goal-id uint))
  (let ((goal (map-get? goals { goal-id: goal-id, user: tx-sender })))
    (match goal
      goal-data (begin
        (asserts! (not (get completed goal-data)) err-already-completed)
        (asserts! (<= block-height (get deadline goal-data)) err-past-deadline)
        (map-set goals
          { goal-id: goal-id, user: tx-sender }
          (merge goal-data { completed: true })
        )
        (try! (emit-event "goal-completed" goal-id))
        (ok true)
      )
      (err err-goal-not-found)
    )
  )
)

(define-public (verify-goal (goal-id uint) (user principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-owner)
    (match (map-get? goals { goal-id: goal-id, user: user })
      goal-data (begin
        (map-set goals
          { goal-id: goal-id, user: user }
          (merge goal-data { verified: true })
        )
        (try! (emit-event "goal-verified" goal-id))
        (ok true)
      )
      (err err-goal-not-found)
    )
  )
)
