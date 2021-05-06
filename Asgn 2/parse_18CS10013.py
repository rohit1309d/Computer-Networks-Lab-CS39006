# Name - Rohit Dhaipule
# Roll no. - 18CS10013

import sys
import xml.etree.ElementTree as ET
import csv
from geolite2 import geolite2


# Xml parser
tree = ET.parse(sys.argv[1])
root = tree.getroot()   # returns a pointer to the first element of the tree

# a set to store all the unique ip addresses
ip_add = set()

# all the field tags are inside proto tags which are in packet tags. Hence we need to parse inside
for child in root:
    if child.tag == "packet":
        for gchild in child:
            if gchild.tag == "proto":
                f = [str(i.get('showname'))[:-4] for i in gchild.findall('field')]  # To check whether any proto tags without a field tag of attribute showname = "Via: Internet.org"
                if "Via: Internet.org" in f:
                    for ggchild in gchild:
                        name = ggchild.get('name')
                        if name == "http.x_forwarded_for":
                            ip_add.add(ggchild.get('show'))

# Dict to count the number of ips from each country
country = {}

# a geolite reader which gives information about an ip
geo = geolite2.reader()


for ip in ip_add:
    cntry = geo.get(ip)['country']['names']['en']

    if cntry in country.keys():
        country[cntry] = country[cntry] + 1     # increase the count
    else :
        country[cntry] = 1  # if country is not included in dictionary then add it and initiate with 1


# writing the country dictionary in a csv file
file = open("data.csv", "w", newline='')
writer = csv.writer(file)
for key, value in country.items():
    writer.writerow([key, value])

print("data.csv exported")