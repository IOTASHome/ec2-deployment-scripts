import boto3
import base64
from botocore.exceptions import ClientError


def get_secret():

    secret_name = "your-secrets-name"
    region_name = "your-regions-name"

    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            raise e
    else:
        if 'SecretString' in get_secret_value_response:
            secret = get_secret_value_response['SecretString']
        else:
            decoded_binary_secret = base64.b64decode(get_secret_value_response['SecretBinary'])
    
    secret_file = open('/root/jc-api-key', 'x')
    secret = secret.replace('{"your-secrets-name":"', '')
    secret = secret[:-2]
    secret_file.write(secret)
    secret_file.close()

if __name__ == '__main__':
    get_secret()
