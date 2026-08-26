## Rule Lifecycle

The original Key Vault failure rule was disabled after telemetry analysis
showed that ResultType was not reliable for detecting failed SecretGet
operations.

The production lab rule now detects:

OperationName == "SecretGet"
and
httpStatusCode_d >= 400