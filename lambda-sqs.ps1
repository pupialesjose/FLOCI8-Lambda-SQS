$ep = "http://localhost:4566"
$region = "us-east-1"
$funcion = "procesar-poliza-sqs"

# 1. Cola
aws sqs create-queue --queue-name cola-polizas-lambda --endpoint-url $ep --region $region
$queueUrl = aws sqs get-queue-url --queue-name cola-polizas-lambda --query QueueUrl --output text --endpoint-url $ep --region $region
$queueArn = aws sqs get-queue-attributes --queue-url $queueUrl --attribute-names QueueArn --query Attributes.QueueArn --output text --endpoint-url $ep --region $region

# 2. Empaquetar y crear la función
Compress-Archive -Path handler.py -DestinationPath function.zip -Force
aws lambda create-function --function-name $funcion --runtime python3.12 --handler handler.lambda_handler --zip-file fileb://function.zip --role arn:aws:iam::000000000000:role/lambda-role --endpoint-url $ep --region $region

# 3. Conectar la cola con la función
aws lambda create-event-source-mapping --function-name $funcion --event-source-arn $queueArn --batch-size 5 --endpoint-url $ep --region $region

# 4. Enviar un mensaje
Set-Content -Path mensaje.json -Value '{"numeroPoliza":"POL-001","ramo":"Vida"}'
aws sqs send-message --queue-url $queueUrl --message-body file://mensaje.json --endpoint-url $ep --region $region