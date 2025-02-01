;; Achievement Badges NFT Contract

(define-non-fungible-token achievement-badge uint)

(define-data-var badge-counter uint u0)

(define-map badge-types
  uint
  {
    name: (string-ascii 50),
    description: (string-utf8 200),
    level-requirement: uint
  }
)

(define-public (mint-badge (badge-type uint) (recipient principal))
  (let ((badge-id (var-get badge-counter)))
    (if (is-eq tx-sender contract-owner)
      (begin
        (try! (nft-mint? achievement-badge badge-id recipient))
        (var-set badge-counter (+ badge-id u1))
        (ok badge-id)
      )
      (err u403)
    )
  )
)
