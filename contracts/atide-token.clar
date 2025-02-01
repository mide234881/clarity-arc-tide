;; ATide Token Contract

(define-fungible-token atide)

(define-constant contract-owner tx-sender)
(define-constant token-name "ATide")
(define-constant token-symbol "AT")

(define-public (mint (amount uint) (recipient principal))
  (if (is-eq tx-sender contract-owner)
    (ft-mint? atide amount recipient)
    (err u403)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (ft-transfer? atide amount sender recipient)
)
