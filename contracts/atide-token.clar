;; ATide Token Contract
;; Implements SIP-010 trait

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token atide)

(define-data-var contract-owner principal tx-sender)
(define-constant token-name "ATide")
(define-constant token-symbol "AT")
(define-constant token-decimals u6)

(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; SIP-010 Implementation
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (try! (ft-transfer? atide amount sender recipient))
    (match memo
      memo-data (print memo-data)
      true
    )
    (ok true)
  )
)

(define-read-only (get-name)
  (ok token-name)
)

(define-read-only (get-symbol)
  (ok token-symbol)
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance atide who))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply atide))
)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
    (ft-mint? atide amount recipient)
  )
)

;; Owner management
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
    (var-set contract-owner new-owner)
    (ok true)
  )
)
