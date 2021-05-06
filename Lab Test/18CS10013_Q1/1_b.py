import sys
import xml.etree.ElementTree as ET
import csv
import re

# Xml parser
tree = ET.parse(sys.argv[1])
root = tree.getroot()   # returns a pointer to the first element of the tree

n = 0
sender = []
receiver = []
subject = []
message = []

# all the field tags are inside proto tags which are in packet tags. Hence we need to parse inside
for child in root:
    for gchild in child:
        # Number of emails = (Number of message packets with proto.showname = "Internet Message Format")
        if gchild.get('showname') == "Internet Message Format":
            for ggchild in gchild:
                if ggchild.get('name') == "imf.subject":    # subject is contained in field tag with name = "imf.subject"
                    subject.append(ggchild.get('showname')[9:]) # getting 

                elif ggchild.get('name') == "imf.message_text":    # body message is contained in a field tag which has a field tag as child with name = "imf.message_text"
                    for field in ggchild:
                        message.append(field.get('show'))

            n += 1

        if gchild.get('showname') == "Simple Mail Transfer Protocol": # search only those proto with showname = "Simple Mail Transfer Protocol"
            for ggchild in gchild:
                if ggchild.get('name') == "smtp.command_line":
                    showname = ggchild.get('show')
                    if "FROM" in showname:  # sender email id contains "from" in showname
                        sender.append(showname[11:-15])
                    elif "TO" in showname:   # receiver email id contains "to"" in showname
                        receiver.append(showname[9:-7])
                


print("Number of Emails transfered = " + str(n))

for i in range(n):
    print()
    print("Email - " + str(i+1))
    print("Sender email id - " + str(sender[i]))
    print("Receiver email id - " + str(receiver[i]))
    print("Subject - " + subject[i])
    print("Message Body - " + message[i])
    