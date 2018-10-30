import getopt, sys, os.path
import json


def main(argv):
    try:
        opts, args = getopt.getopt(argv, "i:",
                                   ["in="])

    except getopt.GetoptError as err:
        usage()
        exit(2)

    in_path = None

    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("-i", "--in"):
            in_path = a

    if in_path is None or in_path == "":
        print("You must select input JSON file")
        sys.exit(1)

    if not os.path.isfile(in_path):
        print("Input file not found: " + in_path)
        sys.exit(1)


    try:

        wrap = []
        for line in open(in_path, 'r'):
            wrap.append(json.loads(line))

        print(json.dumps(wrap,
                   sort_keys=True,
                   indent=4,
                   separators=(',', ': ')))



    except Exception as e:
        print("Error: " + str(e))


def usage():
    print('Usage:')
    print('  python fix-extra-data.py -i raw.json')
    print('  python fix-extra-data.py -i raw.json > out.json')


if __name__ == '__main__':
    main(sys.argv[1:])
