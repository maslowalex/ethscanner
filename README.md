# EthereumScan technical decisions

- Transactions data will be persisted in the database to be able to track it's confirmations, tx_hash and status
- We force a business rule that status change to :confirmed only depends on the number of confirmations
- We will be getting confirmations data calling blockcypher API (https://www.blockcypher.com/) because it contains clear number of confirmations along with the errors (when they occur)
- We choose mocking over VCR cassetes for testing interactions with API
- Transaction confirmations / failures check will be happening in the separate process (EthereumScan.Transactions.Worker)
- To prevent more than one check process to be active at the same time - we will use Registry to keep track of the working processes
- Pooling interval of check process and number of confirmations to threat transaction as confirmed is configurable