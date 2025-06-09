file = open("./suzanne.obj")
newFile = open("./suzTest.obj", "w")

for line in file:
    line = line.rstrip()
    if not line:
        newFile.write("\n")
        continue
    parts = line.split(" ")
    if parts[0] == "f" and len(parts) == 5:
        newFile.write("f " + parts[1] + " " + parts[2] + " " + parts[3] + "\n")
        newFile.write("f " + parts[3] + " " + parts[4] + " " + parts[1] + "\n")
    else:
        newFile.write(line + "\n")
