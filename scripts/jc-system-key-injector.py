import json

def main():
    with open('/opt/jc/jcagent.conf', encoding='utf-8') as data_file:
        data = json.loads(data_file.read())
    key_file = open("/root/jc-system-key", "w")
    key_file.write(data['systemKey'])
    key_file.close()

if __name__ == '__main__':
    main()
