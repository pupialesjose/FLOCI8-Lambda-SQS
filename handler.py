import json

def lambda_handler(event, context):
    for record in event["Records"]:
        poliza = json.loads(record["body"])
        print(f"Procesando póliza {poliza['numeroPoliza']} del ramo {poliza['ramo']}")
    return {"procesados": len(event["Records"])}