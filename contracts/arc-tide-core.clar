;; ArcTide Core Contract v2

;; Constants and Error Codes
(define-data-var contract-owner principal tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-invalid-goal (err u101))
(define-constant err-goal-not-found (err u102))
(define-constant err-already-completed (err u103))
(define-constant err-past-deadline (err u104))
(define-constant err-invalid-progress (err u105))

;; Data Structures
(define-map goals
  { goal-id: uint, user: principal }
  {
    title: (string-utf8 100),
    deadline: uint,
    completed: bool,
    verified: bool,
    reward-claimed: bool,
    progress: uint,
    total-steps: uint
  }
)

(define-data-var goal-counter uint u0)
(define-data-var paused bool false)

;; Events
(define-data-var last-event-id uint u0)

(define-map events
  { event-id: uint }
  {
    event-type: (string-ascii 20),
    goal-id: uint,
    user: principal,
    timestamp: uint,
    data: (optional (string-utf8 100))
  }
)

;; Private Functions
(define-private (emit-event (event-type (string-ascii 20)) (goal-id uint) (data (optional (string-utf8 100))))
  (let ((event-id (var-get last-event-id)))
    (map-set events
      { event-id: event-id }
      {
        event-type: event-type,
        goal-id: goal-id,
        user: tx-sender,
        timestamp: block-height,
        data: data
      }
    )
    (var-set last-event-id (+ event-id u1))
    (ok event-id)
  )
)

;; Public Functions
(define-public (create-goal (title (string-utf8 100)) (deadline uint) (total-steps uint))
  (let ((goal-id (var-get goal-counter)))
    (asserts! (not (var-get paused)) (err u106))
    (asserts! (> deadline block-height) err-invalid-goal)
    (asserts! (> total-steps u0) err-invalid-goal)
    (map-set goals
      { goal-id: goal-id, user: tx-sender }
      {
        title: title,
        deadline: deadline,
        completed: false,
        verified: false,
        reward-claimed: false,
        progress: u0,
        total-steps: total-steps
      }
    )
    (var-set goal-counter (+ goal-id u1))
    (try! (emit-event "goal-created" goal-id none))
    (ok goal-id)
  )
)

(define-public (update-progress (goal-id uint) (new-progress uint))
  (let ((goal (map-get? goals { goal-id: goal-id, user: tx-sender })))
    (match goal
      goal-data (begin
        (asserts! (<= new-progress (get total-steps goal-data)) err-invalid-progress)
        (map-set goals
          { goal-id: goal-id, user: tx-sender }
          (merge goal-data { progress: new-progress })
        )
        (try! (emit-event "progress-updated" goal-id (some (concat "Progress: " (to-string new-progress)))))
        (ok true)
      )
      (err err-goal-not-found)
    )
  )
)

;; Admin Functions
(define-public (set-paused (pause bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-owner)
    (var-set paused pause)
    (ok true)
  )
)

(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-owner)
    (var-set contract-owner new-owner)
    (ok true)
  )
)
