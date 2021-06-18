import sys


## first argument is the .coe file
## second argument is the output file
def main(args):
    with open(args[0], "r") as coe:
        with open(args[1],"w+") as output:
            output.write(".global _start\n")
            output.write("_start:\n")
            output.write("li x10, 0x30000000\n")
            counter = 0x3fff0000
            i = 0
            for line in coe:
                if i < 2:
                    i += 1
                    continue
                if ";" in line:
                    continue
                line.replace("\n","").replace("\r","")
                output.write("li x1, 0x" + line)
                output.write("li x10," + str("0x%x" % (counter) + "\n"))
                output.write("sw x1, 0(x10)\n")
                counter += 4
            output.write("li x10, 0x1fff0000\n")
            output.write("jr x10")

if __name__ == "__main__":
    main(sys.argv[1:])

