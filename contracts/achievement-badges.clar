;; Achievement Badges NFT Contract

;; Implement SIP009 NFT trait
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token achievement-badge uint)

(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-invalid-badge (err u101))

(define-data-var badge-counter uint u0)

(define-map badge-types
  uint
  {
    name: (string-ascii 50),
    description: (string-utf8 200),
    level-requirement: uint,
    metadata-uri: (optional (string-utf8 256))
  }
)

(define-map token-uris
  uint
  (string-utf8 256)
)

;; SIP009 Implementation
(define-public (get-last-token-id)
  (ok (var-get badge-counter))
)

(define-public (get-token-uri (token-id uint))
  (ok (map-get? token-uris token-id))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u403))
    (nft-transfer? achievement-badge token-id sender recipient)
  )
)

;; Badge Management
(define-public (mint-badge (badge-type uint) (recipient principal))
  (let ((badge-id (var-get badge-counter)))
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (try! (nft-mint? achievement-badge badge-id recipient))
    (var-set badge-counter (+ badge-id u1))
    (ok badge-id)
  )
)

(define-public (set-badge-type (badge-type-id uint) (name (string-ascii 50)) (description (string-utf8 200)) (level-req uint) (uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-owner)
    (map-set badge-types
      badge-type-id
      {
        name: name,
        description: description,
        level-requirement: level-req,
        metadata-uri: uri
      }
    )
    (ok true)
  )
)
