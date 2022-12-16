# Questions

## Question 1

Bank accounts can have constraints such "must have a non-negative balance" or
"must have a non-positive balance" (in the case of e.g. some kinds of loans.
It would be weird if the bank owed you on your car loan).

Here's a naive implementation of a bank service with a bug (our actual design is
much better!):

Bank account balances are stored in postgres. We have a standard multi-threaded
web app for processing API requests. When an API request to transfer money
comes in, the service checks the balance constraints of all affected accounts,
and then decides whether to apply the journal entry. Occasionally we see
transactions that shouldn't have been processed, because they violate balance
constraints. Describe some possible causes of the bug, and list some ways to
mitigate it. Outline the performance and scalability tradeoffs of your potential
fixes?

## Question 2

Another bug, closer to how our system works. In this system, we're using Kafka
and Kafka Streams. Kafka Streams supports using a simple KeyValue storage, using
RocksDB. Imagine one of the `journal-entry` messages from the task coming down
the wire on a Kafka topic. We use the KV to store the current balance on
accounts. The stream processor receives the message, we `get` the account
balance, decide whether to apply the journal entry, `set` the new account
balance, and emit two output messages, one for applying/rejecting the journal
entry, and one for the KV state.

The KV is "ephemeral" in the sense that KV writes are sent to a separate Kafka
topic that only contains the KV writes for that stream node. If the stream
processing node dies and is brought up on another machine, it recreates the KV
database by reading the state topic.

We notice that under load, after sending a large volume of transactions through
the system and cutting the power, when we come back up, some account balances
are wrong.

1. Identify some possible ways we could lose writes.
2. What are some easy/cost-effective ways to test/reproduce the failure? Once
   you have a reproducible test case, what are some good ways to isolate the
   failure modes (i.e. if you identified 2 failure modes in part 1, how do you
   determine whether the bug is caused by `a` or `b`)?
