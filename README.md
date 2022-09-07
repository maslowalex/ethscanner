# EthereumScan technical decisions

- Transactions data will be persisted in the database to be able to track it's confirmations, tx_hash and status
- There will be no Payment entity in the system as Transaction is reflecting it's desired properties (looking to the transaction status we can conclude wether Payment is pending / confirmed or failed)
- We force a business rule that status change to :confirmed only depends on the number of confirmations
- We will be getting confirmations data calling blockcypher API (https://www.blockcypher.com/) because it contains clear number of confirmations along with the errors (when they occur)
- We choose mocking over VCR cassetes for testing interactions with API
- Transaction confirmations / failures check will be happening in the separate process (EthereumScan.Transactions.Worker)
- Pooling interval of check process and number of confirmations to threat transaction as confirmed is configurable