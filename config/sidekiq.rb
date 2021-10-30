# configuration file for Sidekiq
:max_retries: 3
:queues:
  - [default, 5]
  - [mailers, 2]