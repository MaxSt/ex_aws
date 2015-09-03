defmodule Test.Dummy.SQS do
  use ExAws.SQS.Client

  def config_root, do: Application.get_all_env(:ex_aws)

  def request(_client, "", action, params) do
    params
    |> Enum.into(%{})
    |> Map.put("Action", action)
  end

  def request(_client, queue_name, action, params) do
    params
    |> Enum.into(%{})
    |> Map.put("QueueName", queue_name)
    |> Map.put("Action", action)
  end

end

defmodule ExAws.SQSTest do
  use ExUnit.Case, async: true
  alias Test.Dummy.SQS


  test "#create_queue" do
    expected = %{"Action" => "CreateQueue", "Attribute.1.Name" => "VisibilityTimeout", "Attribute.1.Value" => 10, "QueueName" => "test_queue"}
    assert expected == SQS.create_queue("test_queue", visibility_timeout: 10)
  end

  test "#delete_queue" do
    expected = %{"Action" => "DeleteQueue", "QueueName" => "982071696186/test_queue"}
    assert expected == SQS.delete_queue("982071696186/test_queue")
  end

  test "#list_queues" do
    expected = %{"Action" => "ListQueues"}
    assert expected == SQS.list_queues
  end

  test "#get_queue_attributes" do
    expected = %{"Action" => "GetQueueAttributes", "AttributeName.1" => "All", "QueueName" => "982071696186/test_queue"}
    assert expected == SQS.get_queue_attributes("982071696186/test_queue")

    expected =  %{"Action" => "GetQueueAttributes", "AttributeName.1" => "VisibilityTimeout", "AttributeName.2" => "MessageRetentionPeriod", "QueueName" => "982071696186/test_queue"}
    assert expected == SQS.get_queue_attributes("982071696186/test_queue", [:visibility_timeout, :message_retention_period])
  end

  test "#set_queue_attributes" do
    expected = %{"Action" => "SetQueueAttributes", "Attribute.1.Name" => "VisibilityTimeout", "Attribute.1.Value" => 10, "QueueName" => "982071696186/test_queue"}
    assert expected == SQS.set_queue_attributes("982071696186/test_queue", visibility_timeout: 10)
  end

  test "#purge_queue" do
    expected = %{"Action" => "PurgeQueue", "QueueName" => "982071696186/test_queue"}
    assert expected == SQS.purge_queue("982071696186/test_queue")
  end

  test "#list_dead_letter_source_queues" do
    expected = %{"Action" => "ListDeadLetterSourceQueues", "QueueName" => "982071696186/test_queue"}
    assert expected == SQS.list_dead_letter_source_queues("982071696186/test_queue")
  end

  test "#add_permission" do
    expected = %{
      "Action" => "AddPermission",
      "Label" => "TestAddPermission",
      "QueueName" => "982071696186/test_queue",
      "AWSAccountId.1" => "681962096817",
      "ActionName.1" => "*",
      "AWSAccountId.2" => "071669896281",
      "ActionName.2" => "SendMessage",
      "AWSAccountId.3" => "071669896281",
      "ActionName.3" => "ReceiveMessage"
    }

    assert expected == SQS.add_permission("982071696186/test_queue", "TestAddPermission", %{"681962096817" => :all, "071669896281" => [:send_message, :receive_message]})
  end

  test "#remove_permission" do
    expected = %{"Action" => "RemovePermission", "Label" => "TestAddPermission", "QueueName" => "982071696186/test_queue"}

    assert expected == SQS.remove_permission("982071696186/test_queue", "TestAddPermission")
  end

  test "#send_message" do
    expected = %{"Action" => "SendMessage",
                 "MessageBody" => "This is the message body.",
                 "QueueName" => "982071696186/test_queue",
                 "DelaySeconds" => 30,
                 "MessageAttribute.1.Name" => "TestStringAttribute",
                 "MessageAttribute.1.Value.StringValue" => "testing!",
                 "MessageAttribute.1.Value.DataType" => "String",
                 "MessageAttribute.2.Name" => "TestBinaryAttribute",
                 "MessageAttribute.2.Value.BinaryValue" => <<31, 139, 8, 0, 0, 0, 0, 0, 0, 3, 43, 73, 45, 46, 201, 204, 75, 87, 4, 0, 188, 169, 224, 119, 8, 0, 0, 0>>,
                 "MessageAttribute.2.Value.DataType" => "Binary",
                 "MessageAttribute.3.Name" => "TestNumberAttribute",
                 "MessageAttribute.3.Value.StringValue" => 42,
                 "MessageAttribute.3.Value.DataType" => "Number",
                 "MessageAttribute.4.Name" => "TestCustomNumberAttribute",
                 "MessageAttribute.4.Value.StringValue" => 7,
                 "MessageAttribute.4.Value.DataType" => "Number.Prime"
                 }

    assert expected == SQS.send_message(
                         "982071696186/test_queue",
                         "This is the message body.",
                         [
                           delay_seconds: 30,
                           message_attributes: [
                             %{
                               name: "TestStringAttribute",
                               data_type: :string,
                               value: "testing!"
                             },
                             %{
                                name: "TestBinaryAttribute",
                                data_type: :binary,
                                value: :zlib.gzip("testing!")
                              },
                              %{
                                name: "TestNumberAttribute",
                                data_type: :number,
                                value: 42
                              },
                              %{
                                name: "TestCustomNumberAttribute",
                                data_type: :number,
                                custom_type: "Prime",
                                value: 7
                              }
                           ]
                         ])
  end

  test "#send_message_batch" do
    expected = %{"Action" => "SendMessageBatch",
                 "QueueName" => "982071696186/test_queue",
                 "SendMessageBatchRequestEntry.1.Id" => "test_message_1",
                 "SendMessageBatchRequestEntry.1.MessageBody" => "This is the message body.",
                 "SendMessageBatchRequestEntry.1.DelaySeconds" => 30,
                 "SendMessageBatchRequestEntry.1.MessageAttribute.1.Name" => "TestStringAttribute",
                 "SendMessageBatchRequestEntry.1.MessageAttribute.1.Value.StringValue" => "testing!",
                 "SendMessageBatchRequestEntry.1.MessageAttribute.1.Value.DataType" => "String",
                 "SendMessageBatchRequestEntry.1.MessageAttribute.2.Name" => "TestBinaryAttribute",
                 "SendMessageBatchRequestEntry.1.MessageAttribute.2.Value.BinaryValue" => <<31, 139, 8, 0, 0, 0, 0, 0, 0, 3, 43, 73, 45, 46, 201, 204, 75, 87, 4, 0, 188, 169, 224, 119, 8, 0, 0, 0>>,
                 "SendMessageBatchRequestEntry.1.MessageAttribute.2.Value.DataType" => "Binary",
                 "SendMessageBatchRequestEntry.1.MessageAttribute.3.Name" => "TestNumberAttribute",
                 "SendMessageBatchRequestEntry.1.MessageAttribute.3.Value.StringValue" => 42,
                 "SendMessageBatchRequestEntry.1.MessageAttribute.3.Value.DataType" => "Number",
                 "SendMessageBatchRequestEntry.1.MessageAttribute.4.Name" => "TestCustomNumberAttribute",
                 "SendMessageBatchRequestEntry.1.MessageAttribute.4.Value.StringValue" => 7,
                 "SendMessageBatchRequestEntry.1.MessageAttribute.4.Value.DataType" => "Number.Prime",
                 "SendMessageBatchRequestEntry.2.Id" => "test_message_2",
                 "SendMessageBatchRequestEntry.2.MessageBody" => "This is the second message body.",
                 "SendMessageBatchRequestEntry.2.MessageAttribute.1.Name" => "TestAnotherStringAttribute",
                 "SendMessageBatchRequestEntry.2.MessageAttribute.1.Value.StringValue" => "still testing!",
                 "SendMessageBatchRequestEntry.2.MessageAttribute.1.Value.DataType" => "String",
                 }

    assert expected == SQS.send_message_batch(
                         "982071696186/test_queue",
                         [
                           [ id: "test_message_1",
                             message_body: "This is the message body.",
                             delay_seconds: 30,
                             message_attributes: [
                               %{
                                 name: "TestStringAttribute",
                                 data_type: :string,
                                 value: "testing!"
                               },
                               %{
                                  name: "TestBinaryAttribute",
                                  data_type: :binary,
                                  value: :zlib.gzip("testing!")
                                },
                                %{
                                  name: "TestNumberAttribute",
                                  data_type: :number,
                                  value: 42
                                },
                                %{
                                  name: "TestCustomNumberAttribute",
                                  data_type: :number,
                                  custom_type: "Prime",
                                  value: 7
                                }
                             ]
                           ],
                           [
                             id: "test_message_2",
                             message_body: "This is the second message body.",
                             message_attributes: [
                               %{
                                 name: "TestAnotherStringAttribute",
                                 data_type: :string,
                                 value: "still testing!"
                               }
                             ]
                           ]
                         ]
                       )
  end

  test "#receive_message" do
    expected = %{"Action" => "ReceiveMessage", "QueueName" => "982071696186/test_queue"}
    assert expected == SQS.receive_message("982071696186/test_queue")

    expected = %{"Action" => "ReceiveMessage", "AttributeName.1" => "All", "MaxNumberOfMessages" => 5, "QueueName" => "982071696186/test_queue"}
    assert expected == SQS.receive_message("982071696186/test_queue", attribute_names: :all,
                                                                      max_number_of_messages: 5)

    expected = %{"Action" => "ReceiveMessage", "AttributeName.1" => "SenderId", "AttributeName.2" => "ApproximateReceiveCount", "QueueName" => "982071696186/test_queue", "VisibilityTimeout" => 1000, "WaitTimeout" => 20}
    assert expected == SQS.receive_message("982071696186/test_queue", attribute_names: [:sender_id, :approximate_receive_count],
                                                                      visibility_timeout: 1000,
                                                                      wait_timeout: 20)
  end

  test "#delete_message" do

  end

  test "#delete_message_batch" do

  end

  test "#change_message_visibility" do

  end

  test "#change_message_visibility_batch" do

  end
end
