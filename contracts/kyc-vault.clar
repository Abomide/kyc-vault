;; Define SIP010 trait
(define-trait sip010-trait
  (
    (transfer (uint principal principal) (response bool uint))
    (get-balance (principal) (response uint uint))
  ))


;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-TRANSFER-FAILED (err u2))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u3))
(define-constant ERR-NO-LOAN (err u4))
(define-constant ERR-NO-COLLATERAL (err u5))
(define-constant ERR-INVALID-AMOUNT (err u6))
(define-constant ERR-NOT-LIQUIDATABLE (err u7))



;; Constants
(define-constant MIN-COLLATERAL-RATIO u150) ;; 150%
(define-constant LIQUIDATION-THRESHOLD u110)

;; Data maps
(define-map collaterals { user: principal } { amount: uint })
(define-map loans { user: principal } { amount: uint, interest-rate: uint, timestamp: uint })

;; Price oracle (simplified mock for testing)
(define-read-only (get-price)
    (ok u100)) ;; Mock price of 1 USD = 100 cents



;; Deposit collateral
(define-public (deposit-collateral (token-trait <sip010-trait>) (amount uint))
    (begin
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        (let ((maybe-collateral (map-get? collaterals { user: tx-sender }))
              (existing (default-to u0 (get amount maybe-collateral)))
              (new-amount (+ existing amount)))
            ;; Transfer tokens to contract
            (try! (contract-call? token-trait transfer 
                amount 
                tx-sender 
                (as-contract tx-sender)))
            ;; Update collateral balance
            (map-set collaterals { user: tx-sender } { amount: new-amount })
            (ok new-amount))))

;; Borrow stablecoin


;; Repay loan
(define-public (repay (loan-token <sip010-trait>) (amount uint))
    (let ((loan (map-get? loans { user: tx-sender })))
        (match loan 
            loan-data
            (begin
                (try! (contract-call? loan-token transfer amount tx-sender (as-contract tx-sender)))
                (let ((remaining (- (get amount loan-data) amount)))
                    (if (<= remaining u0)
                        (begin
                            (map-delete loans { user: tx-sender })
                            (ok u0))
                        (begin
                            (map-set loans 
                                { user: tx-sender } 
                                { amount: remaining, 
                                  interest-rate: (get interest-rate loan-data), 
                                  timestamp: stacks-block-height })
                            (ok remaining)))))
            ERR-NO-LOAN))) ;; No loan found

;; Liquidate undercollateralized positions
(define-public (liquidate (user principal) (loan-token <sip010-trait>) (collateral-token <sip010-trait>))
    (begin
        (let ((loan (map-get? loans { user: user }))
              (collateral (map-get? collaterals { user: user })))
            (match loan loan-data
                (match collateral collateral-data
                    (let ((collateral-ratio (/ (* (get amount collateral-data) u100) (get amount loan-data))))
                        (if (< collateral-ratio LIQUIDATION-THRESHOLD)
                            (begin
                                (map-delete loans { user: user })
                                (map-delete collaterals { user: user })
                                (ok true))
                            (err ERR-NOT-LIQUIDATABLE)))
                    (err ERR-NO-COLLATERAL))
                (err ERR-NO-LOAN)))))

;; Check user status
(define-read-only (get-user-status (user principal))
  {
    collateral: (default-to u0 (get amount (map-get? collaterals { user: user }))),
    loan: (default-to u0 (get amount (map-get? loans { user: user })))
  })
