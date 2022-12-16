# Context

Banks use double entry bookkeeping to keep track of all money as a way of
reducing mistakes. In double entry accounting, you can't just add or subtract
from the balance of an account, you must also keep track of where it goes. So
for example, if you take money out at the ATM, it's not just "subtract £20 from
your account", the bank tracks that as "credit your account £20, and debit £20
to cash", so that we always know where the money came from, and where it's
going.

The ledger keeps track of the balance of all accounts as a series of journal
entries.

A journal entry consists of multiple line items. Each line item contains an
account id, an amount, and a type flag specifying whether it is a debit or
credit. To be considered _balanced_, the line items must balance, i.e. the sum
of all credits must equal the sum of all debits.

# Task

Write a simple AWS Lambda function in your language of choice that expects to
be triggered by messages from an AWS SNS topic, where the message content can be
assumed to adhere to the schema in `journal_entry.json`.

For each message received, the function should send a message to an AWS SQS
queue containing the original input message with the additional key `balanced`,
which has a boolean value saying whether the journal entry is balanced or not.

Provide infrastructure-as-code (IaC) of your choice (CDK, CloudFormation,
Terraform etc) that will deploy the SNS, SQS and Lambda into an AWS account,
including any permissions necessary for the triggering and sending to work
correctly.

If your experience is primarily with Google Cloud, you may substitute
appropriate GCP resources, e.g. Lambda = Cloud Function, SNS = Pub/Sub.
