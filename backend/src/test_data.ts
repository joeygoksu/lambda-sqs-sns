// This file contains test data for the backend tests.
export const true_test_data = {
    "Records": [
      {
        "EventSource": "aws:sns",
        "EventVersion": "1.0",
        "EventSubscriptionArn": "arn:aws:sns:us-east-1:{{{accountId}}}:ExampleTopic",
        "Sns": {
          "Type": "Notification",
          "MessageId": "95df01b4-ee98-5cb9-9903-4c221d41eb5e",
          "TopicArn": "arn:aws:sns:us-east-1:123456789012:ExampleTopic",
          "Subject": "example subject",
          "Message": {
            "id": "8bc24b40-0bbc-11e7-93ae-92361f002671",
            "line-items": [
              {
                "account-id": "2e1a8180-0bba-11e7-93ae-92361f002672",
                "amount": 100,
                "type": "credit"
              },
              {
                "account-id": "2e1a8180-0bba-11e7-93ae-92361f002672",
                "amount": 50,
                "type": "debit"
              },
              {
                "account-id": "2e1a8180-0bba-11e7-93ae-92361f002672",
                "amount": 50,
                "type": "debit"
              },
              {
                "account-id": "2e1a8180-0bba-11e7-93ae-92361f002676",
                "amount": 75,
                "type": "debit"
              },
              {
                "account-id": "2e1a8180-0bba-11e7-93ae-92361f002676",
                "amount": 75,
                "type": "credit"
              }
            ]
          },
          "Timestamp": "1970-01-01T00:00:00.000Z",
          "SignatureVersion": "1",
          "Signature": "EXAMPLE",
          "SigningCertUrl": "EXAMPLE",
          "UnsubscribeUrl": "EXAMPLE",
          "MessageAttributes": {
            "Test": {
              "Type": "String",
              "Value": "TestString"
            },
            "TestBinary": {
              "Type": "Binary",
              "Value": "TestBinary"
            }
          }
        }
      }
    ]
  };