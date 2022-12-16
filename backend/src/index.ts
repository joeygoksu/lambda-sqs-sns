import { SNSEvent } from "aws-lambda";
import { SQS } from "aws-sdk";

const sqs = new SQS();

interface JournalEntry {
  id: string;
  "line-items": Array<{
    "account-id": string;
    amount: number;
    type: "credit" | "debit";
  }>;
}

interface SQSMessage {
  balanced: boolean;
}

// export const handler = async (event: SNSEvent) => {
export const handler = async (event: SNSEvent, context: any, callback: any) => {
  for (const record of event.Records) {
    const journalEntry: JournalEntry = JSON.parse(record.Sns.Message);
    console.log("🚀 journalEntry", journalEntry);
    const balanced = isJournalEntryBalanced(journalEntry);

    if (
      process.env.SQS_QUEUE_URL === undefined ||
      process.env.SQS_QUEUE_URL === ""
    ) {
      throw new Error("SQS_QUEUE_URL is not defined");
    }

    const sqsMessage: SQSMessage = {
      ...journalEntry,
      balanced,
    };

    try {
      // Send the journal entry message to the SQS queue
      await sqs
        .sendMessage(
          {
            QueueUrl: process.env.SQS_QUEUE_URL,
            MessageBody: JSON.stringify(sqsMessage),
          },
          (err, data) => {
            if (err) {
              console.log(err, err.stack);
            } else {
              console.log(data);
            }
          }
        )
        .promise();

      console.log("Message sent to SQS queue");
    } catch (error) {
      console.error(error);
      callback(error);
    } finally {
      callback(null, "success");
    }
  }
};

const isJournalEntryBalanced = (journalEntry: JournalEntry): boolean => {
  const lineItems = journalEntry["line-items"];
  let isBalanced: boolean[] = [];

  // return lineItems object with all properties unique by "account-id" key
  const key = "account-id";

  const arrayUniqueByKey = Array.from(
    new Set(lineItems?.map((item: any) => item[key]))
  );

  // Calculate the sum of all credits and debits in the journal entry
  for (const accountId of arrayUniqueByKey) {
    const creditSum = lineItems
      .filter((lineItem) => lineItem["account-id"] === accountId)
      .filter((lineItem) => lineItem.type === "credit")
      .reduce((sum, lineItem) => sum + lineItem.amount, 0);

    const debitSum = lineItems
      .filter((lineItem) => lineItem["account-id"] === accountId)
      .filter((lineItem) => lineItem.type === "debit")
      .reduce((sum, lineItem) => sum + lineItem.amount, 0);

    // A journal entry is balanced if the sum of credits equals the sum of debits
    isBalanced.push(creditSum === debitSum);
  }

  return isBalanced.every((item) => item === true);
};
